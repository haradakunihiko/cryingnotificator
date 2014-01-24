//
//  MyTabBarControllerViewController.m
//  BabyAlerm
//
//  Created by harada on 2014/01/21.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "MyTabBarControllerViewController.h"

@interface MyTabBarControllerViewController ()

@end

@implementation MyTabBarControllerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[self.tabBar.items objectAtIndex:1] setTitle:@"test"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self.tabBar.items objectAtIndex:1] setTitle:@"test"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
