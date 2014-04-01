//
//  BAConstant.h
//  BabyAlerm
//
//  Created by harada on 2013/12/09.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BAConstant : NSObject

extern NSString * const CONFIGURATION_OTHER;
extern NSString * const CONFIGURATION_HISTORY;


extern NSString * const TickerSymbolPeak;
extern NSString * const TickerSymbolAverage;
extern NSString * const TickerSymbolThreashold;


extern float const DisplayXRange;
extern float const DisplayXRightMergin;
extern float const DisplayXLeftMergin;
extern float const PlotXRange;

extern float const GlobalXRange;

extern float const DisplayYLocation;
extern float const DisplayYRange;

extern int const PlotClusterCount;

#pragma mark - user default key.
extern NSString * const SettingKeyThreshold;
extern NSString * const SettingKeyUUID;
extern NSString * const SettingKeyDetectionInterval;




#pragma mark - peer to peer connection, discoveryInfo Key;
extern NSString * const DiscoveryKeyAdvertiserInstallationId;
extern NSString * const DiscoveryKeyAdvertiserUUID;
extern NSString * const DiscoveryKeyDisplayName;


extern NSString * const ASES_ACCESS_KEY;
extern NSString * const ASES_SECRET_KEY;

extern NSString * const FROM_ADDRESS;


@end
