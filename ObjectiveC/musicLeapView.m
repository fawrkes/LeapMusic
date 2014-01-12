//
//  musicLeapView.m
//  LeapMusic
//
//  Created by Garrett Parrish on 11/23/13.
//  Copyright (c) 2013 Garrett Parrish. All rights reserved.
//

#import "musicLeapView.h"
#import "LeapObjectiveC.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

// Necessary Leap constant (lifted from LeapMotion SDK)
#define   DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)

@implementation musicLeapView
{
    // Conducting Style
    bool continuousConducting;
    bool beatToBeatConducting;

    // Playback rates for each conducting style
    float continuousPlayback;
    float beatBasedPlayback;
    
    // Constants for getting conducting style choice from conducting style button
    int beatToBeatConductingIndex;
    int continuousConductingIndex;

    // Whether or not to use effects
    bool cutConductFollowEffects;
    
}

- (id)initWithFrame:(NSRect)frame
{
    
    // Create View
    self = [super initWithFrame:frame];
        
    // Print out certain data or not
    printData = NO;

    // Instantiate indexes of for different conducting styles
    continuousConductingIndex = 0;
    beatToBeatConductingIndex = 1;
    
    // Manually entered song information
    tempo = 132.0;
    secPerBeat = 60.0/tempo;

    // Global time information
    start = [NSDate date];
    
    ///////////////////////////////////////////////
    /////////// Beat-To-Beat Conducting ///////////
    ///////////////////////////////////////////////
    
    // Beats (array indexes)
    beat1 = 0;
    beat2 = 1;
    beat3 = 2;
    beat4 = 3;
    
    // Hit buffers (once the hand passes a certain point - starts filling
    // To get impact, simply take the first object
    hit1 = [[NSMutableArray alloc] init];
    hit2 = [[NSMutableArray alloc] init];
    hit3 = [[NSMutableArray alloc] init];
    hit4 = [[NSMutableArray alloc] init];
    
    // Array holding hit buffers (to iterate through)
    hits = [[NSArray alloc] initWithObjects:hit1, hit2, hit3, hit4, nil];

    // Beat impact time variables
    hit1Time = [[NSNumber alloc] initWithFloat:0.0];
    hit2Time = [[NSNumber alloc] initWithFloat:0.0];
    hit3Time = [[NSNumber alloc] initWithFloat:0.0];
    hit4Time = [[NSNumber alloc] initWithFloat:0.0];
    
    // Array to hold current beat impacts (for use in calculating playback)
    currentBeatTimes = [[NSMutableArray alloc] initWithObjects: hit1Time, hit2Time, hit3Time, hit4Time, nil];
    
    // Reset playback if stopped conducting for certain time
    latencyDelay = 2.0;
    resetForLatency = [NSTimer scheduledTimerWithTimeInterval:latencyDelay
                                                       target:self
                                                     selector:@selector(resetForLatency)
                                                     userInfo:nil
                                                      repeats:YES];

    ///////////////////////////////////////////////
    //////////// Continuous Conducting ////////////
    ///////////////////////////////////////////////
    
    // Continuous velocity buffer
    velocityBuffer = [[NSMutableArray alloc] init];
    
    ///////////////////////////////////////////////
    ///////////// Frame/View Updates //////////////
    ///////////////////////////////////////////////

    frameUpdateDelay = 0.01;
    
    // Get the latest frame (from AppDelegate)
    frameUpdate = [NSTimer scheduledTimerWithTimeInterval:frameUpdateDelay
                                                   target:self
                                                 selector:@selector(updateFrame)
                                                 userInfo:nil
                                             repeats:YES];

    // Update the view (with the latest frame)
    viewUpdate = [NSTimer scheduledTimerWithTimeInterval:frameUpdateDelay
                                                   target:self
                                                 selector:@selector(updateView)
                                                 userInfo:nil
                                                  repeats:YES];

    return self;
}


