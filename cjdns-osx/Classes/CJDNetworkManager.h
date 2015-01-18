//
//  CJDNetworkManager.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJDNetworkManager : NSObject
+ (CJDNetworkManager *)sharedInstance;
- (void)sendData:(NSData *)data;
- (void)fetchCookie:(void(^)(NSString *cookie))completion;
- (void)ping:(void(^)(NSDictionary *response))completion;
@end
