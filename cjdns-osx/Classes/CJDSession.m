//
//  CJDSession.m
//  cjdns-osx
//
//  Created by maz on 2015-01-18.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDSession.h"

@interface CJDSession()
@end

@implementation CJDSession
- (instancetype)initWithSocketService:(CJDSocketService *)socketService delegate:(id<CJDSessionDelegate>)delegate
{
    if ((self = [super init]))
    {
        self.socketService = socketService;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark CJDSocketServiceDelegate
- (void)connectionPingFailedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectionFailedWithError:)])
    {
        [self.delegate connectionFailedWithError:error];
    }
}

@end
