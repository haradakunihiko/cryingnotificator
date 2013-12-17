//
//  VolumeModel.h
//  BabyAlerm
//
//  Created by harada on 2013/12/16.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HistoryModel;

@interface VolumeModel : NSManagedObject

@property (nonatomic, retain) NSNumber * peak;
@property (nonatomic, retain) NSNumber * average;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSNumber * isOverThreashold;
@property (nonatomic, retain) HistoryModel *history;

@end
