//
//  musicLibraryBrowser.h
//  LeapMusic
//
//  Created by Garrett Parrish on 12/23/13.
//  Copyright (c) 2013 Leap Motion. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface musicLibraryBrowser : NSWindow

@property (weak) IBOutlet NSArrayController *musicLibrary;

@end
