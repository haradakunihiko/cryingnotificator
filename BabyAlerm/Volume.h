//
//  Volume.h
//  BabyAlerm
//
//  Created by harada on 2013/12/09.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Volume : NSObject

@property (nonatomic) float peak;
@property (nonatomic) float average;
@property (nonatomic) NSDate *time;

@end
