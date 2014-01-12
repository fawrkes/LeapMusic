/*******************************************************************************\
 * Copyright (C) 2013 Garrett Parrish                                            *
 * LeapMusic was created for a final project for Harvard University's CS50 class *
 * LeapMusic allows the user to conduct a pre-determined song either continuously*
 * or via a beat-to-beat method. LeapMusic also allows the user to influence     *
 * different effects of a song (volume, reverb, and/or bass amplification).      *
 \*******************************************************************************/

#import "AppDelegate.h"
#import "musicLeapListener.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreAudio/CoreAudio.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import <QTKit/QTKit.h>
#import "musicLeapView.h"

@implementation AppDelegate
{
    musicLeapView *musicLeapView;
    NSTimer *songProgressUpdate;
    NSTimer *countBeats;
    int beatCount;
    NSString* iTunesMusicPath;
}

@synthesize window = _window;
@synthesize musicLeapListener = _musicLeapListener;
@synthesize audioPlayer, audioPlayerBass, audioPlayerMega;
@synthesize tempo;
@synthesize beat;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Instantiate the leap listener and begin receiving information
    _musicLeapListener = [[musicLeapListener alloc] init];
    [_musicLeapListener run];
    
    // Initialize beat count (for countoff)
    beatCount = 0;
    
    // Create and load audioplayers
    [self createAudioPlayers];
}

// Quit application
- (IBAction)quit:(id)sender
{
    [NSApp terminate:self];
}

// Begin playing song
- (IBAction)playSong:(id)sender
{
    [self playAllAudio];
}

- (IBAction)stopMusic:(id)sender
{
    NSLog(@"Pausing song.");
    [audioPlayer pause];
    [audioPlayerBass pause];
    [audioPlayerMega pause];
}

- (IBAction)restartSong:(id)sender
{
    NSLog(@"Restarting song.");
    [self stopAllAudio];
    [self createAudioPlayers];
    [self playAllAudio];
}

- (void) playAllAudio
{
    NSLog(@"Playing song.");
    [audioPlayerBass play];
    [audioPlayerMega play];
    [audioPlayer play];
}

- (void) stopAllAudio
{
    NSLog(@"Stopping audio.");
    [audioPlayer stop];
    [audioPlayerBass stop];
    [audioPlayerMega stop];
}

- (void) createAudioPlayers
{
    // Main Audio Player
    NSError *error;
    NSString *path = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], [NSString stringWithFormat:@"song.mp3"]];
    NSURL *mainAudioFileUrl = [NSURL URLWithString:path];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mainAudioFileUrl error:&error];
    audioPlayer.enableRate = YES;

    // Enhanced Bass Audio Player
    NSError *bassError;
    NSString *bassPath = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], [NSString stringWithFormat:@"song_bass.mp3"]];
    NSURL *bassAudioFileUrl = [NSURL URLWithString:bassPath];
    audioPlayerBass = [[AVAudioPlayer alloc] initWithContentsOfURL:bassAudioFileUrl error:&bassError];
    audioPlayerBass.enableRate = YES;
    
    // Megaphone Audio Player
    NSError *megaError;
    NSString *megaPath = [NSString stringWithFormat: @"%@/%@", [[NSBundle mainBundle] resourcePath], [NSString stringWithFormat:@"song_mega.mp3"]];
    NSURL *megaAudioFileUrl = [NSURL URLWithString:megaPath];
    audioPlayerMega = [[AVAudioPlayer alloc] initWithContentsOfURL:megaAudioFileUrl error:&megaError];
    audioPlayerMega.enableRate = YES;
}

@end
