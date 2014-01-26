LeapMusic
=========

An Interactive Conducting and Music-Manipulation OSX Application Using the LeapMotion Controller

=========

￼LeapMusic Documentation


Setting up the Leap

￼The first step required to run LeapMusic is to configure the LeapMotion controller on a Mac machine. LeapMusic was written in Xcode using Objective-C and is compiled as an OSX Cocoa Application. Apple doesn’t allow machines that don’t use the Mac OSX operating system to open and run Cocoa applications, so, for LeapMotion to be run, it must be on a mac machine.  
 
To setup the LeapMotion controller on a Mac, navigate to this website to download the LeapMotion installer and control panel: https://www.leapmotion.com/setup. Once that has downloaded, open the “Leap Motion.pkg” file and progress through the installation screens. Once installed, an icon should appear in the menu bar (next to the wifi symbol, for example) that looks like a little rectangle (or LeapMotion Controller). Click on that icon and the control panel will open. Here, you can test out visualizations, check for updates, and, otherwise configure your LeapMotion Controller. For LeapMotion to work best, make sure that the “Interaction Heigh” is set to 20.0 cm, which it is by default. If it is anything else, switch it to 20.0 cm. If you experience any issues setting up the controller, refer to LeapMotion’s website for tooltips and walkthroughs regarding how to set up the controller.

Opening leap music

Now that the controller is setup, you are ready to try LeapMusic. To run LeapMusic, you have two options: run the compile and executable application (as you would iTunes or any other Mac OSX application) or compile and run the program through Xcode. The app will function identically in both cases, except that, if you run the application in Xcode, you will be able to see how the LeapMotion Controller is process your hand data and how that influences the music’s play back and effects.

Using Xcode

If you don’t already have Xcode, you can download it here: https://itunes.apple.com/us/ app/xcode/id497799835?ls=1&mt=12. Once you have downloaded Xcode (or it already has been downloaded), decompress the folder “Garrett Parrish CS50 Final” and then the file “LeapMusic.zip” by either double clicking it or using Archive Utility. Then, open the folder, and double click on the file “LeapMusic.xcodeproj” which will open in Xcode. On the navigation tap to your left, you will see three folders: “LeapMusic”, “Frameworks”, and “Products”. Open the “LeapMusic” folder. Within that folder will be 7 files (1 xib, 3 .h files, and 3.m files) and then folders containing LeapSDK files (“Leap Files”), audio files (“Audio Files”), and Image Files (“Image Files”), all of which are used in the application. Feel free to browse through the code and/or the assets by clicking on the different files. Now, to run LeapMusic, click the ‘Play’ button on the top left of the window. Once that button has been clicked, LeapMotion’s main menu should pop up. If you would like to the see output to the log, make sure that you can see Xcode’s terminal window (on the bottom) while LeapMusic is running.

Using the Compiled Application

First, decompress the folder “Garrett Parrish CS50 Final” and then double click on the “LeapMusic” icon. You don’t need to go into the “LeapMusic” folder if you are testing the application this way. Once you’ve done that, LeapMusic should open up it’s main window.

Using LeapMusic

Once LeapMusic opens, take a second to check out the interface. On the top of the application you have two buttons: play (left) and pause (right), which play the chosen song or pause the chosen song. At it’s current stage, LeapMusic only plays one song: “Can’t Take My Eyes Off Of You” by the Four Seasons. Also on the top you can see three boxes: two corresponding to effect types and one which has a button for you to select a conducting type. In the middle of the screen you can see two white squares which are where you will conduct the music. On the bottom left of the window, you can press the “Restart Song” button to restart the song from the beginning and, on the bottom right of the window, you can press the “Quit” button to quit the application. If the LeapMotion controller is plugged in and is configured correctly, place it flush to the edge of the computer or laptop in front of the keyboard. To start conducting, press the play button.

￼LeapMusic’s functionality is split into two types: Beat-To-Beat Conducting and Continuous Conducting.

