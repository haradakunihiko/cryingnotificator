//
//  NotificateTargetDeviceModel.h
//  BabyAlerm
//
//  Created by harada on 2014/02/11.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ContactViewController.h"

@interface NotificateTargetDeviceModel : NSManagedObject<ContactViewControllerViewDelegate>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * installationId;
@property (nonatomic, retain) NSString * udid;
@property (nonatomic, retain) NSDate * prcdate;

@end
