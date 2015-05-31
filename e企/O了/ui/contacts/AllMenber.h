//
//  AllMenber.h
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "menber_info.h"

@interface AllMenber : NSObject

@property (strong, nonatomic)NSMutableArray *menberAraay;
@property (strong, nonatomic)NSDictionary *menberDic;

+(AllMenber *)sharedInstanse;
-(void)releaseInstanse;
@end
