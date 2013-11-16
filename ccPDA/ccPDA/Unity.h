//
//  Unity.h
//  b866
//
//  Created by ccnyou on 10/2/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface Unity : NSObject

+ (Unity*)sharedUnity;
+ (float)currentDeviceVersion;
+ (UIColor *)colorWithRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)a;
+ (UIColor *)colorWithHexString:(NSString *) hexString;


@end
