//
//  CjdrouteServer.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2016-02-14.
//  Copyright © 2016 maz. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CJDRouteAdminServer : NSObject
- (instancetype)initWithExecutablesDirectory:(NSString *)executablesDirectory;
+ (NSString*)standardBinaryDirectory;

@end
NS_ASSUME_NONNULL_END