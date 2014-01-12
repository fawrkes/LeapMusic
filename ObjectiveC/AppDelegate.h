/*******************************************************************************\
* Copyright (C) 2013 Garrett Parrish                                            *
* LeapMusic was created for a final project for Harvard University's CS50 class *
* LeapMusic allows the user to conduct a pre-determined song either continuously*
* or via a beat-to-beat method. LeapMusic also allows the user to influence     *
* different effects of a song (volume, reverb, and/or bass amplification).      *
\*******************************************************************************/

#import <Cocoa/Cocoa.h>
#import "Xcode.h"
#import "LeapObjectiveC.h"
#import <AVFoundation/AVFoundation.h>

// class that gets information from the Leap
@class musicLeapListener;

@interface AppDelegate : NSObject <NSApplicationDelegate>

// Leap Motion configuration
@property LeapFrame *currentFrame;
@property (nonatomic, strong, readonly) musicLeapListener *musicLeapListener;

// Application-specific
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (IBAction)quit:(id)sender;

// Main Window
@property (nonatomic, strong, readonly)IBOutlet NSWindow *window;

// Main Conducting View
@property (weak) IBOutlet NSImageView *mainView;

// Beat Indicator (for beat-to-beat conducting)
@property (weak) IBOutlet NSTextField *beat;

// Effects Labels
@property (weak) IBOutlet NSImageView *rightRollEffectLabel;
@property (weak) IBOutlet NSImageView *leftRollEffectLabel;

// Top Text
@property (weak) IBOutlet NSTextField *welcomeMessage;

// Buttons
@property (weak) IBOutlet NSButton *playMusic;
@property (weak) IBOutlet NSButton *restartSong;
@property (weak) IBOutlet NSButton *quitProgram;
@property (weak) IBOutlet NSButton *stopMusic;

// Conducting style picker
@property (weak) IBOutlet NSSegmentedControl *conductingStylePicker;

// Song Information
@property float tempo;

// Audio Players and Methods
@property (strong, atomic) AVAudioPlayer *audioPlayer;
@property (strong, atomic) AVAudioPlayer *audioPlayerBass;
@property (strong, atomic) AVAudioPlayer *audioPlayerMega;

- (IBAction)playSong:(id)sender;
- (IBAction)restartSong:(id)sender;
- (IBAction)stopMusic:(id)sender;

- (void) createAudioPlayers;
- (void) stopAllAudio;
- (void) playAllAudio;


@end