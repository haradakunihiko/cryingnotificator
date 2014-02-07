//
//  ListeningViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import "BAConstant.h"
#import "VolumeModel.h"

//#import "CPTPlotAreaFrame.h"
// 002003 3 276
// 002403 3 279

@interface UIWindow(AutoLayoutDebug)
+(UIWindow *) keyWindow;
-(NSString *) _autolayoutTrace;

@end


@interface GraphViewController ()<CPTPlotDataSource,CPTPlotSpaceDelegate,NSFetchedResultsControllerDelegate,UINavigationBarDelegate>
@property (strong, nonatomic) IBOutlet UILabel *meterLavel;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;

@property (strong,nonatomic) CPTMutableLineStyle *lineStyleClear;
@property (strong,nonatomic)     CPTMutableTextStyle *textStyleClear;

@property NSArray *listeningConstraints;
@property NSArray *historyConstraints;

@end

@implementation GraphViewController{
    
    IBOutlet UISwitch *scrollSwitch;
    CPTPlotRange *yRange;
    NSInteger prevMag;
    CPTLineStyle *_defaultXAxisStyle;

}
-(void)viewDidLoad{
    [super viewDidLoad];
    [self initPlot];
    
    
    if(self.datasource){
        
        NSError *error;
        // does not need at the main view
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        // this method should be called for history init;
        //    [self updatePlotspaceToShowAll];
        [self resetXAxes];
        [self updatePlotSpace];
        [[self.hostView hostedGraph] reloadData];
    }
    
}

-(void)redraw{
    if(self.datasource){
        
        NSError *error;
        // does not need at the main view
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        // this method should be called for history init;
        //    [self updatePlotspaceToShowAll];
        [self resetXAxes];
        [self updatePlotSpace];
        [[self.hostView hostedGraph] reloadData];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender {
    if(self.completionBlock){
        self.completionBlock();
    }
}

-(void) initPlot{
    [self configureHosts];
    [self configureGraph];
    [self configurePlotSpace];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHosts{
    
    
}
-(void)configureGraph{
    // 1 - Create the graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    self.hostView.hostedGraph = graph;
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    graph.plotAreaFrame.borderLineStyle = nil;
    
    // 4 - Set padding for plot area
    graph.paddingBottom = 0.0f;
    graph.paddingLeft = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingTop = 0.0f;
    
//    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:15.0f];
//    [graph.plotAreaFrame setPaddingRight:30.0f];
}
-(void)configurePlotSpace{
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.delegate = self;
    
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(DisplayYLocation) length:CPTDecimalFromFloat(DisplayYRange)];
    yRange =[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(DisplayYLocation) length:CPTDecimalFromFloat(DisplayYRange)];
    plotSpace.yRange = yRange;
    
}


-(void)configurePlots{
    
    // 1 - Get graph and plot space
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 2 - Create the three plots
    CPTScatterPlot *peakPlot = [[CPTScatterPlot alloc] init];
    peakPlot.dataSource = self;
    peakPlot.identifier = TickerSymbolPeak;
    CPTColor *peakColor = [CPTColor redColor];
    [graph addPlot:peakPlot toPlotSpace:plotSpace];
    
    
    CPTScatterPlot *averagePlot = [[CPTScatterPlot alloc] init];
    averagePlot.dataSource = self;
    averagePlot.identifier = TickerSymbolAverage;
    CPTColor *averageColor = [CPTColor greenColor];
    [graph addPlot:averagePlot toPlotSpace:plotSpace];
    
    CPTScatterPlot *threasholdPlot = [[CPTScatterPlot alloc] init];
    threasholdPlot.dataSource = self;
    threasholdPlot.identifier = TickerSymbolThreashold;
    CPTColor *threasholdColor = [CPTColor whiteColor];
    [graph addPlot:threasholdPlot toPlotSpace:plotSpace];
    
    
    
    

    // 4 - Create styles and symbols
    CPTMutableLineStyle *peakLineStyle = [peakPlot.dataLineStyle mutableCopy];
    peakLineStyle.lineWidth = 2.5;
    peakLineStyle.lineColor = peakColor;
    peakPlot.dataLineStyle = peakLineStyle;
    CPTMutableLineStyle *peakSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    peakSymbolLineStyle.lineColor = peakColor;
    
    CPTMutableLineStyle *averageLineStyle = [averagePlot.dataLineStyle mutableCopy];
    averageLineStyle.lineWidth = 1.0;
    averageLineStyle.lineColor = averageColor;
    averagePlot.dataLineStyle = averageLineStyle;
    CPTMutableLineStyle *averageSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    averageSymbolLineStyle.lineColor = averageColor;
    
    
    CPTMutableLineStyle *threasholdLineStyle = [threasholdPlot.dataLineStyle mutableCopy];
    threasholdLineStyle.lineWidth = 0.5;
    threasholdLineStyle.lineColor = threasholdColor;
    threasholdPlot.dataLineStyle = threasholdLineStyle;
//    CPTMutableLineStyle *threasholdSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//    averageSymbolLineStyle.lineColor = averageColor;

}
-(void)configureAxes{
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
//    CPTXYAxis
    _defaultXAxisStyle = x.axisLineStyle;
    [self clearXAxis];
    x.tickDirection = CPTSignPositive;
    x.orthogonalCoordinateDecimal = [[NSNumber numberWithFloat:DisplayYLocation] decimalValue];
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;

    y.axisLineStyle = self.lineStyleClear;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = self.textStyleClear;
    y.labelOffset = 10.0f;
    y.majorTickLineStyle = self.lineStyleClear;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    y.preferredNumberOfMajorTicks = 10;
    y.minorTicksPerInterval = 0;
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
}

-(void) clearXAxis{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = self.lineStyleClear;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
}

-(void)clearView{
    [self clearXAxis];
    [[self.hostView hostedGraph] reloadData];
}

-(void) resetXAxes{
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    
    x.axisLineStyle = _defaultXAxisStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    // Graph data prepare
	NSDate *refDate = [self baseTime];
    
    //per 5s
	x.majorIntervalLength = CPTDecimalFromFloat(20.0f);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    
	CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
}



-(void)updatePlotSpace{
    switch (self.displayType) {
        case BAGraphDisplayTypeShowAllInView:
            [self updatePlotspaceToShowAll];
            break;
        case BAGraphDisplayTypeShowRecentInViewAndAllInGlobal:
        {
            CPTGraph *graph = [self.hostView hostedGraph];
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
            
            // 5 - Set up plot space
            CGFloat xLocation = [[self lastTime] timeIntervalSinceDate:[self baseTime]] - (DisplayXRange -DisplayXRightMergin);
            xLocation = MAX(xLocation, 0);
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLocation) length:CPTDecimalFromFloat(DisplayXRange)];
            
            // global x range
            [self updateGlobalPlotSpace];
            break;
        }
        case BAGraphDisplayTypeShowAnyInViewAndAllInGlobal:
            [self updateGlobalPlotSpace];
            break;
        case BAGraphDisplayTypeShowRecentInViewAndGlobal:
        {
            CPTGraph *graph = [self.hostView hostedGraph];
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
            
            // 5 - Set up plot space
            CGFloat xLocation = [[self lastTime] timeIntervalSinceDate:[self baseTime]] - (DisplayXRange -DisplayXRightMergin);
            xLocation = MAX(xLocation, -DisplayXLeftMergin);
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLocation) length:CPTDecimalFromFloat(DisplayXRange)];
            
            // global x range
            plotSpace.globalXRange =[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLocation) length:CPTDecimalFromFloat(DisplayXRange)];
            break;
        }
        default:
            break;
    }
}

