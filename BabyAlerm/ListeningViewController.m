//
//  ListeningViewController.m
//  BabyAlerm
//
//  Created by harada on 2013/11/26.
//  Copyright (c) 2013年 harada. All rights reserved.
//

#import "ListeningViewController.h"
#import "AppDelegate.h"
#import "CorePlot-CocoaTouch.h"
#import "Volume.h"
#import "BAConstant.h"

@interface ListeningViewController ()<BLCryPickingShowDelegate,CPTPlotDataSource>
@property (strong, nonatomic) IBOutlet UILabel *meterLavel;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *hostView;

@end

@implementation ListeningViewController{
    
    CryPickingController *_pickingController;
    NSMutableArray *_volumes;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _pickingController = [CryPickingController new];
        _volumes = [NSMutableArray new];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _pickingController.showDelegate = self;
    [_pickingController startListening];

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

-(void) initPlot{
    [self configureHosts];
    [self configureGraph];
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
    NSString *title = @"Crying Volmes";
    graph.title = title;
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
//    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
//    plotSpace.allowsUserInteraction = YES;
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
    
    
    // 3 - Set up plot space
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:peakPlot, averagePlot,nil]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
    plotSpace.xRange = xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    
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

-(void)cryPickingController:(CryPickingController *)cryPickingController meterState:(AudioQueueLevelMeterState )meterState{
    NSString *meterText =[ NSString stringWithFormat: @"peak:%d average:%d",(int)roundf(meterState.mPeakPower),(int)roundf(meterState.mAveragePower)];
    Volume *volume = [Volume new ];
    volume.peak = (float)roundf(meterState.mPeakPower);
    volume.average = (float)roundf(meterState.mAveragePower);
    volume.time = [NSDate date];
    [_volumes addObject:volume];
    [[self.hostView hostedGraph] reloadData];
    self.meterLavel.text =meterText;
}

-(void)setCryingVCDelegate:(id<BLCryPickingDelegate>)delegate{
    if(!_pickingController){
        _pickingController = [CryPickingController new];
    }
    _pickingController.delegate = delegate;
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    NSInteger valueCount = [_volumes count];
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            if (idx < valueCount) {
                return [NSNumber numberWithUnsignedInteger:idx];
            }
            break;
        case CPTScatterPlotFieldY:
            if ([plot.identifier isEqual:TickerSymbolAverage] == YES) {
                return [NSNumber numberWithFloat: [(Volume *) [_volumes objectAtIndex:idx] average]];
            } else if ([plot.identifier isEqual:TickerSymbolPeak] == YES) {
                return [NSNumber numberWithFloat: [(Volume *) [_volumes objectAtIndex:idx] peak]];
            }
            break;
    }
    return[NSDecimalNumber zero];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [_volumes count];
}

@end
