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
    _confPath = [configurationDirectory stringByAppendingPathComponent:@"cjdroute.conf"];
    NSLog(@"_confPath: %@", _confPath);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_confPath]) {
        return nil;
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

#pragma mark - Asynchronous Server Control Methods

- (void)startWithCompletionHandler:(CJDRouteAdminServerControlCompletionHandler)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        BOOL serverDidStart = [self startServerWithError:&error];
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(serverDidStart, error); });
        }
        return;
    });
}

-(BOOL)startServerWithError:(NSError**)error {
    NSTask *controlTask = [[NSTask alloc] init];
    controlTask.launchPath = [self.binPath stringByAppendingPathComponent:@"cjdroute"];
    controlTask.standardInput = [NSFileHandle fileHandleForReadingAtPath:self.confPath];
    controlTask.standardError = [[NSPipe alloc] init];
    [controlTask launch];
    [controlTask waitUntilExit];
    if (controlTask.terminationStatus == 0) {
        self.isRunning = YES;
    }
    
    return controlTask.terminationStatus == 0;
}


@end
NS_ASSUME_NONNULL_END