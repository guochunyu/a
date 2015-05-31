//
//  AllMenber_enterprise.m
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "AllMenber_enterprise.h"
#import "NSString+FilePath.h"


static AllMenber_enterprise* allmenber_enterprise;
@implementation AllMenber_enterprise

+(AllMenber_enterprise *)sharedInstanse{
    if (!allmenber_enterprise) {
        allmenber_enterprise = [[AllMenber_enterprise alloc] init];
        
        NSString *sqlitePath=[SQLITE_PATH filePathOfCaches];
        //        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //        NSString *documentDirectory = [path objectAtIndex:0];
        //        NSString *dppath = [documentDirectory stringByAppendingPathComponent:@"groupAddress.sqlite"];
        FMDatabase *db = [FMDatabase databaseWithPath:sqlitePath];
        if (![db open]) {
            NSLog(@"Could not open dp");
        }else{
            NSLog(@"连接groupAddress成功");
        }
        
        
        NSMutableArray *mutArray = [[NSMutableArray alloc]init];
        FMResultSet *rs=[db executeQuery:@"SELECT * FROM menber_enterprise"];
        while ([rs next]) {
            menber_enterprise *menberenterprise = [[menber_enterprise alloc]init];
            menberenterprise.ID = [rs intForColumn:@"id"];
            menberenterprise.enterld = [rs intForColumn:@"enterId"];
            menberenterprise.menberld = [rs intForColumn:@"menberId"];
            [mutArray addObject:menberenterprise];
        }
        
        allmenber_enterprise.menber_enterpriseArray = mutArray;
        
        [rs close];
        [db close];
    }
    return allmenber_enterprise;
}


-(void)releaseInstanse
{
    allmenber_enterprise = nil;
}

@end
