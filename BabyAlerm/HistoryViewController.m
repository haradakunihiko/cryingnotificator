//
//  HistoryViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "GraphViewController.h"
#import "HistoryGraphViewController.h"
#import "TDBadgedCell.h"


@interface HistoryViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate,GraphViewControllerDataSource>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation HistoryViewController{
    BOOL _showsExecuting;
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
    
    
    [self reloadData];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateExecutingCell:) name:CryingDetectedNotification object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSFetchedResultsController delegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
//    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[[self indexPathOfTable:newIndexPath]] withRowAnimation:UITableViewRowAnimationFade];
//
            //        [self.historyViewController reloadData];
            
//            if ([theObject.type isEqualToNumber:@2]) {
//                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//                [self.tableView insertRowsAtIndexPaths:@[] withRowAnimation:UITableViewRowAnimationFade];
//                
//                
//            }
//            [tableView insertRowsAtIndexPaths:@[[self indexPathOfTable:newIndexPath]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[[self indexPathOfTable:indexPath]] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [tableView reloadRowsAtIndexPaths:@[[self indexPathOfTable:indexPath]] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
   return [self sectionForHistory] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_showsExecuting && section == 0){
        return 1;
    }else{
        return [self numberOfHistory];
    }
//    return [[self historyData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    HistoryModel *historyModel;
    if(_showsExecuting && indexPath.section == 0){
        static NSString *CellIdentifier = @"ExecutingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        historyModel = self.convinedViewController.ongoingHistoryModel;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
        NSString *timeString =[dateFormatter stringFromDate:[historyModel startTime]];
        cell.textLabel.text = timeString;
    }else{
        
        historyModel = [self.fetchedResultsController objectAtIndexPath:[self indexPathOfData:indexPath]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
        
        if ([[historyModel valueForKey:@"isSelfData"] boolValue]) {
            
            static NSString *CellIdentifier = @"Cell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            
            NSTimeInterval interval = [historyModel.endTime timeIntervalSinceDate:historyModel.startTime];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%dh%dm%ds" , (int)interval / 3600,(int)interval / 60 , (int)fmod(interval, 60)];

            cell.textLabel.text = [dateFormatter stringFromDate:[historyModel startTime]];
            if([historyModel.cryTimes intValue] == 0){
                ((TDBadgedCell *)cell).badgeString = nil;
            }else{
                ((TDBadgedCell *)cell).badgeString = [historyModel.cryTimes stringValue];
            }
            ((TDBadgedCell *)cell).badgeTextColor = [UIColor whiteColor];
        }else{
            static NSString *CellIdentifier = @"OtherDataCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = [dateFormatter stringFromDate:[historyModel endTime]];
            cell.detailTextLabel.text = historyModel.deviceName;
            
        }
        
    }
    
    if([historyModel.cryTimes intValue] == 0){
        ((TDBadgedCell *)cell).badgeString = nil;
    }else{
        ((TDBadgedCell *)cell).badgeString = [historyModel.cryTimes stringValue];
    }
    ((TDBadgedCell *)cell).badgeTextColor = [UIColor whiteColor];
    
    
    if([[historyModel valueForKey:@"isViewed"] boolValue]){
        ((TDBadgedCell *)cell).badgeColor = [UIColor blueColor];
    }else{
        ((TDBadgedCell *)cell).badgeColor = [UIColor redColor];
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (!_showsExecuting  || section == 1) {
        return @"history";
    }else{
        return nil;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_showsExecuting && indexPath.section == 0){
        self.convinedViewController.ongoingHistoryModel.isViewed = [NSNumber numberWithBool: YES];
//        [self.convinedViewController switchGraphView:NO];
        self.convinedViewController.showHistory = NO;
//        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    }else{
        self.graphViewController.datasource = self;
        [self graphViewControllerDataSource].isViewed = [NSNumber numberWithBool:YES];
        [self.graphViewController initializeWithDisplaytype:BAGraphDisplayTypeShowAllInView];
        //    [self.graphViewController.view setNeedsDisplay];
        [self.graphViewController redraw];
//        [self.convinedViewController switchGraphView:YES];
        self.convinedViewController.showHistory = YES;
    }
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    [delegate saveContext];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    ((TDBadgedCell *)cell).badgeColor = [UIColor blueColor];
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [[self.tableView cellForRowAtIndexPath:indexPath] reloadInputViews];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
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

#pragma mark - Navigation

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"HistoryModel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sortByStartTime = [[NSSortDescriptor alloc]
                              initWithKey:@"startTime" ascending:NO];
//    NSSortDescriptor *sortByExecuting = [[NSSortDescriptor alloc] initWithKey:@"isExecuting" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortByStartTime, nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@" isSelfData = 1 and isExecuting = 0 "];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
    
}

-(HistoryModel *)graphViewControllerDataSource{
    return [self.fetchedResultsController objectAtIndexPath: [self indexPathOfData:[self.tableView indexPathForSelectedRow]]];
}


-(IBAction)exitFromGraph:(UIStoryboardSegue *)segue{
    // for unwind segue
}

-(IBAction)clear:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear" otherButtonTitles: nil];
    
    [actionSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
        {
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            NSManagedObjectContext *context = delegate.managedObjectContext;
            
            NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
            [fetch setEntity:[NSEntityDescription entityForName:@"HistoryModel" inManagedObjectContext:context]];
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
    [self.tableView reloadData];
}


-(void)refreshTable{
    [self reloadData];

    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

-(void)reloadData{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

-(NSIndexPath *) indexPathOfData : (NSIndexPath *) indexPath{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:0];
}

-(NSIndexPath *)indexPathOfTable: (NSIndexPath *) indexPath{
    return [NSIndexPath indexPathForRow:indexPath.row inSection:[self sectionForHistory]];
}

-(int) sectionForHistory{
    if(_showsExecuting){
        return 1;
    }else{
        return 0;
    }
}

-(NSInteger)numberOfHistory{
    id sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

-(void)updateExecutingCell: (NSNotification *)notification{
    NSLog(@"updateExecutingCell");

    if(self.convinedViewController.executing){
        if(!self.convinedViewController.showHistory){
            self.convinedViewController.ongoingHistoryModel.isViewed = [NSNumber numberWithBool:YES];
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:NO];
    }
}

-(void)showExecutingCell{
    _showsExecuting = YES;
    [self.tableView beginUpdates];
    //
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    //
    [self.tableView endUpdates];
}

-(void)hideExecutingCell{
    if (_showsExecuting) {
        _showsExecuting = NO;
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }

}




@end
