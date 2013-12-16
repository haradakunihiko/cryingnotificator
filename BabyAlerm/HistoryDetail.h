//
//  HistoryDetail.h
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Volume.h"

@interface HistoryDetail : NSObject
@property (nonatomic,strong) Volume *volume;
@property (nonatomic,strong) NSArray *volumeHist;
@end
