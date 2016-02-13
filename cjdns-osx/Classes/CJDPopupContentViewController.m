//
//  CJDPopupContentViewController.m
//  Nome
//
//  Created by maz on 2014-11-15.
//  Copyright (c) 2014 maz. All rights reserved.
//

#import "CJDPopupContentViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "VOKBenkode.h"
#import "CJDNetworkManager.h"
#import "CJDSession.h"

@interface CJDPopupContentViewController () <NSTableViewDelegate,NSTableViewDataSource>
- (IBAction)showUtility:(id)sender;
- (IBAction)quit:(id)sender;
@property (strong, nonatomic) CJDSession *session;
@end

@implementation CJDPopupContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *cjdnsadminPath = [[NSHomeDirectory() stringByExpandingTildeInPath] stringByAppendingPathComponent:@".cjdnsadmin"];
    NSLog(@"%@", cjdnsadminPath);
    //    NSError *err = nil;
    
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
        
        self.session = [[CJDNetworkManager sharedInstance] connectToHost:@"127.0.0.1" port:[[dict objectForKey:@"port"] integerValue] password:dict[@"password"] success:^{
            NSLog(@"callback and success");
        } failure:^(NSError *error) {
            NSLog(@"callback and failure: %@", error);
        }];
        
    }
    else
    {
        NSData *json = [NSJSONSerialization dataWithJSONObject:@{
                                                                 @"addr": @"127.0.0.1",
                                                                 @"port": @11234,
                                                                 @"password": @"You tell me! (Search in ~/cjdroute.conf)"
                                                                 } options:NSJSONWritingPrettyPrinted error:nil];
        [[NSFileManager defaultManager] createFileAtPath:cjdnsadminPath contents:json attributes:nil];
    }
    
    [[CJDNetworkManager sharedInstance] function:@"InterfaceController_peerStats" arguments:@{}];
    //    [[CJDNetworkManager sharedInstance] function:@"Allocator_bytesAllocated" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"Admin_asyncEnabled" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"Allocator_bytesAllocated" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"Allocator_snapshot" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"SessionManager_sessionStats" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"Allocator_bytesAllocated" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"SwitchPinger_ping" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"IpTunnel_listConnections" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"IpTunnel_listConnections" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] function:@"IpTunnel_listConnections" arguments:nil];
    //    [[CJDNetworkManager sharedInstance] ping:^(NSDictionary *response) {
    //        NSLog(@"pong foo!");
    //    }];
}

- (NSFont *)rowFont
{
    return [NSFont systemFontOfSize:30.0];
}

- (IBAction)showUtility:(id)sender
{
    NSLog(@"show util");
}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:nil];
}

@end
