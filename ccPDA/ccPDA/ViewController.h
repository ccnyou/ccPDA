//
//  ViewController.h
//  ccPDA
//
//  Created by ccnyou on 13-11-8.
//  Copyright (c) 2013年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Unity.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UIButton* button;
@property (nonatomic, strong) IBOutlet UIButton* clearButton;
@property (nonatomic, strong) IBOutlet UIButton* openButton;

//- (IBAction)run:(id)sender;
//- (IBAction)onOpen:(id)sender;
//- (IBAction)onClear:(id)sender;
@end
