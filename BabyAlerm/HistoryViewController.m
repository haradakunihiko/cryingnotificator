//
//  HistoryViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "History.h"
#import "HistoryDetailViewController.h"
#import "ListeningViewController.h"

@interface HistoryViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation HistoryViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
//    return [[self historyData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    HistoryModel *historyModel = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    History *history =[[self historyData] objectAtIndex:[indexPath row]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    NSString *timeString =[dateFormatter stringFromDate:[historyModel startTime]];
    cell.textLabel.text = timeString;
    // Configure the cell...
    return cell;
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ToHistoryDetail"]){
        HistoryDetailViewController *toVC = segue.destinationViewController;
        toVC.historyModel = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }else if([segue.identifier isEqualToString:@"ToHistoryGraph"]){
        __weak ListeningViewController *toVC = segue.destinationViewController;
        toVC.historyModel =[self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        toVC.showHistory = YES;
        toVC.displayType = BAGraphDisplayTypeShowAllInView;
        toVC.completionBlock = ^(){
            toVC.showHistory = NO;
            toVC.historyModel = nil;
            toVC.fetchedResultsController = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        };
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


-(NSMutableArray *)historyData{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.histData;
}



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
    
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"startTime" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    //    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
    
}


@end
