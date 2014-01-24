//
//  HistoryViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/12/14.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "HistoryDetailViewController.h"
#import "GraphViewController.h"
#import "HistoryGraphViewController.h"

@interface HistoryViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate,GraphViewControllerDataSource>

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
    
    
    [self reloadData];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refreshControl;

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.convinedViewController.executing){
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numrow %d", section);
    if(self.convinedViewController.executing && section == 0){
        return 1;
    }else{
        return [self numberOfHistory];
    }
//    return [[self historyData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.convinedViewController.executing && indexPath.section == 0){
        static NSString *CellIdentifier = @"ExecutingCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        HistoryModel *historyModel = self.convinedViewController.ongoingHistoryModel;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
        NSString *timeString =[dateFormatter stringFromDate:[historyModel startTime]];
        cell.textLabel.text = timeString;
        return cell;
    }else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
       
        HistoryModel *historyModel = [self.fetchedResultsController objectAtIndexPath:[self indexPathOfData:indexPath]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
        NSString *timeString =[dateFormatter stringFromDate:[historyModel startTime]];
        cell.textLabel.text = timeString;

        NSTimeInterval interval = [historyModel.endTime timeIntervalSinceDate:historyModel.startTime];

                fmod(interval, 300);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%dh%dm%ds" , (int)interval / 3600,(int)interval / 60 , (int)fmod(interval, 60)];
        
        // Configure the cell...
        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSLog(@"title %d", section);
    if (!self.convinedViewController.executing  || section == 1) {
        return @"history";
    }else{
        return nil;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"select row %@",indexPath);
    if(self.convinedViewController.executing && indexPath.section == 0){
        [self.convinedViewController switchGraphView:NO];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        self.graphViewController.datasource = self;
        [self.graphViewController initializeWithDisplaytype:BAGraphDisplayTypeShowAllInView];
        //    [self.graphViewController.view setNeedsDisplay];
        [self.graphViewController redraw];
        [self.convinedViewController switchGraphView:YES];
    }
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
        toVC.historyModel = [self.fetchedResultsController objectAtIndexPath:[self indexPathOfData: [self.tableView indexPathForSelectedRow]]];
    }else if([segue.identifier isEqualToString:@"ToHistoryGraph"]){
        HistoryGraphViewController *historyGraphViewController = segue.destinationViewController;
        historyGraphViewController.historyModel =[self.fetchedResultsController objectAtIndexPath:[self indexPathOfData: [self.tableView indexPathForSelectedRow]]];
        
//        toVC.showHistory = YES;
//        toVC.displayType = BAGraphDisplayTypeShowAllInView;
//        toVC.completionBlock = ^(){
//            toVC.showHistory = NO;
//            toVC.historyModel = nil;
//            toVC.fetchedResultsController = nil;
//            [self dismissViewControllerAnimated:YES completion:nil];
//        };
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
                              initWithKey:@"startTime" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endTime != null"];
    
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
    NSLog(@"%d",buttonIndex);
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

-(NSInteger)numberOfHistory{
    
    id sectionInfo = [[self.fetchedResultsController sections]objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}


@end
