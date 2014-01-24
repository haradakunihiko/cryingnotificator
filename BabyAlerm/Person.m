//
//  Person.m
//  BabyAlerm
//
//  Created by harada on 2013/12/05.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "Person.h"

@implementation Person

-(NSString *)fullname{
    return [NSString stringWithFormat:@"%@ %@",self.lastname ?: @"", self.firstname ?: @""];
}

@end
