//
//  AppDelegate.h
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CryPickingController.h"

extern NSString *const kServiceType;
extern NSString *const DataReceivedNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate,BLCryPickingDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong,nonatomic)MCSession *session;
@property (strong,nonatomic)MCPeerID *peerId;

-(BOOL) sendDeviceTokenToPeer;

@end
