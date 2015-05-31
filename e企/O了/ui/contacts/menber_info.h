//
//  menber_info.h
//  O了
//
//  Created by macmini on 14-01-22.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface menber_info : NSObject

@property (assign, nonatomic)NSInteger ID;
@property (assign, nonatomic)NSInteger orgNum;
@property (copy, nonatomic)NSString *partName;
@property (copy, nonatomic)NSString *telNum;
@property (copy, nonatomic)NSString *menberName;
@property (copy, nonatomic)NSString *shortNum;
@property (copy, nonatomic)NSString *reserve1;
@property (copy, nonatomic)NSString *reserve2;
@property (copy, nonatomic)NSString *reserve3;
@property (copy, nonatomic)NSString *reserve4;
@property (copy, nonatomic)NSString *reserve5;
@property (copy, nonatomic)NSString *reserve6;
@property (copy, nonatomic)NSString *reserve7;
@property (copy, nonatomic)NSString *reserve8;
@property (copy, nonatomic)NSString *reserve9;
@property (copy, nonatomic)NSString *reserve10;
@property (copy, nonatomic)NSString *avatar;
//@property (strong, nonatomic)NSData *avatar_data;

@property (copy, nonatomic)NSString *menber_enterprise_enterld;
///常用联系人
@property (assign, nonatomic)NSInteger freqFlag;
///工作圈ID
@property (assign, nonatomic)NSInteger circleID;

@end
