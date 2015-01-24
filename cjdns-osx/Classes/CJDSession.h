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

@protocol CJDSessionDelegate <NSObject>
@required
- (void)connectionFailedWithError:(NSError *)error;
@end

@interface CJDSession : NSObject <CJDSocketServiceDelegate>
@property (nonatomic, strong) CJDSocketService *socketService;
@property (nonatomic, strong) id <CJDSessionDelegate> delegate;
- (instancetype)initWithSocketService:(CJDSocketService *)socketService delegate:(id<CJDSessionDelegate>)delegate;
@end
