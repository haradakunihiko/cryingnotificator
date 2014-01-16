//
//  ListeningViewController.h
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CryPickingController.h"
#import "HistoryModel.h"

/**
 *  @brief Enumeration of labeling policies
 **/
typedef enum _BAGraphDisplayType {
    BAGraphDisplayTypeShowAllInView,
    BAGraphDisplayTypeShowRecentInViewAndAllInGlobal,
    BAGraphDisplayTypeShowAnyInViewAndAllInGlobal,
    BAGraphDisplayTypeShowRecentInViewAndGlobal
}
BAGraphDisplayType;

@interface ListeningViewController : UIViewController{
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
//@property(nonatomic,strong) HistoryModel *historyModel;

@property (nonatomic) BOOL showHistory;
@property (nonatomic,strong) HistoryModel *historyModel;
@property (nonatomic) BAGraphDisplayType displayType;

@property (nonatomic, copy) void (^completionBlock)();


-(void)setCryingVCDelegate :(id<BLCryPickingDelegate>) delegate;
@end
