//
//  NotificateTargetDeviceModel.m
//  BabyAlerm
//
//  Created by harada on 2014/02/11.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "NotificateTargetDeviceModel.h"


@implementation NotificateTargetDeviceModel

@dynamic name;
@dynamic installationId;
@dynamic udid;
@dynamic prcdate;

-(void)awakeFromInsert{
    [super awakeFromInsert];
    self.prcdate = [NSDate date];
}

-(void)setupCell:(UITableViewCell *)cell{
    cell.textLabel.text = self.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,%@",self.installationId,self.udid];
}

@end
