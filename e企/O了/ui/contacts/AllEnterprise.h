//
//  AllEnterprise.h
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "enterprise_info.h"

@interface AllEnterprise : NSObject
@property (strong, nonatomic)NSArray *EnterpriseArray;

+(AllEnterprise *)sharedInstanse;
-(void)releaseInstanse;
@end
