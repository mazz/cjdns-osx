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

@interface CJDAppDelegate ()
@property (strong, nonatomic) CJDSession *session;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation CJDAppDelegate
{
    AXStatusItemPopup *_statusItemPopup;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    NSString *cjdnsadminPath = [[NSHomeDirectory() stringByExpandingTildeInPath] stringByAppendingPathComponent:@".cjdnsadmin"];
    NSLog(@"%@", cjdnsadminPath);
        NSError *err = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cjdnsadminPath isDirectory:NO])
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:cjdnsadminPath]
                                                             options:NSJSONReadingAllowFragments
                                                               error:nil];
    
        //        self.session = [[CJDNetworkManager sharedInstance] connectToHost:@"109.425.524.353" port:[[dict objectForKey:@"port"] integerValue] password:dict[@"password"] success:^{
        //            NSLog(@"callback and success");
        //        } failure:^(NSError *error) {
        //            NSLog(@"callback and failure: %@", error);
        //        }];
        
        self.session = [[CJDNetworkManager sharedInstance] connectToHost:@"127.0.0.1" port:kCJDRoutAdminDefaultPort password:dict[@"password"] success:^{
            NSLog(@"callback and success");
        } failure:^(NSError *error) {
            NSLog(@"callback and failure: %@", error);
        }];
        
    }
    else
    {
        NSData *json = [NSJSONSerialization dataWithJSONObject:@{
                                                                 @"addr": @"127.0.0.1",
                                                                 @"port": @(kCJDRoutAdminDefaultPort),
                                                                 @"password": @"NONE"
                                                                 } options:NSJSONWritingPrettyPrinted error:nil];
        [[NSFileManager defaultManager] createFileAtPath:cjdnsadminPath contents:json attributes:nil];
    }

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
