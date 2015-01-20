//
//  CJDNetworkManager.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJDSession.h"

@interface CJDNetworkManager : NSObject
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *host;
@property (nonatomic) NSUInteger port;

+ (CJDNetworkManager *)sharedInstance;
- (CJDSession *)connectToHost:(NSString *)host port:(NSUInteger)port password:(NSString *)password;

#warning TEMPORARY short-circuited API
- (void)ping:(void(^)(NSDictionary *response))completion;
- (void)function:(NSString *)function arguments:(NSDictionary *)arguments;

@end
