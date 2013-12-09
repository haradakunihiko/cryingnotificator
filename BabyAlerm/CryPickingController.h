//
//  CryPickingController.h
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class CryPickingController;

@protocol BLCryPickingDelegate <NSObject>
// Notifies the delegate, when the user taps the done button
- (void)cryPickingController:(CryPickingController *)cryPickingController notify:(BOOL )notify;
@end

@protocol BLCryPickingShowDelegate <NSObject>

-(void)cryPickingController:(CryPickingController *)cryPickingController meterState:(AudioQueueLevelMeterState )meterState;
@end

@interface CryPickingController : NSObject

-(void)startListening;
-(void) notify;

@property  (nonatomic, assign) id<BLCryPickingDelegate> delegate;
@property (nonatomic,assign)id<BLCryPickingShowDelegate> showDelegate;
@property (nonatomic) float maxAverage;
@property (nonatomic) float maxPeak;
@property (nonatomic) int maxTimes;
@property (nonatomic) AudioQueueRef queue;

@end
