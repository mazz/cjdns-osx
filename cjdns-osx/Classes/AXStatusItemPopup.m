//
//  StatusItemPopup.m
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import "AXStatusItemPopup.h"

#define kMinViewWidth 22

//
// Private variables
//
@interface AXStatusItemPopup ()
{
    NSViewController *_viewController;
    BOOL _active;
    NSImageView *_imageView;
    NSStatusItem *_statusItem;
    NSMenu *_dummyMenu;
    id _popoverTransiencyMonitor;
    BOOL _wasDragging;
    NSPoint _dragStartPoint;
    NSUInteger _draggedEventCount; // resets to 0 on mousedown mouseup
}

@property(nonatomic, strong, readwrite) NSPopover* popover;

@end

///////////////////////////////////

//
// Implementation
//
@implementation AXStatusItemPopup

- (id)initWithViewController:(NSViewController *)controller
{
    return [self initWithViewController:controller image:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image
{
    return [self initWithViewController:controller image:image alternateImage:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage
{
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    self = [super initWithFrame:NSMakeRect(0, 0, image.size.width, height)];
    if (self) {
        _viewController = controller;
        
        self.image = image;
        self.alternateImage = alternateImage;
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, height)];
        [self addSubview:_imageView];
        
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.view = self;
        _dummyMenu = [[NSMenu alloc] init];
        
        _active = NO;
        _animated = YES;
        _wasDragging = NO;
        _oneShot = NO;
    }
    return self;
}


////////////////////////////////////
#pragma mark - Drawing
////////////////////////////////////

- (void)drawRect:(NSRect)dirtyRect
{
    // set view background color
    if (_active) {
        [[NSColor selectedMenuItemColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    NSRectFill(dirtyRect);
    
    // set image
    NSImage *image = (_active ? _alternateImage : _image);
    _imageView.image = image;
}

////////////////////////////////////
#pragma mark - Position / Size
////////////////////////////////////

- (void)setContentSize:(CGSize)size
{
    _popover.contentSize = size;
}

////////////////////////////////////
#pragma mark - Mouse Actions
////////////////////////////////////

- (void)mouseDown:(NSEvent *)theEvent
{
    _wasDragging = NO;
    _dragStartPoint = NSEvent.mouseLocation;
    [self mouseDeltaOccurred:theEvent];
    _draggedEventCount = 0;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    _draggedEventCount = 0;
    NSLog(@"0 oneshot: %d", _oneShot);
    if (_wasDragging)
    {
        [self mouseDeltaOccurred:theEvent];
        _wasDragging = NO;
        return;
    }
    else
    {
        [self mouseDeltaOccurred:theEvent];
//        return;
    }

    if (_popover.isShown)
    {
        [self hidePopover];
    }
    else if (!_popover.isShown && _oneShot)
    {
        NSLog(@"1 oneshot: %d", _oneShot);
        _oneShot = NO;
    }
    else if (!_popover.isShown)
    {
        [self showPopover];
    }
    NSLog(@"2 oneshot: %d", _oneShot);
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [self mouseUp:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    _wasDragging = YES;
    [self mouseDeltaOccurred:theEvent];
}

- (void)mouseDeltaOccurred:(NSEvent *)theMouseEvent
{
    double deltaX = [NSEvent mouseLocation].x-_dragStartPoint.x;
    double deltaY = [NSEvent mouseLocation].y-_dragStartPoint.y;
    double normalizedDeltaX = deltaX/[[NSScreen mainScreen] frame].size.width; // normalized delta-to-display width
    double normalizedDeltaY = deltaY/[[NSScreen mainScreen] frame].size.height; // normalized delta-to-display height
    
    NSDictionary *delta = @{@"deltaX":[NSNumber numberWithDouble:deltaX],
                            @"deltaY":[NSNumber numberWithDouble:deltaY],
                            @"normalizedDeltaX": [NSNumber numberWithDouble:normalizedDeltaX],
                            @"normalizedDeltaY": [NSNumber numberWithDouble:normalizedDeltaY],
                            @"relativeDeltaX": [NSNumber numberWithDouble:[theMouseEvent deltaX]]};
    
    if ([theMouseEvent type] == NSLeftMouseUp || [theMouseEvent type] == NSRightMouseUp)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusItemMouseUpNotification" object:nil userInfo:delta];
        NSLog(@"mouseup deltaX: %f, deltaY: %f", deltaX, deltaY);
    }
    else if ([theMouseEvent type] == NSLeftMouseDragged || [theMouseEvent type] == NSRightMouseDragged)
    {
        _draggedEventCount++;
        [self _postNotificationDictionary:delta forNormalizedDeltaY:normalizedDeltaY];
    }
    else if ([theMouseEvent type] == NSLeftMouseDown || [theMouseEvent type] == NSRightMouseDown)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusItemMouseDownNotification" object:nil userInfo:@{@"startPointX": [NSNumber numberWithDouble:_dragStartPoint.x],
                                                                                                                             @"startPointY": [NSNumber numberWithDouble:_dragStartPoint.y]
                                                                                                                             }];
    }
}

- (void)_postNotificationDictionary:(NSDictionary*)note_ forNormalizedDeltaY:(double)normalizedDeltaY_
{
    BOOL doPost = NO;
    if (normalizedDeltaY_ >=-0.1)
    {
        doPost = YES;
    }
    else if (normalizedDeltaY_ >=-0.2 && normalizedDeltaY_ <=-0.1 && _draggedEventCount%2 == 0)
    {
        doPost = YES;
    }
    else if (normalizedDeltaY_ >=-0.3 && normalizedDeltaY_ <=-0.2 && _draggedEventCount%3 == 0)
    {
        doPost = YES;
    }
    else if (normalizedDeltaY_ >=-0.4 && normalizedDeltaY_ <=-0.3 && _draggedEventCount%5 == 0)
    {
        doPost = YES;
    }
    else if (normalizedDeltaY_ >=-0.5 && normalizedDeltaY_ <=-0.4 && _draggedEventCount%8 == 0)
    {
        doPost = YES;
    }
    else if (normalizedDeltaY_ >=-1.0 && normalizedDeltaY_ <=-0.5 && _draggedEventCount%13 == 0)
    {
        doPost = YES;
    }
    
    if (doPost)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kStatusItemMouseDraggedDeltaNotification" object:nil userInfo:note_];
    }
}

////////////////////////////////////
#pragma mark - Setter
////////////////////////////////////

- (void)setActive:(BOOL)active
{
    _active = active;
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)image
{
    _image = image;
    [self updateViewFrame];
}

- (void)setAlternateImage:(NSImage *)image
{
    _alternateImage = image;
    if (!image && _image) {
        _alternateImage = _image;
    }
    [self updateViewFrame];
}

////////////////////////////////////
#pragma mark - Helper
////////////////////////////////////

- (void)updateViewFrame
{
    CGFloat width = MAX(MAX(self.image.size.width, self.alternateImage.size.width), self.image.size.width);
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    NSRect frame = NSMakeRect(0, 0, width, height);
    self.frame = frame;
    _imageView.frame = frame;
    
    [self setNeedsDisplay:YES];
}


////////////////////////////////////
#pragma mark - Show / Hide Popover
////////////////////////////////////

- (void)showPopover
{
    [self showPopoverAnimated:_animated];
}

- (void)showPopoverAnimated:(BOOL)animated
{
    self.active = YES;
    
    if (!_popover) {
        _popover = [[NSPopover alloc] init];
        _popover.contentViewController = _viewController;
    }
    
    if (!_popover.isShown) {
        _popover.animates = animated;
        [self.statusItem popUpStatusItemMenu:_dummyMenu];
        [_popover showRelativeToRect:self.frame ofView:self preferredEdge:NSMinYEdge];
        _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask handler:^(NSEvent* event) {
            [self hidePopover];
        }];
    }
}

- (void)hidePopover
{
    self.active = NO;
    
    if (_popover && _popover.isShown) {
        [_popover close];

		if (_popoverTransiencyMonitor) {
            [NSEvent removeMonitor:_popoverTransiencyMonitor];
            _popoverTransiencyMonitor = nil;
        }
    }
}

@end

