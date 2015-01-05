//
//  CJDPopupContentViewController.m
//  Nome
//
//  Created by maz on 2014-11-15.
//  Copyright (c) 2014 maz. All rights reserved.
//

#import "CJDPopupContentViewController.h"
//#import "MAZMetronome.h"
//#import "MAZAppDelegate.h"

@interface CJDPopupContentViewController () <NSTableViewDelegate,NSTableViewDataSource>
//@property (weak) IBOutlet NSTableView *tableView;
- (IBAction)showUtility:(id)sender;
//- (IBAction)columnChangeSelected:(id)sender;
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

//- (IBAction)columnChangeSelected:(id)sender
//{
//    NSInteger selectedRow = [self.tableView selectedRow];
//    
//    if (selectedRow != -1)
//    {
////        NSInteger bpm = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"recents"] objectAtIndex:selectedRow] integerValue];
////        [[MAZMetronome sharedInstance] startWithBpm:bpm];
//        [self.statusItemPopup hidePopover];
////        [self.statusItemPopup setImage:[(MAZAppDelegate*)[NSApp delegate] stringImageWithText:[NSString stringWithFormat:@"%ld", bpm] inverted:YES]];
//    }
//    else {
//        // No row was selected
//    }
//}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:nil];
}
@end