-(void)updateGlobalPlotSpace{
    
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    CGFloat xGlobalRangeLocation= [[self lastTime] timeIntervalSinceDate:[self baseTime]] - (GlobalXRange);
    xGlobalRangeLocation = MAX(xGlobalRangeLocation, 0.0f);
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xGlobalRangeLocation) length:CPTDecimalFromFloat(GlobalXRange+DisplayXRightMergin) ];
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

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    if(!self.historyModel){
        return 0;
    }

    NSInteger valueCount =[self volumeCount];
    NSInteger theIndex;
    if(self.displayType ==BAGraphDisplayTypeShowRecentInViewAndGlobal){
        NSInteger offset =  MAX(valueCount - PlotXRange,0);
        theIndex = idx + offset;
    }else{
        theIndex = idx;
    }

    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if([plot.identifier isEqual:TickerSymbolThreashold]){
                
                CPTGraph *graph = [self.hostView hostedGraph];
                CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
                if (idx == 0) {
                    return [NSDecimalNumber decimalNumberWithDecimal:plotSpace.xRange.location ];
                }else{
                    return  [[NSDecimalNumber decimalNumberWithDecimal:plotSpace.xRange.location ]decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:plotSpace.xRange.length] ];
                //                    return plotSpace.xRange.location + plotSpace.xRange.length;
                }

            }else{
                if (theIndex < valueCount) {
                    NSDate *baseTime = [self baseTime];
                    VolumeModel *theVolume = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
                    NSDate *time = theVolume.time;
                    return [NSNumber numberWithDouble:[time timeIntervalSinceDate:baseTime]];
                }
            }
            break;
        case CPTScatterPlotFieldY:
        {
            if([plot.identifier isEqual:TickerSymbolThreashold]){
                return [NSNumber numberWithFloat: [[NSUserDefaults standardUserDefaults] floatForKey:SettingKeyThreshold]];
            }else{
                
                if (theIndex < valueCount) {
                    VolumeModel *theVolume = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
                    if ([plot.identifier isEqual:TickerSymbolAverage] == YES) {
                        return theVolume.average;
                    } else if ([plot.identifier isEqual:TickerSymbolPeak] == YES) {
                        return theVolume.peak;
                    }
                }
            }
        }
            break;
    }
    return[NSDecimalNumber zero];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    if(!self.historyModel){
        return 0;
    }
    
    if([plot.identifier isEqual:TickerSymbolThreashold]){
        return 2;
    }
    if(self.displayType == BAGraphDisplayTypeShowRecentInViewAndGlobal){
        return MIN([self volumeCount], PlotXRange);
    }else{
        return [self volumeCount];
    }
}

