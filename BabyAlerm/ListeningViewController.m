//
//  ListeningViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
//001021 1 19
//002821 4 28.3

#import "ListeningViewController.h"
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import "Volume.h"
#import "BAConstant.h"

@interface ListeningViewController ()<BLCryPickingShowDelegate,CPTPlotDataSource,CPTPlotSpaceDelegate>
@property (strong, nonatomic) IBOutlet UILabel *meterLavel;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostView;


@end

@implementation ListeningViewController{
    
    IBOutlet UISwitch *scrollSwitch;
    CryPickingController *_pickingController;
    NSMutableArray *_volumes;
    BOOL playing;
//    NSInteger rateOfMagnification;
    CPTPlotRange *yRange;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _volumes = [NSMutableArray new];
        
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;
    
    }
    return self;
}

-(id)init{
    if(self = [super init]){
        _volumes = [NSMutableArray new];
        
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super initWithCoder:aDecoder]){
        _volumes = [NSMutableArray new];
        
        _pickingController = [CryPickingController new];
        _pickingController.showDelegate = self;    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)done:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)start:(UIBarButtonItem *)sender {
    [_volumes removeAllObjects];
    [_pickingController startListening];
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
    // 2 - Set graph title
//    NSString *title = @"Crying Volmes";
//    graph.title = title;
    // 3 - Create and set text style
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
    // 5 - Enable user interactions for plot space
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.delegate = self;
    
    [self configurePlotSpace];
}
-(void)configurePlotSpace{
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    // 5 - Set up plot space
    CGFloat xLocation = [[[_volumes lastObject]time] timeIntervalSinceDate:[self baseTime]] - (DisplayXRange -DisplayXRightMergin);
    xLocation = MAX(xLocation, 0);
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLocation) length:CPTDecimalFromFloat(DisplayXRange)];
    yRange =[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(DisplayYLocation) length:CPTDecimalFromFloat(DisplayYRange)];
    plotSpace.yRange = yRange;
    [self configureGlobalPlotSpace];
}
-(void)configureGlobalPlotSpace{
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    CGFloat xGlobalRangeLocation= [[[_volumes lastObject]time] timeIntervalSinceDate:[self baseTime]] - (GlobalXRange);
    xGlobalRangeLocation = MAX(xGlobalRangeLocation, 0.0f);
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xGlobalRangeLocation) length:CPTDecimalFromFloat(GlobalXRange+DisplayXRightMergin) ];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(DisplayYLocation) length:CPTDecimalFromFloat(DisplayYRange)];
    
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
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
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
    x.tickDirection = CPTSignNegative;
    
    // Graph data prepare
	NSDate *refDate = [self baseTime];

    //per 5s
	x.majorIntervalLength = CPTDecimalFromFloat(60.0f);
	x.minorTicksPerInterval = 1;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];

	CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;

    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Price";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
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
    [_pickingController notify];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

-(void)cryPickingController:(CryPickingController *)cryPickingController volume:(Volume * )volume{
    NSString *meterText =[ NSString stringWithFormat: @"peak:%d average:%d",(int)roundf(volume.peak),(int)roundf(volume.average)];

    [_volumes addObject:volume];
    
    if([_volumes count] == 1){
        [self configureAxes];
    }
    if (scrollSwitch.on) {
        [self configurePlotSpace];
    }else{
        [self configureGlobalPlotSpace];
    }
    

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
    NSInteger valueCount = [_volumes count];
    int rateOfMagnification = [self rateOfMagnification];
    NSInteger theIndex = idx * rateOfMagnification;
    NSInteger lastIndex = MAX(0, (idx + 1) * rateOfMagnification -1) ;

    float maxAverage = -100.0f;
    float maxPeak = -100.0f;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (theIndex < valueCount) {
                NSDate *baseTime = [self baseTime];
                NSDate *time = [[_volumes objectAtIndex:theIndex] time];
//                NSLog(@"plot for index:%d, x:%f " ,idx, [time timeIntervalSinceDate:baseTime]);
                return [NSNumber numberWithDouble:[time timeIntervalSinceDate:baseTime]];
            }
            break;
        case CPTScatterPlotFieldY:
//            float *maxAverage = 0.0f;
//            float maxPeak = 0.0f;
            for (NSInteger i = theIndex; i <= lastIndex && i < valueCount; i++) {
                Volume *theVolume = [_volumes objectAtIndex:i];
                maxAverage = MAX(maxAverage, theVolume.average);
                maxPeak = MAX(maxPeak,theVolume.peak);
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
    return [_volumes count]/[self rateOfMagnification];
}

-(NSDate *)baseTime{
    if([_volumes count] >0){
        NSDate *base = [[_volumes firstObject] time];
        return base;
    }
    return nil;
}
- (IBAction)switchChanged:(UISwitch *)sender {
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    if(sender.on){
        plotSpace.allowsUserInteraction = NO;
    }else{
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
}
-(int)rateOfMagnification :(CPTPlotRange*)range{
    float mag=  [[NSDecimalNumber decimalNumberWithDecimal:range.length] intValue]/DisplayXRange;
    
//    NSLog(@"realMag:%f intMag:%d ",mag,(int)mag );
    return (int )mag;
}

-(int)rateOfMagnification{
    CPTGraph *graph = [self.hostView hostedGraph];
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    return [self rateOfMagnification:plotSpace.xRange];
}

@end
