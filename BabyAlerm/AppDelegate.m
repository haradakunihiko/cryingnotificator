//
//  AppDelegate.m
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "Device.h"
#import "Result.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "HistoryModel.h"
#import "VolumeModel.h"


NSString *const kServiceType = @"tz-babyalerm";
NSString *const RelationDataSavingCompleteNotifiction = @"tz.babyalerm:RelationDataSavingCompleteNotifiction";
NSString *const RelationDataSavingStartNotifiction = @"tz.babyalerm:RelationDataSavingStartNotifiction";

@interface AppDelegate()

@end

@implementation AppDelegate


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"UI2h2OGPsIMVTCW5aFFbijTVz5mXwcX9EMXv0Epg" clientKey:@"owF17Q7RBKMqX2WodUFDSwiYI0ZSTRrfNJSa3YHa"];
    
    if(!application.applicationState != UIApplicationStateBackground){
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if(preBackgroundPush || oldPushHandlerOnly || noPushPayload){
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSDictionary *settingDefaultDictionary = @{SettingKeyThreshold: @-10};
    
    [defaults registerDefaults:settingDefaultDictionary];
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    static NSArray *CONFIGURATIONS;
    if(CONFIGURATIONS == nil){
        CONFIGURATIONS = @[CONFIGURATION_HISTORY,CONFIGURATION_OTHER];
    }
    
    [CONFIGURATIONS enumerateObjectsUsingBlock:^(NSString *configuration, NSUInteger idx, BOOL *stop) {
        

        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent: [NSString stringWithFormat:@"%@.sqlite", configuration]];
        
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:nil error:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }];
    

    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void) truncateDatabase : (NSString *) configuration{
    
    
    NSURL *storeURL =[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",configuration]];
    NSPersistentStore
     * store = [self.persistentStoreCoordinator persistentStoreForURL:storeURL];
    
    [self.persistentStoreCoordinator removePersistentStore:store error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
    
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:nil error:nil];
}

@end