- (void) updateFrame
{
    // Instantiate appdelegate to access its information
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];

    // Get the latest frame (from LeapListener)
    LeapFrame *frame = appDelegate.currentFrame;

    if (printData)
    {
        NSLog(@"Frame id: %lld, timestamp: %lld, hands: %ld, fingers: %ld, tools: %ld, gestures: %ld",
              [frame id], [frame timestamp], [[frame hands] count],
              [[frame fingers] count], [[frame tools] count], [[frame gestures:nil] count]);
    }
    
    // If there are hands
    if ([[frame hands] count] != 0)
    {
        // Get the first hand
        LeapHand *hand = [[frame hands] objectAtIndex:0];

        // Check if the hand has any fingers
        NSArray *fingers = [hand fingers];

        if ([fingers count] != 0)
        {
        
            // Calculate the hand's average finger tip position and velocity
            LeapVector *avgPos = [[LeapVector alloc] init];
            LeapVector *avgVelocity =[[LeapVector alloc] init];

            // Multi-finger support for beat-to-beat conducting
            
            // Iterate through fingers
            for (int i = 0; i < [fingers count]; i++)
            {
                LeapFinger *finger = [fingers objectAtIndex:i];

                // If using beat-to-beat conducting
                if (beatToBeatConducting)
                {
                    // Collect finger positions to average
                    avgPos = [avgPos plus:[finger tipPosition]];
                }
                
                // If using continuous conducting
                if (continuousConducting)
                {
                    // Collect finger velocities to average
                    avgVelocity = [avgVelocity plus:[finger tipVelocity]];
                }
            }
         
            // Note: Avg velocity is interpreted differently for continuous vs. beat-to-beat
            
            if (beatToBeatConducting)
            {
                avgPos = [avgPos divide:[fingers count]];
            }

            // Currently, continuous conducting only works well with 1 finger - so, choose first finger
            if (continuousConducting)
            {
                avgPos = [[fingers objectAtIndex:0] tipPosition];
                avgFingerVelocity = avgVelocity;
            }

            // Set global position
            avgFingerPosition = avgPos;
            
            
            if (printData)
            {
                NSLog(@"Hand has %ld fingers, average finger tip position %@", [fingers count], avgPos);
            }
        }
 
        if (printData)
        {
            // Get the hand's sphere radius and palm position
            NSLog(@"Hand sphere radius: %f mm, palm position: %@",
                  [hand sphereRadius], [hand palmPosition]);

        }

        // Set global main hand
        mainHand = hand;
        
        // Get the hand's normal vector and direction
        const LeapVector *normal = [hand palmNormal];
        const LeapVector *direction = [hand direction];

        if (printData)
        {
            // Calculate the hand's pitch, roll, and yaw angles
                NSLog(@"Hand pitch: %f degrees, roll: %f degrees, yaw: %f degrees\n",
                       [direction pitch] * LEAP_RAD_TO_DEG,
                       [normal roll] * LEAP_RAD_TO_DEG,
                       [direction yaw] * LEAP_RAD_TO_DEG);
        }
        handRollDegree = [normal roll] * LEAP_RAD_TO_DEG;
    }
}

- (void) updateView
{
    // Instantiate appdelegate to access its information
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];

    // Update the current view
    [appDelegate.mainView setNeedsDisplay];

    // Get inputs from user buttons

    // If selected Continuous Conducting
    if ([appDelegate.conductingStylePicker isSelectedForSegment:continuousConductingIndex])
    {
        beatToBeatConducting = NO;
        continuousConducting = YES;
    }
    // If selected Beat-To-Beat Conducting
    else if ([appDelegate.conductingStylePicker isSelectedForSegment:beatToBeatConductingIndex])
    {
        beatToBeatConducting = YES;
        continuousConducting = NO;
    }
}

