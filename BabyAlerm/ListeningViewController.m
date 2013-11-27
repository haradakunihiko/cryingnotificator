//
//  ListeningViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "ListeningViewController.h"
#import "AppDelegate.h"

@interface ListeningViewController ()

@end

@implementation ListeningViewController{
    
    CryPickingController *_pickingController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _pickingController = [CryPickingController new];
	// Do any additional setup after loading the view.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(![delegate sendDeviceTokenToPeer]){
        [self showMessage:@"failed to send notification request to peers"];
        [_pickingController startListening];
    }else{
        [self showMessage:@"succeeded to send notification request to peers"];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)done:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) showMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}
- (IBAction)fireManually:(UIButton *)sender {
    [_pickingController notify];
}

@end
