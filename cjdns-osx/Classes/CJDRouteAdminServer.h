//
//  CjdrouteServer.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2016-02-14.
//  Copyright © 2016 maz. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef void (^CJDRouteAdminServerControlCompletionHandler)(BOOL success, NSError * _Nullable error);

@interface CJDRouteAdminServer : NSObject
@property unsigned long port;
@property (readonly) NSString *binPath;
@property (readonly) NSString *confPath;

+ (CJDRouteAdminServer*)defaultServer;
- (instancetype)initWithExecutablesDirectory:(NSString *)executablesDirectory configurationDirectory:(NSString *)configurationDirectory;
+ (NSString *)binaryDirectory;
+ (NSString *)resourceDirectory;
- (void)startWithCompletionHandler:(CJDRouteAdminServerControlCompletionHandler)completionBlock;

@end
NS_ASSUME_NONNULL_END