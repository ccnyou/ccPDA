//
//  DebugViewController.m
//  ccPDA
//
//  Created by ccnyou on 11/16/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController ()

@property (nonatomic, strong) IBOutlet UITextView* textView;

@end

@implementation DebugViewController


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

}

- (void)awakeFromNib
{
    CGRect frame = self.view.frame;
    frame.size.height -= 50;
    frame.origin.y -= 20;
    self.view.frame = frame;
    
    self.textView.text = @"";
    self.textView.editable = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)log:(id)obj
{
    NSString* str = self.textView.text;
    str = [str stringByAppendingFormat:@"%@\r\n", obj];
    self.textView.text = str;
}

- (void)clean
{
    self.textView.text = @"";
}

@end
