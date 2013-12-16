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


NSString *const kServiceType = @"tz-babyalerm";
NSString *const RelationDataSavingCompleteNotifiction = @"tz.babyalerm:RelationDataSavingCompleteNotifiction";
NSString *const RelationDataSavingStartNotifiction = @"tz.babyalerm:RelationDataSavingStartNotifiction";

@interface AppDelegate()<MCSessionDelegate>

@property (nonatomic,strong) MCAdvertiserAssistant *advertiserAssistant;
@property (nonatomic,strong) NSData *deviceToken;
@property (nonatomic,strong,readwrite) NSString *installationId;


@end

@implementation AppDelegate

-(NSString *)installationId{
    if(!_installationId){
        PFInstallation *currentInstallation =[PFInstallation currentInstallation];
        
        NSMutableString *channel = [NSMutableString stringWithString:@""];
        [channel appendString:[[currentInstallation.installationId stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]stringByReplacingOccurrencesOfString:@" " withString:@""]];
        _installationId = [channel description];
    }
    return _installationId;
}


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
    
    NSString *peerName = [[UIDevice currentDevice]name];
    self.peerId = [[MCPeerID alloc]initWithDisplayName:peerName];
    self.session = [[MCSession alloc]initWithPeer:self.peerId securityIdentity:nil encryptionPreference:MCEncryptionNone];
    self.session.delegate = self;
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:kServiceType discoveryInfo:@{@"displayName":[[UIDevice currentDevice] name],@"installationId":self.installationId} session:self.session];
    [self.advertiserAssistant start];
    self.peerDiscoveryInfo = [NSMutableDictionary new];
    self.contacts = [NSMutableArray new];
    self.histData = [NSMutableArray new];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    self.deviceToken = deviceToken;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation setObject:[[UIDevice currentDevice] name] forKey:@"deviceName"];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    [PFPush handlePush:userInfo];
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [PFPush handlePush:userInfo];
    if(application.applicationState == UIApplicationStateInactive){
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
//    id unarchived  =[NSKeyedUnarchiver unarchiveObjectWithData:data];
//    if ([unarchived isKindOfClass:[Device class]]) {
//        // 登録を行っていますの画面を出す。
//        
//        Device *device = (Device *)unarchived;
//        NSLog(@" received  id : %@, name: %@",[device installationIdentifier],[device deviceName]);
//        
//        PFQuery *query = [PFQuery queryWithClassName:@"Relation"];
//        [query whereKey:@"senderId" equalTo:device.installationIdentifier];
//        [query whereKey:@"receiverId" equalTo:self.installationId];
//        
//        if([query countObjects] == 0){
//            PFObject *obj = [[PFObject alloc]initWithClassName:@"Relation"];
//            obj[@"senderId"] = device.installationIdentifier;
//            obj[@"senderDeviceName"] =device.deviceName;
//            obj[@"receiverId"] = self.installationId;
//            obj[@"receiverDeviceName"] = [[UIDevice currentDevice]name];
//            [obj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                // localnotificationで、完了を表示。receiverに受け取りを伝える。
//            }];
//        }
//    }else if([unarchived isKindOfClass:[Result class]]){
//        Result *result = (Result *)unarchived;
//        if(result.result){
//            
//        }else{
//            
//        }
//    }else{
//        
//    }
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}
-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    if(state == MCSessionStateConnected){
        NSLog(@" state connected %@",peerID.displayName);
    }else if(state == MCSessionStateConnecting){
        NSLog(@" state connecting %@",peerID.displayName);
    }else if(state == MCSessionStateNotConnected){
        NSLog(@" state not connected %@",peerID.displayName);
    }else{
        NSLog(@" state else");
    }
    
    
}
-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

-(BOOL)sendDeviceTokenToPeer{
    NSLog(@"try to regsiter");
    NSMutableArray *pfObjectArray = [NSMutableArray new];
    [self.session.connectedPeers enumerateObjectsUsingBlock:^(MCPeerID* peerID, NSUInteger idx, BOOL *stop) {
        NSDictionary *discoveryInfo = self.peerDiscoveryInfo[peerID];
        NSLog(@"saving relation data. sender id:%@ name:%@ / receiver id:%@ name:%@",self.installationId,[[UIDevice currentDevice]name],discoveryInfo[@"installationId"],discoveryInfo[@"displayName"]);
        
        PFQuery *query = [PFQuery queryWithClassName:@"Relation"];
        [query whereKey:@"senderId" equalTo:self.installationId];
        [query whereKey:@"receiverId" equalTo:discoveryInfo[@"installationId"]];
        
        if([query countObjects] == 0){
            PFObject *obj = [[PFObject alloc]initWithClassName:@"Relation"];
            obj[@"senderId"] = self.installationId;
            obj[@"senderDeviceName"] =[[UIDevice currentDevice]name];
            obj[@"receiverId"] = discoveryInfo[@"installationId"];
            obj[@"receiverDeviceName"] = discoveryInfo[@"displayName"];
            [pfObjectArray addObject:obj];
        }

    }];
    // 画面にロード中を表示する。
    //　アプリを消されたときに、ゴミデータが残る。どれかゴミかを検知したい。
    
    [PFObject saveAllInBackground:pfObjectArray block:^(BOOL succeeded, NSError *error) {
        if(!error){
            //Local Notificationで完了通知。テーブルを再描画！
            [[NSNotificationCenter defaultCenter]postNotificationName:RelationDataSavingCompleteNotifiction object:nil userInfo:@{@"peers":pfObjectArray}];
            NSLog(@"save data completed ");
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
    
    return YES;
//    if([self.session.connectedPeers count] > 0){
//        NSError *error;
//        Device *device = [[Device alloc]init];
//        device.deviceName = [[UIDevice currentDevice] name];
//        device.installationIdentifier = self.installationId;
//        
//        NSData *data =[NSKeyedArchiver archivedDataWithRootObject:device];
//        
//        [self.session sendData:data toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
//        return YES;
//    }else{
//        return NO;
//    }
}

- (void)cryPickingController:(CryPickingController *)cryPickingController notify:(BOOL)notify{
    if(notify){
        NSLog(@" push to channel:%@",self.installationId);
        PFQuery *query = [PFQuery queryWithClassName:@"Relation"];
        [query whereKey:@"senderId" equalTo:self.installationId];
        NSMutableArray *array = [NSMutableArray new];
        NSArray *objects = [query findObjects];
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [array addObject:obj[@"receiverId"]];

        }];
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"installationId" containedIn:array];
        
        PFPush *push = [[PFPush alloc]init];
        [push setQuery:pushQuery];
//        [push setMessage:@"crying"];
        [push setData:[NSDictionary dictionaryWithObjectsAndKeys:
                      @"Baby is crying", @"alert",
                      @"default", @"sound",
                       nil]];
        [push sendPushInBackground];
    }
}

@end
