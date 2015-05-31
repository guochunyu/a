//
//  SqlAddressData.m
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "SqlAddressData.h"
#import "SqlLiteCreate.h"
#import "FMDatabaseAdditions.h"
#import "EmployeeModel.h"
#import "VisibilityContactModel.h"
#import "PinYin4Objc.h"


@implementation SqlAddressData
static FMDatabaseQueue *menberDbQueue=nil;
static NSString * orgtag=nil;
static NSString * org_id=nil;
static BOOL isSeeOther;
static BOOL addPersonInfoFlag = NO;
//static VisibilityContactModel * filter=nil;
//打开数据库
+ (BOOL)openDB
{
    if (!menberDbQueue) {
        menberDbQueue=[SqlLiteCreate getDataBase];
    }
    return YES;
}

+(void)releaseDataQueue;{
    if (menberDbQueue) {
        menberDbQueue=nil;
    }
    if (orgtag) {
        orgtag=nil;
    }
    if (org_id) {
        org_id=nil;
    }
}
#pragma mark----创建联系人信息表
+(void)createPersoninfoTable
{

    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //       设置缓存区
        [db setShouldCacheStatements:YES];
        NSString *tableName=@"contact";
        //       创建表
        if (![db tableExists:@"contact"]) {
//            [db executeUpdate:@"CREATE TABLE contact (_id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT)"];
            NSArray *columns=@[@"id integer primary key autoincrement",
                               @"priority integer",//排序字段
                               @"name text",//联系人名字
                               @"title text",
                               @"tele text",//联系人固话
                               @"emailaddress text",//联系人邮箱
                               @"telephonenum text",//电话
                               @"imacct text",
                               @"short_num text",//短号
                               @"uid text",//uid
                               @"sort_key text",
                               @"position text",//联系人职务
                               @"imag_path text",//头像url
                               @"weight text",
                               @"organization text",//部门ID
                               @"organiztion_name text",//部门名字
                               @"pinyin_name text",//汉语名字的拼音
                               @"first_name text"
                               ];
            NSArray *indexes=@[@"name",@"uid",@"organization",@"organiztion_name",@"pinyin_name",@"first_name",@"imacct",@"emailaddress"];
            
            BOOL result=[self createTable1:tableName columns:columns indexes:indexes whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        //名字缩写
        if (![db columnExists:@"name_abbreviate text" inTableWithName:@"contact"]) {
            [db executeUpdate:@"alter table contact add name_abbreviate text"];
        }
        /*
        //人员职务
        if (![db columnExists:@"title text" inTableWithName:@"contact"]) {
            [db executeUpdate:@"alter table contact add title text"];
        }
        */
//       需要加索引,暂不处理

        [db close];
    }];
    
}
//快速创建表，建立索引
+(BOOL)createTable1:(NSString *)table columns:(NSArray *)columns indexes:(NSArray *)indexes whithDb:(FMDatabase *)db
{
    BOOL success    = true;
    BOOL shouldDrop = false;
    NSString *ddl   = [NSString stringWithFormat:@"select count(*)"
                       " from sqlite_master"
                       " where type ='table' and name = '%@'", table];
    FMResultSet *rs = [db executeQuery:ddl];
    
    if ([rs next]
        && [rs intForColumnIndex:0]
        ) {
        shouldDrop = true;
    }
    
    [rs close];
    
    if (shouldDrop) {
        ddl     = [NSString stringWithFormat:@"DROP TABLE %@", table];
        success = success && [db executeUpdate:ddl];
    }
    
    //根据columns数组拼DDL，所有columns均设置为NOT NULL
    NSMutableArray *notNullColumns = [NSMutableArray arrayWithCapacity:columns.count];
    
    [columns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            return;
        }
        
        NSString *c = (NSString *)obj;
        NSString *d = nil;
        
        if ([c hasSuffix:@"text"]) {
            d = @"  DEFAULT ''";
            
        } else if ([c hasSuffix:@"integer"]
                   || [c hasSuffix:@"real"]
                   || [c hasSuffix:@"numeric"]
                   ) {
            d = @"  DEFAULT 0";
        } else if ([c hasSuffix:@"integer primary key autoincrement"]){
            d = @" NOT NULL DEFAULT 0";
        }
        
        [notNullColumns addObject:[obj stringByAppendingString:d]];
    }];
    
    //拼出CREATE TABLE语句
    ddl     = [NSString stringWithFormat:@"CREATE TABLE %@(%@)", table, [notNullColumns componentsJoinedByString:@", "]];
    success = success && [db executeUpdate:ddl];
    
    //建立索引
    for (NSString *idx in indexes) {
        ddl     = [NSString stringWithFormat:@"CREATE INDEX %@_%@_idx ON %@(%@)", table, idx, table, idx];
        success = success && [db executeUpdate:ddl];
    }
    
    return success;
}

//表中是否存在某字段
+(BOOL)isExitSomeColumn;
{
    __block BOOL result=NO;
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //       设置缓存区
        [db setShouldCacheStatements:YES];
        //       创建表
        if ([db tableExists:@"contact"]) {
            if ([db columnExists:@"title" inTableWithName:@"contact"] && [db columnExists:@"tele" inTableWithName:@"contact"]) {
                result = YES;
            }else
            {
                [db executeUpdate:@"alter table contact add title text"];
                [db executeUpdate:@"alter table contact add tele text"];
                //部门priority
                if (![db columnExists:@"organization_priority" inTableWithName:@"organiztions"]) {
                    [db executeUpdate:@"alter table organiztions add organization_priority integer"];
                }
            }
        }
        [db close];
    }];
    return result;
}
///增加contact表中的字段
+(void)adapterContactSomeColumn;
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //       设置缓存区
        [db setShouldCacheStatements:YES];
        //       创建表
        if ([db tableExists:@"contact"]) {
            if ([db columnExists:@"title" inTableWithName:@"contact"] )
            {
                [db executeUpdate:@"alter table contact add title text"];
            }
            else if ([db columnExists:@"tele" inTableWithName:@"contact"] )
            {
                [db executeUpdate:@"alter table contact add tele text"];
            }
                if (![db columnExists:@"organization_priority" inTableWithName:@"organiztions"]) {
                    [db executeUpdate:@"alter table organiztions add organization_priority integer"];
            }
        }
        [db close];
    }];
    
}
#pragma mark - 查询contact表中是否有数据,YES为有
+(BOOL)queryContactIsNull{
    __block BOOL result=NO;
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=@"select *from contact limit 1";
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            result=YES;
            break;
        }
        
        [db close];
    }];
    
    return result;
}
#pragma mark-----添加个人信息
+(void)addPersonInfo:(NSArray*)dataArray
{
    [self openDB];
    addPersonInfoFlag = YES;
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //      开启事务，批量插入数据
        [db beginDeferredTransaction];
        @try {
            NSString * sqlStr= @"INSERT INTO contact (id,priority,name,title,tele,emailaddress,telephonenum,imacct,short_num,uid,sort_key,position,imag_path,weight,organization,organiztion_name,pinyin_name,first_name,name_abbreviate) VALUES (?,?,?,?,?,?,?,?,?,?,0,?,?,0,?,?,?,?,?)";
            for (NSDictionary * dic in dataArray)
            {
                NSArray * personArray=dic[@"personList"];
                NSString * org_name=dic[@"name"];
                for (NSDictionary * data in personArray) {
                    int actionType = [(NSNumber*)data[@"actionType"] intValue];
                    if (actionType == 2 || actionType == 3 ) {
                        NSString *deleteStr = [NSString stringWithFormat:@"delete from contact where id = '%@'",data[@"id"]];
                        [db executeUpdate:deleteStr];
                    }
                    // EmployeeModel * model=[[EmployeeModel alloc]initWithDictionary:data];
                    //NSString * pinyin=model.name;
                    //                    NSString * pinyin_name=[SqlAddressData changeNameChinese:pinyin];
                    
                    //                    NSString * name_suoxie=[SqlAddressData getFirstZimu:pinyin];
                    
                    NSString * pinyin_name=data[@"pinyin"];
                    if([pinyin_name length]==0)
                    {
                        pinyin_name=[SqlAddressData changeNameChinese:data[@"name"]];
                    }
                    
                    NSString * name_suoxie=data[@"pinyinHead"];
                    
                    
                    NSString * first_ofName=[pinyin_name substringWithRange:NSMakeRange(0, 1)];
                    
                    if (actionType !=2 ) {
                        NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
                        NSString *imacct = data[@"imacct"];
                        NSRange range = [imacct rangeOfString:E_APP_KEY];
                        if(!(range.location == NSNotFound))
                        {
                            imacct = [imacct stringByReplacingOccurrencesOfString:E_APP_KEY withString:@""];
                        }
                        [db executeUpdate:sqlStr,data[@"id"],data[@"priority"],data[@"name"],data[@"title"],data[@"tele"],data[@"email"],data[@"phone"],imacct,data[@"shotNum"],uid,data[@"position"],data[@"avatarimgurl"],data[@"orgId"],org_name,pinyin_name,first_ofName,name_suoxie];
                    }
                    
                }
            }
        }
        @catch (NSException *exception) {
            [db rollback];
        }
        @finally {
            addPersonInfoFlag = NO;
            [db commit];
        }
        [db close];
    }];
}

