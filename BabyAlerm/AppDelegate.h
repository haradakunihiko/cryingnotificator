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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)truncateDatabase:(NSString *)configuration;
@end
