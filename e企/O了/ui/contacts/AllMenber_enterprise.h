//
//  AllMenber_enterprise.h
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "menber_enterprise.h"

@interface AllMenber_enterprise : NSObject

@property (strong, nonatomic)NSArray *menber_enterpriseArray;

+(AllMenber_enterprise *)sharedInstanse;
-(void)releaseInstanse;
@end
