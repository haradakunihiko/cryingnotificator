//
//  Device.h
//  BabyAlerm
//
//  Created by harada on 2013/11/27.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Device : NSObject<NSCoding>

@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) NSString *installationIdentifier;

@end