// Draw screen
- (void)drawRect:(NSRect)dirtyRect
{
    // Instantiate appdelegate to access its information
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    
    // Get main view
    NSImageView *mainView = appDelegate.mainView;

    //////////////////////////////////////////////
    ///////////// Conducting Box /////////////////
    //////////////////////////////////////////////
    
    // Get conducting view dimensions
    CGFloat winWidth = mainView.frame.size.width;
    CGFloat winHeight = mainView.frame.size.height;
    
    // Draw outer frame
    NSRect borderRect = NSMakeRect(0, 0, winWidth, winHeight);
    [[NSColor whiteColor] set];
    NSBezierPath *border = [NSBezierPath bezierPathWithRect:borderRect];
    [border setLineWidth:10.0];
    [border stroke];
    
    // Get coordinates of inner frame
    int frameDiv = 15;
    CGFloat conX1 = winWidth/frameDiv;
    CGFloat conY1 = conX1;
    CGFloat conX2 = winWidth - (2 * conX1);
    CGFloat conY2 = winHeight - (2 * conX1);
    
    // Draw conducting frame
    NSRect conductPath = NSMakeRect(conX1, conY1, conX2, conY2);
    [[NSColor whiteColor] set];
    NSBezierPath *conductingPath = [NSBezierPath bezierPathWithRect:conductPath];
    [conductingPath setLineWidth:4.0];
    [conductingPath stroke];

    //////////////////////////////////////////////
    /////// Adjust Volume Based on Z-Index ///////
    //////////////////////////////////////////////

    // z: min = -200 | max = 200
    // vol: min = 0 | mid = 0.5 | max 1.0

    // Empirically determined scale
    float volumeScale = 300.0;
    
    // Initial volume
    float initialVolume = 0.5;
    
    // Works for both positive and negative z values
    appDelegate.audioPlayer.volume = initialVolume + avgFingerPosition.z/volumeScale;
    appDelegate.audioPlayerMega.volume = initialVolume + avgFingerPosition.z/volumeScale;
    appDelegate.audioPlayerBass.volume = initialVolume + avgFingerPosition.z/volumeScale;
    

    //////////////////////////////////////////////
    ////////////// Finger Position ///////////////
    //////////////////////////////////////////////
    
    // Get average finger position from Leap-generated info
    NSPoint leapPoint = NSMakePoint(avgFingerPosition.x, avgFingerPosition.y);
    
    // Scale to correspond to this specific view
    CGPoint fingerCenter = [mainView convertPoint:leapPoint fromView:mainView];

    // Magic numbers for screen (empirically gathered)
    int xCenter = 400;
    int yCenter = 200;
    int yScale = 20;
    
    // Scaling for converting from hands to screen coordinates
    // Corresponds to sensativity of x and y coordinates
    int horizontalScale = 2.5;
    int verticalScale = 1.5;
    
    // Finger location circle
    int circleScale = 3;
    int radius = avgFingerPosition.z/circleScale;

    // Draw circle
    float xCoordinate = ((fingerCenter.x + xCenter) - radius);
    float yCoordinate = ((fingerCenter.y + yScale) - radius);

    // On left side of screen
    if (xCoordinate < xCenter)
    {
        xCoordinate -= abs(xCenter - xCoordinate) * horizontalScale;
    }
    
    // On Right side of screen
    else if (xCoordinate > xCenter)
    {
        xCoordinate += abs(xCenter - xCoordinate) * horizontalScale;
    }
    
    // Bottom half of screen
    if (yCoordinate < yCenter)
    {
        yCoordinate -= abs(yCenter - yCoordinate) * verticalScale;
    }
    
    // Top half of screen
    else if (xCoordinate > yCenter)
    {
        yCoordinate += abs(yCenter - yCoordinate) * verticalScale;
    }

    // Create color for finger tracker (hot -- cold)
    CGFloat green = 1.0 - appDelegate.audioPlayer.volume;
    CGFloat blue = 1.0 - appDelegate.audioPlayer.volume;
    CGFloat red = appDelegate.audioPlayer.volume;

    // Loud = Red | Quiet = white/blue
    volumeGauge = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];

    // Outer finger circle
    NSRect outerFingerAv = NSMakeRect(xCoordinate, yCoordinate, radius*2, radius*2);
    NSBezierPath *outerFingerAvPath = [NSBezierPath bezierPathWithOvalInRect:outerFingerAv];

    [outerFingerAvPath setLineWidth:5.0];
    [volumeGauge set];
    [outerFingerAvPath stroke];
    
    // Inner finger circle
    NSRect innerFingerAv = NSMakeRect(xCoordinate+(radius/2), yCoordinate+(radius/2), radius, radius);
    NSBezierPath *innerFingerAvPath = [NSBezierPath bezierPathWithOvalInRect:innerFingerAv];
    
    [innerFingerAvPath setLineWidth:5.0];
    [volumeGauge set];
    [innerFingerAvPath stroke];

    //////////////////////////////////////////////
    /////////// Beat to beat conducting //////////
    //////////////////////////////////////////////

    if (beatToBeatConducting)
    {
        // Past bottom barrier
        if (yCoordinate < conY1)
        {
            [self beat: 1];
        }
        
        // Past left barrier
        else if (xCoordinate < conX1)
        {
            [self beat: 2];
        }
        
        // Past right barrier
        else if (xCoordinate > conX2)
        {
            [self beat: 3];
        }
        
        // Past top barrier
        else if (yCoordinate > conY2)
        {
            [self beat: 4];
        }

        // In middle
        else
        {
            // Rest all beat buffers
            [self resetAllHits];
        }
    }
    
    //////////////////////////////////////////////
    /////////// Continuous Conducting ////////////
    //////////////////////////////////////////////
    
    if (continuousConducting)
    {
        // Set screen to clear
        [appDelegate.beat setStringValue:@""];

        // Silence other audioplayers
        [appDelegate.audioPlayerBass setVolume:0.0];
        [appDelegate.audioPlayerMega setVolume:0.0];
        
        // Information sampled every 0.01 seconds
        // Playback rate supported for down to 0.5 and up to 2.0

        // Calculate the magnitude of the average finger velocity in the x-y plane (pythagorean theorem)
        float averageTipVelocity = sqrtf(powf(avgFingerVelocity.x, 2.0) + powf(avgFingerVelocity.y, 2.0));
        
        // Size of velocity buffer (number of velocities to keep)
        // Corresponds to resolution of conducting vs. smoothness
        
        int velocityBufferSize = 10;
        
        // If buffer filled already
        if ([velocityBuffer count] > velocityBufferSize)
        {
            // Remove last object
            [velocityBuffer removeObject:[velocityBuffer lastObject]];
        }
        
        // Insert new velocity at beginning -> shift everything else down
        [velocityBuffer insertObject:[NSNumber numberWithFloat:averageTipVelocity] atIndex:0];

        // Calculate average velocity (basically integrate)
        float sum = 0;
        for (id vel in velocityBuffer)
        {
            sum = sum + [vel floatValue];
        }
        currentVelocity = sum/velocityBufferSize;
        
        // Calculate playback
        
        // NOTE: Screen units are in pixels - leap units are in mm
        
        // Empirically determined constants for leap
        float leapLeftBound = -112.0;
        float leapRightBound = 21.0;
        
        // Ratio to convert leap coordinates to screen coordinates
        float leapToScreenMappingRatio = (fabsf(leapLeftBound) + fabsf(leapRightBound))/(conX1 - conX2);
        
        // Expected screen displacement based on current velocity
        float expectedScreenDisplacement = currentVelocity * frameUpdateDelay * (1.0/leapToScreenMappingRatio);
        
        // Average beat distance (2.5 times half the width of the square
        // Approximately the distance hand would travel during beat to beat conducting
        float averageBeatDistance = (conX2 - conX1) / 2 * 2.5;
        
        // Calculate expected time differnce
        float deltaT = (expectedScreenDisplacement / averageBeatDistance) * secPerBeat ;
        
        // Set playback rate to account fot time difference
        float updatedPlaybackRate = fabs(deltaT / frameUpdateDelay);
        
        // Set playback rate
        continuousPlayback = updatedPlaybackRate;
        
        // Apply playback rate
        [self applyPlaybackRate:continuousPlayback];
    }
    
    //////////////////////////////////////////////
    ////////////////// Effects ///////////////////
    //////////////////////////////////////////////
    
    // Only support effects for beat to beat conducting
    if (beatToBeatConducting)
    {
        // Empirically determined constants for roll degree
        // Dead zone in middle (of 30 degrees)
        float effectMin = -75.0;
        float effectMidBottom = -15.0;
        float effectMidTop = 15.0;
        float effectMax = 75.0;
        
        // Bring volume of megaphone track up/down
        if (handRollDegree > effectMidTop && handRollDegree < effectMax)
        {
            // Linear mapping of volume to effect range
            appDelegate.audioPlayerMega.volume = fabs(handRollDegree / effectMin);
            
            // Decrease the volume of the actual audio player to account for increase/decrease in effects
            appDelegate.audioPlayer.volume -= appDelegate.audioPlayerMega.volume;
        }
        
        // Bring volume of bass track up/down
        else if (handRollDegree < effectMidBottom && handRollDegree > effectMin)
        {
            // Linear mapping of volume to effect range
            appDelegate.audioPlayerBass.volume =  fabs(handRollDegree / effectMax);
            
            // Decrease the volume of the actual audio player to account for increase/decrease in effects
            appDelegate.audioPlayer.volume -= appDelegate.audioPlayerBass.volume;
        }
        
        // If in dead zone - don't have any effects
        else
        {
            appDelegate.audioPlayerBass.volume = 0.0;
            appDelegate.audioPlayerMega.volume = 0.0;
        }
    }
    
    // Redraw window
    [super drawRect:dirtyRect];
}


