//
//  CjdrouteServer.m
//  cjdns-osx
//
//  Created by Michael Hanna on 2016-02-14.
//  Copyright © 2016 maz. All rights reserved.
//

#import "CJDRouteAdminServer.h"

NS_ASSUME_NONNULL_BEGIN
@interface CJDRouteAdminServer ()
@property BOOL isRunning;
@end

static CJDRouteAdminServer* _sharedServer = nil;

@implementation CJDRouteAdminServer
+ (CJDRouteAdminServer*)defaultServer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedServer = [[CJDRouteAdminServer alloc] initWithExecutablesDirectory:[self binaryDirectory] configurationDirectory:[self resourceDirectory]];
    });
    return _sharedServer;
}

- (instancetype)initWithExecutablesDirectory:(NSString*)executablesDirectory configurationDirectory:(NSString*)configurationDirectory
{
    if (!(self = super.init))
        return nil;
    
    _binPath = executablesDirectory;
    _port = kCJDRoutAdminDefaultPort;

    NSString* conf = [configurationDirectory stringByAppendingPathComponent:@"cjdroute.conf"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:conf]) {
        NSLog(@"conf: %@", conf);
    }
    return self;
}

+ (NSString*)binaryDirectory
{
    return [NSBundle mainBundle].resourcePath;
}

+ (NSString*)resourceDirectory
{
    return [NSBundle mainBundle].resourcePath;
}

@end
NS_ASSUME_NONNULL_END