//
//  ViewController.m
//  ccPDA
//
//  Created by ccnyou on 13-11-8.
//  Copyright (c) 2013年 ccnyou. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.textView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)run:(id)sender
{
    self.textView.text = [self.textView.text stringByAppendingString:@"ok\r\n"];
}

@end
