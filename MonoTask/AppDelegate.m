//
//  AppDelegate.m
//  MonoTask
//
//  Created by Charles Stigler on 28/01/2018.
//  Copyright © 2018 MonoTask. All rights reserved.
//

#import "AppDelegate.h"
#import "SystemEvents.h"
#import "AHLaunchCtl.h"
#import <ServiceManagement/ServiceManagement.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (assign, nonatomic) BOOL darkModeOn;
@property (assign, nonatomic) BOOL enabled;

@end

@implementation AppDelegate

static NSString const *kLoginHelperBundleIdentifier = @"com.monotask.MonoTaskLoginHelper";

// TODO: Make option for fullscreen on every activation, or launch only (current behavior)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSLog(@"launching");
    // Add a listener to full screen each application when it launches
    NSNotificationCenter* workspaceNotificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [workspaceNotificationCenter addObserverForName: NSWorkspaceDidActivateApplicationNotification
                                             object: nil
                                              queue: nil
                                         usingBlock:^(NSNotification * _Nonnull note) {
                                             if (!self.enabled) return;
                                             
                                             NSRunningApplication* runningApp = [note.userInfo objectForKey: NSWorkspaceApplicationKey];
                                             
                                             NSLog(@"Full-screening %@", runningApp.localizedName);
                                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                 [self fullScreenApplication: runningApp];
                                             });
                                         }];
    
    // TODO: make this work well with Dark Mode
    // TODO: grey out the status item when we're disabled
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSImage* statusBarImage = [NSImage imageNamed:@"menu-bar-icon.png"];
    statusBarImage.template = YES;
    self.statusItem.image = statusBarImage;
    self.statusItem.menu = self.statusMenu;
    [self.statusItem setAction:@selector(statusItemClicked:)];
    
    // update the menu item name to Enable/Disable whenever that changes
    self.enabled = YES;
    [self updateEnabledInterface];
    
    // update the menu item for "Run on Startup"
    [self updateRunOnStartupMenu];
    NSLog(@"launched");
}

// TODO: don't try to fullscreen if it's already fullscreen!
- (void)fullScreenApplication:(NSRunningApplication*)app {
    SystemEventsApplication* sysEventsApp = [SBApplication applicationWithBundleIdentifier: @"com.apple.SystemEvents"];
    SystemEventsProcess* proc = [[[sysEventsApp applicationProcesses] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"bundleIdentifier = %@", app.bundleIdentifier]] firstObject];
    
    NSDate* pollStart = [NSDate date];
    while ([[proc windows] count] < 1 && [[NSDate date] timeIntervalSinceDate: pollStart] < 10) {
        NSLog(@"Waiting for another 0.1s for %@ to start a window", app.localizedName);
        [NSThread sleepForTimeInterval: 0.1];
    }
    
    [app activateWithOptions: 0];
    NSAppleEventDescriptor *list = [NSAppleEventDescriptor listDescriptor];
    [list insertDescriptor:[NSAppleEventDescriptor descriptorWithEnumCode:SystemEventsEMdsCommandDown] atIndex:0];
    [list insertDescriptor:[NSAppleEventDescriptor descriptorWithEnumCode:SystemEventsEMdsShiftDown] atIndex:0];
    [sysEventsApp keystroke: @"f" using: list];
    
    NSAppleEventDescriptor *list2 = [NSAppleEventDescriptor listDescriptor];
    [list2 insertDescriptor:[NSAppleEventDescriptor descriptorWithEnumCode:SystemEventsEMdsControlDown] atIndex:0];
    [list2 insertDescriptor:[NSAppleEventDescriptor descriptorWithEnumCode:SystemEventsEMdsCommandDown] atIndex:0];
    [sysEventsApp keystroke: @"f" using: list2];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    [self updateEnabledInterface];
}
- (IBAction)toggleEnabled:(id)sender {
    self.enabled = !self.enabled;
}

- (void)updateEnabledInterface {
    self.statusItem.button.appearsDisabled = !self.enabled;
    
    if (self.enabled) {
        self.toggleEnabledMenuItem.title = @"Disable MonoTask";
    } else {
        self.toggleEnabledMenuItem.title = @"Enable MonoTask";
    }
}

- (void)addLoginItem {
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)kLoginHelperBundleIdentifier, true)) {
        NSLog(@"SMLoginItemSetEnabled failed to add login item");
    }
    [self updateRunOnStartupMenu];
}
- (void)removeLoginItem {
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)kLoginHelperBundleIdentifier, false)) {
        NSLog(@"SMLoginItemSetEnabled failed to remove login item");
    }
    [self updateRunOnStartupMenu];
}
- (BOOL)loginItemIsPresent {
    NSArray* jobDicts = CFBridgingRelease(SMCopyAllJobDictionaries(kSMDomainUserLaunchd));
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([kLoginHelperBundleIdentifier isEqualToString:[job objectForKey:@"Label"]]) {
                return YES;
            }
        }
    }
    
    return NO;
}
- (void)updateRunOnStartupMenu {
    if ([self loginItemIsPresent]) {
        self.runOnStartupItem.state = NSOnState;
        self.runOnStartupItem.action = @selector(removeLoginItem);
    } else {
        self.runOnStartupItem.state = NSOffState;
        self.runOnStartupItem.action = @selector(addLoginItem);
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
