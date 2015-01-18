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
#import "VOKBenkode.h"
#import "NSImage+Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Digest.h"

@interface CJDAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation CJDAppDelegate
{
    AXStatusItemPopup *_statusItemPopup;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSData *dataIn = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(dataIn.bytes, dataIn.length,  macOut.mutableBytes);
    
    NSLog(@"dataIn: %@", dataIn);

    NSLog(@"macOut: %@", [macOut hexDigest]);
    
//    NSData *encoded = [VOKBenkode encode:@{@"q":@"ping", @"txid":@"my request"}];
//    //{ "q": "ping", "txid": "my request" }
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//    
//    encoded = [VOKBenkode encode:@{@"q":@"cookie", @"txid":@"cookie request"}];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];

    [[CJDNetworkManager sharedInstance] fetchCookie:^(NSString *cookie)
    {
        NSLog(@"got cookie: %@", cookie);
    }];
    
    [[CJDNetworkManager sharedInstance] ping:^(NSDictionary *response) {
        NSLog(@"got ping response: %@", response);
    }];
//      d1:q24:Admin_availableFunctions4:argsd4:pagei' +
//      str(page) + 'eee')
//    "q": "Admin_availableFunctions",
//    "args": {
//        "page": 0

//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@0}
//                                   }];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//
//
//    
//    
//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@1}
//                                   }];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//
//    
//    
//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@2}
//                                   }];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//
//
//    
//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@3}
//                                   }];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//
//    
//    
//    
//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@4}
//                                   }];
//    //{ "q": "ping", "txid": "my request" }
//    //d1:q6:cookiee
//    NSLog(@"bencoded: %@", [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding]);
//    [[CJDNetworkManager sharedInstance] sendData:encoded];
//
//    
//    
//    encoded = [VOKBenkode encode:@{@"q":@"Admin_availableFunctions",
//                                   @"args":@{@"page":@5}
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
