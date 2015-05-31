//
//  SqlLiteCreate.h
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface SqlLiteCreate : NSObject
+ (FMDatabaseQueue *)getDataBase;
+(void)releaseDatabase;
@end
