//
//  CJDSession.m
//  cjdns-osx
//
//  Created by maz on 2015-01-18.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDSession.h"
#import "CJDSession+Private.h"

NSString *const CJDSessionAdminFunctionsDidGetFetchedNotification = @"CJDSessionAdminFunctionsDidGetFetchedNotification";
typedef void(^CJDSessionSuccessCallback)();
typedef void(^CJDSessionFailureCallback)(NSError *error);

@interface CJDSession()
@property (nonatomic, strong) CJDSocketService *socketService;
@property (nonatomic, assign) BOOL connected;
@end

@implementation CJDSession
{
    CJDSessionSuccessCallback _success;
    CJDSessionFailureCallback _failure;
    dispatch_source_t _keepAliveSource;
}

- (instancetype)initWithSocketService:(CJDSocketService *)socketService
{
    if ((self = [super init]))
    {
        self.socketService = socketService;
        self.adminFunctions = [NSDictionary dictionary];
        self.connected = NO;
    }
    
    return self;
}

- (void)sendConnectionPing:(void(^)())success failure:(void(^)(NSError *error))failure
{
    _success = success;
    _failure = failure;
    
    [self.socketService sendConnectPing];
}

- (void)disconnect
{
    if (self.connected)
    {
        dispatch_source_cancel(_keepAliveSource);
        _keepAliveSource = nil;
        self.connected = NO;
    }
}

#pragma mark CJDSocketServiceDelegate
- (void)connectionPingDidFailWithError:(NSError *)error
{
    _failure(error);
}

- (void)connectionPingDidSucceed
{
    NSLog(@"connectionPingDidSucceed");
    _success();
 
    self.connected = YES;
    [self.socketService fetchAdminFunctions:^(NSDictionary *response)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CJDSessionAdminFunctionsDidGetFetchedNotification object:nil userInfo:@{@"adminFunctions": response}];
        self.adminFunctions = response;
    }];

    _keepAliveSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_keepAliveSource, dispatch_walltime(NULL, 0), 2ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_keepAliveSource, ^{
            [self.socketService keepAlive];
    });
    dispatch_resume(_keepAliveSource);
}

- (void)keepAliveDidSucceed
{
    NSLog(@"keepAliveDidSucceed");
}

- (void)keepAliveDidFailWithError:(NSError *)error
{
    NSLog(@"keepAliveDidFailWithError:");
    [self disconnect];
}

@end
