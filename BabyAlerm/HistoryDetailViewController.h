//
//  HistoryDetailViewController.h
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryModel.h"

@interface HistoryDetailViewController : UITableViewController

@property (nonatomic) NSInteger historyIndex;
@property (nonatomic) HistoryModel *historyModel;

@end
