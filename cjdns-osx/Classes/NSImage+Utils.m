//
//  NSImage+Utils.m
//  cjdns-osx
//
//  Created by Michael Hanna on 2015-01-05.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "NSImage+Utils.h"

CGFloat kMAZAppDelegateMinTextWidth = 36.0;

@implementation NSImage (Utils)
+ (NSImage *)stringImageWithText:(NSString *)text_ inverted:(BOOL)inverted_
{
    NSColor *textColor = (inverted_) ? [NSColor whiteColor]:[NSColor blackColor];
    NSColor *backgroundColor = (inverted_) ? [NSColor blackColor] : [NSColor whiteColor];
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:text_ attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:18.0],NSForegroundColorAttributeName: textColor, NSBackgroundColorAttributeName: backgroundColor}];
//    NSLog(@"[attrString size]: %@", NSStringFromSize((NSSize)[attrString size]));
    
    CGFloat width = kMAZAppDelegateMinTextWidth;
    if ([attrString size].width >= kMAZAppDelegateMinTextWidth)
    {
        width = [attrString size].width;
    }
    
    NSTextField *tf = [[NSTextField alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, [attrString size].height)];
    [tf setTextColor:textColor];
    //    [tf setBezelStyle:NSTextFieldRoundedBezel];
    [tf setBackgroundColor:backgroundColor];
    [tf setAlignment:NSCenterTextAlignment];
    [tf setStringValue:text_];
    [tf setFocusRingType:NSFocusRingTypeNone];
    return [self imageOfView:tf];
    //    [_statusItemPopup setImage:[self writeImageForView:tf]];
}

+ (NSImage *)imageOfView:(NSView*)view
{
    NSBitmapImageRep* rep = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
    [view cacheDisplayInRect:view.bounds toBitmapImageRep:rep];
    
    NSData *data = [rep representationUsingType:NSPNGFileType properties: nil];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%dimage.png", abs(arc4random())]];
    
//    NSLog(@"filePath: %@", filePath);
    [data writeToFile:filePath atomically:YES];
    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    
    return image;
}
@end
