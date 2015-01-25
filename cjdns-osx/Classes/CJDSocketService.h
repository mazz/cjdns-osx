//
//  CJDApiService.h
//  cjdns-osx
//
//  Created by maz on 2015-01-17.
//  Copyright (c) 2015 maz. All rights reserved.
//

// abstracts network socket

#import <Foundation/Foundation.h>

@protocol CJDSocketServiceDelegate <NSObject>
@required
- (void)connectionPingDidSucceed;
- (void)connectionPingDidFailWithError:(NSError *)error;
- (void)keepAliveDidSucceed;
- (void)keepAliveDidFailWithError:(NSError *)error;
@end

@interface CJDSocketService : NSObject
@property (nonatomic, strong) id <CJDSocketServiceDelegate> delegate;
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port password:(NSString *)password delegate:(id<CJDSocketServiceDelegate>)delegate;
- (void)fetchAdminFunctions:(void(^)(NSDictionary *response))completion;
- (void)sendConnectPing;
- (void)keepAlive;
- (void)function:(NSString *)function arguments:(NSDictionary *)arguments tag:(long)tag;
@end
