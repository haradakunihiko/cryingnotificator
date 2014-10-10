//
//  ContactViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/12/05.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "ContactViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "GraphViewController.h"
#import "CryPickingController.h"
#import <Parse/Parse.h>
#import "NotificateTargetModel.h"
#import "AppDelegate.h"
#import "NotificateTargetDeviceModel.h"
#import "NearbyDeviceBrowserTableViewController.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ContactViewController ()<ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,NSFetchedResultsControllerDelegate,MCBrowserViewControllerDelegate>{
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic,retain) NSFetchedResultsController *fetchedResultsControllerForDevice;

@end

@implementation ContactViewController{
    UIActionSheet *_acthionSheet;
    NSMutableDictionary *_discoveryInfos;
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
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    if (![[self fetchedResultsControllerForDevice] performFetch:&error]) {
        
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
    }

    _discoveryInfos = [NSMutableDictionary new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
 
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfDataWithType:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
   id<ContactViewControllerViewDelegate> target = [[self fetchedResultsController:(CNNotificateTargetModelType)indexPath.section] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    [target setupCell:cell];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = delegate.managedObjectContext;
        // Delete the row from the data source
        NSIndexPath *modifiedIndexPath =[ NSIndexPath indexPathForRow:indexPath.row inSection:0];
        NotificateTargetModel *target = [[self fetchedResultsController:(CNNotificateTargetModelType)indexPath.section] objectAtIndexPath:modifiedIndexPath];
        [context deleteObject:target];
        
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case CNNotificateTargetModelEmail:
            return [NSString stringWithFormat:@"email"];
            break;
        case CNNotificateTargetModelDevice:
            return [NSString stringWithFormat:@"device"];
            break;
        default:
            break;
    }
    return @"";
}

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
- (void)addPerson {
    ABPeoplePickerNavigationController *pickerController = [[ABPeoplePickerNavigationController alloc]init];
    pickerController.peoplePickerDelegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];

}
- (IBAction)editPerson:(UIBarButtonItem *)sender {
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    ABMultiValueRef addresses = ABRecordCopyValue(person, kABPersonEmailProperty);
    int addressCount = (int)ABMultiValueGetCount(addresses);
    if(addressCount > 1){
        [peoplePicker setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInteger:kABPersonEmailProperty]]];
        return YES;
    }else if(addressCount == 1){
        NSString *emailAddress = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(addresses, 0));
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        [self saveNewPerson:emailAddress firstName:firstName lastName:lastName];

        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }else{
    
       return NO;
    }
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(multiValue, identifier);
    NSString *email = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multiValue, index));
    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    [self saveNewPerson:email firstName:firstName lastName:lastName];
    return NO;
}

