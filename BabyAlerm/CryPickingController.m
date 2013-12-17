//
//  CryPickingController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "AppDelegate.h"
#import "CryPickingController.h"
#import "Person.h"
#import <Parse/Parse.h>
#import "History.h"
#import "HistoryDetail.h"
#import "HistoryModel.h"
#import "VolumeModel.h"

@interface CryPickingController()

-(void)preparePicking;
-(void)notify;

@end

@implementation CryPickingController{
    BOOL _checkingInProgress;
    NSInteger _times;
    NSTimer *timer;
    
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
        self.maxAverage = -1.0f;
        self.maxPeak = -1.0f;
        self.maxTimes = 1;
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        
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
    NSMutableArray *histData = delegate.histData;
    History *history = [History new];
    history.startTime = [NSDate date];
    
    NSManagedObjectContext *context = delegate.managedObjectContext;
    self.historyModel = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryModel" inManagedObjectContext:context];
    self.historyModel.startTime = [NSDate date];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [histData addObject:history];
    
    
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
}

-(void)updateVolume :(NSTimer *)timer{
    
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(_queue,kAudioQueueProperty_CurrentLevelMeterDB,&levelMeter,&levelMeterSize);
    
    Volume *volume = [Volume new ];
    volume.peak = (float)roundf(levelMeter.mPeakPower);
    volume.average = (float)roundf(levelMeter.mAveragePower);
    volume.time = [NSDate date];
    
    
//    HistoryModel *historyModel =  timer.userInfo[@"historyModel"];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    VolumeModel *volumeModel = [NSEntityDescription insertNewObjectForEntityForName:@"VolumeModel" inManagedObjectContext:context];
    volumeModel.peak =[NSNumber numberWithFloat:roundf(levelMeter.mPeakPower)] ;
    volumeModel.average =[NSNumber numberWithFloat:(float)roundf(levelMeter.mAveragePower)];
    volumeModel.time = [NSDate date];
    [self.historyModel addVolumesObject:volumeModel ];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
//    // Test listing all FailedBankInfos from the store
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HistoryModel"
//                                              inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    for (HistoryModel *model in fetchedObjects) {
//        NSLog(@"starttime: %@", model.startTime);
//        NSOrderedSet *details = model.volumes;
//        [details enumerateObjectsUsingBlock:^(VolumeModel *obj, NSUInteger idx, BOOL *stop) {
//            NSLog(@"ave: %@",obj.average);
//            NSLog(@"peak: %@",obj.peak);
//        }];
//    }
    
    
    [self.showDelegate cryPickingController:self volume:volume];
    
    
    if ( levelMeter.mPeakPower >= self.maxPeak || levelMeter.mAveragePower >= self.maxAverage) {
        _times++;
    }else{
        _times--;
        if(_times <0){
            _times = 0;
        }
    }
    if(_times >= self.maxTimes){
        [self notify:volume];
        _times = 0;
    }
}

-(void)notify :(Volume *)volume{
    NSLog(@"fire!");
    
    AppDelegate *delegate =(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *notifyContacts = delegate.contacts;
    
    NSArray *histData = delegate.histData;
    History *histoy = [histData lastObject];
    HistoryDetail *detail = [HistoryDetail new];
    detail.volume = volume;
    [histoy addObject:detail];
    
    NSMutableArray *addresses = [NSMutableArray new];
    [notifyContacts enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
        [addresses addObject:person.email];
    }];
    
    [PFCloud callFunctionInBackground:@"sendMail" withParameters:@{@"addresses":addresses} block:^(id object, NSError *error) {
        NSMutableString *notice = [NSMutableString stringWithString:@"mail sent to :"];
        [notifyContacts enumerateObjectsUsingBlock:^(Person *obj, NSUInteger idx, BOOL *stop) {
            
            [notice appendString:obj.email];
            [notice appendString:@"/"];
        }];
        NSLog(@"%@",[notice description]);
    }];
//    [self.delegate cryPickingController:self notify:YES];
}


@end
