//
//  DBManager.h
//  e企
//
//  Created by zw on 15/2/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseAdditions.h"

@class FMDatabase;

@interface DBManager : NSObject
{
    NSString *_name;
}
@property (nonatomic, readonly) FMDatabase *dataBase;

+(DBManager *) defaultDBManager;

- (void) close;
@end

