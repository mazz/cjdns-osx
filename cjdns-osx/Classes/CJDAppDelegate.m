//
//  AppDelegate.m
//  cjdns-osx
//
//  Created by maz on 2015-01-04.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDAppDelegate.h"
#import "AXStatusItemPopup.h"
#import "CJDSession.h"
#import "CJDNetworkManager.h"
#import "CJDPopupContentViewController.h"
#import "NSImage+Utils.h"
#import "CJDRouteAdminServer.h"

@interface CJDAppDelegate ()
@property (strong, nonatomic) CJDSession *session;
@property (weak) IBOutlet NSWindow *window;
@property CJDRouteAdminServer *server;
@end

@implementation CJDAppDelegate {
    AXStatusItemPopup* _statusItemPopup;
}

#pragma mark - NSApplicationDelegate

-(void)applicationWillFinishLaunching:(NSNotification *)notification {
    
    /* Make sure that the app is inside the application directory */
#if !DEBUG
//    [[PGApplicationMover sharedApplicationMover] validateApplicationPath];
#endif
    
    [self validateNoOtherVersionsAreRunning];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              kCJDRouteAdminShowWelcomeWindowPreferenceKey: @(YES)
                                                              }];
}
-(void)validateNoOtherVersionsAreRunning {
    NSMutableArray *runningCopies = [NSMutableArray array];
    [runningCopies addObjectsFromArray:[NSRunningApplication runningApplicationsWithBundleIdentifier:@"me.maz.cjdns-osx"]];
    for (NSRunningApplication *runningCopy in runningCopies) {
        if (![runningCopy isEqual:[NSRunningApplication currentApplication]]) {
            NSAlert *alert = [NSAlert alertWithMessageText: @"Another copy of cjdns-osx is already running."
                                             defaultButton: @"OK"
                                           alternateButton: nil
                                               otherButton: nil
                                 informativeTextWithFormat: @"Please quit %@ before starting this copy.", runningCopy.localizedName];
            [alert runModal];
            exit(1);
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    NSLog(@"[[NSBundle mainBundle] resourcePath]: %@", [[NSBundle mainBundle] resourcePath]);

    self.server = [CJDRouteAdminServer defaultServer];
    [self.server startWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"self.server start success");
            [self startSession];
        } else {
            NSLog(@"self.server start fail: %@", error);
        }
    }];
    

    CJDPopupContentViewController* contentViewController = [[CJDPopupContentViewController alloc] initWithNibName:NSStringFromClass([CJDPopupContentViewController class]) bundle:nil];

    NSImage* image = [NSImage stringImageWithText:@"cjdns" inverted:YES];
    NSImage* alternateImage = [NSImage stringImageWithText:@"cjdns" inverted:NO];

    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:alternateImage];
    // globally set animation state (optional, defaults to YES)
    //    _statusItemPopup.animated = NO;
    // optionally set the popover to the contentview to e.g. hide it from there
    contentViewController.statusItemPopup = _statusItemPopup;
}

- (void)startSession {
    
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    // make sure preferences are saved before quitting
//    PreferenceWindowController *prefController = [PreferenceWindowController sharedController];
//    if (prefController.isWindowLoaded && prefController.window.isVisible && ![prefController windowShouldClose:prefController.window]) {
//        return NSTerminateCancel;
//    }
//    
    if (!self.server.isRunning) {
        return NSTerminateNow;
    }
    
    [self.server stopWithCompletionHandler:^(BOOL success, NSError *error) {
        [sender replyToApplicationShouldTerminate:YES];
    }];

    return NSTerminateLater;
}

- (void)applicationWillTerminate:(NSNotification*)aNotification
{
    // Insert code here to tear down your application
}

@end
