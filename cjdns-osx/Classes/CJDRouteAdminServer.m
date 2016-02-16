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
        if (!serverDidStart) {
            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
            return;
        }
        
//        PostgresDataDirectoryStatus dataDirStatus = [PostgresServer statusOfDataDirectory:_varPath error:&error];
//        
//        if (dataDirStatus==PostgresDataDirectoryEmpty) {
//            BOOL serverDidInit = [self initDatabaseWithError:&error];
//            if (!serverDidInit) {
//                if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
//                return;
//            }
//            
//            BOOL serverDidStart = [self startServerWithError:&error];
//            if (!serverDidStart) {
//                if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
//                return;
//            }
//            
//            BOOL createdUser = [self createUserWithError:&error];
//            if (!createdUser) {
//                if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
//                return;
//            }
//            
//            BOOL createdUserDatabase = [self createUserDatabaseWithError:&error];
//            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(createdUserDatabase, error); });
//        }
//        else if (dataDirStatus==PostgresDataDirectoryCompatible) {
//            BOOL serverDidStart = [self startServerWithError:&error];
//            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(serverDidStart, error); });
//        }
//        else {
//            if (completionBlock) dispatch_async(dispatch_get_main_queue(), ^{ completionBlock(NO, error); });
//        }
        
    });
}

-(BOOL)startServerWithError:(NSError**)error {
    NSTask *controlTask = [[NSTask alloc] init];
    controlTask.launchPath = [self.binPath stringByAppendingPathComponent:@"cjdroute"];
//    controlTask.arguments = @[
//                              @"<",
//                              self.confPath
//                              ];
    
    controlTask.standardInput = [NSFileHandle fileHandleForReadingAtPath:self.confPath];
//                              /* control command          */ @"start",
//                                                             /* data directory           */ @"-D", self.varPath,
//                                                             /* wait for server to start */ @"-w",
//                                                             /* server log file          */ @"-l", self.logfilePath,
//                                                             /* allow overriding port    */ @"-o", [NSString stringWithFormat:@"-p %lu", self.port]
//                                                             ];
    controlTask.standardError = [[NSPipe alloc] init];
    [controlTask launch];
    NSString *controlTaskError = [[NSString alloc] initWithData:[[controlTask.standardError fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    [controlTask waitUntilExit];
    
    if (controlTask.terminationStatus != 0 && error) {
        NSMutableDictionary *errorUserInfo = [[NSMutableDictionary alloc] init];
        errorUserInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"Could not start cjdroute admin server.",nil);
        errorUserInfo[NSLocalizedRecoverySuggestionErrorKey] = controlTaskError;
//        errorUserInfo[NSLocalizedRecoveryOptionsErrorKey] = @[@"OK", @"Open Server Log"];
//        errorUserInfo[NSRecoveryAttempterErrorKey] = [[RecoveryAttempter alloc] init];
//        errorUserInfo[@"ServerLogRecoveryOptionIndex"] = @1;
//        errorUserInfo[@"ServerLogPath"] = self.logfilePath;
        *error = [NSError errorWithDomain:@"me.maz.cjdns-osx.cjdroute" code:controlTask.terminationStatus userInfo:errorUserInfo];
    }
    
    if (controlTask.terminationStatus == 0) {
        self.isRunning = YES;
    }
    
    return controlTask.terminationStatus == 0;
}


@end
NS_ASSUME_NONNULL_END