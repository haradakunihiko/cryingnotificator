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
extern NSString *const RelationDataSavingCompleteNotifiction;
extern NSString *const RelationDataSavingStartNotifiction;

@interface AppDelegate : UIResponder <UIApplicationDelegate,BLCryPickingDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong,nonatomic)MCSession *session;
@property (strong,nonatomic)MCPeerID *peerId;

@property (nonatomic,strong,readonly) NSString *installationId;

@property (nonatomic,strong) NSMutableDictionary *peerDiscoveryInfo;

@property (nonatomic,strong) NSMutableArray *contacts;
@property (nonatomic,strong) NSMutableArray *histData;


-(BOOL) sendDeviceTokenToPeer;

@end
