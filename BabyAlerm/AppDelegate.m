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


NSString *const kServiceType = @"tz-cryingNotif";
NSString *const RelationDataSavingCompleteNotifiction = @"tz.babyalerm:RelationDataSavingCompleteNotifiction";
NSString *const RelationDataSavingStartNotifiction = @"tz.babyalerm:RelationDataSavingStartNotifiction";
NSString *const PeerConnectionAcceptedNotification = @"asia.tzap.apps.BabyAlerm:PeerConnectionAcceptedNotification";
NSString *const CryingDetectedNotification = @"asia.tzap.apps.BabyAlerm:CryingDetectedNotification";
NSString *const CryingDataDownloadedNotification = @"asia.tzap.apps.BabyAlerm:CryingDataDownloadedNotification";

@interface AppDelegate()<MCSessionDelegate>{
    NSMutableDictionary *_discoveryInfos;
}

@property (strong,nonatomic) MCAdvertiserAssistant *advertiserAssistant;

@end

@implementation AppDelegate{
    
}



@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLauchingWithOptions:launchOptions:%@",[launchOptions description]);
    _discoveryInfos = [NSMutableDictionary new];
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"UI2h2OGPsIMVTCW5aFFbijTVz5mXwcX9EMXv0Epg" clientKey:@"owF17Q7RBKMqX2WodUFDSwiYI0ZSTRrfNJSa3YHa"];
    
    if(application.applicationState != UIApplicationStateBackground){
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if(preBackgroundPush || oldPushHandlerOnly || noPushPayload){
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSDictionary *settingDefaultDictionary = @{SettingKeyThreshold: @-10,SettingKeyUUID:[[NSUUID UUID] UUIDString],SettingKeyDetectionInterval:@10};
    
    [defaults registerDefaults:settingDefaultDictionary];
    self.peerId = [[MCPeerID alloc]initWithDisplayName:[[UIDevice currentDevice]name]];
    self.session = [[MCSession alloc]initWithPeer:self.peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    
    // 初回はまだDBに無い可能性もあるが、installationIdさえ分かれば良いのでここで取得する。
    NSString *installationId =[PFInstallation currentInstallation].installationId;
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:kServiceType discoveryInfo:@{DiscoveryKeyAdvertiserInstallationId: installationId,DiscoveryKeyAdvertiserUUID:[defaults stringForKey:SettingKeyUUID]} session:self.session];
    [self.advertiserAssistant start];
    
    [self loadUndownloadedDataInBackground:installationId];
    return YES;
}


-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    NSLog(@"willFinishLaunchingWithOptions:launchOptions:%@",[launchOptions description]);
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

#pragma mark - Core Data help methods
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


-(void) truncateDatabase : (NSString *) configuration{
    
    
    NSURL *storeURL =[[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",configuration]];
    NSPersistentStore
    * store = [self.persistentStoreCoordinator persistentStoreForURL:storeURL];
    
    [self.persistentStoreCoordinator removePersistentStore:store error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
    
    [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:configuration URL:storeURL options:nil error:nil];
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

#pragma mark - Remote Notification
-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    PFInstallation *installation = [PFInstallation currentInstallation];
    NSLog(@"installation id:%@",installation.installationId);
    [installation setDeviceTokenFromData:deviceToken];
    [installation saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"didReceive:userInfo:%@",[userInfo description]);
//    [PFPush handlePush:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"didReceive:userInfo:%@,fetch:",[userInfo description]);
    NSString *objectId = userInfo[@"objectId"];
    if(objectId != nil){
        [self downloadCryingData:objectId];
        completionHandler(UIBackgroundFetchResultNewData);
    }else{
        completionHandler(UIBackgroundFetchResultNoData);
    }

}

-(void) downloadCryingData:(NSString *)objectId{
    PFObject *object = [PFObject objectWithoutDataWithClassName:@"CryingData" objectId:objectId];
    [object fetch];
    
    [self decodeDownloadedData:object];
}

-(HistoryModel *)fetchHistoryModelWithStartTime:(NSDate *) startTime{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"HistoryModel" inManagedObjectContext:context];
    [fetch setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime = %@ ",startTime];
    [fetch setPredicate:predicate];
    
    NSArray *results = [context executeFetchRequest:fetch error:nil];
    return results.firstObject;
}

-(void)decodeDownloadedData:(PFObject *) object{
    PFFile *file = object[@"data"];
    NSData *data = [file getData];
    
    NSDictionary *dataDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSArray *volumeArray = dataDictionary[@"volume"];
    NSString *deviceName = dataDictionary[@"deviceName"];
    NSDate *startTime = dataDictionary[@"startTime"];
    NSDate *cryTime = dataDictionary[@"cryTime"];
    NSNumber *cryTimes = dataDictionary[@"cryTimes"];
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    HistoryModel *historyModel = [self fetchHistoryModelWithStartTime:startTime];
    if(historyModel != nil){
        [historyModel.volumes enumerateObjectsUsingBlock:^(VolumeModel *volume, NSUInteger idx, BOOL *stop) {
            [context deleteObject:volume];
        }];
//
//        
//
        historyModel.lastCryTime = cryTime;
        historyModel.cryTimes = cryTimes;
        historyModel.isViewed = NO;
    }else{
//    }
        historyModel = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryModel" inManagedObjectContext:context];
        historyModel.isSelfData = NO;
        historyModel.deviceName = deviceName;
        historyModel.startTime = startTime;
        historyModel.lastCryTime = cryTime;
        historyModel.cryTimes = cryTimes;
        historyModel.type = @2;
    }
    
    [volumeArray enumerateObjectsUsingBlock:^(NSDictionary *volumeData, NSUInteger idx, BOOL *stop) {
        
        VolumeModel *volumeModel = [NSEntityDescription insertNewObjectForEntityForName:@"VolumeModel" inManagedObjectContext:context];
        [volumeData enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSObject *obj, BOOL *stop) {
            [volumeModel setValue:obj forKey:key];
        }];
        volumeModel.history = historyModel;

        if(idx == [volumeArray count] -1){
            historyModel.endTime = volumeModel.time;
        }
    }];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }else{
        // finally
        [object deleteInBackground];
//        [[NSNotificationCenter defaultCenter] postNotificationName:CryingDataDownloadedNotification object:nil userInfo:nil];
    }
}



#pragma mark - peer to peer session
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    switch (state) {
        case MCSessionStateConnected:
            [[NSNotificationCenter defaultCenter] postNotificationName:PeerConnectionAcceptedNotification object:nil userInfo:@{@"peer":peerID,@"accept":@YES}];
            break;
        case MCSessionStateConnecting:
            break;
        case MCSessionStateNotConnected:
            if(![session.connectedPeers containsObject:peerID]){
                [[NSNotificationCenter defaultCenter] postNotificationName:PeerConnectionAcceptedNotification object:nil userInfo:@{@"peer":peerID,@"accept":@NO}];
            }
            break;
        default:
            break;
    }
    
//    NSLog(@"session didChangeState peerID:%@, state:%ld",peerID,state);
}

-(void) loadUndownloadedDataInBackground :(NSString *)installationId{

    PFQuery *undownloadedQuery = [PFQuery queryWithClassName:@"CryingData"];
    
    [undownloadedQuery whereKey:@"sendToDeviceInstallationId" equalTo:installationId];
    [undownloadedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
            [self decodeDownloadedData:obj];
        }];
    }];
}

@end
