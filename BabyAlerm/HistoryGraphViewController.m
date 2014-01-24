//
//  HitoryGraphViewController.m
//  BabyAlerm
//
//  Created by harada on 2014/01/20.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "HistoryGraphViewController.h"
#import "GraphViewController.h"


@interface HistoryGraphViewController ()


@end

@implementation HistoryGraphViewController

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EmbededGraph"]){
        self.graphViewController =  segue.destinationViewController;
        self.graphViewController.datasource = self;
        [self.graphViewController initializeWithDisplaytype:BAGraphDisplayTypeShowAllInView];
        [NSFetchedResultsController deleteCacheWithName:nil];
    }
}

-(HistoryModel *)graphViewControllerDataSource{
    return self.historyModel;
}



@end
