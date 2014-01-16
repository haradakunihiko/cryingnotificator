//
//  ListeningViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
#import "ListeningViewController.h"
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import "Volume.h"
#import "BAConstant.h"
#import "VolumeModel.h"
// 002003 3 276
// 002403 3 279


@interface ListeningViewController ()<BLCryPickingShowDelegate,CPTPlotDataSource,CPTPlotSpaceDelegate,NSFetchedResultsControllerDelegate,UINavigationBarDelegate>
@property (strong, nonatomic) IBOutlet UILabel *meterLavel;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@end

@implementation ListeningViewController{
    
    IBOutlet UISwitch *scrollSwitch;
    CryPickingController *_pickingController;
    BOOL playing;
    CPTPlotRange *yRange;
    NSInteger prevMag;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;
        self.displayType = BAGraphDisplayTypeShowRecentInViewAndGlobal;
    }
    return self;
}
-(id)init{
    if(self = [super init]){
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;
        self.displayType = BAGraphDisplayTypeShowRecentInViewAndGlobal;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;
        self.displayType = BAGraphDisplayTypeShowRecentInViewAndGlobal;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initPlot];
    
    if(self.showHistory){
        
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self updatePlotspaceToShowAll];
        [[self.hostView hostedGraph] reloadData];
    }
}

- (IBAction)done:(UIBarButtonItem *)sender {
    if(self.completionBlock){
        self.completionBlock();
    }
}
- (IBAction)start:(UIBarButtonItem *)sender {
    [_pickingController startListening];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"history == %@", [self historyModel]];
    NSLog(@"history:%@",[self historyModel].startTime);
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    
    self.displayType = BAGraphDisplayTypeShowRecentInViewAndGlobal;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)] animated:YES];
}

-(void) stop:(id)sender{
    [_pickingController stopListening];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(start:)] animated:YES];
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
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    // 4 - Set padding for plot area
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    [graph.plotAreaFrame setPaddingRight:30.0f];
    
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
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableLineStyle *lineStyleClear = [CPTMutableLineStyle lineStyle];
    lineStyleClear.lineWidth = 0.0f;
    lineStyleClear.lineColor = [CPTColor clearColor];
    
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableTextStyle *textStyleClear = [[CPTMutableTextStyle alloc] init];
    textStyleClear.color = [CPTColor clearColor];
    textStyleClear.fontName = @"Helvetica-Bold";
    textStyleClear.fontSize = 11.0f;
    
    
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 2.0f;

    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor blackColor];
    tickLineStyle.lineWidth = 1.0f;
    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
//    x.title = @"Time";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
//    x.majorTickLength = 4.0f;
    x.tickDirection = CPTSignPositive;
    
    // Graph data prepare
	NSDate *refDate = [self baseTime];

    //per 5s
	x.majorIntervalLength = CPTDecimalFromFloat(30.0f);
//	x.minorTicksPerInterval = 10;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];

	CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;

    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
//    y.title = @"Price";
//    y.titleTextStyle = axisTitleStyle;
//    y.titleOffset = -40.0f;
    y.axisLineStyle = lineStyleClear;
    y.majorGridLineStyle = gridLineStyle;
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
    NSMutableSet *yMinorLocations = [NSMutableSet set];    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
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
            xLocation = MAX(xLocation, 0);
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
- (IBAction)fireManually:(UIButton *)sender {
//    [_pickingController notify];
}

-(void)cryPickingController:(CryPickingController *)cryPickingController volume:(Volume * )volume{
    NSString *meterText =[ NSString stringWithFormat: @"peak:%d average:%d",(int)roundf(volume.peak),(int)roundf(volume.average)];
    
//    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    if([self volumeCount] == 1){
        [self configureAxes];
    }
    
    [self updatePlotSpace: self.displayType];
   

    [[self.hostView hostedGraph] reloadData];

    self.meterLavel.text =meterText;
}

-(void)setCryingVCDelegate:(id<BLCryPickingDelegate>)delegate{
    if(!_pickingController){
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;
    }
    _pickingController.delegate = delegate;
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
//    NSLog(@"%d",idx);
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
- (IBAction)switchChanged:(UISwitch *)sender {
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    if(sender.on){
        self.displayType = BAGraphDisplayTypeShowRecentInViewAndGlobal;
        plotSpace.allowsUserInteraction = NO;
    }else{
        self.displayType = BAGraphDisplayTypeShowAnyInViewAndAllInGlobal;
        plotSpace.allowsUserInteraction = YES;
    }
}

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate{
    if(coordinate == CPTCoordinateY){
        return yRange;
    }else if(coordinate == CPTCoordinateX){
        int rateOfMagnification =  [self rateOfMagnification:newRange];
        if(rateOfMagnification<1){
            return ((CPTXYPlotSpace *)space).xRange;
        }
    }
    return newRange;
}

-(void)plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate{
//    CPTPlotRange * xRange =((CPTXYPlotSpace *)space).xRange;
//    float mag=  [[NSDecimalNumber decimalNumberWithDecimal:xRange.length] intValue]/DisplayXRange;
//    rateOfMagnification =  (int)mag;
//    NSLog(@"realMag:%f intMag:%d ",mag,rateOfMagnification );
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    //per 5s
    NSInteger currentMag = [self rateOfMagnification];
    if(prevMag !=currentMag){
        x.majorIntervalLength = CPTDecimalFromFloat(30.0f * [self rateOfMagnification]);
        [[self.hostView hostedGraph]reloadData];
    }
    prevMag = currentMag;
    
}
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
    NSLog(@"history:%@",[self historyModel].startTime);
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
    if(self.showHistory){
        return _historyModel;
    }else{
        return _pickingController.historyModel;
    }
}

-(void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item{
    NSLog(@"pop!");
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
    interval = MAX(DisplayXRange, interval);
    
    x.majorIntervalLength = CPTDecimalFromFloat(interval / 2);
    
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(interval)];
    
    [[self.hostView hostedGraph]reloadData];
}

@end
