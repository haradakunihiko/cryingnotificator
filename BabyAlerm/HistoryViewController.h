//
//  HistoryViewController.h
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphViewController.h"
#import "ConvinedViewController.h"

@interface HistoryViewController : UITableViewController

@property(nonatomic,strong) GraphViewController *graphViewController;
@property(nonatomic,strong) ConvinedViewController *convinedViewController;

-(void) refreshTable;
-(void) reloadData;
-(NSInteger) numberOfHistory;

-(void) showExecutingCell;
-(void) hideExecutingCell;

@end