//创建部门关系表
+(void)createBranchTable
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        //       设置缓存区
        [db open];
        NSString * tableName=@"organiztions";
        [db setShouldCacheStatements:YES];
        if (![db tableExists:@"organiztions"]) {
//            [db executeUpdate:@"CREATE TABLE organiztions (_id INTEGER PRIMARY KEY,organiztion_tag TEXT,organiztion_name TEXT,organiztion_parent_tag TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organiztion_have_child INTEGER )"];
            NSArray *columns=@[@"_id integer primary key autoincrement",@"organization_priority integer",
                               @"organiztion_tag text",//部门ID
                               @"organiztion_name text",//部门名字
                               @"organiztion_parent_tag text",//父部门ID
                               @"weight integer",
                               @"organiztion_have_child integer",//是否有子部门
                               ];
            NSArray *indexes=@[@"organiztion_tag",@"organiztion_name",
                               @"organiztion_parent_tag",];
            BOOL result=[self createTable1:tableName columns:columns indexes:indexes whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        /*
        //部门priority
        if (![db columnExists:@"organization_priority integer" inTableWithName:@"organiztions"]) {
            [db executeUpdate:@"alter table contact add organization_priority integer"];
        }
         */
        [db close];
    }];
}
#pragma mark-----添加部门信息
+(void)addContactsInfo:(NSArray*)dataArray
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        [db beginDeferredTransaction];
        for (NSDictionary *data in dataArray) {
            int actionType = [(NSNumber*)data[@"actionType"] intValue];
            
            if (actionType == 2 || actionType == 3 ) {
                NSString *deleteStr = [NSString stringWithFormat:@"delete from organiztions where organiztion_tag = '%@'",data[@"id"]];
                [db executeUpdate:deleteStr];
            }
            
            if (actionType!=2) {
                ContactsModel * model=[[ContactsModel alloc]initWithDictionary:data];
                    if (model) {
                    NSString *sqlStr=[NSString stringWithFormat:@"INSERT INTO organiztions (organization_priority,organiztion_tag,organiztion_name,organiztion_parent_tag,weight,organiztion_have_child) VALUES (%@,%d,'%@',%d,0,0)",data[@"priority"],model.contactsID,model.name,model.parentId];
                    [db executeUpdate:sqlStr];
                }
            }
            
        }
        [db commit];
        [db close];
    }];
    
}
#pragma mark------查询部门表是否为空-----
+(BOOL)queryOrgIsNull
{
    __block BOOL result=NO;
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=@"select *from organiztions";
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            result=YES;
            break;
        }
        [db close];
    }];
    
    return result;
}
//删除表的内容
+(void)deleTableData
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([db tableExists:@"organiztions"]) {
            [db executeUpdate:@"DELETE FROM  organiztions"];
        }
        if ([db tableExists:@"contact"]) {
            [db executeUpdate:@"DELETE FROM contact"];
        }
        [db close];
    }];
}
#pragma mark-----查询有父节点的部门
+(NSArray*)selectBranchTable
{
    [self openDB];
    __block  NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([db tableExists:@"organiztions"]) {
            FMResultSet * set=[db executeQuery:@"SELECT organiztion_parent_tag FROM organiztions WHERE organiztion_parent_tag !=0"];
            while ([set next]) {
                NSString * organiztion_parent_tag=[set stringForColumn:@"organiztion_parent_tag"];
                [array addObject:organiztion_parent_tag];
            }
            [set close];
        }
    }];
    return [NSArray arrayWithArray:array];
}
#pragma mark----更新父节点的属性
+(void)updateBranchTable
{
//    [self openDB];
    NSArray * orgIdArray=[self selectBranchTable];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        [db beginTransaction];
        for (int i=0; i<orgIdArray.count; i++) {
            orgtag=[orgIdArray objectAtIndex:i];
            NSString * sqlStr=[NSString stringWithFormat:@"UPDATE organiztions set organiztion_have_child='1' where organiztion_tag='%@'",orgtag];
            [db executeUpdate:sqlStr];
        }
        [db commit];
    }];
}

#pragma mark --更新个人信息属性
+(void)upDateAvatarimgurl:(NSString *)imgurl WithUserPhone:(NSString *)phone
{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db beginTransaction];
            NSString *sqlStr=[NSString stringWithFormat:@"UPDATE contact set imag_path='%@' where telephonenum='%@'",imgurl,phone];
            [db executeUpdate:sqlStr];
            [db commit];
        }];
    }
    
}






#pragma mark-------获得自己所在部门ID
+(NSArray*)selectOrgByUserName
{
    [self openDB];
    NSString * username=[ConstantObject sharedConstant].userInfo.phone;
    __block  NSMutableArray * orgidArr=[NSMutableArray arrayWithCapacity:0];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        select distinct organization from  contact
        if ([db tableExists:@"contact"]) {
            NSString * sqlstr=[NSString stringWithFormat:@"SELECT DISTINCT organization FROM contact where telephonenum='%@'",username];
            FMResultSet * set=[db executeQuery:sqlstr];
            while ([set next]) {
                NSString * orgId=[set stringForColumn:@"organization"];
                [orgidArr addObject:orgId];
            }
        }
    }];
//    NSSet * set=[NSSet setWithArray:orgidArr];
//    NSArray * array=[set allObjects];
    return [NSArray arrayWithArray:orgidArr];
}
#pragma mark------获得部门同事
+(NSArray*)selectMinefriend
{
    [self openDB];
    NSArray * array=[self selectOrgByUserName];
    __block NSMutableArray * friendArray=[NSMutableArray arrayWithCapacity:0];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([db tableExists:@"contact"]) {
            for (int i=0; i<array.count; i++) {
                NSString * orgId=[array objectAtIndex:i];
                NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@'",orgId];
                FMResultSet * set=[db executeQuery:sqlStr];
                while ([set next]) {
                    NSString * name=[set stringForColumn:@"name"];
                    [friendArray addObject:name];
                }
            }
            
        }
        [db close];
    }];
    return [NSArray arrayWithArray:friendArray];
}
#pragma mark-----获得自己同事所在部门名字
+(NSArray*)selectOrgName
{
    [self openDB];
    NSArray * array=[self selectOrgByUserName];
    __block NSMutableArray * orgArray=[NSMutableArray arrayWithCapacity:0];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        for (int i=0; i<array.count; i++) {
            NSString * orgId=[array objectAtIndex:i];
//            SELECT DISTINCT organization FROM contact where name='%@'",username
            NSString * sqlStr=[NSString stringWithFormat:@"SELECT  DISTINCT organiztion_name FROM organiztions where organiztion_tag='%@'",orgId];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                NSString * orgName=[set stringForColumn:@"organiztion_name"];
                [orgArray addObject:orgName];
            }
        }
        [db close];
    }];
    return [NSArray arrayWithArray:orgArray];
}

//获得部门ID
+(NSString*)getOrganiztionsBySection:(NSString*)name
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM organiztions where organiztion_name='%@'",name];
        FMResultSet * set=[db executeQuery:sqlStr];
        while ([set next]) {
            org_id=[set stringForColumn:@"organiztion_tag"];
        }
        [db close];
    }];
    return org_id;
}
#pragma mark-----得到部门联系人以及这个部门下的部门
+(NSArray*)getOrgPeopleByOrgId:(NSString*)orgId
{
    [self openDB];
    NSDictionary * dic=[self selecLeaderVisibility];
    BOOL lead_all=[dic[leaderVisibility]boolValue];
    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
    VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
    
    NSArray * see_array=[SqlAddressData selectNewVisibilityTable:orgId];
    if (see_array.count>0) {
        isSeeOther=YES;
        filter=[see_array objectAtIndex:0];
    }else{
        isSeeOther=NO;
    }
    
    __block NSMutableArray * peopleArray=[NSMutableArray arrayWithCapacity:0];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //         NSString * sqlStr=[NSString stringWithFormat:@"SELECT *FROM (SELECT * FROM contact where organization='%@'  order by priority asc) order by id asc",orgId];
      
        NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' order by pinyin_name asc",orgId];

        NSString * sqlStr1=[NSString stringWithFormat:@"SELECT * FROM organiztions where organiztion_parent_tag='%@'",orgId];
        FMResultSet * set_1=[db executeQuery:sqlStr];
        while ([set_1 next]) {
            EmployeeModel * model=[[EmployeeModel alloc]init];
            model.type=1;
            model.name=[set_1 stringForColumn:@"name"];
            model.avatarimgurl=[set_1 stringForColumn:@"imag_path"];
            model.position=[set_1 stringForColumn:@"position"];
            model.title = [set_1 stringForColumn:@"title"];
            model.tele = [set_1 stringForColumn:@"tele"];
            model.phone=[set_1 stringForColumn:@"telephonenum"];
            model.email=[set_1 stringForColumn:@"emailaddress"];
            model.shotNum=[set_1 stringForColumn:@"short_num"];
            model.imacct=[set_1 stringForColumn:@"imacct"];
            //model.comman_orgName = [set_1 stringForColumn:@"comman_rogname"];
            
            //            _id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT
            if (isSeeOther) {
                if([model.position isEqualToString:@"员工"]){
                    if (filter.visibilityList_staffView==1) {
                        [peopleArray addObject:model];
                        continue;
                    }
                    
                }if ([model.position isEqualToString:@"部门领导"]) {
                    if (filter.visibilityList_leadView==1) {
                        [peopleArray addObject:model];
                        continue;
                    }
                }if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all) {
                        if (lead_phone) {
                            [peopleArray addObject:model];
                            continue;
                        }else{
                            model.phone=@"";
                            [peopleArray addObject:model];
                            continue;
                        }
                    }else{
                        DDLogInfo(@"不插入公司领导");
                    }
                    
                }
            }else{
                if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all) {
                        if (lead_phone) {
                            [peopleArray addObject:model];
                            continue;
                        }else{
                            model.phone=@"";
                            [peopleArray addObject:model];
                            continue;
                        }
                    }else{
                        DDLogInfo(@"不插入公司领导");
                    }
                    
                }
                [peopleArray addObject:model];
            }
        }
