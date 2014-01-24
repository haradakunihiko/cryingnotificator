//
//  CryPickingController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "AppDelegate.h"
#import "CryPickingController.h"
#import <Parse/Parse.h>
#import "HistoryModel.h"
#import "VolumeModel.h"
#import "GraphViewController.h"
#import "NotificateTargetModel.h"

@interface CryPickingController()

-(void)preparePicking;

@end

@implementation CryPickingController{
    BOOL _checkingInProgress;
    NSInteger _times;
    NSTimer *timer;
    BOOL notifying;
    
}
static void AudioInputCallback(  void* inUserData,
                               AudioQueueRef inAQ,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumberPacketDescriptions,
                               const AudioStreamPacketDescription *inPacketDescs){
    
}

-(id)init{
    if(self = [super init]){
        [self preparePicking];
        self.maxTimes = 1;
        
    }
    return self;
}

-(void)preparePicking{
    AudioStreamBasicDescription description;
    description.mSampleRate = 44100.0f;
    description.mFormatID = kAudioFormatLinearPCM;
    description.mFormatFlags = kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    description.mBytesPerPacket = 2;
    description.mFramesPerPacket = 1;
    description.mBytesPerFrame = 2;
    description.mChannelsPerFrame = 1;
    description.mBitsPerChannel = 16;
    description.mReserved = 0;
    
    
    AudioQueueNewInput(&description, AudioInputCallback, (__bridge void *)(self), CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &_queue);
    AudioQueueStart(_queue, NULL);
    UInt32 enabledLevelMeter = true;
    AudioQueueSetProperty(_queue,kAudioQueueProperty_EnableLevelMetering,&enabledLevelMeter,sizeof(UInt32));
    
    _times = 0;
}

-(void) startListening {
    //231928 0 12.0
    //232328 2 14.9
    //232528 2 15.0
    //234028 3 15.5
    //234828 4 15.6
    if(timer){
        [timer invalidate];
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.historyModel = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryModel" inManagedObjectContext:context];
    self.historyModel.startTime = [NSDate date];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    notifying = NO;
    _times =0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateVolume:)
                                           userInfo:nil
                                    repeats:YES];
}

-(void)stopListening{
    if(timer){
        [timer invalidate];
    }
    self.historyModel.endTime = [NSDate date];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    self.historyModel = nil;
}

-(void)updateVolume :(NSTimer *)timer{
    
    // get sound meter.
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(_queue,kAudioQueueProperty_CurrentLevelMeterDB,&levelMeter,&levelMeterSize);
    
    // save to DB
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    VolumeModel *volumeModel = [NSEntityDescription insertNewObjectForEntityForName:@"VolumeModel" inManagedObjectContext:context];
    volumeModel.peak =[NSNumber numberWithFloat:roundf(levelMeter.mPeakPower)] ;
    volumeModel.average =[NSNumber numberWithFloat:(float)roundf(levelMeter.mAveragePower)];
    volumeModel.time = [NSDate date];
    volumeModel.history = self.historyModel;
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    // notify to view.
    [self.graphVC updateView:volumeModel];
    
//    [self.showDelegate cryPickingController:self volume:volumeModel];
    
    // fire if it is louder than the threshold.
    float threshold =[[NSUserDefaults standardUserDefaults] floatForKey:SettingKeyThreshold];
    if ( levelMeter.mPeakPower >= threshold || levelMeter.mAveragePower >= threshold) {
        if(!notifying){
            [self notify:volumeModel];
            notifying = YES;
        }
        _times = 0;
    }else{
        if(notifying){
            _times++;
            if(_times >=10){
                notifying = NO;
            }
        }
    }
}

-(void)notify :(VolumeModel *)volumeModel{
    NSLog(@"fire!");
    
    AppDelegate *delegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = delegate.managedObjectContext;

    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NotificateTargetModel" inManagedObjectContext:context];
    [fetch setEntity:entity];

    NSArray* targets =[context executeFetchRequest:fetch error:nil];
    
    NSMutableArray *addresses = [NSMutableArray new];
    NSMutableString *notice = [NSMutableString stringWithString:@"mail sent to :"];
    [targets enumerateObjectsUsingBlock:^(NotificateTargetModel *target, NSUInteger idx, BOOL *stop) {
        [addresses addObject:target.email];
        [notice appendString:target.email];
        [notice appendString:@"/"];
    }];
    
    [PFCloud callFunctionInBackground:@"sendMail" withParameters:@{@"addresses":addresses} block:^(id object, NSError *error) {
        NSLog(@"%@",[notice description]);
    }];
}

-(HistoryModel *)graphViewControllerDataSource{
    return self.historyModel;
}


@end
