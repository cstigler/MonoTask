//
//  AppDelegate.h
//  MonoTask
//
//  Created by Charles Stigler on 28/01/2018.
//  Copyright © 2018 MonoTask. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (IBAction)toggleEnabled:(id)sender;

@property (weak) IBOutlet NSMenu* statusMenu;
@property (weak) IBOutlet NSMenuItem *toggleEnabledMenuItem;
@property (weak) IBOutlet NSMenuItem *runOnStartupItem;

@end

