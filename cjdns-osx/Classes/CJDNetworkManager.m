//
//  CJDNetworkManager.m
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDNetworkManager.h"
#import "CJDSocketService.h"

@interface CJDNetworkManager()
@property (strong, nonatomic) CJDSession *session;
@end

@implementation CJDNetworkManager

- (void)ping:(void(^)(NSDictionary *response))completion
{
    [self.session.socketService ping:nil];
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

- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password
{
    self.session = [[CJDSession alloc] initWithSocketService:[[CJDSocketService alloc] initWithHost:host port:port password:password]];
    return self.session;
}

@end
