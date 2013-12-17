//
//  CryPickingController.h
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Volume.h"
#import "HistoryModel.h"

@class CryPickingController;

@protocol BLCryPickingDelegate <NSObject>
// Notifies the delegate, when the user taps the done button
- (void)cryPickingController:(CryPickingController *)cryPickingController notify:(BOOL )notify;
@end

@protocol BLCryPickingShowDelegate <NSObject>

-(void)cryPickingController:(CryPickingController *)cryPickingController volume:(Volume * )volume;

@end

@interface CryPickingController : NSObject

-(void)startListening;
-(void)stopListening;
-(void) notify;

@property  (nonatomic, assign) id<BLCryPickingDelegate> delegate;
@property (nonatomic,assign)id<BLCryPickingShowDelegate> showDelegate;
@property (nonatomic) float maxAverage;
@property (nonatomic) float maxPeak;
@property (nonatomic) int maxTimes;
@property (nonatomic) AudioQueueRef queue;

@property(nonatomic,strong) HistoryModel *historyModel;

@end