//        FMResultSet * set_3=[db executeQuery:sqlStr2];
//        while ([set_3 next]) {
//            EmployeeModel * model=[[EmployeeModel alloc]init];
//            model.type=1;
//            model.name=[set_3 stringForColumn:@"name"];
//            model.avatarimgurl=[set_3 stringForColumn:@"imag_path"];
//            model.title = [set_3 stringForColumn:@"title"];
//            model.tele = [set_3 stringForColumn:@"tele"];
//            model.position=[set_3 stringForColumn:@"position"];
//            model.phone=[set_3 stringForColumn:@"telephonenum"];
//            model.email=[set_3 stringForColumn:@"emailaddress"];
//            model.shotNum=[set_3 stringForColumn:@"short_num"];
//            model.imacct=[set_3 stringForColumn:@"imacct"];
//            
//            //            _id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT
//            if (isSeeOther) {
//                if([model.position isEqualToString:@"员工"]){
//                    if (filter.visibilityList_staffView==1) {
//                        [peopleArray addObject:model];
//                        continue;
//                    }
//                    
//                }if ([model.position isEqualToString:@"部门领导"]) {
//                    if (filter.visibilityList_leadView==1) {
//                        [peopleArray addObject:model];
//                        continue;
//                    }
//                }if ([model.position isEqualToString:@"公司领导"]) {
//                    if (lead_all) {
//                        if (lead_phone) {
//                            [peopleArray addObject:model];
//                            continue;
//                        }else{
//                            model.phone=@"";
//                            [peopleArray addObject:model];
//                            continue;
//                        }
//                    }else{
//                        DDLogInfo(@"不插入公司领导");
//                    }
//                    
//                }
//            }else{
//                if ([model.position isEqualToString:@"公司领导"]) {
//                    if (lead_all) {
//                        if (lead_phone) {
//                            [peopleArray addObject:model];
//                            continue;
//                        }else{
//                            model.phone=@"";
//                            [peopleArray addObject:model];
//                            continue;
//                        }
//                    }else{
//                        DDLogInfo(@"不插入公司领导");
//                    }
//                    
//                }
//                [peopleArray addObject:model];
//            }
//        }
//        
        
        
        FMResultSet *set_2=[db executeQuery:sqlStr1];
        while ([set_2 next]) {
            EmployeeModel * model=[[EmployeeModel alloc]init];
            model.type=2;
            model.orgId=[set_2 stringForColumn:@"organiztion_tag"];
            model.name=[set_2 stringForColumn:@"organiztion_name"];
            [peopleArray addObject:model];
        }
        [db close];
    }];
    return peopleArray;
}
//+(NSArray*)getOrgPeopleByOrgId:(NSString*)orgId
//{
//    [self openDB];
//    NSDictionary * dic=[self selecLeaderVisibility];
//    BOOL lead_all=[dic[leaderVisibility]boolValue];
//    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
//    VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
//
//    NSArray * see_array=[SqlAddressData selectNewVisibilityTable:orgId];
//    if (see_array.count>0) {
//        isSeeOther=YES;
//        filter=[see_array objectAtIndex:0];
//    }else{
//        isSeeOther=NO;
//    }
//
//    __block NSMutableArray * peopleArray=[NSMutableArray arrayWithCapacity:0];
//    [menberDbQueue inDatabase:^(FMDatabase *db) {
//        [db open];
////         NSString * sqlStr=[NSString stringWithFormat:@"SELECT *FROM (SELECT * FROM contact where organization='%@'  order by priority asc) order by id asc",orgId];
//        NSString * position=@"%领导";
//        NSString * position1=@"%员工";
//        NSString * phone = [ConstantObject sharedConstant].userInfo.phone;
//        NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and  position like '%@' order by priority asc",orgId,position];
//         NSString * sqlStr2=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and  position like '%@' order by priority asc",orgId,position1];
//        
//        NSString * sqlStr1=[NSString stringWithFormat:@"SELECT * FROM organiztions where organiztion_parent_tag='%@'",orgId];
//        FMResultSet * set_1=[db executeQuery:sqlStr];
//        while ([set_1 next]) {
//            EmployeeModel * model=[[EmployeeModel alloc]init];
//            model.type=1;
//            model.name=[set_1 stringForColumn:@"name"];
//            model.avatarimgurl=[set_1 stringForColumn:@"imag_path"];
//            model.position=[set_1 stringForColumn:@"position"];
//            model.title = [set_1 stringForColumn:@"title"];
//            model.tele = [set_1 stringForColumn:@"tele"];
//            model.phone=[set_1 stringForColumn:@"telephonenum"];
//            model.email=[set_1 stringForColumn:@"emailaddress"];
//            model.shotNum=[set_1 stringForColumn:@"short_num"];
//            model.imacct=[set_1 stringForColumn:@"imacct"];
//            //model.comman_orgName = [set_1 stringForColumn:@"comman_rogname"];
//            
////            _id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT
//            if (isSeeOther) {
//                if([model.position isEqualToString:@"员工"]){
//                    if (filter.visibilityList_staffView==1) {
//                        [peopleArray addObject:model];
//                        continue;
//                    }
//                    
//                }if ([model.position isEqualToString:@"部门领导"]) {
//                    if (filter.visibilityList_leadView==1) {
//                        [peopleArray addObject:model];
//                        continue;
//                    }
//                }if ([model.position isEqualToString:@"公司领导"]) {
//                    if (lead_all) {
//                        if (lead_phone) {
//                            [peopleArray addObject:model];
//                            continue;
//                        }else{
//                            model.phone=@"";
//                            [peopleArray addObject:model];
//                            continue;
//                        }
//                    }else{
//                        DDLogInfo(@"不插入公司领导");
//                    }
//                    
//                }
//            }else{
//                if ([model.position isEqualToString:@"公司领导"]) {
//                    if (lead_all) {
//                        if (lead_phone) {
//                            [peopleArray addObject:model];
//                            continue;
//                        }else{
//                            model.phone=@"";
//                            [peopleArray addObject:model];
//                            continue;
//                        }
//                    }else{
//                        DDLogInfo(@"不插入公司领导");
//                    }
//                    
//                }
//                [peopleArray addObject:model];
//            }
//        }
//        FMResultSet * set_3=[db executeQuery:sqlStr2];
//        while ([set_3 next]) {
//            EmployeeModel * model=[[EmployeeModel alloc]init];
//            model.type=1;
//            model.name=[set_3 stringForColumn:@"name"];
//            model.avatarimgurl=[set_3 stringForColumn:@"imag_path"];
//            model.title = [set_3 stringForColumn:@"title"];
//            model.tele = [set_3 stringForColumn:@"tele"];
//            model.position=[set_3 stringForColumn:@"position"];
//            model.phone=[set_3 stringForColumn:@"telephonenum"];
//            model.email=[set_3 stringForColumn:@"emailaddress"];
//            model.shotNum=[set_3 stringForColumn:@"short_num"];
//            model.imacct=[set_3 stringForColumn:@"imacct"];
//            
//            //            _id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT
//            if (isSeeOther) {
//                if([model.position isEqualToString:@"员工"]){
//                    if (filter.visibilityList_staffView==1) {
//                        [peopleArray addObject:model];
//                        continue;
//                    }
//                    
//                }if ([model.position isEqualToString:@"部门领导"]) {
//                    if (filter.visibilityList_leadView==1) {
//                        [peopleArray addObject:model];
//                        continue;
//                    }
//                }if ([model.position isEqualToString:@"公司领导"]) {
//                    if (lead_all) {
//                        if (lead_phone) {
//                            [peopleArray addObject:model];
//                            continue;
//                        }else{
//                            model.phone=@"";
//                            [peopleArray addObject:model];
//                            continue;
//                        }
//                    }else{
//                        DDLogInfo(@"不插入公司领导");
//                    }
//                    
//                }
//            }else{
//                if ([model.position isEqualToString:@"公司领导"]) {
//                    if (lead_all) {
//                        if (lead_phone) {
//                            [peopleArray addObject:model];
//                            continue;
//                        }else{
//                            model.phone=@"";
//                            [peopleArray addObject:model];
//                            continue;
//                        }
//                    }else{
//                        DDLogInfo(@"不插入公司领导");
//                    }
//                    
//                }
//                [peopleArray addObject:model];
//            }
//        }
//
//        
//        
//        FMResultSet *set_2=[db executeQuery:sqlStr1];
//        while ([set_2 next]) {
//            EmployeeModel * model=[[EmployeeModel alloc]init];
//            model.type=2;
//            model.orgId=[set_2 stringForColumn:@"organiztion_tag"];
//            model.name=[set_2 stringForColumn:@"organiztion_name"];
//            [peopleArray addObject:model];
//        }
//        [db close];
//    }];
//    return peopleArray;
//}
+(NSArray*)getNewOrgPeopleByOrgId:(NSString*)orgId
{
    [self openDB];
    NSDictionary * dic=[self selecLeaderVisibility];
    BOOL lead_all=[dic[leaderVisibility]boolValue];
    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
    VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
    
    NSArray * see_array=[SqlAddressData selectNewVisibilityTable:orgId];
    if (see_array.count>0) {
        isSeeOther=YES;
        filter=[see_array objectAtIndex:0];
    }else{
        isSeeOther=NO;
    }
    
    __block NSMutableArray * peopleArray=[NSMutableArray arrayWithCapacity:0];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM(SELECT * FROM contact where organization='%@' order by priority asc) order by id asc",orgId];
        NSString * position=@"%领导";
        NSString * position1=@"%员工";
        NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and  position like '%@' order by priority asc",orgId,position];
        
        NSString * sqlStr2=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and  position like '%@' order by priority asc",orgId,position1];
        
        NSString * sqlStr1=[NSString stringWithFormat:@"SELECT * FROM organiztions where organiztion_parent_tag='%@'",orgId];
        FMResultSet * set_1=[db executeQuery:sqlStr];
        while ([set_1 next]) {
            EmployeeModel * model=[[EmployeeModel alloc]init];
            model.type=1;
            model.name=[set_1 stringForColumn:@"name"];
            model.avatarimgurl=[set_1 stringForColumn:@"imag_path"];
            model.title = [set_1 stringForColumn:@"title"];
            model.position=[set_1 stringForColumn:@"position"];
            model.phone=[set_1 stringForColumn:@"telephonenum"];
            model.email=[set_1 stringForColumn:@"emailaddress"];
            model.shotNum=[set_1 stringForColumn:@"short_num"];
            model.imacct=[set_1 stringForColumn:@"imacct"];
            
            
            //            _id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT
            if (isSeeOther) {
                if([model.position isEqualToString:@"员工"]){
                    if (filter.visibilityList_staffView==1) {
                        [peopleArray addObject:model];
                        continue;
                    }
                    
                }if ([model.position isEqualToString:@"部门领导"]) {
                    if (filter.visibilityList_leadView==1) {
                        [peopleArray addObject:model];
                        continue;
                    }
                }if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all) {
                        if (lead_phone) {
                            model.leaderType=0;
                            [peopleArray addObject:model];
                            continue;
                        }else{
                            //                            model.phone=@"";
                            model.leaderType=1;
                            [peopleArray addObject:model];
                            continue;
                        }
                    }else{
                        DDLogInfo(@"不插入公司领导");
                    }
                    
                }
            }else{
                if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all) {
                        if (lead_phone) {
                            model.leaderType=0;
                            [peopleArray addObject:model];
                            continue;
                        }else{
                            //                            model.phone=@"";
                            model.leaderType=1;
                            [peopleArray addObject:model];
                            continue;
                        }
                    }else{
                        DDLogInfo(@"不插入公司领导");
                    }
                    
                }
                [peopleArray addObject:model];
            }
        }
        
        FMResultSet * set2=[db executeQuery:sqlStr2];
        while ([set2 next]) {
            EmployeeModel * model=[[EmployeeModel alloc]init];
            model.type=1;
            model.name=[set2 stringForColumn:@"name"];
            model.avatarimgurl=[set2 stringForColumn:@"imag_path"];
            model.title = [set2 stringForColumn:@"title"];
            model.position=[set2 stringForColumn:@"position"];
            model.phone=[set2 stringForColumn:@"telephonenum"];
            model.email=[set2 stringForColumn:@"emailaddress"];
            model.shotNum=[set2 stringForColumn:@"short_num"];
            model.imacct=[set2 stringForColumn:@"imacct"];
            
            
            //            _id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT
            if (isSeeOther) {
                if([model.position isEqualToString:@"员工"]){
                    if (filter.visibilityList_staffView==1) {
                        [peopleArray addObject:model];
                        continue;
                    }
                    
                }if ([model.position isEqualToString:@"部门领导"]) {
                    if (filter.visibilityList_leadView==1) {
                        [peopleArray addObject:model];
                        continue;
                    }
                }if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all) {
                        if (lead_phone) {
                            model.leaderType=0;
                            [peopleArray addObject:model];
                            continue;
                        }else{
                            //                            model.phone=@"";
                            model.leaderType=1;
                            [peopleArray addObject:model];
                            continue;
                        }
                    }else{
                        DDLogInfo(@"不插入公司领导");
                    }
                    
                }
            }else{
                if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all) {
                        if (lead_phone) {
                            model.leaderType=0;
                            [peopleArray addObject:model];
                            continue;
                        }else{
                            //                            model.phone=@"";
                            model.leaderType=1;
                            [peopleArray addObject:model];
                            continue;
                        }
                    }else{
                        DDLogInfo(@"不插入公司领导");
                    }
                    
                }
                [peopleArray addObject:model];
            }
        }

        
        FMResultSet *set_2=[db executeQuery:sqlStr1];
        while ([set_2 next]) {
            EmployeeModel * model=[[EmployeeModel alloc]init];
            model.type=2;
            model.orgId=[set_2 stringForColumn:@"organiztion_tag"];
            model.name=[set_2 stringForColumn:@"organiztion_name"];
            [peopleArray addObject:model];
        }
        [db close];
    }];
    return peopleArray;
}

