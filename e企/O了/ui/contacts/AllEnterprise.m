//
//  AllEnterprise.m
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "AllEnterprise.h"
#import "NSString+FilePath.h"

static AllEnterprise* allenterprisetance;
@implementation AllEnterprise
@synthesize EnterpriseArray;

+(AllEnterprise *)sharedInstanse{
    if (!allenterprisetance) {
        allenterprisetance = [[AllEnterprise alloc] init];
        
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
        FMResultSet *rs=[db executeQuery:@"select * from enterprise_info where orgName <> '公司领导'"];
        while ([rs next]) {
            enterprise_info *enterprise = [[enterprise_info alloc]init];
            enterprise.ID = [rs intForColumn:@"id"];
            enterprise.OrgNum = [rs intForColumn:@"orgNum"];
            enterprise.orgName = [rs stringForColumn:@"orgName"];
            [mutArray addObject:enterprise];
//            enterprise_info *enter = [enterprise_info enterprise_infoOfCategory:[rs intForColumn:@"id"] name:[rs stringForColumn:@"orgName"] num:[rs intForColumn:@"orgNum"]];
//            [mutArray addObject:enter];
        }
       
        allenterprisetance.EnterpriseArray = mutArray;
        [rs close];
        [db close];
    }
    return allenterprisetance;
}

-(void)releaseInstanse
{
    allenterprisetance = nil;
}
@end
