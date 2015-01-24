//
//  CJDSession.m
//  cjdns-osx
//
//  Created by maz on 2015-01-18.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDSession.h"
#import "CJDSession+Private.h"

typedef void(^CJDSessionSuccessCallback)();
typedef void(^CJDSessionFailureCallback)(NSError *error);

@interface CJDSession()
@property (nonatomic, strong) CJDSocketService *socketService;
@end

@implementation CJDSession
{
    CJDSessionSuccessCallback _success;
    CJDSessionFailureCallback _failure;
}

- (instancetype)initWithSocketService:(CJDSocketService *)socketService
{
    if ((self = [super init]))
    {
        self.socketService = socketService;
    }
    
    return self;
}

- (void)sendConnectPingWithSuccess:(void(^)())success failure:(void(^)(NSError *error))failure
{
    _success = success;
    _failure = failure;
    [self.socketService sendConnectPing];
}

#pragma mark CJDSocketServiceDelegate
- (void)connectionPingDidFailWithError:(NSError *)error
{
    _failure(error);
}

- (void)connectionPingDidSucceed
{
    _success();
}
@end