#pragma mark-----获得某个部门下的人员-----
+(NSArray*)getOfContactPeople:(NSString*)org_tag
{
    //  filterArray这个数组中保存有用户对所有的部门人员的可见性
    //    NSArray * filterArray=[self selectvisibility];
    VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
    //    DDLogInfo(@"屏蔽的部门id===%@",filter.visibilityList_orgId);
    //    NSArray * filterArray=[self checkOutAll];
    //               正方向查找不可以，反方向
    //正方向
    //                    for (int i=0; i<filterArray.count; i++) {
    //                        filter=[filterArray objectAtIndex:i];
    //                        if ([filter.visibilityList_orgId isEqualToString:org_tag]) {
    //                            isSeeOther=YES;
    //                        }
    //                    }
    //反方向
    NSArray * see_array=[SqlAddressData selectNewVisibilityTable:org_tag];
    if (see_array.count>0) {
        isSeeOther=YES;
        filter=[see_array objectAtIndex:0];
    }else{
        isSeeOther=NO;
    }
    
    NSDictionary * dic=[self selecLeaderVisibility];
    BOOL lead_all=[dic[leaderVisibility]boolValue];
    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            //            NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM(SELECT * FROM contact where organization='%@' order by priority asc) order by id asc",org_tag];
            //            NSString * sqlStr=[NSString stringWithFormat:@"SELECT *FROM (SELECT * FROM contact where organization='%@'  order by priority asc) order by id asc",org_tag];
         
            NSString * phone = [ConstantObject sharedConstant].userInfo.phone;
            NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and telephonenum != '%@' order by pinyin_name asc",org_tag,phone];
          
            
            NSString * sqlStr1=[NSString stringWithFormat:@"SELECT * FROM organiztions WhERE organiztion_parent_tag='%@'",org_tag];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                EmployeeModel * model=[[EmployeeModel alloc]init];
                model.type=1;
                model.title = [set stringForColumn:@"title"];
                model.tele = [set stringForColumn:@"tele"];
                model.name=[set stringForColumn:@"name"];
                model.avatarimgurl=[set stringForColumn:@"imag_path"];
                model.position=[set stringForColumn:@"position"];
                model.phone=[set stringForColumn:@"telephonenum"];
                model.email=[set stringForColumn:@"emailaddress"];
                model.shotNum=[set stringForColumn:@"short_num"];
                model.imacct=[set stringForColumn:@"imacct"];
                model.comman_orgName=[set stringForColumn:@"organiztion_name"];
                
                //              如果是单个部门的话这么做可以满足
                //              设置员工可见性
                //              点击的部门是否和自己屏蔽的部门一致，如果一致就进行筛选
                //                DDLogInfo(@"点击的部门id===%@",org_tag);
                if (isSeeOther) {
                    if([model.position isEqualToString:@"员工"]){
                        if (filter.visibilityList_staffView==1) {
                            [array addObject:model];
                            continue;
                        }
                        
                    }if ([model.position isEqualToString:@"部门领导"]) {
                        if (filter.visibilityList_leadView==1) {
                            [array addObject:model];
                            continue;
                        }
                    }if ([model.position isEqualToString:@"公司领导"]) {
                        if (lead_all) {
                            if (lead_phone) {
                                [array addObject:model];
                                continue;
                            }else{
                                model.phone=@"";
                                [array addObject:model];
                                continue;
                            }
                        }else{
                            DDLogInfo(@"不插入公司领导");
                        }
                        
                    }
                    
                }
                else{
                    //               设置领导可见性
                    if ([model.position isEqualToString:@"公司领导"]) {
                        if (lead_all) {
                            if (lead_phone) {
                                [array addObject:model];
                                continue;
                            }else{
                                model.phone=@"";
                                [array addObject:model];
                                continue;
                            }
                        }else{
                            DDLogInfo(@"不插入公司领导");
                        }
                    }else{
                        [array addObject:model];
                    }
                }
                //                [array addObject:model];
            }
                      
            
            FMResultSet * set_1=[db executeQuery:sqlStr1];
            while ([set_1 next]) {
                EmployeeModel * model=[[EmployeeModel alloc]init];
                model.type=2;
                model.orgId=[set_1 stringForColumn:@"organiztion_tag"];
                model.name=[set_1 stringForColumn:@"organiztion_name"];
                [array addObject:model];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
//+(NSArray*)getOfContactPeople:(NSString*)org_tag
//{
//    //  filterArray这个数组中保存有用户对所有的部门人员的可见性
//    //    NSArray * filterArray=[self selectvisibility];
//    VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
//    //    DDLogInfo(@"屏蔽的部门id===%@",filter.visibilityList_orgId);
//    //    NSArray * filterArray=[self checkOutAll];
//    //               正方向查找不可以，反方向
//    //正方向
//    //                    for (int i=0; i<filterArray.count; i++) {
//    //                        filter=[filterArray objectAtIndex:i];
//    //                        if ([filter.visibilityList_orgId isEqualToString:org_tag]) {
//    //                            isSeeOther=YES;
//    //                        }
//    //                    }
//    //反方向
//    NSArray * see_array=[SqlAddressData selectNewVisibilityTable:org_tag];
//    if (see_array.count>0) {
//        isSeeOther=YES;
//        filter=[see_array objectAtIndex:0];
//    }else{
//        isSeeOther=NO;
//    }
//    
//    NSDictionary * dic=[self selecLeaderVisibility];
//    BOOL lead_all=[dic[leaderVisibility]boolValue];
//    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
//    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
//    if ([self openDB]) {
//        [menberDbQueue inDatabase:^(FMDatabase *db) {
//            [db open];
////            NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM(SELECT * FROM contact where organization='%@' order by priority asc) order by id asc",org_tag];
////            NSString * sqlStr=[NSString stringWithFormat:@"SELECT *FROM (SELECT * FROM contact where organization='%@'  order by priority asc) order by id asc",org_tag];
//            NSString * position=@"%领导";
//            NSString * position1=@"%员工";
//            NSString * phone = [ConstantObject sharedConstant].userInfo.phone;
//            NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and telephonenum != '%@' and  position like '%@' order by first_name asc",org_tag,phone,position];
//            NSString * sqlStr2=[NSString stringWithFormat:@"SELECT * FROM contact where organization='%@' and telephonenum != '%@' and  position like '%@' order by first_name asc",org_tag,phone,position1];
//            
//            NSString * sqlStr1=[NSString stringWithFormat:@"SELECT * FROM organiztions WhERE organiztion_parent_tag='%@'",org_tag];
//            FMResultSet * set=[db executeQuery:sqlStr];
//            while ([set next]) {
//                EmployeeModel * model=[[EmployeeModel alloc]init];
//                model.type=1;
//                model.title = [set stringForColumn:@"title"];
//                model.tele = [set stringForColumn:@"tele"];
//                model.name=[set stringForColumn:@"name"];
//                model.avatarimgurl=[set stringForColumn:@"imag_path"];
//                model.position=[set stringForColumn:@"position"];
//                model.phone=[set stringForColumn:@"telephonenum"];
//                model.email=[set stringForColumn:@"emailaddress"];
//                model.shotNum=[set stringForColumn:@"short_num"];
//                model.imacct=[set stringForColumn:@"imacct"];
//                model.comman_orgName=[set stringForColumn:@"organiztion_name"];
//                
//                //              如果是单个部门的话这么做可以满足
//                //              设置员工可见性
//                //              点击的部门是否和自己屏蔽的部门一致，如果一致就进行筛选
//                //                DDLogInfo(@"点击的部门id===%@",org_tag);
//                if (isSeeOther) {
//                    if([model.position isEqualToString:@"员工"]){
//                        if (filter.visibilityList_staffView==1) {
//                            [array addObject:model];
//                            continue;
//                        }
//                        
//                    }if ([model.position isEqualToString:@"部门领导"]) {
//                        if (filter.visibilityList_leadView==1) {
//                            [array addObject:model];
//                            continue;
//                        }
//                    }if ([model.position isEqualToString:@"公司领导"]) {
//                        if (lead_all) {
//                            if (lead_phone) {
//                                [array addObject:model];
//                                continue;
//                            }else{
//                                model.phone=@"";
//                                [array addObject:model];
//                                continue;
//                            }
//                        }else{
//                            DDLogInfo(@"不插入公司领导");
//                        }
//
//                    }
//                    
//                }
//                else{
//                    //               设置领导可见性
//                    if ([model.position isEqualToString:@"公司领导"]) {
//                        if (lead_all) {
//                            if (lead_phone) {
//                                [array addObject:model];
//                                continue;
//                            }else{
//                                model.phone=@"";
//                                [array addObject:model];
//                                continue;
//                            }
//                        }else{
//                            DDLogInfo(@"不插入公司领导");
//                        }
//                    }else{
//                        [array addObject:model];
//                    }
//                }
//                //                [array addObject:model];
//            }
//            FMResultSet * set2=[db executeQuery:sqlStr2];
//            while ([set2 next]) {
//                EmployeeModel * model=[[EmployeeModel alloc]init];
//                model.type=1;
//                model.title = [set2 stringForColumn:@"title"];
//                model.tele = [set2 stringForColumn:@"tele"];
//                model.name=[set2 stringForColumn:@"name"];
//                model.avatarimgurl=[set2 stringForColumn:@"imag_path"];
//                model.position=[set2 stringForColumn:@"position"];
//                model.phone=[set2 stringForColumn:@"telephonenum"];
//                model.email=[set2 stringForColumn:@"emailaddress"];
//                model.shotNum=[set2 stringForColumn:@"short_num"];
//                model.imacct=[set2 stringForColumn:@"imacct"];
//                model.comman_orgName=[set2 stringForColumn:@"organiztion_name"];
//                
//                //              如果是单个部门的话这么做可以满足
//                //              设置员工可见性
//                //              点击的部门是否和自己屏蔽的部门一致，如果一致就进行筛选
//                //                DDLogInfo(@"点击的部门id===%@",org_tag);
//                if (isSeeOther) {
//                    if([model.position isEqualToString:@"员工"]){
//                        if (filter.visibilityList_staffView==1) {
//                            [array addObject:model];
//                            continue;
//                        }
//                        
//                    }if ([model.position isEqualToString:@"部门领导"]) {
//                        if (filter.visibilityList_leadView==1) {
//                            [array addObject:model];
//                            continue;
//                        }
//                    }if ([model.position isEqualToString:@"公司领导"]) {
//                        if (lead_all) {
//                            if (lead_phone) {
//                                [array addObject:model];
//                                continue;
//                            }else{
//                                model.phone=@"";
//                                [array addObject:model];
//                                continue;
//                            }
//                        }else{
//                            DDLogInfo(@"不插入公司领导");
//                        }
//                        
//                    }
//                    
//                }
//                else{
//                    //               设置领导可见性
//                    if ([model.position isEqualToString:@"公司领导"]) {
//                        if (lead_all) {
//                            if (lead_phone) {
//                                [array addObject:model];
//                                continue;
//                            }else{
//                                model.phone=@"";
//                                [array addObject:model];
//                                continue;
//                            }
//                        }else{
//                            DDLogInfo(@"不插入公司领导");
//                        }
//                    }else{
//                        [array addObject:model];
//                    }
//                }
//                //                [array addObject:model];
//            }
//
//
//            FMResultSet * set_1=[db executeQuery:sqlStr1];
//            while ([set_1 next]) {
//                EmployeeModel * model=[[EmployeeModel alloc]init];
//                model.type=2;
//                model.orgId=[set_1 stringForColumn:@"organiztion_tag"];
//                model.name=[set_1 stringForColumn:@"organiztion_name"];
//                [array addObject:model];
//            }
//            [db close];
//        }];
//    }
//    return [NSArray arrayWithArray:array];
//}


//在联系人表中获得所有的部门Id
+(NSArray*)getAllOrgId
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select distinct organization from  contact"];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                NSString *organization=[set stringForColumn:@"organization"];
                [array addObject:organization];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
//在部门表中获得所有的部门名字
+(NSArray*)getAllorgName
{
   NSArray * orgIdArray= [SqlAddressData getAllOrgId];
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            for (int i=0; i<orgIdArray.count; i++) {
                NSString * orgId=orgIdArray[i];
                NSString * sqlStr=[NSString stringWithFormat:@"select distinct organiztion_name from  organiztions where organiztion_tag='%@'",orgId];
                FMResultSet * set=[db executeQuery:sqlStr];
                while ([set next]) {
                    NSString *organization=[set stringForColumn:@"organiztion_name"];
                    [array addObject:organization];
                }
            }
           [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
#pragma  mark---lx
#pragma  mark---更新联系人表中部门名字
+(void)updateContactOfOrgName
{
    NSArray * orgNameArray=[SqlAddressData getAllorgName];
    NSArray * orgIdArray=[SqlAddressData getAllOrgId];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db beginTransaction];
            for (int i=0; i<orgNameArray.count; i++) {
                NSString * orgName=orgNameArray[i];
                NSString * orgId  =orgIdArray[i];
                NSString * sqlStr=[NSString stringWithFormat:@"UPDATE contact set organiztion_name='%@' where organization='%@'",orgName,orgId];
                [db executeUpdate:sqlStr];
            }
            [db commit];
            [db close];
        }];
    }
}
#pragma mark---获得联系人表中所有的名字
+(NSArray*)getAllContactName
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select distinct name from  contact"];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                NSString * name=[set stringForColumn:@"name"];
                [array addObject:name];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
