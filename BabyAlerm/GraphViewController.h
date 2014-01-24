//
//  ListeningViewController.h
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryModel.h"
#import "VolumeModel.h"

@class CryPickingController;
@class GraphViewController;

@protocol GraphViewControllerDataSource <NSObject>
- (HistoryModel *)graphViewControllerDataSource;
@end

/**
 *  @brief Enumeration of labeling policies
 **/
typedef enum _BAGraphDisplayType {
    BAGraphDisplayTypeShowNothing,
    BAGraphDisplayTypeShowAllInView,
    BAGraphDisplayTypeShowRecentInViewAndAllInGlobal,
    BAGraphDisplayTypeShowAnyInViewAndAllInGlobal,
    BAGraphDisplayTypeShowRecentInViewAndGlobal
}
BAGraphDisplayType;

@interface GraphViewController : UIViewController

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
//@property(nonatomic,strong) HistoryModel *historyModel;

@property (nonatomic) BOOL showHistory;
@property (nonatomic,assign) id<GraphViewControllerDataSource> datasource;



@property (nonatomic,strong) HistoryModel *historyModel;
@property (nonatomic) BAGraphDisplayType displayType;

@property (nonatomic, copy) void (^completionBlock)();

-(void) updateView: (VolumeModel *)volume;
-(void) initializeWithDisplaytype : (BAGraphDisplayType) displayType;

-(void) redraw;

@end