Using Beat-To-Beat Conducting

To use beat-to-beat conducting, first hold your index finger above the LeapMotion Controller until you see a circle corresponding to it’s relative location in the main conducting view. LeapMusic will take the average position of your finger tips and draw it on the screen/use it to conduct, so take a second and try holding different number fingers up and seeing how the location of the circle changes. You’ll also notice that, when you change the Z-Location of your hand, the color of the circle changes as well; this corresponds to the relative volume of the song. I you play the song, notice how you can change the volume by moving your hand forwards and backwards.
In this mode, you have access to the effects of volume, megaphone, and bass enhancement. If you roll your hand to the right, notice how the bass-end of the song will increase in volume and intensity and if you roll your hand to the left, the bass-end of the song will begin to disappear and the upper-frequencies of the song will be enhanced so that the song appears as if it’s originating from a megaphone. All of these effects can be used while you are conducting.

If you do not conduct any notes (i.e. touch the edges of the inner square) within the time period of two beats, the song will revert to it’s original playback rate. To conduct, the app will recognize when your hand hits one of the barriers of the inner square as if you were conducting in 4/4. 

￼￼LeapMusic calculates the audio playback rate by calculating the time difference between the times that your finger crosses the edges of the inner square, which correspond to how you should be conducting the song. So, if you take a longer time than the song appears between beats, the music will play more slowly. If you take a shorter time than it would normally, playback will increase and the song will go faster. If, at any point, you would like to stop conducting, simply hold your hand in the middle for more than about 2.0 seconds, and playback will revert to normal. This is often the best way to check out the effects and volume characteristics. At any point, you can press the pause button, restart the song, or switch to continuous feedback.

Using Continuous Conducting

If you click on continuous conducting, LeapMusic will track the velocity of your fingers in real time and adjust the playback rate accordingly. Currently, LeapMusic’s continuous conducting function is only supported for one finger. So, make sure to only use your index finger when using this mode. It may take a few seconds for you to become accustom to how much your finger movements will affect playback. The best way to make smooth playback is to find a simple shape (i.e an infinity sign or an arc) or simply move your finger back and fourth at different speeds. Notice how you can slow down playback quite abruptly or speed it up quickly. Note that only volume is supported on this mode, not the other effects.

Enjoy LeapMusic!



LeapMusic Design 
=========

Leap Listener

￼These files, ‘LeapListener.h’ and ‘LeapListener.m’, are lifted from LeapMotion’s Objective-C SDK. LeapMotion does not fully support Objective-C yet and has not documentation for it, but does have some support files floating around in different places on it’s GitHub, website, and forum, so these files are lifted from that. Basically, this file gets the latest frame from the LeapMotion Controller and stores it in the AppDelegate’s ‘currentFrame’ variable, which makes it accessible to the other views, windows, and view controllers. It does this at a rate of about 100 per second and sometimes fluctuates.

App Delegate

￼‘AppDelegate.h’ stores all of the global variables that need to be accessed and updated by both the LeadListener and by the LeapView. Within this file, all of the properties are separated and labeled by function. ‘AppDelegate.m’ handles all of the playing of audio and links those functions to the interface of ‘MainMenu.xib’, which can also be found in the main bundle. The play, pause, restart, and quit buttons all call methods that are located in ‘AppDelegate.m’, which perform functions corresponding to the function name.

Leap View
 
This view controller handles all the drawing of the hand and handles the processing of playback rates and effect volumes. The best way to explain the control flow of this controller is to break it up into sections.

￼Frame Update

