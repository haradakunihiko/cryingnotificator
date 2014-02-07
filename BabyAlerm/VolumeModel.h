//
//  VolumeModel.h
//  BabyAlerm
//
//  Created by harada on 2014/01/28.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HistoryModel;

@interface VolumeModel : NSManagedObject

@property (nonatomic, retain) NSNumber * average;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) NSNumber * isOverThreashold;
@property (nonatomic, retain) NSNumber * peak;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) HistoryModel *history;

@property (nonatomic) long count;

@end
