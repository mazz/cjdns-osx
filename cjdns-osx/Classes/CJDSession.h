//
//  CJDSession.h
//  cjdns-osx
//
//  Created by maz on 2015-01-18.
//  Copyright (c) 2015 maz. All rights reserved.
//

// manages the keepalive

#import <Foundation/Foundation.h>
#import "CJDSocketService.h"

@interface CJDSession : NSObject <CJDSocketServiceDelegate>

@property (nonatomic, strong, readonly) CJDSocketService *socketService;
#warning TODO delegate not required/not by design, so remove
- (instancetype)initWithSocketService:(CJDSocketService *)socketService;
@end
