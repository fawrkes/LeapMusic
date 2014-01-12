//
//  musicLeapView.h
//  LeapMusic
//
//  Created by Garrett Parrish on 11/23/13.
//  Copyright (c) 2013 Garrett Parrish. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface musicLeapView : NSImageView
{
    // Leap Motion Information
    LeapVector  *avgFingerPosition;
    LeapVector  *avgFingerVelocity;
    LeapHand    *mainHand;
    float frameUpdateDelay;
    float handRollDegree;
    NSColor *volumeGauge;
    
    // Fram Update
    NSTimer *frameUpdate;
    NSTimer *viewUpdate;
    
    // Whether or not to NSLog certain information
    bool printData;
    
    // Song Information
    float tempo;
    
    ///////////////////////////////////////////////
    /////////// Beat-To-Beat Conducting ///////////
    ///////////////////////////////////////////////
    
    // Beat Information
    NSMutableArray  *currentBeatTimes;

    int             beat1, beat2, beat3, beat4;
    float           last1Time, last2Time, last3Time, last4Time;
    
    // Beat-impact Variables
    NSArray         *hits;
    NSMutableArray  *hit1, *hit2, *hit3, *hit4;
    NSNumber        *hit1Time, *hit2Time, *hit3Time, *hit4Time;
    
    // Timer to set playback to 1.0 if user stopped conducting
    NSTimer *resetForLatency;
    float latencyDelay;

    ///////////////////////////////////////////////
    //////////// Continuous Conducting ////////////
    ///////////////////////////////////////////////
    
    // Hand Velocity Information
    NSMutableArray  *velocityBuffer;
    float           currentVelocity;
    float distanceOfBeat;

    // Time-related Information
    NSDate *start;
    float secPerBeat;
    NSTimeInterval time;
}

// Frame/View Updates
- (void) updateFrame;
- (void) updateView;

// Playback setter
- (void) applyPlaybackRate: (float) playback;

///////////////////////////////////////////////
/////////// Beat-To-Beat Conducting ///////////
///////////////////////////////////////////////

- (void) beat: (int) num;
- (void) updateRate: (int) a and: (int) b;
- (void) resetBeats: (int) a and: (int) b;
- (void) resetAllHits;
- (void) resetForLatency;

@end
