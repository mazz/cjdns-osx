//
//  CJDNetworkManager.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJDSession.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CJDSessionCreateCompletionHandler)(BOOL success, NSError *_Nullable error);

@interface CJDNetworkManager : NSObject
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *host;
@property (nonatomic) NSUInteger port;

+ (CJDNetworkManager *)sharedInstance;
- (CJDSession*)connectWithAdminDirectory:(NSString*)adminDirectory completionHandler:(CJDSessionCreateCompletionHandler)completion;
//- (CJDSession *)connectWithAdminDirectory:(NSString *)adminDirectory success:(void(^)())success failure:(void(^)(NSError *error))failure;
//- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password success:(void(^)())success failure:(void(^)(NSError *error))failure;

#warning TEMPORARY short-circuited API
- (void)function:(NSString *)function arguments:(NSDictionary *)arguments;

@end
NS_ASSUME_NONNULL_END