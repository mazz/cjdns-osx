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

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    NSLog(@"[[NSBundle mainBundle] resourcePath]: %@", [[NSBundle mainBundle] resourcePath]);

    self.server = [[CJDRouteAdminServer alloc] initWithExecutablesDirectory:[CJDRouteAdminServer binaryDirectory] configurationDirectory:[CJDRouteAdminServer resourceDirectory]];
    
    self.session = [[CJDNetworkManager sharedInstance] connectWithAdminDirectory:[NSHomeDirectory() stringByExpandingTildeInPath] completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"session creation success");
        } else {
            NSLog(@"session creation failure: %@", error);
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

- (void)applicationWillTerminate:(NSNotification*)aNotification
{
    // Insert code here to tear down your application
}

@end
