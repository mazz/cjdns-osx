//
//  CJDSession+Private.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-24.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDSession.h"

extern NSString *const CJDSessionAdminFunctionsDidGetFetchedNotification;
@interface CJDSession (Private)
- (void)sendConnectionPingWithCompletionHandler:(CJDSessionCreateCompletionHandler)completionHandler;
- (void)sendConnectionPing:(void(^)())success failure:(void(^)(NSError *error))failure;
- (void)disconnect;
@end
