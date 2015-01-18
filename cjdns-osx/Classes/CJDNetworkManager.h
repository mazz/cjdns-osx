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
- (void)ping:(void(^)(NSDictionary *response))completion;
- (void)function:(NSString *)function password:(NSString *)password arguments:(NSDictionary *)arguments;
@end
