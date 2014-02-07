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

@interface ContactViewController ()<ABPeoplePickerNavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,NSFetchedResultsControllerDelegate>{

}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ContactViewController{
    UIActionSheet *_acthionSheet;
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
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
//    _contacts = [NSMutableArray new];

    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
   NotificateTargetModel *target = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
//    cell.textLabel.text = ((Person *)[self contact][indexPath.row]).email;
//    cell.detailTextLabel.text = ((Person *)[self contact][indexPath.row]).fullname;
    cell.textLabel.text = target.email;
    cell.detailTextLabel.text = target.fullname;
    
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
        NotificateTargetModel *target = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    int addressCount = ABMultiValueGetCount(addresses);
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

- (void) showMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@""
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}


-(IBAction)addPressed:(id)sender{
    _acthionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Contacts",@"Input",nil];
    [_acthionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}
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
        default:
            break;
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    _acthionSheet = nil;
}

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

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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



@end