#pragma mark---将名字拆分
+(NSString*)getFirstZimu:(NSString*)name
{
    NSMutableString * zimu=[NSMutableString stringWithCapacity:0];
    NSMutableArray * strArray=[NSMutableArray arrayWithCapacity:0];
    NSInteger length =[name length];
    for (int i=0; i<length; i++) {
        NSRange range=NSMakeRange(i, 1);
        NSString * substr=[name substringWithRange:range];
        [strArray addObject:substr];
//        DDLogInfo(@"strArray====%@",strArray);
    }
    for (int j=0; j<strArray.count; j++) {
        NSString * pinyin=[strArray objectAtIndex:j];
        NSString * oneZimu=[SqlAddressData changeNameChinese:pinyin];
        NSString * first_zimu=[oneZimu substringWithRange:NSMakeRange(0, 1)];
        [zimu insertString:first_zimu atIndex:j];
    }
    return [NSString stringWithString:zimu];
}

#pragma mark---将汉字名字转化拼音
+(NSString*)changeNameChinese:(NSString*)zhongwenName
{
        HanyuPinyinOutputFormat * outPutFormat=[[HanyuPinyinOutputFormat alloc]init];
        [outPutFormat setToneType:ToneTypeWithoutTone];
        [outPutFormat setVCharType:VCharTypeWithV];
        [outPutFormat setCaseType:CaseTypeLowercase];
        NSString *pinyin_name=[PinyinHelper toHanyuPinyinStringWithNSString:zhongwenName withHanyuPinyinOutputFormat:outPutFormat withNSString:@""];
    return pinyin_name;
}
#pragma mark------获得搜索条件的人
+ (NSArray *)getContactWithRequirement:(NSString *)requirement
{
   
    NSDictionary * dic=[self selecLeaderVisibility];
    BOOL lead_all=[dic[leaderVisibility]boolValue];
    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
    __block VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];

     NSMutableArray *arrayContact=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        /**
         要求：中文名字、拼音、拼音缩写、手机号码、短号、部门6种方式
         * menberName      员工名称  name
         * telephonenum    手机号
         * reserve1        拼音缩写
         * reserve2        首字母缩写
         * reserve10       短号     shortNum
         * 中文名
         **/
        
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * phone = [ConstantObject sharedConstant].userInfo.phone;
            NSString *sqlSelectContact=[NSString stringWithFormat:@"select * from contact where  (telephonenum like '%%%@%%' or name like '%%%@%%' or short_num like '%%%@%%' or pinyin_Name like '%%%@%%' or first_name like'%%%@%%' or organiztion_name like '%%%@%%' or name_abbreviate like '%%%@%%') and telephonenum != '%@' limit 0,50",requirement,requirement,requirement,requirement,requirement,requirement,requirement,phone];
            FMResultSet *set=[db executeQuery:sqlSelectContact];
            while ([set next]) {
                EmployeeModel * model=[self getEmployeeModel:set andDb:db];
                [arrayContact addObject:model];
            }
           // DDLogInfo(@"******%@******",arrayContact);
            [db close];
        }];
        for (int i=0; i<arrayContact.count;) {
            EmployeeModel *model=[arrayContact objectAtIndex:i];
            NSArray * see_array=[SqlAddressData selectNewVisibilityTable:model.orgId];
            if (see_array.count>0) {
                isSeeOther=YES;
                filter=[see_array objectAtIndex:0];
            }else{
                isSeeOther=NO;
            }
            if (isSeeOther) {
                if([model.position isEqualToString:@"员工"]){
                    if (filter.visibilityList_staffView==0) {
                        [arrayContact removeObject:model];
                        continue;
                    }
                    
                }if([model.position isEqualToString:@"部门领导"]) {
                    if (filter.visibilityList_leadView==0) {
                        [arrayContact removeObject:model];
                        continue;
                    }
                }if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all==NO) {
                        [arrayContact removeObject:model];
                        continue;
                    }else{
                        if (lead_phone==NO) {
                            model.phone=@"";
                            //[arrayContact addObject:model.phone];
                        }
                    }
                }
            }else{
                if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all==NO) {
                        [arrayContact removeObject:model];
                        continue;
                    }else{
                        if (lead_phone==NO) {
                            model.phone=@"";
                            //[arrayContact addObject:model.phone];
                        }
                    }
                }
                
            }
            i++;
        }
    }
    return [NSArray arrayWithArray:arrayContact];
}


