//
//  CJDApiService.h
//  cjdns-osx
//
//  Created by maz on 2015-01-17.
//  Copyright (c) 2015 maz. All rights reserved.
//

// abstracts network socket

#import <Foundation/Foundation.h>

@interface CJDSocketService : NSObject
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port password:(NSString *)password;

- (void)ping:(void(^)(NSDictionary *response))completion;
- (void)function:(NSString *)function arguments:(NSDictionary *)arguments;
@end
