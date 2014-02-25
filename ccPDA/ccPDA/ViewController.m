//
//  ViewController.m
//  ccPDA
//
//  Created by ccnyou on 13-11-8.
//  Copyright (c) 2013年 ccnyou. All rights reserved.
//

#import "ViewController.h"
#import "FMDatabase.h"
#import "ZipArchive.h"
#import "CCSegmentedControl.h"
#import "Unity.h"
#import "DebugViewController.h"
#import "TodayViewController.h"
#import "UserViewController.h"

#if !LOG_TO_FILE
#define NSLog(s, ...) [self log:[NSString stringWithFormat:(s), ##__VA_ARGS__]]
#endif


@interface ViewController ()

@property (nonatomic, strong) TodayViewController* todayViewController;
@property (nonatomic, strong) DebugViewController* debugViewController;
@property (nonatomic, strong) UserViewController* userViewController;
@property (nonatomic, strong) NSArray* viewControllers;
@property (nonatomic,   weak) UIViewController* activeViewController;
@property (nonatomic, strong) UIView* contentView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initControls];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Self Methods
- (void)initControls
{
    CCSegmentedControl* segmentedControl = [[CCSegmentedControl alloc] initWithItems:@[@"今日关注", @"个人信息", @"调试信息"]];
    segmentedControl.frame = CGRectMake(0, 0, 320, 50);
    segmentedControl.segmentTextColor = [Unity colorWithHexString:@"#535353"];
    segmentedControl.selectedSegmentTextColor = [UIColor whiteColor];
    segmentedControl.backgroundImage = [self imageWithName:@"分段控件背景.png"];
    segmentedControl.selectedStainView = [[UIImageView alloc] initWithImage:[self imageWithName:@"分段控件阴影.png"]];
    [segmentedControl addTarget:self action:@selector(segmentValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 320, self.view.frame.size.height - 50)];
    [self.view addSubview:contentView];
    _contentView = contentView;
    
    UIStoryboard* storeBoard = [UIStoryboard storyboardWithName:@"TodayViewController" bundle:nil];
    _todayViewController = [storeBoard instantiateInitialViewController];
    
    _userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
    
    storeBoard = [UIStoryboard storyboardWithName:@"DebugViewController" bundle:nil];
    _debugViewController = [storeBoard instantiateInitialViewController];

    _viewControllers = @[_todayViewController, _userViewController, _debugViewController];
    for (UIViewController* viewController in _viewControllers) {
        [self addChildViewController:viewController];
    }
    
    _activeViewController = _todayViewController;
    [contentView addSubview:_activeViewController.view];
    
    NSLog(@"%s line:%d", __FUNCTION__, __LINE__);
}

- (UIImage *)imageWithName:(NSString *)imageName
{
    return [UIImage imageNamed:imageName];
}

- (void)log:(id)obj
{
    [_debugViewController log:obj];
}


#pragma mark - Event Handling
- (void)segmentValueChanged:(CCSegmentedControl *)segmentedControl
{
    [_activeViewController.view removeFromSuperview];
    UIViewController* viewController = [_viewControllers objectAtIndex:segmentedControl.selectedSegmentIndex];
    [_contentView addSubview:viewController.view];
}

@end
