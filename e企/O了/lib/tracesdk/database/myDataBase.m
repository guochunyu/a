//
//  myDataBase.m
//  MobileSDK
//
//  Created by Dora.Lin on 14-1-24.
//  Copyright (c) 2014年 LiPo. All rights reserved.
//

#import "myDataBase.h"
#import "FMDatabase.h"

@implementation myDataBase
{
    FMDatabase *_database;
}
@synthesize dataArray = _dataArray;
static myDataBase * _sharedMyDataBase;
+(myDataBase *)sharedMyDataBase{
    @synchronized(self){
        if (!_sharedMyDataBase) {
            _sharedMyDataBase=[[self alloc]init];
        }
    }
    return _sharedMyDataBase;
}
-(id)init
{
    self=[super init];
    if (self) {
        [self createDataBase];
        [self createTable];
        _dataArray = [[NSMutableArray alloc]init];
    }
    return self;
}
-(void)createDataBase{
    _database=[[FMDatabase alloc]initWithPath:[NSString stringWithFormat:@"%@ChinaMobileSDK.db",[NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()]]];
    if (![_database open]) {
        NSLog(@"数据库打开失败");
    }else{
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:[NSString stringWithFormat:@"%@ChinaMobileSDK.db",[NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()]] forKey:@"baseFilePath"];
        //NSLog(@"数据库创建成功\n%@",[NSString stringWithFormat:@"%@ChinaMobileSDK.db",[NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()]]);
    }
}
-(void)createTable{
    [_database open];
    [_database executeUpdate:@"create table SDKTable(groupID integer,body text)"];
    [_database close];
}
-(void)insertData:(NSString *)body groupID:(NSInteger)Id
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * filePath = [userDefaults objectForKey:@"baseFilePath"];
    //NSLog(@"filePath:\n%@",filePath);
    float len = [self fileSizeAtPath:filePath];
    //超过2m删除一半
    //NSLog(@"len=%f",len);
    if (len>2) {
        NSInteger groupIdASC=[self getID];
        NSInteger groupIdDESC = [self getGroupID];
        for (int i=0; i<(groupIdDESC-groupIdASC)/2; i++) {
            [self removeDataWithId:[self getID]];
           // NSLog(@"%d",[self getID]);
        }
    }
    [_database open];
    [_database executeUpdate:@"insert into SDKTable values(?,?)",[NSNumber numberWithInteger:Id],body];
    [_database close];
}

//单个文件的大小
- (float) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize]/(1024.0*1024.0);
    }
    return 0;
}
////遍历文件夹获得文件夹大小，返回多少M
//- (float ) folderSizeAtPath:(NSString*) folderPath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:folderPath]) return 0;
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
//    NSString* fileName;
//    long long folderSize = 0;
//    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//    }
//    return folderSize/(1024.0*1024.0);
//}

-(NSDictionary *)fillData{
    [_database open];
    [_dataArray removeAllObjects];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    int groupID;
    FMResultSet *res=[_database executeQuery:@"select * from SDKTable"];
    while ([res next]) {
        NSString *body=[res stringForColumn:@"body"];
        groupID = [res intForColumn:@"groupID"];//123...
        [_dataArray addObject:[NSNumber numberWithInt:groupID]];
        [dict setObject:body forKey:[NSNumber numberWithInt:groupID]];
        //NSLog(@"fillGroupID:%d",groupID);
    }
    [_database close];
    return dict;
}
-(NSInteger)getGroupID{
    [_database open];
    int groupId=0;
    FMResultSet *res =[_database executeQuery:@"select groupID from SDKTable order by groupID desc limit 1"];
    while ([res next]) {
        if ([res intForColumn:@"groupID"] != 0) {
            groupId=[res intForColumn:@"groupID"];
        }
    }
    [_database close];
    //NSLog(@"desc:%d",groupId);
    return groupId;
    
}
//降序
-(NSInteger)getID
{
    [_database open];
    int groupId=0;
    FMResultSet *res =[_database executeQuery:@"select groupID from SDKTable order by groupID asc limit 1"];//asc
    while ([res next]) {
        if ([res intForColumn:@"groupID"] != 0) {
            groupId=[res intForColumn:@"groupID"];
        }
    }
    [_database close];
    //NSLog(@"asc:%d",groupId);
    return groupId;
}
//-(void)changeSaveMark:(int)num groupid:(int)Id//默认0，删除0，未发送改变1保存
//{
//    [_database open];
//    [_database executeUpdate:@"update SDKTable set save=? where groupID=?",[NSNumber numberWithInt:num],[NSNumber numberWithInt:Id]];
//    [_database close];
//}
-(void)removeDataWithId:(int)groupId{
    //NSLog(@"%d",groupId);
    [_database open];
    if ([_database executeQuery:@"select body from SDKTable"]) {
        [_database executeUpdate:@"delete from SDKTable where groupID=?",[NSNumber numberWithInt:groupId]];
    }
    [_database close];
    
}

@end
