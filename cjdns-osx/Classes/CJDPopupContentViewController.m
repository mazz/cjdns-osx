//
//  CJDPopupContentViewController.m
//  Nome
//
//  Created by maz on 2014-11-15.
//  Copyright (c) 2014 maz. All rights reserved.
//

#import "CJDPopupContentViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "VOKBenkode.h"

@interface CJDPopupContentViewController () <NSTableViewDelegate,NSTableViewDataSource>
- (IBAction)showUtility:(id)sender;
- (IBAction)quit:(id)sender;
@end

@implementation CJDPopupContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSFont *)rowFont
{
    return [NSFont systemFontOfSize:30.0];
}

- (IBAction)showUtility:(id)sender
{
    NSLog(@"show util");
}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:nil];
}

@end
