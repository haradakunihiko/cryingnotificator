//
//  CryPickingController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "AppDelegate.h"
#import "CryPickingController.h"

@interface CryPickingController()

-(void)preparePicking;
-(void)notify;

@end

@implementation CryPickingController{
    BOOL _checkingInProgress;
    NSInteger _times;
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
        self.maxTimes = 5;
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
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(updateVolume:)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)updateVolume :(NSTimer *)timer{
    AudioQueueLevelMeterState levelMeter;
    UInt32 levelMeterSize = sizeof(AudioQueueLevelMeterState);
    AudioQueueGetProperty(_queue,kAudioQueueProperty_CurrentLevelMeterDB,&levelMeter,&levelMeterSize);
    [self.showDelegate cryPickingController:self meterState:levelMeter];
    
    
    if ( levelMeter.mPeakPower >= self.maxPeak || levelMeter.mAveragePower >= self.maxAverage) {
        _times++;
    }else{
        _times--;
        if(_times <0){
            _times = 0;
        }
    }
    if(_times >= self.maxTimes){
        [self notify];
        _times = 0;
    }
}

-(void)notify{
    NSLog(@"fire!");
    [self.delegate cryPickingController:self notify:YES];
}


@end