+ (NSArray *)getNewContactWithRequirement:(NSString *)requirement
{
    NSDictionary * dic=[self selecLeaderVisibility];
    BOOL lead_all=[dic[leaderVisibility]boolValue];
    BOOL lead_phone=[dic[leaderPhoneVisibility]boolValue];
    __block VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
    
    __block NSMutableArray *arrayContact=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
      /**
         要求：中文名字、拼音、拼音缩写、手机号码、短号、部门6种方式
         * menberName      员工名称  name
         * telephonenum    手机号
         * reserve1        拼音缩写
         * reserve2        首字母缩写
         * reserve10       短号     shortNum
         * 中文名
      **/
        
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString *sqlSelectContact=[NSString stringWithFormat:@"select * from contact where  (telephonenum like '%%%@%%' or name like '%%%@%%' or short_num like '%%%@%%' or pinyin_Name like '%%%@%%' or first_name like'%%%@%%' or organiztion_name like '%%%@%%' or name_abbreviate like '%%%@%%') limit 0,50",requirement,requirement,requirement,requirement,requirement,requirement,requirement];
            FMResultSet *set=[db executeQuery:sqlSelectContact];
            while ([set next]) {
                EmployeeModel * model=[self getEmployeeModel:set andDb:db];
                [arrayContact addObject:model];
            }
            [db close];
        }];
        for (int i=0; i<arrayContact.count;) {
            EmployeeModel *model=[arrayContact objectAtIndex:i];
            NSArray * see_array=[SqlAddressData selectNewVisibilityTable:model.orgId];
            if (see_array.count>0) {
                isSeeOther=YES;
                filter=[see_array objectAtIndex:0];
            }else{
                isSeeOther=NO;
            }
            if (isSeeOther) {
                if([model.position isEqualToString:@"员工"]){
                    if (filter.visibilityList_staffView==0) {
                        [arrayContact removeObject:model];
                        continue;
                    }
                    
                }if([model.position isEqualToString:@"部门领导"]) {
                    if (filter.visibilityList_leadView==0) {
                        [arrayContact removeObject:model];
                        continue;
                    }
                }if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all==NO) {
                        [arrayContact removeObject:model];
                        continue;
                    }else{
                        if (lead_phone==NO) {
                            model.leaderType=1;
                            //                            model.phone=@"";
                            //[arrayContact addObject:model.phone];
                        }
                    }
                }
            }else{
                if ([model.position isEqualToString:@"公司领导"]) {
                    if (lead_all==NO) {
                        [arrayContact removeObject:model];
                        continue;
                    }else{
                        if (lead_phone==NO) {
                            model.leaderType=1;
                            //                            model.phone=@"";
                            //[arrayContact addObject:model.phone];
                        }
                    }
                }
                
            }
            i++;
        }
    }
    return [NSArray arrayWithArray:arrayContact];
}


+(EmployeeModel *)getEmployeeModel:(FMResultSet *)rs andDb:(FMDatabase *)db{
    
    EmployeeModel *model=[[EmployeeModel alloc] init];
    model.phone=[rs stringForColumn:@"telephonenum"];
    model.position=[rs stringForColumn:@"position"];
    model.tele = [rs stringForColumn:@"tele"];
    model.avatarimgurl=[rs stringForColumn:@"imag_path"];
//    model.personID=[rs stringForColumn:@""];
    model.email=[rs stringForColumn:@"emailaddress"];
    model.title= [rs stringForColumn:@"title"];
    model.imacct=[rs stringForColumn:@"imacct"];
    model.name=[rs stringForColumn:@"name"];
    model.shotNum=[rs stringForColumn:@"short_num"];
    model.comman_orgName=[rs stringForColumn:@"organiztion_name"];
    model.pinyin_name=[rs stringForColumn:@"pinyin_name"];
    model.first_name=[rs stringForColumn:@"first_name"];
    model.orgId=[rs stringForColumn:@"organization"];
    model.orgName=[rs stringForColumn:@"organiztion_name"];
    model.nameSuoXie=[rs stringForColumn:@"name_abbreviate"];
    
    NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM commen_contact WHERE telephonenum='%@'",model.phone];
    FMResultSet * common_rs=[db executeQuery:sqlStr];
    while ([common_rs next]) {
        /**
         *  理论上这里只有一个结果
         */
        model.freqFlag=1;
        break;
    }
    return model;
}

