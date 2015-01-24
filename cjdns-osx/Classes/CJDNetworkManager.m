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

- (void)ping:(void(^)(NSDictionary *response))completion
{
    [self.session.socketService ping:completion];
}

- (void)function:(NSString *)function arguments:(NSDictionary *)arguments
{
    [self.session.socketService function:function arguments:arguments];
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

//- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password error:(NSError **)error
- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password
{
    CJDSocketService *ss = [[CJDSocketService alloc] initWithHost:host port:port password:password delegate:nil];

    self.session = [[CJDSession alloc] initWithSocketService:ss];
    [ss setDelegate:self.session];
    return self.session;
}

- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password success:(void(^)())success failure:(void(^)(NSError *error))failure
{
    CJDSocketService *ss = [[CJDSocketService alloc] initWithHost:host port:port password:password delegate:nil];

    self.session = [[CJDSession alloc] initWithSocketService:ss];
    [self.session sendConnectPingWithSuccess:success failure:failure];
    [ss setDelegate:self.session];
    return self.session;
}

@end
