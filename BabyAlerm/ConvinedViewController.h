//
//  ConvinedViewController.h
//  BabyAlerm
//
//  Created by harada on 2014/01/22.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HistoryModel;

@interface ConvinedViewController : UIViewController

@property (nonatomic) BOOL executing;
@property (readonly) HistoryModel *ongoingHistoryModel;

-(void) switchGraphView :(BOOL) showHistory;



@end
