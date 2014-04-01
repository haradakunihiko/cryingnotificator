//
//  CryPickingController.h
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "HistoryModel.h"
#import "GraphViewController.h"
@class CryPickingController;

@interface CryPickingController : NSObject<GraphViewControllerDataSource>

-(void)startListening;
-(void)stopListening;

@property (nonatomic) int maxTimes;
@property (nonatomic) AudioQueueRef queue;

@property(nonatomic,strong) HistoryModel *historyModel;

//@property (nonatomic,strong) HistoryModel *history;
//@property (nonatomic,strong )GraphViewController *graphViewController;
//@property  (nonatomic,strong) GraphViewController *graphViewController;

@property (nonatomic,strong)GraphViewController *graphVC;

@end