// Interpret beat-to-beat conducting
- (void) beat: (int) num
{
    // Instantiate appdelegate to access its information
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];

    // Get current time (since start) - absolute doesn't matter - only relative
    time = fabs([start timeIntervalSinceNow]);

    switch (num)
    {
        // NOTE: all 4 of these cases are identical except for which beat they pertain to
        // Only beat 1 is commented
            
        // Beat 1
        case 1:
            
            // Temp to store current time while in beat zone
            hit1Time = [NSNumber numberWithFloat:time];
            
            // Add that temp to an array of times
            [hit1 addObject:hit1Time];
            
            // Show a '1' on the screen
            [appDelegate.beat setStringValue:@"1"];
            
            // If more than 1 time has been stored in the buffer (hand has been there for a long period of time)
            if ([hit1 count] == 2)
            {
                // Allow one initial value to pass for redundency, null, and error checking
                int one = 1;
                // Set current beat time to the latest impact
                currentBeatTimes[beat1] = [hit1 objectAtIndex:one];

                // Reset beats not needed for calculation of rate
                [self resetBeats:beat2 and:beat3];

                // Update playback rate
                [self updateRate:beat1 and:beat4];
            }

            break;
        
        case 2:

            hit2Time = [NSNumber numberWithFloat:time];
            [hit2 addObject:hit2Time];
            [appDelegate.beat setStringValue:@"2"];
            
            if ([hit2 count] == 2)
            {
                int one = 1;
                currentBeatTimes[beat2] = [hit2 objectAtIndex:one];
                [self resetBeats:beat3 and:beat4];
                [self updateRate:beat2 and:beat1];
            }
            break;
            
        case 3:
            
            hit3Time = [NSNumber numberWithFloat:time];
            [hit3 addObject:hit3Time];
            [appDelegate.beat setStringValue:@"3"];
            
            if ([hit3 count] == 2)
            {
                int one = 1;
                currentBeatTimes[beat3] = [hit3 objectAtIndex:one];
                [self resetBeats:beat4 and:beat1];
                [self updateRate:beat3 and:beat2];
            }
            break;
            
        case 4:
            hit4Time = [NSNumber numberWithFloat:time];
            [hit4 addObject:hit4Time];
            [appDelegate.beat setStringValue:@"4"];
            
            if ([hit4 count] == 2)
            {
                int one = 1;
                currentBeatTimes[beat4] = [hit4 objectAtIndex:one];
                [self resetBeats:beat1 and:beat2];
                [self updateRate:beat4 and:beat3];
            }
            break;
    }
}

