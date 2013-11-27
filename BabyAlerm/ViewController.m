//
//  ViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/23.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "ViewController.h"
#import "CryPickingController.h"
#import "AppDelegate.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import <Parse/Parse.h>
@interface ViewController ()<MCBrowserViewControllerDelegate,PFLogInViewControllerDelegate,PFSignUpViewControllerDelegate>


@end

@implementation ViewController{
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if(![PFUser currentUser]){
        PFLogInViewController *loginVC = [[PFLogInViewController alloc]init];
        loginVC.delegate  = self;
        PFSignUpViewController *signUpVC =[[PFSignUpViewController alloc]init];
        signUpVC.delegate = self;
        [loginVC setSignUpController:signUpVC];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)searchDevices:(UIButton *)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    MCBrowserViewController *browserVC = [[MCBrowserViewController alloc]initWithServiceType:kServiceType session:delegate.session];
    browserVC.delegate = self;
    [self presentViewController:browserVC animated:YES completion:nil];
}
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password{
    if(username && password && username.length != 0 && password.length != 0){
        return YES;
    }
    
    [[[UIAlertView alloc]initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    return NO;
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error{
    NSLog(@"Failed to log in...");
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info{
    __block BOOL informationComplete = YES;
    
    [info enumerateKeysAndObjectsUsingBlock:^(id key, NSString *field, BOOL *stop) {
        if(!field || field.length == 0){
            informationComplete = NO;
            return;
        }
    }];
    
    if (!informationComplete) {
        [[[UIAlertView alloc]initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    return informationComplete;
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error{
    NSLog(@"Failed to log in...");
}

-(void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController{
    NSLog(@"User dismissed the signupcontroller");
}

@end
