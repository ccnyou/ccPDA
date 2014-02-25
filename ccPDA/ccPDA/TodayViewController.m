//
//  TodayViewController.m
//  ccPDA
//
//  Created by ccnyou on 11/16/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import "TodayViewController.h"
#import "LunarCalendar.h"
#import "MRZoomScrollView.h"
@interface TodayViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet MRZoomScrollView* zoomScrollView;
@property (nonatomic, strong) IBOutlet UILabel* nowLabel;
@property (nonatomic, strong) IBOutlet UILabel* lunarLabel;
@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@property (nonatomic, strong) NSTimer* timer;

@end

@implementation TodayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect frame = self.view.frame;
    frame.size.height -= 50;
    frame.origin.y -= 20;
    self.view.frame = frame;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    dateFormatter.dateFormat = @"yyyy-MM-dd a HH:mm:ss EEEE";
    _dateFormatter = dateFormatter;
    
    self.lunarLabel.textAlignment = NSTextAlignmentCenter;
    self.nowLabel.textAlignment = NSTextAlignmentCenter;
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.layer.borderColor = [UIColor grayColor].CGColor;
    _scrollView.layer.borderWidth = 1.0f;
    _scrollView.layer.cornerRadius = 5.0;
    
    _zoomScrollView = [[MRZoomScrollView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    _zoomScrollView.backgroundColor = [UIColor clearColor];
    _zoomScrollView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage* image = [UIImage imageNamed:@"my_course_list.png"];
    _zoomScrollView.imageView.image = image;
    [self.scrollView addSubview:_zoomScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s line:%d %f", __FUNCTION__, __LINE__, self.view.frame.size.height);
    
    NSDate* date = [NSDate date];
    self.nowLabel.text = [_dateFormatter stringFromDate:date];
    
    LunarCalendar* lunarDate = [date chineseCalendarDate];
    NSString* lunarDateString = [NSString stringWithFormat:@"农历：%@%@", [lunarDate MonthLunar], [lunarDate DayLunar]];
    self.lunarLabel.text = lunarDateString;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_timer invalidate];
}

- (void)awakeFromNib
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTime
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    self.nowLabel.text = [_dateFormatter stringFromDate:date];
}

@end
