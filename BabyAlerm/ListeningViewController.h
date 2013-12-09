//
//  ListeningViewController.h
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CryPickingController.h"

@interface ListeningViewController : UIViewController{
}

-(void)setCryingVCDelegate :(id<BLCryPickingDelegate>) delegate;
@end
