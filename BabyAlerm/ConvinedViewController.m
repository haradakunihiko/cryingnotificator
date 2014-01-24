//
//  ConvinedViewController.m
//  BabyAlerm
//
//  Created by harada on 2014/01/22.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "ConvinedViewController.h"
#import "CryPickingController.h"
#import "GraphViewController.h"
#import "HistoryViewController.h"
#import "AppDelegate.h"

@interface ConvinedViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *graphContainer;
@property (weak, nonatomic) IBOutlet UIView *recordingView;
@property (weak, nonatomic) IBOutlet UIView *historyContainer;
@property (weak, nonatomic) IBOutlet UIView *historyGraphContainer;

@property (nonatomic,weak) GraphViewController *graphViewController;
@property (nonatomic,weak) GraphViewController *historyGraphViewController;
@property (nonatomic,weak) HistoryViewController *historyViewController;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ConvinedViewController{
    
    BOOL _hiddenStatusBar;
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
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        //viewControllerで制御することを伝える。iOS7 からできたメソッド
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    [self.graphContainer addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)]];
    [self.historyGraphContainer addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)]];
    
    
    self.historyViewController.graphViewController = self.historyGraphViewController;
//    [self setNeedsStatusBarAppearanceUpdate];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
//    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
//    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)tapped : (UIGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _hiddenStatusBar = !_hiddenStatusBar;
        int alpha = _hiddenStatusBar ? 0 : 1;
        
        CGRect barFrame = self.navigationController.navigationBar.frame;
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.alpha = alpha;
        }];
                
        self.navigationController.navigationBar.frame = CGRectZero;
        self.navigationController.navigationBar.frame = barFrame;

    }
    
}

-(BOOL)prefersStatusBarHidden{
    return _hiddenStatusBar;
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EmbededGraph"]){
        self.graphViewController =  segue.destinationViewController;
    }
    if([segue.identifier isEqualToString:@"EmbededHistoryGraph"]){
        self.historyGraphViewController =  segue.destinationViewController;
    }
    if([segue.identifier isEqualToString:@"EmbededHistory"]){
        self.historyViewController =  segue.destinationViewController;
        self.historyViewController.convinedViewController = self;
    }
    
}


- (IBAction)start:(UIButton *)sender {
    
    if(self.executing){
        self.executing = NO;
        [_pickingController stopListening];
        [self.startButton setTitle:@"start" forState:UIControlStateNormal];
        
        [self.historyViewController.tableView beginUpdates];
        
        [self.historyViewController.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.historyViewController.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self.historyViewController reloadData];
        
        [self.historyViewController.tableView endUpdates];
        
    }else{
        
        if(![self hasMoreThanZeroAddress]){
            UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:@"No address to notify has been set. Are you sure to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView.delegate = self;
            [alertView show];
        }else{
            [self startListening];
        }
    }
}

-(void) startListening{
    
    self.executing = YES;
    if(!_pickingController ){
        _pickingController = [CryPickingController new];
    }
    _graphViewController.datasource = _pickingController;
    _pickingController.graphVC = _graphViewController;
    [self.graphViewController initializeWithDisplaytype:BAGraphDisplayTypeShowRecentInViewAndGlobal];
    
    [_pickingController startListening];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    [self switchGraphView:NO];
    
    [self.historyViewController.tableView beginUpdates];
    
    [self.historyViewController.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.historyViewController.tableView endUpdates];
    [self.startButton setTitle:@"stop" forState:UIControlStateNormal];
}


-(void)switchGraphView:(BOOL)showHistory{
    self.historyGraphContainer.alpha = showHistory ? 1 : 0;
    self.graphContainer.alpha = showHistory ? 0 : 1;
    [self.view setNeedsDisplay];
    if(!showHistory){
        [self.historyViewController.tableView deselectRowAtIndexPath:[self.historyViewController.tableView indexPathForSelectedRow] animated:YES];
    }
//    [self.historyViewController.tableView reloadData];

}

-(HistoryModel *)ongoingHistoryModel{
    return _pickingController.historyModel;
}
- (IBAction)clear:(UIBarButtonItem *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles: nil];
    
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            
            [self.historyViewController numberOfHistory];
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context = delegate.managedObjectContext;
            
            NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription
                                           entityForName:@"HistoryModel" inManagedObjectContext:context];
            [fetch setEntity:entity];
            
            
            NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                      initWithKey:@"startTime" ascending:NO];
            [fetch setSortDescriptors:[NSArray arrayWithObject:sort]];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self != %@",[self ongoingHistoryModel]];
            
            [fetch setPredicate:predicate];
            
//            
//            
//            NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
//            
//            
//            [fetch setEntity:[NSEntityDescription entityForName:@"HistoryModel" inManagedObjectContext:context]];
//            
            NSArray * result = [context executeFetchRequest:fetch error:nil];
            for (id history in result)
                [context deleteObject:history];
            
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
        }
            break;
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.historyViewController refreshTable];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
            [self startListening];
            break;
        default:
            break;
    }
}

-(BOOL) hasMoreThanZeroAddress{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NotificateTargetModel" inManagedObjectContext:context];
    [fetch setEntity:entity];
    NSInteger count =[context countForFetchRequest:fetch error:nil];
    if(count ==NSNotFound){
        return NO;
    }else{
        return count > 0;
    }
}


@end
