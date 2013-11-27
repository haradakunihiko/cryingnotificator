//
//  AppDelegate.m
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>


NSString *const kServiceType = @"tz-babyalerm";
NSString *const DataReceivedNotifiction = @"tz.babyalerm:DataReceivedNotification";

@interface AppDelegate()<MCSessionDelegate>

@property (nonatomic,strong) MCAdvertiserAssistant *advertiserAssistant;
@property (nonatomic,strong) NSData *deviceToken;
@property (nonatomic,strong) NSString *installationId;

@end

@implementation AppDelegate

-(NSString *)installationId{
    if(!_installationId){
        PFInstallation *currentInstallation =[PFInstallation currentInstallation];
        _installationId =[[currentInstallation.installationId stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]]stringByReplacingOccurrencesOfString:@" " withString:@""];
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
    self.advertiserAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:kServiceType discoveryInfo:nil session:self.session];
    [self.advertiserAssistant start];
    
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
    NSString *targetInstallationId =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableString *channel = [NSMutableString stringWithString:@"BC_"];
    [channel appendString:targetInstallationId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:[channel description] forKey:@"channels"];
    [currentInstallation saveInBackground];
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}
-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    
}
-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}

-(BOOL)sendDeviceTokenToPeer{
    NSLog(@"try to send installation id to peer");
    if([self.session.connectedPeers count] > 0){
        NSError *error;
        NSLog(@" found %d" , [self.session.connectedPeers count]);
        NSLog(@"send installationid:  %@",self.installationId);
        
        [self.session sendData:[self.installationId dataUsingEncoding:NSUTF8StringEncoding ]  toPeers:self.session.connectedPeers withMode:MCSessionSendDataReliable error:&error];
        return YES;
    }else{
        return NO;
    }
}

- (void)cryPickingController:(CryPickingController *)cryPickingController notify:(BOOL)notify{
    if(notify){
        PFPush *push = [[PFPush alloc]init];
        NSMutableString *channel = [NSMutableString stringWithString:@"BC_"];
        [channel appendString:self.installationId];
        NSLog(@" push to channel:%@",[channel description]);
        [push setChannel:[ channel  description]];
        [push setMessage:@"crying"];
        [push sendPushInBackground];
    }
}

@end
