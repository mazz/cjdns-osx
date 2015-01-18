//
//  AppDelegate.m
//  cjdns-osx
//
//  Created by maz on 2015-01-04.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDAppDelegate.h"
#import "AXStatusItemPopup.h"
#import "CJDPopupContentViewController.h"
#import "CJDNetworkManager.h"
#import "NSImage+Utils.h"

@interface CJDAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation CJDAppDelegate
{
    AXStatusItemPopup *_statusItemPopup;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[CJDNetworkManager sharedInstance] function:@"ping" password:@"ADMINPASSFOO" arguments:nil];

//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@0}
//                                   }];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//
    CJDPopupContentViewController *contentViewController = [[CJDPopupContentViewController alloc] initWithNibName:NSStringFromClass([CJDPopupContentViewController class]) bundle:nil];

    NSImage *image = [NSImage stringImageWithText:@"cjdns" inverted:YES];
    NSImage *alternateImage = [NSImage stringImageWithText:@"cjdns" inverted:NO];

    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:alternateImage];
    // globally set animation state (optional, defaults to YES)
    //    _statusItemPopup.animated = NO;
    // optionally set the popover to the contentview to e.g. hide it from there
    contentViewController.statusItemPopup = _statusItemPopup;

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

@end
