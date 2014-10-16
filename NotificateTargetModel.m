//
//  NotificateTargetModel.m
//  BabyAlerm
//
//  Created by harada on 2014/10/10.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "NotificateTargetModel.h"


@implementation NotificateTargetModel

@dynamic email;
@dynamic firstname;
@dynamic lastname;
@dynamic prcdate;
@dynamic manually;

-(void)awakeFromInsert{
    [super awakeFromInsert];
    self.prcdate = [NSDate date];
}


-(NSString *)fullname{
    if(self.firstname || self.lastname){
        
        return [NSString stringWithFormat:@"%@ %@",self.lastname ?: @"", self.firstname ?: @""];
    }else{
        return @"Input Manually";
    }
}

-(void)setupCell:(UITableViewCell *)cell{
    cell.textLabel.text = self.email;
    cell.detailTextLabel.text = self.fullname;
}
@end
