//
//  Result.m
//  BabyAlerm
//
//  Created by harada on 2013/11/28.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "Result.h"

@implementation Result

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[NSNumber numberWithBool:self.result ] forKey:@"result"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.result = [[aDecoder decodeObjectForKey:@"result"] boolValue];
    return self;
}

@end
