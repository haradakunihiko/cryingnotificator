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
#import <AWSRuntime/AWSRuntime.h>
#import <AWSSES/AWSSES.h>

@interface CryPickingController()

-(void)preparePicking;

@end

@implementation CryPickingController{
    BOOL _checkingInProgress;
    NSInteger _times;
    NSTimer *timer;
    BOOL notifying;
    
    long _count;
    
//    NSMutableSet *_recentSet;
    NSMutableArray *_summarizeArray;
    
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
        _summarizeArray = [NSMutableArray new];
        [_summarizeArray addObject:[NSMutableArray new]];
//        _recentSet = [NSMutableSet new];
        _count = 0;
        
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

    notifying = NO;
    _times =0;
    
    [self.graphVC performFetch];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateVolume)
                                           userInfo:nil
                                    repeats:YES];
}

-(void)stopListening{
    if(timer){
        [timer invalidate];
    }
    
    self.graphVC.autoUpdate = NO;
    for (int i = MAX(0, [self.historyModel.volumes count] - PlotXRange); i < [self.historyModel.volumes count]; i++) {
        VolumeModel *volume = [self.historyModel.volumes objectAtIndex:i];
        volume.enabled = NO;
    }
    
    __block VolumeModel *max ;
    for (int i = 0; i < [_summarizeArray count] - 1; i++) {
        [[_summarizeArray objectAtIndex:i] enumerateObjectsUsingBlock:^(VolumeModel *obj, NSUInteger idx, BOOL *stop) {
            if(max == nil){
                max = obj;
            }else{
                max= max.peak >= obj.peak ? max : obj;
            }
        }];
    }
    NSMutableArray *array = [_summarizeArray lastObject];
    if(max!= nil){
        [array addObject:max];
    }
    [array enumerateObjectsUsingBlock:^(VolumeModel *obj, NSUInteger idx, BOOL *stop) {
        obj.enabled = [NSNumber numberWithBool:YES];
    }];
    
    self.historyModel.endTime = [NSDate date];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    self.historyModel = nil;
}


-(VolumeModel *)saveVolume{

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
//    volumeModel.count = _count++;

    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    return volumeModel;
}

-(void) adjustSummarizeArray{
    [_summarizeArray enumerateObjectsUsingBlock:^(NSMutableArray *innerArray, NSUInteger idx, BOOL *stop) {
        BOOL existsNext = ([_summarizeArray count] >=idx + 2);
        
        if(([innerArray count] >= (2 * PlotXRange)) && !existsNext) {
            [_summarizeArray addObject:[NSMutableArray new]];
            existsNext = YES;
        }
        if (existsNext) {
            // exists next.
            [self addToSummarizeArrayNext:innerArray target:[_summarizeArray objectAtIndex:idx + 1]];
        }
    }];
}

-(void) addToSummarizeArrayNext : (NSMutableArray *)array target: (NSMutableArray *)targetArray{
    __block VolumeModel *prev;
    [array enumerateObjectsUsingBlock:^(VolumeModel *volume, NSUInteger idx, BOOL *stop) {
        if(idx == 0){
            prev = volume;
        }else if (idx % 2 == 1) {
            VolumeModel *enabled;
            VolumeModel *disabled;
            if(prev.peak >= volume.peak){
                enabled = prev;
                disabled = volume;
            }else{
                enabled = volume;
                disabled = prev;
            }
//            enabled.enabled = [NSNumber numberWithBool:YES];
//            disabled.enabled =[NSNumber numberWithBool:NO];

            [targetArray addObject:enabled];
            prev = nil;
        }else{
            prev = volume;
        }
    }];
    [array removeAllObjects];
    
    if (prev != nil) {
        [array addObject:prev];
    }
}

-(void)updateVolume{
    _count++;
    VolumeModel *volumeModel = [self saveVolume];

    if(_count > PlotXRange){
        VolumeModel * volume = [self.historyModel.volumes objectAtIndex:_count - PlotXRange - 1];
        volume.enabled = [NSNumber numberWithBool:NO];
    }
    
    [[_summarizeArray firstObject]addObject:volumeModel];
    [self adjustSummarizeArray];
    
    // notify to view.
    [self.graphVC updateView:volumeModel];
    
    // fire if it is louder than the threshold.
    float threshold =[[NSUserDefaults standardUserDefaults] floatForKey:SettingKeyThreshold];
    if ( [volumeModel.peak floatValue] >= threshold || [volumeModel.average floatValue] >= threshold) {
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
    NSMutableString *notice = [NSMutableString stringWithString:@"mail will be sent to :"];
    [targets enumerateObjectsUsingBlock:^(NotificateTargetModel *target, NSUInteger idx, BOOL *stop) {
        [addresses addObject:target.email];
        [notice appendString:target.email];
        [notice appendString:@"/"];
    }];

    NSLog(@"%@",[notice description]);
//    [self sendWithAmazonSES:addresses withTime:volumeModel.time];

    [self sendWithParse:addresses withTime:volumeModel.time withDescription:[notice description]];
}

-(void) sendWithAmazonSES :(NSArray *)addresses withTime:(NSDate *)currentTime{
    AmazonSESClient *sesClient = [[AmazonSESClient alloc] initWithAccessKey:ASES_ACCESS_KEY withSecretKey:ASES_SECRET_KEY];
    sesClient.endpoint = @"https://email.us-west-2.amazonaws.com";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMddHHmmss" options:0 locale:[NSLocale currentLocale]];
    
    SESContent *subject = [[SESContent alloc]init];
    subject.data = [NSString stringWithFormat:@"[Crying Notification] crying at %@",[dateFormatter stringFromDate:currentTime]];
    SESContent *messageBody = [[SESContent alloc] init];
    messageBody.data = @"Your baby may be crying!";
    
    SESBody *body = [[SESBody alloc]init];
    body.text = messageBody;
    SESMessage *message = [[SESMessage alloc] init];
    message.body = body;
    message.subject =subject;
    
    SESDestination *destination = [[SESDestination alloc]init];
    [addresses enumerateObjectsUsingBlock:^(NSString *address, NSUInteger idx, BOOL *stop) {
        [destination addToAddresse:address];
    }];

    SESSendEmailRequest *request = [[SESSendEmailRequest alloc] init];
    request.source = FROM_ADDRESS;
    request.message = message;
    request.destination = destination;
    
    
    @try {
        SESSendEmailResponse *response = [sesClient sendEmail:request];
        NSLog(@"%@",[response description]);
    }
    @catch (AmazonServiceException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"%@",[exception description]);
    }

    
    
}


-(void)sendWithParse:(NSArray *)addresses withTime:(NSDate *)currentTime withDescription :(NSString*)description{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMddHHmmss" options:0 locale:[NSLocale currentLocale]];
    
    [PFCloud callFunctionInBackground:@"sendMail" withParameters:@{@"addresses":addresses,@"cryTime":currentTime, @"cryTimeString" :[dateFormatter stringFromDate:currentTime] } block:^(id object, NSError *error) {
        NSLog(@"%@",description);
    }];
}

-(HistoryModel *)graphViewControllerDataSource{
    return self.historyModel;
}


@end
