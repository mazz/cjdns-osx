//
//  NSData+Digest.m
//  cjdns-osx
//
//  Created by maz on 2015-01-17.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "NSData+Digest.h"

@implementation NSData (Digest)
- (NSString *)hexDigest
{
    NSString *hex = [self description];
    hex = [hex stringByReplacingOccurrencesOfString:@" " withString:@""];
    hex = [hex stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hex = [hex stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    return hex;
}
@end
