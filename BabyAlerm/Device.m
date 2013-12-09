//
//  Device.m
//  BabyAlerm
//
//  Created by harada on 2013/11/27.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "Device.h"

@implementation Device


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.installationIdentifier forKey:@"installationIdentifier"];
    [aCoder encodeObject:self.deviceName forKey:@"deviceName"];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    _installationIdentifier = [aDecoder decodeObjectForKey:@"installationIdentifier"];
    _deviceName = [aDecoder decodeObjectForKey:@"deviceName"];
    
    NSLog(@" id : %@, name: %@",[self installationIdentifier],[self deviceName]);
    return self;
}



@end
