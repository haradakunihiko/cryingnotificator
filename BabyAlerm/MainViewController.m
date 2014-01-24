//
//  MainViewController.m
//  BabyAlerm
//
//  Created by harada on 2014/01/17.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "MainViewController.h"
#import "CryPickingController.h"
#import "GraphViewController.h"

@interface MainViewController ()
@property (nonatomic,weak) GraphViewController *graphViewController;

@end

@implementation MainViewController{
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
	// Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)start:(UIBarButtonItem *)sender {
    if(!_pickingController ){
        _pickingController = [CryPickingController new];
    }
    self.graphViewController.datasource = _pickingController;
    _pickingController.graphVC = self.graphViewController;
    [self.graphViewController initializeWithDisplaytype:BAGraphDisplayTypeShowRecentInViewAndGlobal];
    
    [_pickingController startListening];
   

    
//    self.graphViewController.historyModel = _pickingController.historyModel;
    
    [NSFetchedResultsController deleteCacheWithName:nil];

    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)] animated:YES];
}


-(void) stop:(id)sender{
    [_pickingController stopListening];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(start:)] animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EmbededGraph"]){
        self.graphViewController =  segue.destinationViewController;
    }
}

@end
