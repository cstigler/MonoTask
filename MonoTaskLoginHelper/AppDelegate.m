//
//  AppDelegate.m
//  MonoTaskLoginHelper
//
//  Created by Charles Stigler on 28/01/2018.
//  Copyright © 2018 MonoTask. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"LAUNCHED MONOTASK HELPER!");
    // Borrowed from https://rhult.github.io/articles/sandboxed-launch-on-login/
    // Get the path for the main app bundle from the helper bundle path.
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [basePath stringByDeletingLastPathComponent];
    path = [path stringByDeletingLastPathComponent];
    path = [path stringByDeletingLastPathComponent];
    path = [path stringByDeletingLastPathComponent];
    
    // Launch the executable inside the app, seems to work better according to this (and my testing seems to agree):
    // http://stackoverflow.com/questions/9011836/sandboxed-helper-app-can-not-launch-the-correct-parent-application?rq=1
    // But we also fall back to the app in case this is a bug that will get fixed in an OS X update.
    
    NSString *pathToExecutable = [path stringByAppendingPathComponent:@"Contents/MacOS/MonoTask"];
    
    if ([[NSWorkspace sharedWorkspace] launchApplication:pathToExecutable]) {
        NSLog(@"Launched executable succcessfully");
    }
    else if ([[NSWorkspace sharedWorkspace] launchApplication:path]) {
        NSLog(@"Launched app succcessfully");
    } else {
        NSLog(@"Failed to launch");
    }
    
    // We are done, so we might just quit at this point.
    [[NSApplication sharedApplication] terminate:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