-(void) saveNewPerson:(NSString *)email firstName:(NSString *)firstName lastName:(NSString *)lastName{
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NotificateTargetModel *target = [NSEntityDescription insertNewObjectForEntityForName:@"NotificateTargetModel" inManagedObjectContext:context];
    target.firstname = firstName;
    target.lastname = lastName;
    target.email = email;
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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


-(IBAction)addPressed:(id)sender{
    _acthionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Contacts",@"Input",@"Search Nearby Device",nil];
    [_acthionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

#pragma mark - ActionSheet Delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self addPerson];
            break;
        case 1:
        {
            UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:nil message:@"Input email address to send notification." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            alertView.delegate = self;
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
            
        }
            break;
        case 2:
        {
            [self performSegueWithIdentifier:@"ShowNearbyDevices" sender:self];
//            AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
//            MCBrowserViewController *browserViewController = [[MCBrowserViewController alloc]initWithServiceType:kServiceType session:delegate.session];
//            browserViewController.delegate = self;
//
//            [self presentViewController:browserViewController animated:YES completion:nil];
            
        }
            break;
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    _acthionSheet = nil;
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:
        {
            NSString *text = [[alertView textFieldAtIndex:0] text];
            [self saveNewPerson:text firstName:nil lastName:nil];
        }
            break;
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.tableView reloadData];
}

//+(CNNotificateTargetModelType) cNNotificateTargetModelTypeWithInt: (NSInteger) type{
//    switch (type) {
//        case 0:
//            return CNNotificateTargetModelEmail;
//            break;
//        case 1:
//            return CNNotificateTargetModelDevice;
//        default:
//            break;
//    }
//}


//-(NSFetchedResultsController *)fetchedResultsControllerWithInt : (NSInteger)type{
//    return [self fetchedResultsController:type];
//}


-(NSInteger) numberOfDataWithType:(NSInteger) type{

    
    id sectionInfo = [[[self fetchedResultsController:(CNNotificateTargetModelType)type] sections]objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

-(NSFetchedResultsController *)fetchedResultsController : (CNNotificateTargetModelType)type{
    NSFetchedResultsController *result;
    switch (type) {
        case CNNotificateTargetModelEmail:
            result = self.fetchedResultsController;
            break;
        case CNNotificateTargetModelDevice:
            result = self.fetchedResultsControllerForDevice;
            break;
        default:
            break;
    }
    return result;
}

-(CNNotificateTargetModelType)modelTypeForFetchedResultsController : (NSFetchedResultsController *)controller{
    if(controller == nil){
        return CNNotificateTargetModelUnknown;
    }
    if([controller isEqual:self.fetchedResultsController]){
        return CNNotificateTargetModelEmail;
    }else if([controller isEqual:self.fetchedResultsControllerForDevice]){
        return CNNotificateTargetModelDevice;
    }
    return CNNotificateTargetModelUnknown;
}

-(NSFetchedResultsController *)fetchedResultsControllerForDevice{
    
    if (_fetchedResultsControllerForDevice != nil) {
        return _fetchedResultsControllerForDevice;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NotificateTargetDeviceModel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"prcdate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsControllerForDevice = theFetchedResultsController;
    _fetchedResultsControllerForDevice.delegate = self;
    return _fetchedResultsControllerForDevice;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"NotificateTargetModel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"prcdate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
    
}


#pragma mark - NSFetchedResultsController Delegate
-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
    UITableView *tableView = self.tableView;
    NSIndexPath *modifiedIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:[self modelTypeForFetchedResultsController:controller]];
    NSIndexPath *modifiedNewIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:[self modelTypeForFetchedResultsController:controller]];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:modifiedNewIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:modifiedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray
//                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

#pragma mark - BrowserViewController Delegate

-(BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{
    [self storeDiscoveryInfo:info withPeerId:peerID];
    return YES;
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    

    [browserViewController dismissViewControllerAnimated:YES completion:^{

        NSArray *deviceInfos = [self retrieveDeviceInfosFromSession:browserViewController.session];
        
        [deviceInfos enumerateObjectsUsingBlock:^(NSDictionary *deviceInfo, NSUInteger idx, BOOL *stop) {
            [self saveNewDevice:[deviceInfo objectForKey:DiscoveryKeyDisplayName] installationId:[deviceInfo objectForKey:DiscoveryKeyAdvertiserInstallationId]];
        }];
        
        [_discoveryInfos removeAllObjects];
        
        [browserViewController.session disconnect];
    }];
}


-(NSArray *)retrieveDeviceInfosFromSession: (MCSession *)session{
    NSMutableArray *deviceInfos = [NSMutableArray new];
    [session.connectedPeers enumerateObjectsUsingBlock:^(MCPeerID *peerId, NSUInteger idx, BOOL *stop) {
        NSDictionary *discoveryInfo = _discoveryInfos[peerId];
        NSLog(@"found discovery Info :%@ for peerId:%@",[discoveryInfo description],peerId.displayName);
        
        NSMutableDictionary *deviceInfo = [discoveryInfo mutableCopy];
        
        [deviceInfo setObject:peerId.displayName forKey:DiscoveryKeyDisplayName];
        [deviceInfos addObject:deviceInfo];
    }];
    return deviceInfos;
}

-(void)storeDiscoveryInfo:(NSDictionary  *)discoveryInfo withPeerId: (MCPeerID *)peerId{
    _discoveryInfos[peerId] = discoveryInfo;
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ShowNearbyDevices"]){
        NearbyDeviceBrowserTableViewController *viewController = (NearbyDeviceBrowserTableViewController *)segue.destinationViewController;
        NSArray *devices =[self.fetchedResultsControllerForDevice fetchedObjects];
        NSMutableSet *installationIds = [NSMutableSet new];
        [devices enumerateObjectsUsingBlock:^(NotificateTargetDeviceModel *target, NSUInteger idx, BOOL *stop) {
            [installationIds addObject:target.installationId];
        }];
        viewController.registerdDeviceInstallationIds = installationIds;
    }
}



@end
