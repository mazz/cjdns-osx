//
//  CJDNetworkManager.m
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDNetworkManager.h"
#import "CJDSocketService.h"
#import "CJDSession+Private.h"

@interface CJDNetworkManager()
@property (strong, nonatomic) CJDSession *session;
@end

@implementation CJDNetworkManager

- (void)function:(NSString *)function arguments:(NSDictionary *)arguments
{
    [self.session.socketService function:function arguments:arguments tag:-1];
}

+ (CJDNetworkManager *)sharedInstance
{
    static CJDNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CJDNetworkManager alloc] init];
    });
    return manager;
}

- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password success:(void(^)())success failure:(void(^)(NSError *error))failure
{
    CJDSocketService *ss = [[CJDSocketService alloc] initWithHost:host port:port password:password delegate:nil];

    self.session = [[CJDSession alloc] initWithSocketService:ss];
    
    // if the initial connection ping returns a successful response(pong) then the session will
    // get and store admin functions AND initiate a keep-alive
    [self.session sendConnectionPing:success failure:failure];
    [ss setDelegate:self.session];
    return self.session;
}

@end
