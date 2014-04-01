//
//  NearbyDeviceBrowserTableViewController.m
//  BabyAlerm
//
//  Created by harada on 2014/02/11.
//  Copyright (c) 2014年 harada. All rights reserved.
//

#import "NearbyDeviceBrowserTableViewController.h"
#import "AppDelegate.h"
#import "NotificateTargetDeviceModel.h"

@interface NearbyDeviceBrowserTableViewController ()<MCNearbyServiceBrowserDelegate>


@property (nonatomic,strong)MCNearbyServiceBrowser *browser;
@property (readonly) NSString *serviceType;
@property (readonly) MCPeerID *peerId;
@property (readonly) MCSession *session;

@property (nonatomic,strong) NSMutableArray *nearbyPeers;
@property (nonatomic,strong) NSMutableArray *registerdNearbyPeers;

@property (nonatomic,strong) NSMutableSet *declinedPeers;
@property (nonatomic,strong) NSMutableSet *invitingPeers;


@property (nonatomic,strong) NSMutableDictionary *discoveryInfos;

@end

@implementation NearbyDeviceBrowserTableViewController{
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.nearbyPeers = [NSMutableArray new];
    self.declinedPeers = [NSMutableSet new];
    self.invitingPeers = [NSMutableSet new];
    self.discoveryInfos =[NSMutableDictionary new];
    self.registerdNearbyPeers = [NSMutableArray new];
    
    self.browser = [[MCNearbyServiceBrowser alloc]initWithPeer:self.peerId serviceType:self.serviceType];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerConnected:) name:PeerConnectionAcceptedNotification object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)willMoveToParentViewController:(UIViewController *)parent{
    NSLog(@"willMoveToParentViewController");
    [self.session disconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([self.registerdNearbyPeers count] >0){
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.nearbyPeers count];
            break;
        case 1:
            return [self.registerdNearbyPeers count];
            break;
        default:
            break;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"nearby devices";
            break;
        case 1:
            return @"nearby registered devices";
            break;
        default:
            break;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(indexPath.section == 0){
        MCPeerID *peer =[self.nearbyPeers objectAtIndex:indexPath.row];
        // Configure the cell...
        cell.textLabel.text = peer.displayName;
        
        if([self.session.connectedPeers containsObject:peer]){
            // 接続済みはチェックをつける。
            UILabel *checkmarkLabel =
            [[UILabel alloc]
             initWithFrame:CGRectMake(0, 0, 20, 20)];
            checkmarkLabel.text = @" √ ";
            cell.accessoryView = checkmarkLabel;
        }else if([self.invitingPeers containsObject:peer]){
            // 接続中はindicatorを表示する。
            if (![cell.accessoryView isKindOfClass:[UIActivityIndicatorView class]]) {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activityIndicator.hidesWhenStopped = YES;
                [activityIndicator startAnimating];
                cell.accessoryView = activityIndicator;
            }
        }else{
            cell.accessoryView = nil;
        }
        // 接続中はindicator
        // 登録済みは選択不可(別section?)。
        
    }else if(indexPath.section == 1){
        MCPeerID *peer = [self.registerdNearbyPeers objectAtIndex:indexPath.row];
        cell.textLabel.text = peer.displayName;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    // #warning 既に接続ちゅうのpeerは操作しない。
    // #warning 接続済みのpeerは接続しない。
    // #warning 登録済みのpeerはのぞく。
//    if([self.invitingPeers containsObject:peer]){
//        return;
//    }
    if(indexPath.section == 0){
        MCPeerID *peer =[self.nearbyPeers objectAtIndex:indexPath.row];
        [self.invitingPeers addObject:peer];
        [self.browser invitePeer:peer toSession:self.session withContext:[@"Making contact" dataUsingEncoding:NSUTF8StringEncoding] timeout:30];
        [self.tableView reloadData];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - MCBrowser delegate

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    NSLog(@"browse found peer:%@",peerID);
    NSString *installationId = info[DiscoveryKeyAdvertiserInstallationId];
    if([self.registerdDeviceInstallationIds containsObject:installationId]){
        [self.registerdNearbyPeers addObject:peerID];
    }else{
        [self.nearbyPeers addObject:peerID];
        self.discoveryInfos[peerID] = info;
    }

    [self.tableView reloadData];
//        [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.nearbyPeers count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    [self.nearbyPeers removeObject:peerID];
    [self.declinedPeers removeObject:peerID];
    [self.invitingPeers removeObject:peerID];
    [self.registerdNearbyPeers removeObject:peerID];
    
    [self.discoveryInfos removeObjectForKey:peerID];
  
    [self.tableView reloadData];
//    [self.tableView beginUpdates];
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.nearbyPeers indexOfObject:peerID] inSection:0  ] ]withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
}

#pragma mark - property

-(NSString *)serviceType{
    return kServiceType;
}

-(MCPeerID *)peerId{
    AppDelegate *delegate =[[UIApplication sharedApplication] delegate];
    return delegate.peerId;
}

-(MCSession *)session{
    AppDelegate *delegate =[[UIApplication sharedApplication] delegate];
    return delegate.session;
}

//pragma todo browserのstopをどこでよぶk？

#pragma mark - notification center
-(void)peerConnected:(NSNotification *)notification{
    MCPeerID *peer = (MCPeerID *)[notification userInfo][@"peer"];
    BOOL nearbyDeviceDecision =[[notification userInfo][@"accept"] boolValue];
    if (nearbyDeviceDecision) {
        NSString *installationId =self.discoveryInfos[peer][DiscoveryKeyAdvertiserInstallationId];
        [self saveNewDevice:peer.displayName installationId:installationId];
        [self.nearbyPeers removeObject:peer];
        
        [self.registerdNearbyPeers addObject:peer];
        [self.registerdDeviceInstallationIds addObject:installationId];
        [self.session cancelConnectPeer:peer];
        
    }else{
        [self.declinedPeers addObject:peer];
    }
    [self.invitingPeers removeObject:peer];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void) saveNewDevice:(NSString *)deviceName installationId:(NSString *)installationId{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NotificateTargetDeviceModel  *target = [NSEntityDescription insertNewObjectForEntityForName:@"NotificateTargetDeviceModel" inManagedObjectContext:context];
    target.name = deviceName;
    target.installationId = installationId;
    
    NSError *error;
    if(![context save:&error]){
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

@end
