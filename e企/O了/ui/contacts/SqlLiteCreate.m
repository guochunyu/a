//
//  SqlLiteCreate.m
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "SqlLiteCreate.h"
#import "NSString+FilePath.h"


@implementation SqlLiteCreate
static FMDatabaseQueue *db;


+(NSString *)getFilePath
{
    //判断目录是否存在，不存在则创建目录
    NSDictionary * dic=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
    DDLogInfo(@"dict=%@",dic);
    NSString * uid=[dic[@"data"] isKindOfClass:[NSDictionary class]]?(dic[@"data"][@"uid"]):@"";
    NSString * gid=[[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString * filename=[NSString stringWithFormat:@"/%@%@data/database.sqlite",uid,gid];
    NSString *filePath=[filename filePathOfDocuments];
    DDLogInfo(@"%@",filePath);
    NSString *sqliteDictionary = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:sqliteDictionary]){
        [fileManager createDirectoryAtPath:sqliteDictionary withIntermediateDirectories:YES attributes:nil error:nil];
    }
   
     DDLogInfo(@"%@",filePath);
//    /var/mobile/Containers/Data/Application/29FBC883-8B89-4587-94AB-7C1FFCEA24F1/Documents/190012303001111121221data/database.sqlite
//    /var/mobile/Containers/Data/Application/29FBC883-8B89-4587-94AB-7C1FFCEA24F1/Documents/190012303001886710193data/database.sqlite
    return filePath;
}

+ (FMDatabaseQueue *)getDataBase;
{
    db=[FMDatabaseQueue databaseQueueWithPath:[self getFilePath]];
    return db;
}

+(void)releaseDatabase
{
    db=nil;
}

@end
