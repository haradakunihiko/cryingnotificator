//
//  ReceiverTableViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/27.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "ReceiverTableViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ListeningViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ReceiverTableViewController ()<MCBrowserViewControllerDelegate>

@end

@implementation ReceiverTableViewController{
    NSString *_parseClassName;
    NSMutableArray *_dataSource;
    NSMutableDictionary *_peerInfo;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        
        _parseClassName = @"Relation";
        _dataSource = [NSMutableArray new];
        _keyColumn = @"senderId";
        _displayColumn = @"receiverDeviceName";
        _peerInfo = [NSMutableDictionary new];
    }
    return self;
}

-(NSArray *) dataSource{
    return _dataSource;
}

-(void)loadDataWithUpdate:(BOOL) update{
    [self loadDataWithUpdate:update withEndRefreshing:NO];
}

-(void)loadDataWithUpdate:(BOOL) update withEndRefreshing:(BOOL) endRefreshing{
    [self loadDataWithUpdate:update withEndRefreshing:endRefreshing withHideHUD:NO];
}

-(void)loadDataWithUpdate:(BOOL) update withEndRefreshing:(BOOL) endRefreshing withHideHUD : (BOOL) hideHUD {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    PFQuery *query = [PFQuery queryWithClassName:_parseClassName];
    [query whereKey:self.keyColumn equalTo:delegate.installationId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _dataSource = [objects mutableCopy];
            if(update){
                [self.tableView reloadData];
                if(endRefreshing){
                    [self.refreshControl endRefreshing];
                }
                if(hideHUD) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                }
            }
        }else{
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
     }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshControlValueChanged) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(savingCompleted:) name:RelationDataSavingCompleteNotifiction object:nil];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadDataWithUpdate:YES withEndRefreshing:NO withHideHUD:YES];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self dataSource] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    PFObject *obj = [self dataSource][indexPath.row];
    cell.textLabel.text = obj[self.displayColumn];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *object = _dataSource[indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        }];
        
        [_dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)SearchReceiver:(UIBarButtonItem *)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    MCBrowserViewController *browserVC = [[MCBrowserViewController alloc]initWithServiceType:kServiceType session:delegate.session];
    browserVC.delegate = self;
    [delegate.session disconnect];
    [self presentViewController:browserVC animated:YES completion:nil];
}




-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    
    
    [browserViewController dismissViewControllerAnimated:YES completion:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }];
    

    
    AppDelegate *delegate =
    (AppDelegate *) [[UIApplication sharedApplication]
                     delegate];
    [delegate sendDeviceTokenToPeer];

}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
    [self loadDataWithUpdate:YES];
}

- (void)refreshControlValueChanged{
    [self loadDataWithUpdate:YES withEndRefreshing:YES] ;
}


-(BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    AppDelegate *delegate =
    (AppDelegate *) [[UIApplication sharedApplication]
                     delegate];
    delegate.peerDiscoveryInfo[peerID] = info;
    return YES;
}


-(void)savingCompleted: (NSNotification *)notification{
    [self loadDataWithUpdate:YES withEndRefreshing:YES withHideHUD:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ReceiverToListening"]){
        ListeningViewController *listeningVC= segue.destinationViewController;
        [listeningVC setCryingVCDelegate:(AppDelegate *)[[UIApplication sharedApplication]delegate]];
    }
}

@end
