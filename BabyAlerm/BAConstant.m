//
//  BAConstant.m
//  BabyAlerm
//
//  Created by harada on 2013/12/09.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "BAConstant.h"

@implementation BAConstant
NSString * const TickerSymbolPeak = @"PEAK";
NSString * const TickerSymbolAverage = @"AVERAGE";

float const DisplayXRange = 60.0f;
float const DisplayXRightMergin = 10.0f;
//float const GlobalRange = 60.0f * 60 * 10;
float const GlobalXRange = 60.0f * 60 * 24;

float const DisplayYLocation = -70.0f;
float const DisplayYRange = 90.0f;
@end
