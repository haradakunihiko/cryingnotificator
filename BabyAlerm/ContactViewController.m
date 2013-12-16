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
#import "Person.h"
#import "ListeningViewController.h"
#import "CryPickingController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface ContactViewController ()<ABPeoplePickerNavigationControllerDelegate,BLCryPickingDelegate>{
//    NSMutableArray* _contacts;
}

@end

@implementation ContactViewController

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
    // Return the number of rows in the section.
    return [[self contact] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", ((Person *)[self contact][indexPath.row]).firstname, ((Person *)[self contact][indexPath.row]).lastname];
    cell.detailTextLabel.text = ((Person *)[self contact][indexPath.row]).email;
    
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
        // Delete the row from the data source
        [[self contact] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
- (IBAction)addPerson:(UIBarButtonItem *)sender {
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
        Person *person = [Person new];
        person.firstname = firstName;
        person.lastname = lastName;
        person.email = emailAddress;
        [[self contact] addObject:person];
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
    Person *personObj = [Person new];
    personObj.firstname = firstName;
    personObj.lastname = lastName;
    personObj.email  = email;
    [[self contact] addObject:personObj];
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
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

-(void)cryPickingController:(CryPickingController *)cryPickingController notify:(BOOL)notify{
    NSMutableArray *addresses = [NSMutableArray new];
    [[self contact] enumerateObjectsUsingBlock:^(Person *person, NSUInteger idx, BOOL *stop) {
        [addresses addObject:person.email];
    }];
    
    [PFCloud callFunctionInBackground:@"sendMail" withParameters:@{@"addresses":addresses} block:^(id object, NSError *error) {
        NSMutableString *notice = [NSMutableString stringWithString:@"mail sent to :"];
        [[self contact] enumerateObjectsUsingBlock:^(Person *obj, NSUInteger idx, BOOL *stop) {

            [notice appendString:obj.email];
            [notice appendString:@"/"];
        }];
        NSLog(@"%@",[notice description]);
    }];
}

-(NSMutableArray*) contact{
    AppDelegate *delegate =[[UIApplication sharedApplication] delegate];
    return [delegate contacts];
}

@end
