//
//  NotificateTargetModel.h
//  BabyAlerm
//
//  Created by harada on 2014/01/24.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NotificateTargetModel : NSManagedObject

@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSDate * prcdate;

-(NSString *) fullname;
@end
