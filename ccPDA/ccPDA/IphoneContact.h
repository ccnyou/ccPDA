//
//  IphoneContact.h
//  ccPDA
//
//  Created by ccnyou on 11/6/13.
//  Copyright (c) 2013 ccnyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IphoneContact : NSObject

@property (nonatomic, strong) NSString* lookUpKey;
@property (nonatomic, strong) NSString* contactName;
@property (nonatomic, strong) NSString* pinyin;
@property (nonatomic, strong) NSString* contactEmail;
@property (nonatomic, strong) NSString* contactCompany;
@property (nonatomic, strong) NSString* contactJob;
@property (nonatomic, strong) NSString* contactAdress;
@property (nonatomic, strong) NSString* contactMobile;
@property (nonatomic, strong) NSString* contactFax;
@property (nonatomic, strong) NSString* contactTelephone;
@property (nonatomic, strong) NSString* headImage;
@end