// Update the playback rate corresponding to the latest beat times
- (void) updateRate: (int) a and: (int) b
{
    // Get current and past beat
    float currentBeat = [currentBeatTimes[a] floatValue];
    float pastBeat = [currentBeatTimes[b] floatValue];
    float newPlayback;
    
    // Make sure that the values are not 0.0 (reset to null)

    if (currentBeat != 0.0 && pastBeat != 0.0)
    {
        // Calculate the difference between the beats
        float difference = fabs(currentBeat - pastBeat);

        // Calculate the ratio of difference to spb
        newPlayback = secPerBeat/difference;

        // If difference would produce a playback rate that would sound bad, revert to normal
        if (difference > 2 * secPerBeat || difference < 0.5 * secPerBeat)
        {
            newPlayback = 1.0;
        }
    }
    // If conducted out of order -- go back to normal
    else
    {
        newPlayback = 1.0;
    }

    beatBasedPlayback = newPlayback;

    // Apply playback rate
    [self applyPlaybackRate:beatBasedPlayback];
}

- (void) applyPlaybackRate: (float) playback
{
    // Instantiate appdelegate to access its information
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];

    [appDelegate.audioPlayer setRate:playback];
    [appDelegate.audioPlayerMega setRate:playback];
    [appDelegate.audioPlayerBass setRate:playback];
}

// Reset unused beats
- (void) resetBeats: (int) a and: (int) b
{
    // Nullify them
    currentBeatTimes[a] = [NSNumber numberWithFloat:0.0];
    currentBeatTimes[b] = [NSNumber numberWithFloat:0.0];
}

// Reset all hit buffers
- (void) resetAllHits
{
    // Go through beat impact buffers
    for (id hit in hits)
    {
        // If not null
        if ([hit count] > 0)
        {
            // Remove objects from the top down
            for (unsigned long i = ([hit count] - 1); i > 0; i--)
            {
                id currentObject = [hit objectAtIndex:i];
                [hit removeObject:currentObject];
            }
        }
    }
}

// If, during beat-to-beat conducting, user has stopped conducting, reset to normal playback rate
- (void) resetForLatency
{
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];

    // Go through current beat times and get the last the two beat that haven't
    // been nullified (those which the hand is between), calculate the difference
    // between the times, and if it's going to throw playback off significantly
    // set playback to normal and nullify those beats
    
    float a = 0.0;
    float b = 0.0;
    int numBeatZero = 0;
    
    for (id beat in currentBeatTimes)
    {
        if ([beat floatValue] != 0.0)
        {
            if (a != 0.0)
            {
                a = [beat floatValue];
            }
            else
            {
                b = [beat floatValue];
            }
        }
        else
        {
            numBeatZero++;
        }
    }
    
    float difference = fabs(a - b);

    if ( difference > 2 * secPerBeat || difference < 0.5 * secPerBeat || numBeatZero > 3)
    {
        appDelegate.audioPlayer.rate = 1.0;
    }
}

@end