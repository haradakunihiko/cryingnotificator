//
//  NotificateTargetModel.m
//  BabyAlerm
//
//  Created by harada on 2014/01/24.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "NotificateTargetModel.h"


@implementation NotificateTargetModel

@dynamic firstname;
@dynamic lastname;
@dynamic email;
@dynamic prcdate;

-(void)awakeFromInsert{
    [super awakeFromInsert];
    self.prcdate = [NSDate date];
}

-(NSString *)fullname{
    return [NSString stringWithFormat:@"%@ %@",self.lastname ?: @"", self.firstname ?: @""];
}

@end