The first section is the update timers which fire every 0.01 second (approximately 100x a second - just like the LeapListener), which update the frame (by getting the current frame from the AppDelegate and calculating the average velocity and average position of the fingers in the current hand inside of the ‘updateFrame’ method. This method gets the current frame, iterates through the ‘fingers’ array of the first ‘hand’ and averages the tip position of them, storing them in ‘avgFingerPosition’. If the user has selected beat-to-beat conducting or continuous conducting mode, denoted by subsequently named booleans (which are set upon each view update) then it will calculate different average position (beat-to-beat: average of all fingers — continuous: first finger). Only if continuous conducting is selected will it bother to calculate the average velocity. The end of this function calculates the roll angle of the first hand, which will then be used for effect volumes.

View Update

This function tells the view it needs to redraw itself by calling the ‘setNeedsDisplay’ method of an NSView. Then, this method gets the input from the conducting style picker and sets the corresponding booleans accordingly

Drawing the screen
 
The ‘drawRect’ method is automatically called whenever an NSView needs to be updated, either by some on-screen action (i.e. a click) or by the ‘setNeedsDisplay’ method. The first third of this method deals with drawing the conducting frame. It gets the view dimensions and then draws a rectangle corresponding to those dimensions. This was designed so that the view could be dynamically sized and this code wouldn’t have to be manually updated. Then, an inner rectangle is drawn based on the ‘frameDiv’ variable which specifies what fraction of the size the inner rectangle will be drawn at.

Adjusting the Volume Based on Z-Index
The ‘drawRect’ method proceeds to adjust the volume of the audio players based on z index. The minimum volume that the AVAudioPlayer class takes is 0.0 and the max is 1.0. The minimum z-index I wanted the leap to record was -200 with the max being 200. So, I simply set up a linear mapping between the volume scale and the z-index. A volume of 0.5 would correspond to a z-index of 0 and other volumes would scale linearly with that.

The equation used to calculate this volume was:

volume = initialVolume + (avgFingerPosition) / volumeScale Finger Position Calculation

This segment of the ‘drawRect’ method deals with drawing the finger’s position on the screen. Basically, there are a series of translations that translate the LeapMotion Controller’s coordinates (in mm) to pixels on the screen relative to the specific window that’s open. Notice that, even if you move the window around on the screen, your finger will still correspond to the relative location on the window. In this segment, a point is made from the average finger position and then is converted to screen coordinates by the ‘convertPoint’ method. Two scales were implanted corresponding to how much a movement on the LeapMotion Controller corresponded to a movement on the screen. This was useful when resizing the main window.

Then, two concentric circles were drawn to indicate finger position. The circle’s radius corresponds to the z-index (volume) of audio player and is scaled by ‘circleScale’. Then the x and y coordinates of the circle are calculated (so that the middle of the circle corresponds with the middle of your hand. Then, based on the the location of the circle, the different scales are applied to the coordinates, which need to be handled separately because of different negative cases.

Then a color that corresponds to the volume is generated and applied to the two circles. The ‘colorWithCalibratedRedGreenBlue’ method takes float values from 0.0 to 1.0 for each color and makes an NSColor out of them. So, I then set up the same mapping that I made for volume and applied it to these values, then created a color from them, applied them to the circles and drew the circles.

Beat To Beat Conducting

Beat-to-beat conducting works by essentially taking two consecutive beat impacts (when your finger crosses the top, right, bottom, or left bound of the inner rectangle, calculates the difference in time between them and adjusts the playback rate accordingly to account for the difference between that time and normal time it would take. The ‘drawRect’ method simply waits until your finger has crossed one of those barriers and then calls the ‘beat’ method, passing in which beat was hit. If your finger in the middle, it will zero out all the buffers that hold the different times you were in each beat (will be explained later).

The ‘beat’ method sets the ‘lastBeatTime’ to the current time ‘timeInSec’, which is updated every time the view loads and also sets the variable ‘time’. So, whenever your finger crosses one of the barriers, it will begin filling a buffer with the time every time the method is called (every 0.01 seconds). It will then take the 2nd object in that array (not the first due to some bugs and null checking) and use that as the ‘beat impact’. This makes it clear why the ‘beat buffers’ are zeroed out every time your hand lands in the middle.

There is an array called ‘currentBeatTimes’ which stores the beat impact times of the past two beats (and deletes the others), via the ‘resetBeats’ method. Then the ‘updateRate’ method is called which adjusts the playback by doing some math to incorporate the beat impact times of the two beats that were passed to it. This process is repeated for all 4 beats, albeit with different beats passed to the different functions to correspond, obviously, to the different beats.

Once the ‘updateRate’ method is called, the current and past beat are collected from the ‘currentBeatTimes’ array and then, if they aren’t null, the difference is calculated between them. The the new playback rate is calculated basically by getting the ratio between how long should have occurred between beats (based on the tempo of the song) and the time that did pass between beats (difference between current and past). The equation for playback is:

newPlayback = secPerBeat / fabs(current − past)

Once this is calculated, the ‘applyPlaybackRate’ method is called, which applies the playback rate to all three audio players simultaneously, so as to make sure they are all synced. up. If the difference would produce a change that would make the playback sound bad (more than double the tempo or less than half the tempo), it will set the playback back to the original. This process then repeats for each successive beat.

Continuous Playback

The second mode of conducting implements continuous playback. This mode effectively works by continuously integrating the velocity of your main finger and using that ‘averaged velocity’ to infer how far your hand is likely to travel vs. how far it would travel if it were conducting at the actual tempo (specified manually).

The average velocity of the fingers in the x-y plane is calculated using the pythagorean theorem:

avgTipVelocity = sqrt(avgFingerVelocity.x^2 + avgFingerVelocity.y^2)

Then, the past 10 average tip velocities that were recorded are held in ‘velocityBuffer’, which throws the last one out every time it gets a new one. Then the average of those velocities is then computed, via standard arithmetic average. Then, in order to convert from LeapMotion coordinates (in mm/s) to screen coordinates (pixels/s), a ratio must be applied:

ratio = fabs(leapLeftBound) + ( fabs(leapRightBound) / conductingFrameWidth)

Then, the expected screen displacement (based on the velocity) is calculated for that ￼instant:

disp = (currentVel * frameUpdateDelay) / ratio

￼Then, based on this expected displacement, LeapMusic calculates the expected time displacement between the current frame and the next, based on that screens displacement and the seconds per beat:

ΔT = dispsecPerBeat / avgBeatDist

￼Then, finally, the updated playback rate is calculated as the ratio of the expected time delay vs. how long will actually be delayed (frame update delay):

newPlayback = fabs( ΔT / rameUpdateDelay)

Then, this new playback rate is then applied to all the audio players. 

Effects (Megaphone and Bass Amplification)

To achieve different audio affects and allow the user to manipulate them, separate mixes of the song were created in Reaper64 (http://www.reaper.fm) which were then imported into the main bundle. Three separate audio players are initialized with the application: one for the main track and one each for the separate effects. These audio players are always initialized, paused, played, and have their playback’s adjusted together. The processing of effects simply raises the corresponding volume of one while decreasing the other.

Effects were chosen to only be supported on beat to beat conducting because continuous conducting was hard enough to control and make sound good without more effects getting in the way. Another linear mapping between the roll degree and audio player volume was setup. The range of hand roll degrees that I wanted to support was from -75 to 75 with the volume of the effects ranging from 0.0 to 1.0. I left a dead zone of 30 degrees in the middle to allow the user to use the main track if they wanted to just listen to the song and try other effects. The equation used to calculate the new volume is:

newVol = abs(handRollDegree / effectRange)

Effect range corresponds to the range that I pre-determined to correspond to this linear mapping. Additionally, the volume change that occurs on the effects tracks is also applied to the main track volume in the reverse direction (gets softer when effects get louder) so as to make the effects more noticeable. Also an edge case was added corresponding to the dead zone: make sure the effects volumes are zero, just to make everything consistent.

Copyright Garrett Parrish 2014.