//获得根节点的id,name
+(NSDictionary*)getRootOrganiztions
{
    __block NSMutableDictionary * orgDic=[NSMutableDictionary dictionaryWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select * from organiztions where organiztion_parent_tag='0'"];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                NSString * org_id=[set stringForColumn:@"organiztion_tag"];
                NSString * org_name=[set stringForColumn:@"organiztion_name"];
                [orgDic setValue:org_id forKey:@"organiztion_tag"];
                [orgDic setValue:org_name forKey:@"organiztion_name"];
            }
            [db close];
        }];
    }
    return orgDic;
}
#pragma mark-----获得部门名
+(NSArray*)getOrgName
{
   NSDictionary * dic=[self getRootOrganiztions];
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select * from organiztions where organiztion_parent_tag='%@' order by organization_priority asc",dic[@"organiztion_tag"]];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                EmployeeModel * model=[[EmployeeModel alloc]init];
                model.name=[set stringForColumn:@"organiztion_name"];
                model.orgId=[set stringForColumn:@"organiztion_tag"];
                model.type=2;
                [array addObject:model];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
//查看有没有子结点
+(NSInteger)getChildByName:(NSString*)name
{
    __block NSInteger  child=0;
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select organiztion_have_child  from organiztions where organiztion_name='%@'",name];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                child=[set intForColumn:@"organiztion_have_child"];
             }
            [db close];
        }];
    }
    return child;
}
#pragma mark---获得该部门下的联系人
+(NSArray*)getContactByOrgName:(NSString*)name
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select * from contact where organiztion_name='%@'",name];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                EmployeeModel * model=[[EmployeeModel alloc]init];
                model.name=[set stringForColumn:@"name"];
                model.avatarimgurl=[set stringForColumn:@"imag_path"];
                model.position=[set stringForColumn:@"position"];
                model.phone=[set stringForColumn:@"telephonenum"];
                model.email=[set stringForColumn:@"emailaddress"];
                model.shotNum=[set stringForColumn:@"short_num"];
                [array addObject:model];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
//查询父节点的tag
+(NSString*)getOrgTag
{
    __block NSString * org_tag=[[NSString alloc]init];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select distinct organiztion_tag from organiztions where organiztion_have_child='1' and organiztion_parent_tag!='0'"];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                org_tag=[set stringForColumn:@"organiztion_tag"];
            }
            [db close];
            
        }];
    }
    return org_tag;
}
//得到子部门
+(NSArray*)getOfOrgChildByOrgTag;
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    NSString * org_tag=[SqlAddressData getOrgTag];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select * from organiztions where organiztion_parent_tag='%@'",org_tag];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                NSString * org_name=[set stringForColumn:@"organiztion_name"];
                [array addObject:org_name];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}

+(EmployeeModel *)queryMemberInfoWithImacct:(NSString *)imacct{
    
    __block EmployeeModel *employeeM=[[EmployeeModel alloc] init];
//    if (!addPersonInfoFlag) {
        if ([self openDB]) {
            [menberDbQueue inDatabase:^(FMDatabase *db) {
                [db open];
                //            [db executeUpdate:@"CREATE TABLE contact (_id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT)"];
                NSString *sqlStr=[NSString stringWithFormat:@"select *from contact where imacct = '%@'",imacct];
                FMResultSet *rs=[db executeQuery:sqlStr];
                while ([rs next]) {
                    employeeM.name=[rs stringForColumn:@"name"];
                    employeeM.tele = [rs stringForColumn:@"tele"];
                    employeeM.avatarimgurl=[rs stringForColumn:@"imag_path"];
                    employeeM.position=[rs stringForColumn:@"position"];
                    employeeM.phone=[rs stringForColumn:@"telephonenum"];
                    employeeM.email=[rs stringForColumn:@"emailaddress"];
                    employeeM.shotNum=[rs stringForColumn:@"short_num"];
                    employeeM.imacct=[rs stringForColumn:@"imacct"];
                    employeeM.pinyin_name = [rs stringForColumn:@"pinyin_name"];
                    employeeM.first_name = [rs stringForColumn:@"first_name"];
                    employeeM.comman_orgName = [rs stringForColumn:@"organiztion_name"];
                    break;
                }
                [db close];
            }];
        }
//    }
    return employeeM;
}
+(EmployeeModel *)queryMemberInfoWithEmail:(NSString *)email{
    
    __block EmployeeModel *employeeM=[[EmployeeModel alloc] init];
    //    if (!addPersonInfoFlag) {
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString *sqlStr=[NSString stringWithFormat:@"select *from contact where emailaddress = '%@'",email];
            FMResultSet *rs=[db executeQuery:sqlStr];
            while ([rs next]) {
                employeeM.name=[rs stringForColumn:@"name"];
                employeeM.avatarimgurl=[rs stringForColumn:@"imag_path"];
                employeeM.position=[rs stringForColumn:@"position"];
                employeeM.phone=[rs stringForColumn:@"telephonenum"];
                employeeM.email=[rs stringForColumn:@"emailaddress"];
                employeeM.shotNum=[rs stringForColumn:@"short_num"];
                employeeM.imacct=[rs stringForColumn:@"imacct"];
                break;
            }
            [db close];
        }];
    }
    //    }
    return employeeM;
}
#pragma mark ----根据手机号码搜索联系人

+(EmployeeModel *)queryMemberInfoWithPhone:(NSString *)phone{
    
    __block EmployeeModel *employeeM=[[EmployeeModel alloc] init];
    //    if (!addPersonInfoFlag) {
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            //            [db executeUpdate:@"CREATE TABLE contact (_id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organization TEXT,organiztion_name TEXT)"];
            NSString *sqlStr=[NSString stringWithFormat:@"select *from contact where telephonenum = '%@'",phone];
            FMResultSet *rs=[db executeQuery:sqlStr];
            while ([rs next]) {
                employeeM.name=[rs stringForColumn:@"name"];
                employeeM.avatarimgurl=[rs stringForColumn:@"imag_path"];
                employeeM.position=[rs stringForColumn:@"position"];
                employeeM.phone=[rs stringForColumn:@"telephonenum"];
                employeeM.email=[rs stringForColumn:@"emailaddress"];
                employeeM.shotNum=[rs stringForColumn:@"short_num"];
                employeeM.imacct=[rs stringForColumn:@"imacct"];
                employeeM.comman_orgName = [rs stringForColumn:@"organiztion_name"];
                break;
            }
            [db close];
        }];
    }
    //    }
    return employeeM;
}

#pragma mark----创建常用联系人表
+(void)createCommenContact
{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db setShouldCacheStatements:YES];
            if (![db tableExists:@"commen_contact"]) {
                [db executeUpdate:@"CREATE TABLE commen_contact (_id INTEGER PRIMARY KEY,name TEXT,emailaddress TEXT,telephonenum TEXT,imacct TEXT,short_num TEXT,uid TEXT,sort_key TEXT,position TEXT,imag_path TEXT,weight INTEGER NOT NULL DEFAULT 0 ,organiztion_name TEXT,frag INTEGER)"];
            }
            [db close];
        }];
     }
}

#pragma mark----------跟新常用联系人照片
+(void)updateCommenContactImage:(NSString *)imgurl WithUserPhone:(NSString *)phone{
        if ([self openDB]) {
            [menberDbQueue inDatabase:^(FMDatabase *db) {
                [db open];
                if ([db tableExists:@"commen_contact"]) {
                     NSString *sqlStr=[NSString stringWithFormat:@"UPDATE commen_contact set imag_path='%@' where telephonenum='%@'",imgurl,phone];
                    [db executeUpdate:sqlStr];
                    [db commit];
                }
            }];
        }
}
    



#pragma mark-----更新常用联系人表的信息
+(void)updateCommenContact:(EmployeeModel*)model OrgName:(NSString*)orgName;
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
       if (!model.freqFlag==1)
        {
            NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
            if ([db tableExists:@"commen_contact"]) {
                NSString * sqlStr=[NSString stringWithFormat:@"INSERT INTO commen_contact (name,emailaddress,telephonenum,imacct,short_num,uid,sort_key,position,imag_path,weight,organiztion_name ,frag,imacct) VALUES ('%@','%@','%@','%@','%@','%@',0,'%@','%@',0,'%@',1,'%@')",model.name,model.email,model.phone,model.imacct,model.shotNum,uid,model.position,model.avatarimgurl,orgName,model.imacct];
                [db executeUpdate:sqlStr];
            }
         }
        else{
            if ([db tableExists:@"commen_contact"]) {
                NSString * sqlStr=[NSString stringWithFormat:@"DELETE FROM commen_contact WHERE name = '%@'",model.name];
                [db executeUpdate:sqlStr];
            }
        }
       [db close];
    }];
}

//查询常用联系人表
+(NSArray*)selectCommanContact:(NSString*)userUid
{
    __block NSMutableArray *array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM commen_contact WHERE uid='%@'",userUid];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
//                EmployeeModel * model=[[EmployeeModel alloc]init];
//                model.name=[set stringForColumn:@"name"];
//                model.avatarimgurl=[set stringForColumn:@"imag_path"];
//                model.position=[set stringForColumn:@"position"];
//                model.phone=[set stringForColumn:@"telephonenum"];
//                model.email=[set stringForColumn:@"emailaddress"];
//                model.shotNum=[set stringForColumn:@"short_num"];
//                model.imacct=[set stringForColumn:@"imacct"];
//                model.personID=[set stringForColumn:@""];
//                model.comman_orgName=[set stringForColumn:@"organiztion_name"];
//                model.freqFlag=1;
//                model.type=1;
                NSString *imacct = [set stringForColumn:@"imacct"] ;
                [array addObject:imacct];
            }
            [db close];
        }];
    }
  //   return [NSArray arrayWithArray:array];
    NSMutableArray *empArray=[NSMutableArray arrayWithCapacity:0];
    for (NSString *imacct in array) {
        EmployeeModel *model = [SqlAddressData queryMemberInfoWithImacct:imacct];
        if (model.imacct) {
            model.freqFlag=1;
            model.type=1;
            [empArray addObject:model];
        }
    }
  return [NSArray arrayWithArray:empArray];
}
+(NSArray*)selectCommanContactByPhone:(NSString*)phone
{
    __block NSMutableArray *array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"SELECT * FROM commen_contact WHERE telephonenum='%@'",phone];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                EmployeeModel * model=[[EmployeeModel alloc]init];
                model.name=[set stringForColumn:@"name"];
                model.avatarimgurl=[set stringForColumn:@"imag_path"];
                model.position=[set stringForColumn:@"position"];
                model.phone=[set stringForColumn:@"telephonenum"];
                model.email=[set stringForColumn:@"emailaddress"];
                model.shotNum=[set stringForColumn:@"short_num"];
                model.imacct=[set stringForColumn:@"imacct"];
                model.personID=[set stringForColumn:@""];
                model.comman_orgName=[set stringForColumn:@"organiztion_name"];
                model.freqFlag=1;
                model.type=1;
                [array addObject:model];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}

