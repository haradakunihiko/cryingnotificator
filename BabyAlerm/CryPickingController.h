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

@interface CryPickingController : NSObject

-(void)startListening;
-(void) notify;

@property  (nonatomic, assign) id<BLCryPickingDelegate> delegate;

@end
