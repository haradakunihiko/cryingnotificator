//
//  ContactViewController.h
//  BabyAlerm
//
//  Created by harada on 2013/12/05.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ContactViewControllerViewDelegate <NSObject>
-(void)setupCell:(UITableViewCell*)cell;
@end

@interface ContactViewController : UITableViewController

typedef enum _CNNotificateTargetModelType {
    CNNotificateTargetModelEmail = 0,
    CNNotificateTargetModelDevice = 1,
    CNNotificateTargetModelUnknown = -1
}
CNNotificateTargetModelType;

@end