-(NSDate *)baseTime{
    if(self.historyModel){
        return self.historyModel.startTime;
    }else{
        return [NSDate date];
    }
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    if(!self.historyModel){
        return nil;
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"VolumeModel" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"time" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSPredicate *predicate;
//    if(self.displayType == BAGraphDisplayTypeShowAllInView){
//        predicate =[NSPredicate predicateWithFormat:@"history == %@ and enabled == 1 ", [self historyModel]];
//    }else{
//        predicate =[NSPredicate predicateWithFormat:@"history == %@ ", [self historyModel]];
//    }
        predicate =[NSPredicate predicateWithFormat:@"history == %@ and enabled == 1 ", [self historyModel]];
    
    [fetchRequest setPredicate:predicate];
    if(self.displayType == BAGraphDisplayTypeShowRecentInViewAndGlobal){
        [fetchRequest setFetchBatchSize:60];
    }else{
        [fetchRequest setFetchBatchSize:60];
    }

    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:context sectionNameKeyPath:nil
                                                   cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
    
}

-(NSInteger) volumeCount{
    if(!self.historyModel){
        return 0;
    }
    id  sectionInfo =
    [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

-(NSDate *)lastTime{
    if(!self.historyModel){
        return nil;
    }
    NSInteger count = [self volumeCount];
    if(count > 0){
        VolumeModel *volume =[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:count -1 inSection:0]];
        return volume.time;
    }else{
        return nil;
    }
}

-(HistoryModel *)historyModel{
    if(self.datasource){
        return [self.datasource graphViewControllerDataSource];
    }else{
        return _historyModel;
    }
}

-(void)updatePlotspaceToShowAll{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    CPTAxis *x = axisSet.xAxis;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
	CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = [self baseTime];
    x.labelFormatter = timeFormatter;
    
    double interval =([[self lastTime] timeIntervalSince1970] - [[self baseTime] timeIntervalSince1970]);
    interval = MAX(PlotXRange, interval);
    
    x.majorIntervalLength = CPTDecimalFromFloat(interval / 3);
    
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-interval * 2/15) length:CPTDecimalFromFloat(interval + interval * 4 / 15)];
    
//    [[self.hostView hostedGraph]reloadData];
}

-(void)updateView : (VolumeModel*)volume{
    NSString *meterText =[ NSString stringWithFormat: @"peak:%d average:%d",(int)roundf([volume.peak intValue]),(int)roundf([volume.average intValue])];
    self.meterLavel.text =meterText;
}


-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            if (self.autoUpdate) {
                [[self.hostView hostedGraph]reloadData];
                [self updatePlotSpace];
            }
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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


-(void)initializeWithDisplaytype:(BAGraphDisplayType)displayType{
    self.fetchedResultsController = nil;
    self.displayType = displayType;
    if (displayType == BAGraphDisplayTypeShowRecentInViewAndGlobal) {
        self.autoUpdate = YES;
    }else{
        self.autoUpdate = NO;
    }
}

-(CPTMutableLineStyle *)lineStyleClear{
    if(!_lineStyleClear){
        _lineStyleClear= [CPTMutableLineStyle lineStyle];
        _lineStyleClear.lineWidth = 0.0f;
        _lineStyleClear.lineColor = [CPTColor clearColor];
    }
    return _lineStyleClear;
}

-(CPTMutableTextStyle *)textStyleClear{
    if (!_textStyleClear) {
        _textStyleClear.color = [CPTColor clearColor];
        _textStyleClear.fontName = @"Helvetica-Bold";
        _textStyleClear.fontSize = 11.0f;
    }
    return _textStyleClear;
}

-(void)performFetch{
    NSError *error;
    // does not need at the main view
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    }
}

@end
