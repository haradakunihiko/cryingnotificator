//
//  HitoryGraphViewController.h
//  BabyAlerm
//
//  Created by harada on 2014/01/20.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphViewController.h"

@class HistoryModel;

@interface HistoryGraphViewController : UIViewController<GraphViewControllerDataSource>

@property (nonatomic,strong) GraphViewController *graphViewController;
@property (nonatomic,strong) HistoryModel *historyModel;


@end
