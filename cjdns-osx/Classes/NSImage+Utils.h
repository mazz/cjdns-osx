//
//  NSImage+Utils.h
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Utils)
+ (NSImage *)stringImageWithText:(NSString *)text_ inverted:(BOOL)inverted_;
+ (NSImage *)imageOfView:(NSView*)view;
@end