#pragma mark-----联系人可见性表-----
+(void)createVisibilityContactTable
{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db setShouldCacheStatements:YES];
            if (![db tableExists:@"contact_visibility"]) {
                [db executeUpdate:@"CREATE TABLE contact_visibility (_id INTEGER PRIMARY KEY,personID INTEGER,uid TEXT,positionId TEXT,mine_orgId TEXT,visibilityList_orgId TEXT,visibilityList_parentId TEXT,visibilityList_leadView INTEGER NOT NULL DEFAULT 1 ,visibilityList_staffView INTEGER NOT NULL DEFAULT 1)"];
            }
            [db close];
        }];
    }
}
#pragma mark-----添加信息
+(void)deleteVisilityInfo:(NSString*)see_orgId
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([db tableExists:@"newcontact_visibility"]) {
            NSString * sqlStr=[NSString stringWithFormat:@"DELETE FROM  newcontact_visibility where orgId ='%@'",see_orgId];
//@"DELETE FROM newcontact_visibility"
            [db executeUpdate:sqlStr];
        }
        [db close];
    }];
}
+(void)deleteVisilityContact
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([db tableExists:@"leader_visibility"]) {
            [db executeUpdate:@"DELETE FROM newcontact_visibility"];
        }
        [db close];
    }];

}

+(void)deleteLeadertable
{
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([db tableExists:@"leader_visibility"]) {
            [db executeUpdate:@"DELETE FROM leader_visibility"];
        }
        [db close];
    }];
}

#pragma mark-----可见性表插入信息----
+(void)addVisibilityInfo:(VisibilityContactModel*)model
{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"INSERT INTO contact_visibility (personID,uid,positionId,mine_orgId,visibilityList_orgId,visibilityList_parentId,visibilityList_leadView,visibilityList_staffView ) VALUES ('%d','%@','%@','%@','%@','%@','%d','%d')",model.personID,model.uid,model.positionId,model.mine_orgId,model.visibilityList_orgId,model.parentId,model.visibilityList_leadView,model.visibilityList_staffView];
            [db executeUpdate:sqlStr];
            [db close];
        }];
    }
}
//查询可见性表是否为空 YES代表不为空
+(BOOL)queryVisibilityContact
{
    __block BOOL result=NO;
    [self openDB];
    [menberDbQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=@"select *from newcontact_visibility";
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            result=YES;
            break;
        }
        
        [db close];
    }];
    
    return result;
}

#pragma mark------查询可见性------
+(NSArray*)selectvisibility
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            VisibilityContactModel * model=[[VisibilityContactModel alloc]init];
           
                NSString * sqlStr=@"SELECT * FROM contact_visibility";
                FMResultSet * set=[db executeQuery:sqlStr];
                while ([set next]) {
                    model.positionId=[set stringForColumn:@"positionId"];
                    model.mine_orgId=[set stringForColumn:@"mine_orgId"];
                    model.visibilityList_orgId=[set stringForColumn:@"visibilityList_orgId"];
                    model.visibilityList_leadView=[set intForColumn:@"visibilityList_leadView"];
                    model.visibilityList_staffView=[set intForColumn:@"visibilityList_staffView"];
                    [array addObject:model];
                }
         [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
#pragma mark-----领导人可见性表---
+(void)createVisibilityLeaderTable
{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db setShouldCacheStatements:YES];
            if (![db tableExists:@"leader_visibility"]) {
                [db executeUpdate:@"CREATE TABLE leader_visibility (_id INTEGER PRIMARY KEY,leaderVisibility INTEGER,leaderPhoneVisibility INTEGER)"];
            }
            [db close];
        }];
    }
}
+(void)addLeaderVisibilityLeader:(BOOL)leader_all leaderPhone:(BOOL)leader_phone{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"INSERT INTO leader_visibility (leaderVisibility,leaderPhoneVisibility) VALUES ('%d','%d')",leader_all,leader_phone];
            [db executeUpdate:sqlStr];
            [db close];
        }];
    }

}
+(NSDictionary*)selecLeaderVisibility
{
    __block NSMutableDictionary * dic=[NSMutableDictionary dictionaryWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
             NSString * sqlStr=@"SELECT * FROM leader_visibility";
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                BOOL leader1=[set intForColumn:@"leaderVisibility"];
                NSString * leaderVisibility1=[NSString stringWithFormat:@"%d",leader1];
                BOOL leader2=[set intForColumn:@"leaderPhoneVisibility"];
                NSString  *leaderPhoneVisibility1=[NSString stringWithFormat:@"%d",leader2];
                [dic setObject:leaderVisibility1 forKey:leaderVisibility];
                [dic setObject:leaderPhoneVisibility1 forKey:leaderPhoneVisibility];
            }
            [db close];
        }];
    }
    return [NSDictionary dictionaryWithDictionary:dic];
}
#pragma mark------创建新的表,表中的字段保存有屏蔽的部门id，员工，领导的屏蔽性
+(void)createNewVisibilityTable
{
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            [db setShouldCacheStatements:YES];
            if (![db tableExists:@"newcontact_visibility"]) {
                [db executeUpdate:@"CREATE TABLE newcontact_visibility (_id INTEGER PRIMARY KEY,orgId TEXT,lead_see INTEGER ,people_see INTEGER )"];
            }
            [db close];
        }];
    }

}
#pragma mark----添加新的可见性表信息
+(void)addNewVisibility:(VisibilityContactModel*)model
{
//    NSArray * arrray=[self selectAllOrgID];
//    __block NSString * org=@"";
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
//            for (int i=0; i<arrray.count; i++) {
//               NSString * org=[arrray objectAtIndex:i];
//                if ([model.visibilityList_orgId class]) {
//                    if ([model.visibilityList_orgId isEqualToString:org]) {
                        NSString * sqlStr=[NSString stringWithFormat:@"INSERT INTO newcontact_visibility (orgId,lead_see,people_see) VALUES ('%@',%d,%d)",model.visibilityList_orgId,model.visibilityList_leadView,model.visibilityList_staffView];
                        [db executeUpdate:sqlStr];
//                        break;
//                    }
//                }
//                }
          [db close];
        }];
    }
}
//查询数据库
+(NSArray*)selectNewVisibilityTable
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select *from newcontact_visibility"];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                VisibilityContactModel * model=[[VisibilityContactModel alloc]init];
                model.visibilityList_leadView=[set intForColumn:@"lead_see"];
                model.visibilityList_staffView=[set intForColumn:@"people_see"];
                model.visibilityList_orgId=[set stringForColumn:@"orgId"];
                [array addObject:model];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];

}
+(NSArray*)selectNewVisibilityTable:(NSString*)see_orgId
{
    __block NSMutableArray * array=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=[NSString stringWithFormat:@"select *from newcontact_visibility where orgId='%@'",see_orgId];
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                VisibilityContactModel * model=[[VisibilityContactModel alloc]init];
                model.visibilityList_leadView=[set intForColumn:@"lead_see"];
                model.visibilityList_staffView=[set intForColumn:@"people_see"];
                [array addObject:model];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:array];
}
#pragma mark----查询所有的部门ID
+(NSArray*)selectAllOrgID
{
    __block NSMutableArray * orgIdArray=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=@"SELECT  organiztion_tag FROM organiztions";
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                NSString * orgId=[set stringForColumn:@"organiztion_tag"];
                [orgIdArray addObject:orgId];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:orgIdArray];
}
#pragma mark----查询可见性表的所有数据
+(NSArray*)checkOutAll
{
    __block NSMutableArray * orgIdArray=[NSMutableArray arrayWithCapacity:0];
    if ([self openDB]) {
        [menberDbQueue inDatabase:^(FMDatabase *db) {
            [db open];
            NSString * sqlStr=@"SELECT  * FROM newcontact_visibility";
            FMResultSet * set=[db executeQuery:sqlStr];
            while ([set next]) {
                VisibilityContactModel * filter=[[VisibilityContactModel alloc]init];
                filter.visibilityList_orgId=[set stringForColumn:@"orgId"];
                filter.visibilityList_leadView=[set intForColumn:@"lead_see"];
                filter.visibilityList_staffView=[set intForColumn:@"people_see"];
                [orgIdArray addObject:filter];
            }
            [db close];
        }];
    }
    return [NSArray arrayWithArray:orgIdArray];
}

@end