//
//  CJDNetworkManager.m
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDNetworkManager.h"
#import "CJDSession+Private.h"
#import "CJDSocketService.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJDNetworkManager ()
@property (strong, nonatomic) CJDSession* session;
@property (strong, nonatomic) CJDSessionCreateCompletionHandler completionHandler;
@end

@implementation CJDNetworkManager

- (void)function:(NSString*)function arguments:(NSDictionary*)arguments
{
    [self.session.socketService function:function arguments:arguments tag:-1];
}

+ (CJDNetworkManager*)sharedInstance
{
    static CJDNetworkManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CJDNetworkManager alloc] init];
    });
    return manager;
}

- (CJDSession*)connectWithAdminDirectory:(NSString*)adminDirectory completionHandler:(CJDSessionCreateCompletionHandler)completion
{

    self.completionHandler = completion;

    NSString* cjdnsadminPath = [adminDirectory stringByAppendingPathComponent:@".cjdnsadmin"];
    NSDictionary* dict = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cjdnsadminPath isDirectory:NO]) {
        dict = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:cjdnsadminPath]
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];

        //        self.session = [[CJDNetworkManager sharedInstance] connectToHost:@"127.0.0.1" port:kCJDRoutAdminDefaultPort password:dict[@"password"] success:^{
        //            NSLog(@"callback and success");
        //        }
        //                                                                 failure:^(NSError* error) {
        //                                                                     NSLog(@"callback and failure: %@", error);
        //                                                                 }];
    }
    else {
        NSData* json = [NSJSONSerialization dataWithJSONObject:@{
            @"addr" : @"127.0.0.1",
            @"port" : @(kCJDRouteAdminDefaultPort),
            @"password" : @"NONE"
        }
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        [[NSFileManager defaultManager] createFileAtPath:cjdnsadminPath contents:json attributes:nil];
    }

    if (dict != nil) {
        CJDSocketService* ss = [[CJDSocketService alloc] initWithHost:@"127.0.0.1" port:kCJDRouteAdminDefaultPort password:dict[@"password"] delegate:nil];

        self.session = [[CJDSession alloc] initWithSocketService:ss];

        // if the initial connection ping returns a successful response(pong) then the session will
        // get and store admin functions AND initiate a keep-alive
        [self.session sendConnectionPingWithCompletionHandler:self.completionHandler];
//        [self.session sendConnectionPing:; failure:<#^(NSError *error)failure#>]
//        [self.session sendConnectionPing:success failure:failure];
        [ss setDelegate:self.session];
    }
    else {
        if (self.completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionHandler(NO, [NSError errorWithDomain:@"Could not create data structure from cjdnsadmin file" code:-1 userInfo:nil]);
            });
        }
        return nil;
    }

    return self.session;
}

- (CJDSession*)connectToHost:(NSString*)host port:(NSUInteger)port password:(NSString*)password success:(void (^)())success failure:(void (^)(NSError* error))failure
{
    CJDSocketService* ss = [[CJDSocketService alloc] initWithHost:host port:port password:password delegate:nil];

    self.session = [[CJDSession alloc] initWithSocketService:ss];

    // if the initial connection ping returns a successful response(pong) then the session will
    // get and store admin functions AND initiate a keep-alive
    [self.session sendConnectionPing:success failure:failure];
    [ss setDelegate:self.session];
    return self.session;
}

@end
NS_ASSUME_NONNULL_END