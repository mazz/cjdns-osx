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
- (instancetype)initWithSocketService:(CJDSocketService *)socketService
{
    if ((self = [super init]))
    {
        self.socketService = socketService;
    }
    return self;
}
@end
