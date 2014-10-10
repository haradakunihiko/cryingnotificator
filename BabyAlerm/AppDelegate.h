//
//  AppDelegate.h
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
// 234504 4 29.8

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CryPickingController.h"


#import <MultipeerConnectivity/MultipeerConnectivity.h>

extern NSString *const kServiceType;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property  (strong, nonatomic) MCSession *session;
@property (strong,nonatomic) MCPeerID *peerId;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) saveBackground :(NSManagedObjectContext *) temporaryMOC;
- (void) mergeToMainMOC :(NSManagedObjectContext *) temporaryMOC;

-(void)truncateDatabase:(NSString *)configuration;

extern NSString *const PeerConnectionAcceptedNotification;
extern NSString *const CryingDetectedNotification;
extern NSString *const CryingDataDownloadedNotification;




@end
