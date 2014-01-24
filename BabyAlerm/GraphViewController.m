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

@property NSArray *listeningConstraints;
@property NSArray *historyConstraints;

@end

@implementation GraphViewController{
    
    IBOutlet UISwitch *scrollSwitch;
    BOOL playing;
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
        [self updatePlotSpace:self.displayType];
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
        [self updatePlotSpace:self.displayType];
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

}
-(void)configureAxes{
    
    // 1 - Create styles
//    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
//    axisTitleStyle.color = [CPTColor whiteColor];
//    axisTitleStyle.fontName = @"Helvetica-Bold";
//    axisTitleStyle.fontSize = 12.0f;
//    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
//    axisLineStyle.lineWidth = 2.0f;
//    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableLineStyle *lineStyleClear = [CPTMutableLineStyle lineStyle];
    lineStyleClear.lineWidth = 0.0f;
    lineStyleClear.lineColor = [CPTColor clearColor];
    
    
//    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
//    axisTextStyle.color = [CPTColor whiteColor];
//    axisTextStyle.fontName = @"Helvetica-Bold";
//    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableTextStyle *textStyleClear = [[CPTMutableTextStyle alloc] init];
    textStyleClear.color = [CPTColor clearColor];
    textStyleClear.fontName = @"Helvetica-Bold";
    textStyleClear.fontSize = 11.0f;
    
    
    
//    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
//    tickLineStyle.lineColor = [CPTColor whiteColor];
//    tickLineStyle.lineWidth = 2.0f;

//    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
//    tickLineStyle.lineColor = [CPTColor blackColor];
//    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTXYAxis *x = axisSet.xAxis;
//    CPTXYAxis
    _defaultXAxisStyle = x.axisLineStyle;
    x.axisLineStyle = lineStyleClear;
    
//    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
//    x.labelTextStyle = axisTextStyle;
//    x.majorTickLineStyle = axisLineStyle;
    x.tickDirection = CPTSignPositive;
    
    x.orthogonalCoordinateDecimal = [[NSNumber numberWithFloat:DisplayYLocation] decimalValue];
    
    // 4 - Configure y-axis
    CPTXYAxis *y = axisSet.yAxis;

//    y.orthogonalCoordinateDecimal = [[NSNumber numberWithFloat:-30.0f] decimalValue];
    y.axisLineStyle = lineStyleClear;
//    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = textStyleClear;
    y.labelOffset = 10.0f;
    y.majorTickLineStyle = lineStyleClear;
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



-(void)updatePlotSpace : (BAGraphDisplayType) showType{
    switch (showType) {
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
            xLocation = MAX(xLocation, -8.0f);
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
    NSInteger valueCount =[self volumeCount];
    int rateOfMagnification = [self rateOfMagnification];
    NSInteger theIndex;
    NSInteger lastIndex;
    if(self.displayType ==BAGraphDisplayTypeShowRecentInViewAndGlobal){
        NSInteger offset =  MAX(valueCount - 60,0);
        theIndex = idx + offset;
        lastIndex = theIndex;
    }else{
        theIndex = idx * rateOfMagnification;
        lastIndex = MAX(0, (idx + 1) * rateOfMagnification -1) ;
    }
    
    float maxAverage = -100.0f;
    float maxPeak = -100.0f;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (theIndex < valueCount) {
                NSDate *baseTime = [self baseTime];
                VolumeModel *theVolume = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:theIndex inSection:0]];
                NSDate *time = theVolume.time;
                return [NSNumber numberWithDouble:[time timeIntervalSinceDate:baseTime]];
            }
            break;
        case CPTScatterPlotFieldY:
            for (NSInteger i = theIndex; i <= lastIndex && i < valueCount; i++) {
                VolumeModel *theVolume = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                maxAverage = MAX(maxAverage, [theVolume.average floatValue]);
                maxPeak = MAX(maxPeak,[theVolume.peak floatValue]);
            }
            
            
            if ([plot.identifier isEqual:TickerSymbolAverage] == YES) {
                return [NSNumber numberWithFloat: maxAverage];
            } else if ([plot.identifier isEqual:TickerSymbolPeak] == YES) {
                return [NSNumber numberWithFloat: maxPeak];
            }
            break;
    }
    return[NSDecimalNumber zero];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    if(self.displayType == BAGraphDisplayTypeShowRecentInViewAndGlobal){
        return MIN([self volumeCount], 60);
    }else{
        return [self volumeCount]/[self rateOfMagnification];
    }
}

-(NSDate *)baseTime{
    if([self volumeCount] >0){
        VolumeModel *volume = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        return volume.time;
    }else{
        return [NSDate date];
    }
}

//-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate{
//    if(coordinate == CPTCoordinateY){
//        return yRange;
//    }else if(coordinate == CPTCoordinateX){
//        int rateOfMagnification =  [self rateOfMagnification:newRange];
//        if(rateOfMagnification<1){
//            return ((CPTXYPlotSpace *)space).xRange;
//        }
//    }
//    return newRange;
//}

//-(void)plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate{
////    CPTPlotRange * xRange =((CPTXYPlotSpace *)space).xRange;
////    float mag=  [[NSDecimalNumber decimalNumberWithDecimal:xRange.length] intValue]/DisplayXRange;
////    rateOfMagnification =  (int)mag;
////    NSLog(@"realMag:%f intMag:%d ",mag,rateOfMagnification );
//    
//    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
//    // 3 - Configure x-axis
//    CPTAxis *x = axisSet.xAxis;
//    //per 5s
//    NSInteger currentMag = [self rateOfMagnification];
//    if(prevMag !=currentMag){
//        x.majorIntervalLength = CPTDecimalFromFloat(30.0f * [self rateOfMagnification]);
//        [[self.hostView hostedGraph]reloadData];
//    }
//    prevMag = currentMag;
//    
//}
-(int)rateOfMagnification :(CPTPlotRange*)range{
    float mag=  [[NSDecimalNumber decimalNumberWithDecimal:range.length] intValue]/DisplayXRange;
    
    return (int )mag;
}

-(int)rateOfMagnification{
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    return [self rateOfMagnification:plotSpace.xRange];
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
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
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"history == %@", [self historyModel]];
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

-(NSInteger) volumeCount{
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

-(NSDate *)lastTime{
    NSInteger count = [self volumeCount];
    if(count > 0){
        VolumeModel *volume =[_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:count -1 inSection:0]];
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
    interval = MAX(DisplayXRange - DisplayXRightMergin * 2, interval);
    
    x.majorIntervalLength = CPTDecimalFromFloat(interval / 3);
    
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-interval * 2/15) length:CPTDecimalFromFloat(interval + interval * 4 / 15)];
    
//    [[self.hostView hostedGraph]reloadData];
}

-(void)updateView : (VolumeModel*)volume{
    NSString *meterText =[ NSString stringWithFormat: @"peak:%d average:%d",(int)roundf([volume.peak intValue]),(int)roundf([volume.average intValue])];
    
    //    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    if([self volumeCount] == 1){
        [self resetXAxes];
    }
    
    [self updatePlotSpace: self.displayType];
    
    
    [[self.hostView hostedGraph] reloadData];
    
    self.meterLavel.text =meterText;
}

-(void)initializeWithDisplaytype:(BAGraphDisplayType)displayType{
    self.fetchedResultsController = nil;
    self.displayType = displayType;
}

@end
