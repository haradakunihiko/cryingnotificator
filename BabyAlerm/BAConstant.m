//
//  BAConstant.m
//  BabyAlerm
//
//  Created by harada on 2013/12/09.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "BAConstant.h"

@implementation BAConstant


NSString * const CONFIGURATION_OTHER = @"Other";
NSString * const CONFIGURATION_HISTORY  = @"History";

NSString * const TickerSymbolPeak = @"PEAK";
NSString * const TickerSymbolAverage = @"AVERAGE";
NSString * const TickerSymbolThreashold = @"THREASHOLD";

float const DisplayXRange = 76.0f;
float const DisplayXRightMergin = 8.0f;
float const DisplayXLeftMergin = 8.0f;

float const PlotXRange = DisplayXRange - DisplayXLeftMergin - DisplayXRightMergin;

//float const GlobalRange = 60.0f * 60 * 10;
float const GlobalXRange = 60.0f * 60 * 24;

float const DisplayYLocation = -70.0f;
float const DisplayYRange = 90.0f;

int const PlotClusterCount = 30;

NSString  * const SettingKeyThreshold = @"Threshold";

NSString * const ASES_ACCESS_KEY = @"AKIAJN6FRH24YQCCXWOA";
NSString * const ASES_SECRET_KEY = @"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";


NSString * const FROM_ADDRESS = @"cryingnotificationnoreply@ses.tzap.asia";
//NSString * const FROM_ADDRESS = @"sthsoulful@gmail.com";

@end
