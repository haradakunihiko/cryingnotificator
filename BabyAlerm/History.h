//
//  History.h
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryDetail.h"

@interface History : NSObject
@property (nonatomic,strong) NSDate *startTime;
@property (nonatomic,strong) NSMutableArray *historyDetails;

-(void) addObject : (HistoryDetail *)detail;
-(NSInteger) count;
-(HistoryDetail *)objectAtIndex :(NSInteger) index;

@end
