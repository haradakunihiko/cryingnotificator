//
//  NearbyDeviceBrowserTableViewController.h
//  BabyAlerm
//
//  Created by harada on 2014/02/11.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface NearbyDeviceBrowserTableViewController : UITableViewController

@property (nonatomic,strong) NSMutableSet *registerdDeviceInstallationIds;


@end
