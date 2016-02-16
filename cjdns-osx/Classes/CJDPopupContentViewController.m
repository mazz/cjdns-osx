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

@interface CJDPopupContentViewController () <NSTableViewDelegate,NSTableViewDataSource>
- (IBAction)showUtility:(id)sender;
- (IBAction)openDocumentation:(id)sender;
- (IBAction)quit:(id)sender;
@end

@implementation CJDPopupContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[CJDNetworkManager sharedInstance] function:@"InterfaceController_peerStats" arguments:@{}];
    [[CJDNetworkManager sharedInstance] function:@"SessionManager_sessionStats" arguments:@{}];
    //    [[CJDNetworkManager sharedInstance] function:@"Allocator_bytesAllocated" arguments:nil];
//    [[CJDNetworkManager sharedInstance] function:@"Admin_asyncEnabled" arguments:@{}];
//    [[CJDNetworkManager sharedInstance] function:@"Allocator_bytesAllocated" arguments:@{}];
//    [[CJDNetworkManager sharedInstance] function:@"Allocator_snapshot" arguments:@{}];
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

- (IBAction)openDocumentation:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/cjdelisle/cjdns/tree/master/doc"]];

}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:nil];
}

@end
