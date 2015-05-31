//
//  SqliteDataDao.m
//  e企
//
//  Created by roya-7 on 14/11/4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "SqliteDataDao.h"
//聊天数据保存路径
#define CHAT_SQLITE_PATH [NSString stringWithFormat:@"/chatData/chatData.sqlite"]

#define chatTableName @"chat_message_table"//默认表名
#define chat_message_image_table_name @"chat_message_image"//图片信息表名
#define chat_voice_data_table_name @"chat_message_voice_table"//语音表名
#define chat_list @"chat_list" //聊天回话列表,表
#define chat_group @"chat_group_table"//群组数据
#define chat_public @"chat_public"//公众号
#define chat_bulletin @"chat_bulletin" //公告
#define chat_teammessage @"chat_teammessage"  //和企录团队
#define chat_video @"chat_video"//视频
#define chat_tempstr @"chat_tempstr"//会话草稿
static SqliteDataDao *dataDao=nil;
static FMDatabaseQueue *dataQueue=nil;
@implementation SqliteDataDao

#pragma mark - 创建表格
//建表的方便方法，传入表名和字段名的字符串数组，再传入要建立索引的字段名字符串数组就可以了，如果表已存在则会drop后重新建新表
- (BOOL)createTable:(NSString *)table columns:(NSArray *)columns indexes:(NSArray *)indexes whithDb:(FMDatabase *)db
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
            d = @" NOT NULL DEFAULT ''";
            
        } else if ([c hasSuffix:@"integer"]
                   || [c hasSuffix:@"real"]
                   || [c hasSuffix:@"numeric"]
                   ) {
            d = @" NOT NULL DEFAULT 0";
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
///<初始化
+(SqliteDataDao *)sharedInstanse{
    if (!dataDao) {
        dataDao=[[SqliteDataDao alloc] init];
        
    }
    return dataDao;
}
-(void)releaseData{
    if (dataDao) {
        dataDao=nil;
    }
    if(dataQueue){
        dataQueue=nil;
    }
}
-(id)init{
    self=[super init];
    if (self) {
        //创建dbQueue对象
        [self open];
    }
    return self;
}
-(void)open{
    if (!dataQueue) {
        NSString *gid=[[NSUserDefaults standardUserDefaults] objectForKey:myGID];
        if(!gid || (NSNull *)gid == [NSNull null])
        {
            DDLogInfo(@"%@",gid);
            return;
        }
        NSString *sqlPath=[[NSString stringWithFormat:@"/chatData/chatData_%@_%@.sqlite",[ConstantObject sharedConstant].userInfo.phone,gid] filePathOfDocuments];
        
        DDLogInfo(@"%@",sqlPath);
        NSString *sqliteDictionary = [sqlPath stringByDeletingLastPathComponent];
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:sqliteDictionary]){
            [fileManager createDirectoryAtPath:sqliteDictionary withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        dataQueue=[FMDatabaseQueue databaseQueueWithPath:sqlPath];
    }
}
//排序方法
NSComparator cmptrMenbermess = ^(id obj1, id obj2){
    NSString *str1 = obj1;
    NSString *str2 = obj2;
    return [str1 compare:str2];
};
-(void)creatTabel{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        [self createTaskTable:db];
        [self createTaskStatusTable:db];
        NSString *tableName=@"chat_message_table";
        if (![db tableExists:tableName]) {
//            <message id="5gMA1-4" to="+8618867101953_3398351028@li726-26" type="chat" from="+8613911633763_3398351028@li726-26/Smack">
//            <body>返回</body><thread>745b98c7-2c2e-4a99-b0fb-977c979bd083</thread></message>

            NSArray *columns=@[@"id integer primary key autoincrement",//自增长字段
                               @"userId text",          ///<当前用户名
                               @"receiveTime text",     ///<接受时间
                               @"messageId text",       ///<消息id
                               @"toUserId text",        ///<to
                               @"fromUserId text",      ///<from
                               @"chatType integer",     //消息类型,单聊为0,群聊为1,
                               @"content text",         //消息内容
                               @"thread text",          //thread
                               @"messageType integer",  //消息类型,0为文本,1为图片,2为语音
                               @"isRead integer",       //是否已读,0未读,1已读
                               @"isSendSucceed text",   //是否发送成功,默认为0正在发送,成功1,失败2
                               @"purpose integer"       // 用途（如1预留，转任务2，默认为0）.
                               ];
            NSArray *indexes=@[@"id",@"userId",@"receiveTime",@"messageId",@"toUserId",@"fromUserId",@"chatType",@"content",@"thread",@"messageType,isRead,isSendSucceed, purpose"];
            BOOL result=[self createTable:tableName columns:columns indexes:indexes whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        
        if (![db tableExists:@"chat_message_image"]) {
            NSArray *colums=@[@"id integer primary key autoincrement",
                              @"messageId text",
                              @"middleLink text",
                              @"originalLink text",
                              @"smallLink text",
                              @"imageName text",
                              @"imagePath text",
                              @"imageWidth integer",
                              @"imageHeight integer"
                              ];
            BOOL result=[self createTable:@"chat_message_image" columns:colums indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }

        }
        if (![db tableExists:chat_voice_data_table_name]) {
            NSArray *colume=@[@"id integer primary key autoincrement",
                              @"messageId text",
                              @"voiceUrl text",
                              @"voiceLength text",
                              @"voicePath text",
                              @"voiceName text"
                              ];
            BOOL result=[self createTable:chat_voice_data_table_name columns:colume indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        
        if (![db columnExists:@"IsPlay integer" inTableWithName:chat_voice_data_table_name]) {
            [db executeUpdate:@"alter table chat_message_voice_table add IsPlay integer default 0"];
        }
        if (![db tableExists:chat_list]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"toUserId text",///<to
                               @"fromUserId text",///<from
                               @"chatType integer",//聊天类型,单聊为0,群聊为1
                               @"lastMessage text",//最后一条消息
                               @"lastTime text",//最后一条消息时间
                               @"lastSender text",//最后一条消息的发送人
                               @"lastMessageType integer",//最后一条消息的类型
                               @"lastMessageId text",//最后一条消息的id
                               @"toUserIdAvatar text",//对方的头像
                               @"isDelete integer",//是否被删除
                               @"priority integer",//优先级,用于置顶排序
                               @"chatName text"//如果是群聊,或者服务号,为其名字
                               ];
            BOOL result=[self createTable:chat_list columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        if(![db tableExists:chat_tempstr]){
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"toUserId text",
                               @"tempstr text"];
            BOOL result=[self createTable:chat_tempstr columns:columes indexes:nil whithDb:db];
            if(result){
                DDLogInfo(@"会话草稿建表成功");
            }
        }
        
        if (![db tableExists:chat_group]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"userid text",
                               @"roomName text",
                               @"roomJid text",
                               @"roomMemberList text"];
            BOOL result=[self createTable:chat_group columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        if (![db tableExists:chat_public]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"pa_uuid text",
                               @"name text",
                               @"logo text",
                               @"sip_uri text"];
            BOOL result=[self createTable:chat_public columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        if (![db tableExists:chat_bulletin]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"title text",
                               @"bulletinID text",
                               @"msg_digest text",
                               @"picUrl text",
                               @"fileType text",
                               @"createTime text",
                               @"receiveTime text"];
            BOOL result=[self createTable:chat_bulletin columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"公告创建表成功");
            }
        }
        if (![db tableExists:chat_video]) {

            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"messageId text",
                               @"duration text",
                               @"createTime text",
                               @"filesize text",
                               @"media_uuid text",
                               @"original_link text",
                               @"title text"];
            BOOL result=[self createTable:chat_video columns:columes indexes:columes whithDb:db];
            if (result) {
                DDLogInfo(@"创建表成功");
            }
        }
        [db close];
        
    }];
}

-(BOOL)isExitSomeColumn
{
    [self open];
    __block BOOL result=NO;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //       设置缓存区
        [db setShouldCacheStatements:YES];
        //       创建表
        if ([db tableExists:chatTableName]) {
            if ([db columnExists:@"purpose" inTableWithName:chatTableName]) {
                result = YES;
            }else
            {
                [db executeUpdate:@"alter table chat_message_table add purpose text"];
    
            }
        }
        [db close];
    }];
    return result;

}


#pragma mark - 插入数据
-(BOOL)insertDataToMessageData:(MessageModel *)mm{
    [self open];
    
    __block BOOL _result=NO;
    
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *userId=[ConstantObject sharedConstant].userInfo.phone;
        NSString *receiveTime=mm.receivedTime;
        NSString *messageID=mm.messageID;
        NSString *toUserId=mm.to;
        NSString *fromUserId=mm.from;
        NSString *chatType=[NSString stringWithFormat:@"%d",mm.chatType];
        NSString *content=mm.msg;
        NSString *thread=mm.thread;
        NSString *messageType=[NSString stringWithFormat:@"%d",mm.fileType];
//        NSString *purpose = [NSString stringWithFormat:@"%d", mm.purpose];
        
        NSString *slecetStr=[NSString stringWithFormat:@"select *from chat_message_table where messageId='%@'",messageID];
        FMResultSet *rs=[db executeQuery:slecetStr];
        
        BOOL isExist=NO;
        
        while ([rs next]) {
            isExist=YES;
            _result=NO;
            DDLogInfo(@"消息已经存在,跳过");
            break;
        }
        NSString *isRead=@"0";
        NSString *purpose=@"0";
        if (mm.fileType==7) {
//            isRead=@"1";
        }
         NSString *toUserId_str=mm.to;
        if (!isExist) {
            NSString *sqlStr=@"insert into chat_message_table ('userId','receiveTime','messageId','toUserId','fromUserId','chatType','content','thread','messageType','isRead','purpose','isSendSucceed') VALUES(?,?,?,?,?,?,?,?,?,?,?,'3')";
            [db executeUpdate:sqlStr,userId,receiveTime,messageID,toUserId,fromUserId,chatType,content?content:@"",thread?thread:@"",messageType,isRead,purpose];
            
            if ([messageType isEqualToString:@"1"]) {
                //图片
                [self insertImageChatData:mm withDb:db];
            }else if ([messageType isEqualToString:@"2"]){
                //声音
                [self insertVoiceChatData:mm withDb:db];
            }else if ([messageType isEqualToString:@"4"]){
                //视频
                [self insertVideoChatData:mm withDb:db];
            }
            
            //开始插入聊天回话表
            //先查询是否存在
            
            if (mm.chatType == 1 && mm.fileType !=7 ) {
                NSString *selectGroupChatListSql=[NSString stringWithFormat:@"select *from chat_group_table where roomJid='%@'",mm.to];
                FMResultSet *chat_group_list_rs=[db executeQuery:selectGroupChatListSql];
                if (![chat_group_list_rs next]) {
                    _result = NO;
                    return;
                }
            }
            
            
        }
        if ([mm.to isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
            //如果是发给我的消息,把from和to调换
            toUserId_str=mm.from;
        }
        NSString *selectChatListSql=[NSString stringWithFormat:@"select *from %@ where toUserId='%@'",chat_list,toUserId_str];
        FMResultSet *chat_list_rs=[db executeQuery:selectChatListSql];
        BOOL chat_list_isExist=NO;
        while ([chat_list_rs next]) {
            chat_list_isExist=YES;
        }
        
        if (chat_list_isExist) {
            //            UPDATE %@ set isSendSucceed = '%@' where messageId ='%@'",chatTableName,state,messageId
            NSString *updateChatList=[NSString stringWithFormat:@"update %@ set isDelete = '0',lastSender='%@',lastTime='%@',lastMessageType ='%@',lastMessage ='%@',lastMessageId='%@' where toUserId='%@'",chat_list,fromUserId,receiveTime,messageType,content,messageID,toUserId_str];
            BOOL result=[db executeUpdate:updateChatList];
            if (result) {
                DDLogInfo(@"更新聊天回话表成功");
            }
            _result= result&& !isExist ;
        }else{
            NSString *insertChatList;
            if(mm.chatType == 4)
            {
                insertChatList=[NSString stringWithFormat:@"insert into %@(toUserId,fromUserId,chatType,lastMessage,lastTime,lastSender,toUserIdAvatar,isDelete,priority,chatName,lastMessageType,lastMessageId) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",chat_list,toUserId_str,toUserId_str,chatType,content,receiveTime,fromUserId,@"",@"0",@"1",@"",messageType,messageID];
            }else
            {
                insertChatList=[NSString stringWithFormat:@"insert into %@(toUserId,fromUserId,chatType,lastMessage,lastTime,lastSender,toUserIdAvatar,isDelete,priority,chatName,lastMessageType,lastMessageId) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",chat_list,toUserId_str,toUserId_str,chatType,content,receiveTime,fromUserId,@"",@"0",@"0",@"",messageType,messageID];
            }
            BOOL result=[db executeUpdate:insertChatList];
            if (result) {
                DDLogInfo(@"插入聊天回话表成功");
            }
            _result=result;
        }
        
        
        [db close];
    }];
    
    return _result;
}
-(BOOL)insertImageChatData:(MessageModel *)mm withDb:(FMDatabase *)db{
    
    NSString *messageId=mm.messageID;
    NSString *middleLink=mm.imageChatData.middleLink;
    NSString *originalLink=mm.imageChatData.originalLink;
    NSString *smallLink=mm.imageChatData.smallLink;
    NSString *imageName=mm.imageChatData.imageName;
    NSString *path=mm.imageChatData.imagePath;
//    int width=mm.imageChatData.imagewidth;
//    int height=mm.imageChatData.imageheight;
    NSString *width=[NSString stringWithFormat:@"%d",mm.imageChatData.imagewidth];
    NSString *height=[NSString stringWithFormat:@"%d",mm.imageChatData.imageheight];
    NSString *sqlStr=@"insert into chat_message_image(messageId,middleLink,originalLink,smallLink,imageName,imagePath,imageWidth,imageHeight) values(?,?,?,?,?,?,?,?)";
    BOOL result=[db executeUpdate:sqlStr,messageId,middleLink?middleLink:@"",originalLink?originalLink:@"",smallLink?smallLink:@"",imageName?imageName:@"",path?path:@"",width?width:@"120",height?height:@"90"];
    return result;
    
}
-(BOOL)insertVoiceChatData:(MessageModel *)mm withDb:(FMDatabase *)db{
    

    NSString *messageId=mm.messageID;
    NSString *voiceUrl=mm.chatVoiceData.voiceUrl;
    NSString *voicePath=mm.chatVoiceData.voicePath;
    NSString *voiceLength=mm.chatVoiceData.voiceLenth;
    NSString *sqlStr=[NSString stringWithFormat:@"insert into %@(messageId,voiceUrl,voicePath,voiceLength) values(?,?,?,?)",chat_voice_data_table_name];
    BOOL result=[db executeUpdate:sqlStr,messageId,voiceUrl?voiceUrl:@"",voicePath?voicePath:@"",voiceLength?voiceLength:@""];
    
    return result;
}
-(BOOL)insertVideoChatData:(MessageModel *)mm withDb:(FMDatabase *)db{

    NSString *messageId=mm.messageID;
    NSString *createTime=mm.chatVideoModel.createTime;
    NSString *duration=mm.chatVideoModel.duration;
    NSString *fileSize=mm.chatVideoModel.filesize;
    NSString *media_uuid=mm.chatVideoModel.media_uuid;
    NSString *original_link=mm.chatVideoModel.original_link;
    NSString *title=mm.chatVideoModel.title;

    NSString *sqlStr=[NSString stringWithFormat:@"insert into %@(messageId,duration,createTime,filesize,media_uuid,original_link,title) values('%@','%@','%@','%@','%@','%@','%@')",chat_video,messageId,duration?duration:@"",createTime?createTime:@"",fileSize?fileSize:@"",media_uuid?media_uuid:@"",original_link?original_link:@"",title?title:@""];
    
    BOOL result=[db executeUpdate:sqlStr];
    
    return result;
}
-(BOOL)insertTempstr:(NSString *)toUserId tempstr:(NSString *)str{
    [self open];
    __block BOOL _result=NO;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sqlStr=[NSString stringWithFormat:@"insert into %@(toUserID,tempstr) values('%@','%@')",chat_tempstr,toUserId,str];
        BOOL result=[db executeUpdate:sqlStr];
        if(result){
            DDLogInfo(@"插入草稿信息成功");
        }else{
            DDLogInfo(@"插入草稿信息失败");
        }
        _result=result;
        [db close];
    }];
    return _result;
}
#pragma mark - 聊天记录查询
-(NSArray *)queryChatDataWithToUserId:(NSString *)toUserId{
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *userId=[ConstantObject sharedConstant].userInfo.phone;
        
//        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        
//        NSString *selectStr=[NSString stringWithFormat:@"select *from chat_message_table where userid='%@'  and touserid='%@' order by receiveTime asc",userId,toUserId];
        NSString *selectStr=[NSString stringWithFormat:@"select *from chat_message_table where userid='%@'  and touserid='%@' order by id asc",userId,toUserId];
        FMResultSet *rs=[db executeQuery:selectStr];
        while ([rs next]) {
            NotesData *nd=[self getNotesData:rs];
            
            if(nd.chatType == 5)
            {
                NSString *selectTeamMsgSql = [NSString stringWithFormat:@"select *from chat_teammessage where notify_msgid = '%@'",nd.contentsUuid];
                FMResultSet *teamMsgData_rs=[db executeQuery:selectTeamMsgSql];
                while ([teamMsgData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.teamMsgModel=[self getTeamMessageModelWithRs:teamMsgData_rs];
                }
                [teamMsgData_rs close];
                
            }else if ([nd.typeMessage isEqualToString:@"1"]) {
                //图片
                NSString *selectImageDataSql=[NSString stringWithFormat:@"select *from chat_message_image where messageId = '%@'",nd.contentsUuid];
                FMResultSet *imageData_rs=[db executeQuery:selectImageDataSql];
                while ([imageData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.imageCHatData=[self getImageChatData:imageData_rs];
                }
                [imageData_rs close];
                
            }else if ([nd.typeMessage isEqualToString:@"2"]){
                //语音
                NSString *selectVoiceDataSql=[NSString stringWithFormat:@"select *from %@ where messageId = '%@'",chat_voice_data_table_name,nd.contentsUuid];
                FMResultSet *voiceData_rs=[db executeQuery:selectVoiceDataSql];
                while ([voiceData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.chatVoiceData=[self getChatVoiceData:voiceData_rs];
                }
                [voiceData_rs close];
            }else if ([nd.typeMessage isEqualToString:@"4"]){
                NSString *selectVideoSql=[NSString stringWithFormat:@"select *from %@ where messageId = '%@'",chat_video,nd.contentsUuid];
                FMResultSet *videoRs=[db executeQuery:selectVideoSql];
                while ([videoRs next]) {
                    nd.chatVideoModel=[self getChatVideoData:videoRs];
                }
                [videoRs close];
            }
            
            [array addObject:nd];
        }
        
        [db close];
    }];
    
    return array;
}
-(NSArray *)queryChatDataWithToUserId:(NSString *)toUserId location:(int)location length:(int)length{
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *userId=[ConstantObject sharedConstant].userInfo.phone;
//        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        NSString *selectStr=[NSString stringWithFormat:@"select *from chat_message_table where userid='%@' and isRead='1' and touserid='%@' order by id desc limit %d,%d",userId,toUserId,location,length];
        DDLogInfo(@"%@",selectStr);
        FMResultSet *rs=[db executeQuery:selectStr];
        while ([rs next]) {
            NotesData *nd=[self getNotesData:rs];
            if(nd.chatType == 5)
            {
                NSString *selectTeamMsgSql = [NSString stringWithFormat:@"select *from chat_teammessage where notify_msgid = '%@'",nd.contentsUuid];
                FMResultSet *teamMsgData_rs=[db executeQuery:selectTeamMsgSql];
                while ([teamMsgData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.teamMsgModel=[self getTeamMessageModelWithRs:teamMsgData_rs];
                    if([nd.typeMessage isEqualToString:@"1"]){
                        ImageChatData *icd=[[ImageChatData alloc] init];
                        icd.middleLink=nd.teamMsgModel.notify_picUrl;
                        icd.originalLink=nd.teamMsgModel.notify_picUrl;
                        icd.smallLink=nd.teamMsgModel.notify_picUrl;
                        icd.imageName=@"";
                        icd.imagePath=@"";
                        icd.imagewidth=[nd.teamMsgModel.with_pic floatValue];
                        icd.imageheight=[nd.teamMsgModel.height_pic floatValue];
                        nd.imageCHatData=icd;
                    }
                }
                [teamMsgData_rs close];
                
            }else if ([nd.typeMessage isEqualToString:@"1"]) {
                //图片
                NSString *selectImageDataSql=[NSString stringWithFormat:@"select *from chat_message_image where messageId = '%@'",nd.contentsUuid];
                FMResultSet *imageData_rs=[db executeQuery:selectImageDataSql];
                while ([imageData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.imageCHatData=[self getImageChatData:imageData_rs];
                }
                [imageData_rs close];
                
            }else if ([nd.typeMessage isEqualToString:@"2"]){
                //语音
                NSString *selectVoiceDataSql=[NSString stringWithFormat:@"select *from %@ where messageId = '%@'",chat_voice_data_table_name,nd.contentsUuid];
                FMResultSet *voiceData_rs=[db executeQuery:selectVoiceDataSql];
                while ([voiceData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.chatVoiceData=[self getChatVoiceData:voiceData_rs];
                }
                [voiceData_rs close];
            }else if ([nd.typeMessage isEqualToString:@"4"]){
                NSString *selectVideoSql=[NSString stringWithFormat:@"select *from %@ where messageId = '%@'",chat_video,nd.contentsUuid];
                FMResultSet *videoRs=[db executeQuery:selectVideoSql];
                while ([videoRs next]) {
                    nd.chatVideoModel=[self getChatVideoData:videoRs];
                }
                [videoRs close];
            }
            
            [array addObject:nd];
        }
        
        [db close];
    }];
    return array;
}
-(NotesData *)queryChatMessageWithMessageID:(NSString *)messageId{
    __block  NotesData *nd;
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *selectStr=[NSString stringWithFormat:@"select *from chat_message_table where  messageid = '%@'",messageId];
        FMResultSet *rs=[db executeQuery:selectStr];
        while ([rs next]) {
           nd=[self getNotesData:rs];
        }
        [db close];
    }];
    return nd;
}
-(NotesData *)getNotesData:(FMResultSet *)rs{
    NotesData *notesData=[[NotesData alloc] init];
    notesData.contentsUuid=[rs stringForColumn:@"messageId"];
    notesData.sendContents=[rs stringForColumn:@"content"];
    notesData.chatType = [[rs stringForColumn:@"chatType"]integerValue];
    notesData.fromUserName=[rs stringForColumn:@"fromUserId"];
    notesData.fromUserId=[rs stringForColumn:@"fromUserId"];
    notesData.typeMessage=[NSString stringWithFormat:@"%d",[rs intForColumn:@"messageType"]];
    notesData.serverTime=[rs stringForColumn:@"receiveTime"];
    notesData.isSend=[rs stringForColumn:@"isSendSucceed"];
    notesData.isTask=[[rs stringForColumn:@"purpose"] intValue];
    return notesData;
}
-(ImageChatData *)getImageChatData:(FMResultSet *)rs{
    ImageChatData *icd=[[ImageChatData alloc] init];
    icd.middleLink=[rs stringForColumn:@"middleLink"];
    icd.originalLink=[rs stringForColumn:@"originalLink"];
    icd.smallLink=[rs stringForColumn:@"smallLink"];
    icd.imageName=[rs stringForColumn:@"imageName"];
    icd.imagePath=[rs stringForColumn:@"imagePath"];
    icd.imagewidth=[rs intForColumn:@"imageWidth"];
    icd.imageheight=[rs intForColumn:@"imageHeight"];
    return icd;
}
-(ChatVoiceData *)getChatVoiceData:(FMResultSet *)rs{
    ChatVoiceData *cvd=[[ChatVoiceData alloc] init];
    cvd.voicePath=[rs stringForColumn:@"voicePath"];
    cvd.voiceUrl=[rs stringForColumn:@"voiceUrl"];
    cvd.voiceLenth=[rs stringForColumn:@"voiceLength"];
    cvd.isRead=[rs intForColumn:@"IsPlay"];
    return cvd;
}
-(ChatVideoModel *)getChatVideoData:(FMResultSet *)rs{
    ChatVideoModel *cvm=[[ChatVideoModel alloc] init];
    cvm.createTime=[rs stringForColumn:@"createTime"];
    cvm.duration=[rs stringForColumn:@"duration"];
    cvm.media_uuid=[rs stringForColumn:@"media_uuid"];
    cvm.original_link=[rs stringForColumn:@"original_link"];
    cvm.title=[rs stringForColumn:@"title"];
    cvm.filesize=[rs stringForColumn:@"filesize"];
    
    return cvm;
}
#pragma mark - 更新图片数据表
-(void)updateImageChatDataWithMessageId:(NSString *)messageId imageChatData:(ImageChatData *)imageChatData{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *middleLink=imageChatData.middleLink;
        NSString *originalLink=imageChatData.originalLink;
        NSString *smallLink=imageChatData.smallLink;
        NSString *imageName=imageChatData.imageName;
        NSString *path=imageChatData.imagePath;
        int width=imageChatData.imagewidth;
        int height=imageChatData.imageheight;
        NSString *sql=[NSString stringWithFormat:@"UPDATE %@ set middleLink = '%@',originalLink='%@',smallLink='%@',imageName='%@',imagePath='%@',imageWidth='%d',imageHeight='%d' where messageId='%@'",chat_message_image_table_name,middleLink?middleLink:@"",originalLink?originalLink:@"",smallLink?smallLink:@"",imageName?imageName:@"",path?path:@"",width?width:120,height?height:90,messageId];
        [db executeUpdate:sql];
        [db close];
    }];
}
-(void)updateVoiceMessageDataWithMessageId:(NSString *)messageId voiceChatData:(ChatVoiceData *)voiceChatData{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *voiceUrl=voiceChatData.voiceUrl;
        NSString *voicePath=voiceChatData.voicePath;
        NSString *voiceLength=voiceChatData.voiceLenth;
        NSString *sqlStr=[NSString stringWithFormat:@"insert into %@(messageId,voiceUrl,voicePath,voiceLength) values(?,?,?,?)",chat_voice_data_table_name];
        BOOL result=[db executeUpdate:sqlStr,messageId,voiceUrl?voiceUrl:@"",voicePath?voicePath:@"",voiceLength?voiceLength:@""];
        if (result) {
            DDLogInfo(@"更新语音表成功");
        }
        [db close];
    }];
}
-(void)updateSendStateWithMessageID:(NSString *)messageId state:(NSString *)state{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        
        NSString *sql=[NSString stringWithFormat:@"UPDATE %@ set isSendSucceed = '%@' where messageId ='%@'",chatTableName,state,messageId];
        [db executeUpdate:sql];
        [db close];
    }];
}

#pragma mark -更新群名
-(void)updateRoomInfoWithRoomJid:(NSString *)roomjid RoomName:(NSString*)roomName
{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        
        NSString *sql=[NSString stringWithFormat:@"UPDATE %@ set roomName = '%@' where roomJid ='%@'",chat_group,roomName,roomjid];
        [db executeUpdate:sql];
        [db close];
    }];

}
#pragma mark - 查询消息列表
-(NSArray *)queryChatListDataWithToUserId{
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        ChatListModel *publicClm=[[ChatListModel alloc] init];
        int index=0;
        BOOL isHavaPublic=NO;
        NSMutableArray *publicArray=[[NSMutableArray alloc] init];
        
        NSString *sql=[NSString stringWithFormat:@"select *from %@ where isDelete=0 order by priority desc,lastTime desc",chat_list];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            ChatListModel *clm=[self getChatListDataCLM:rs];
            NSString *userId=[ConstantObject sharedConstant].userInfo.phone;
            
            NSString *unReadCountStr=[NSString stringWithFormat:@"select *from chat_message_table where isRead = '0' and userid='%@' and touserid ='%@'",userId,clm.toUserId];
            FMResultSet *unReadCount_rs=[db executeQuery:unReadCountStr];
            int unReadCount=0;
            while ([unReadCount_rs next]) {
                unReadCount++;
            }
            
            clm.unReadCount=unReadCount;
            
            NSString *last_message_Str=[NSString stringWithFormat:@"select *from chat_message_table where userid='%@' and touserid ='%@' order by id desc limit 0,1",userId,clm.toUserId];
            FMResultSet *last_message_rs=[db executeQuery:last_message_Str];
            
            BOOL is_exist=NO;
            while ([last_message_rs next]) {
                is_exist=YES;
                clm.lastMessage=[last_message_rs stringForColumn:@"content"];
                clm.lastMessageType=[last_message_rs intForColumn:@"messageType"];
                break;
            }
            
            if (!is_exist) {
                clm.lastMessageType=0;
                
            }
            
            if (!isHavaPublic) {
                index++;
            }
            
            if (clm.chatType==1) {
                //群组
                RoomInfoModel *rim=[self getRoomInfoModelWithDb:db roomJid:clm.toUserId];
                if (!rim) {
                    continue;
                }
                clm.roomInfoModel=rim;
            }else if (clm.chatType==2){
                
                NSString *publicModelSql=[NSString stringWithFormat:@"select *from %@ where pa_uuid='%@'",chat_public,clm.toUserId];
                FMResultSet *public_rs=[db executeQuery:publicModelSql];
                PublicaccountModel *pm;
                while ([public_rs next]) {
                    pm=[self getPublicaccountModelWithRs:public_rs];
                    continue;
                }
                
                clm.publicModel=pm;
                [publicArray addObject:clm];
                if (isHavaPublic) {
                    continue;
                }
                isHavaPublic=YES;
                
            }else if(clm.chatType == 0){
                NSString *from = [last_message_rs stringForColumn:@"fromUserId"];
                EmployeeModel *fromEmp = [SqlAddressData queryMemberInfoWithImacct:from];
                if (fromEmp.imacct == nil) {
                    continue;
                }
                
                NSString *to = [last_message_rs stringForColumn:@"toUserId"];
                EmployeeModel *toEmp = [SqlAddressData queryMemberInfoWithImacct:to];
                if (toEmp.imacct == nil) {
                    continue;
                }
                
            }
            
            [array addObject:clm];
        }
        if (isHavaPublic) {
            ChatListModel *_tempCLM=[array objectAtIndex:index-1];
            _tempCLM.publicModelArray=publicArray;
            [array replaceObjectAtIndex:index-1 withObject:_tempCLM];
        }
        
        [db close];
    }];
    
    return array;
}
-(ChatListModel *)queryOneChatDataWithToUserId:(NSString *)toUserId{
    __block ChatListModel *rsClm=[[ChatListModel alloc] init];
        [self open];
        [dataQueue inDatabase:^(FMDatabase *db) {
            [db open];
            int index=0;
            BOOL isHavaPublic=NO;
            NSMutableArray *publicArray=[[NSMutableArray alloc] init];
            NSString *sql=[NSString stringWithFormat:@"select *from %@ where toUserId='%@' ",chat_list,toUserId];
            FMResultSet *rs=[db executeQuery:sql];
            while ([rs next]) {
                ChatListModel *clm=[self getChatListDataCLM:rs];
                NSString *userId=[ConstantObject sharedConstant].userInfo.phone;
                NSString *unReadCountStr=[NSString stringWithFormat:@"select *from chat_message_table where isRead = '0' and userid='%@' and touserid ='%@'",userId,clm.toUserId];
                FMResultSet *unReadCount_rs=[db executeQuery:unReadCountStr];
                int unReadCount=0;
                while ([unReadCount_rs next]) {
                    unReadCount++;
                }
                clm.unReadCount=unReadCount;
                NSString *last_message_Str=[NSString stringWithFormat:@"select *from chat_message_table where userid='%@' and touserid ='%@' order by id desc limit 0,1",userId,clm.toUserId];
                FMResultSet *last_message_rs=[db executeQuery:last_message_Str];
                BOOL is_exist=NO;
                while ([last_message_rs next]) {
                    is_exist=YES;
                    clm.lastMessage=[last_message_rs stringForColumn:@"content"];
                    clm.lastMessageType=[last_message_rs intForColumn:@"messageType"];
                    break;
                }
                if (!is_exist) {
                    clm.lastMessageType=0;
                    
                }
                if (!isHavaPublic) {
                    index++;
                }
                if (clm.chatType==1) {
                    //群组
                    RoomInfoModel *rim=[self getRoomInfoModelWithDb:db roomJid:clm.toUserId];
                    if (!rim) {
                        continue;
                    }
                    clm.roomInfoModel=rim;
                }else if (clm.chatType==2){
                    
                    NSString *publicModelSql=[NSString stringWithFormat:@"select *from %@ where pa_uuid='%@'",chat_public,clm.toUserId];
                    FMResultSet *public_rs=[db executeQuery:publicModelSql];
                    PublicaccountModel *pm;
                    while ([public_rs next]) {
                        pm=[self getPublicaccountModelWithRs:public_rs];
                        continue;
                    }
                    
                    clm.publicModel=pm;
                    [publicArray addObject:clm];
                    if (isHavaPublic) {
                        continue;
                    }
                    isHavaPublic=YES;
                    
                }else if(clm.chatType == 0){
                    NSString *from = [last_message_rs stringForColumn:@"fromUserId"];
                    EmployeeModel *fromEmp = [SqlAddressData queryMemberInfoWithImacct:from];
                    if (fromEmp.imacct == nil) {
                        continue;
                    }
                    
                    NSString *to = [last_message_rs stringForColumn:@"toUserId"];
                    EmployeeModel *toEmp = [SqlAddressData queryMemberInfoWithImacct:to];
                    if (toEmp.imacct == nil) {
                        continue;
                    }
                }else if (clm.chatType == 4)
                {
                    
                }else if (clm.chatType == 5)
                {
                    
                }
                rsClm=clm;
//                [array addObject:clm];
            }
//            if (isHavaPublic) {
//                ChatListModel *_tempCLM=[array objectAtIndex:index-1];
//                _tempCLM.publicModelArray=publicArray;
//                [array replaceObjectAtIndex:index-1 withObject:_tempCLM];
//            }
            [db close];
        }];
    return rsClm;
}
-(ChatListModel *)getChatListDataCLM:(FMResultSet *)rs{
    ChatListModel *clm=[[ChatListModel alloc] init];
    clm.toUserId=[rs stringForColumn:@"toUserId"];
    clm.fromUserId=[rs stringForColumn:@"fromUserId"];
    clm.chatType=[rs intForColumn:@"chatType"];
    clm.lastTime=[rs stringForColumn:@"lastTime"];
    clm.lastSender=[rs stringForColumn:@"lastSender"];
    clm.lastMessageType=[rs intForColumn:@"lastMessageType"];
    clm.toUserIdAvatar=[rs stringForColumn:@"toUserIdAvatar"];
    clm.isDelete=[rs intForColumn:@"isDelete"];
    clm.priority=[rs intForColumn:@"priority"];
    clm.chatName=[rs stringForColumn:@"chatName"];
//    clm.lastMessage=[rs stringForColumn:@"lastMessage"];
    clm.memberInfo=[SqlAddressData queryMemberInfoWithImacct:clm.toUserId];
    return clm;
}
#pragma mark - 根据toUserid删除回话
-(void)deleteChatListWithToUserId:(NSString *)toUserId{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"delete from %@ where toUserId='%@'",chat_list,toUserId];
        BOOL result=[db executeUpdate:sql];
        if (result) {
            DDLogInfo(@"删除消息列表成功");
        }
        [db close];
    }];
}
#pragma mark - 置顶相关
#pragma mark - 根据toUserId更改优先级
-(void)updateChatListPriorityWithWithToUserId:(NSString *)toUserId priority:(int)priority{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"update %@ set priority='%d' where toUserId='%@'",chat_list,priority,toUserId];
        [db executeUpdate:sql];
        [db close];
    }];
}
-(int)queryPriorityWithToUserId:(NSString *)toUserId{
    [self open];
    
    __block int priority=0;
    
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"select *from %@ where toUserId='%@'",chat_list,toUserId];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            priority=[rs intForColumn:@"priority"];
        }
        [db close];
    }];
    return priority;
}
#pragma mark - 修改已读未读状态
-(void)updateReadStateWithToUserId:(NSString *)toUserId{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        
        NSString *userId=[ConstantObject sharedConstant].userInfo.phone;
        
//        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        
        NSString *sql=[NSString stringWithFormat:@"update %@ set isRead='1' where userid='%@' and toUserId='%@'",chatTableName,userId,toUserId];
        [db executeUpdate:sql];
        [db close];
    }];
}
-(void)updateReadStateWithToMessageId:(NSString *)messageId{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        
        NSString *sql=[NSString stringWithFormat:@"update %@ set isRead='1' where messageId='%@'",chatTableName,messageId];
        [db executeUpdate:sql];
        [db close];
    }];
}

#pragma mark - 修改是否转为任务
-(void)updateTaskStateWithToMessageId:(NSString *)messageId {
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql = [NSString stringWithFormat:@"update %@ set purpose='2' where messageId='%@'",chatTableName,messageId];
        [db executeUpdate:sql];
        [db close];
    }];
}
/**
 *  删除消息
 *
 *  @param messageId
 */
-(void)deleteChatDataWithMessageId:(NSArray *)messageIds{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        for (NSString *messageId in messageIds) {
            NSString *sql=[NSString stringWithFormat:@"delete from %@ where messageId='%@'",chatTableName,messageId];
            NSString *sql_image=[NSString stringWithFormat:@"delete from %@ where messageId='%@'",chat_message_image_table_name,messageId];
            NSString *sql_voice=[NSString stringWithFormat:@"delete from %@ where messageId='%@'",chat_voice_data_table_name,messageId];
            [db executeUpdate:sql];

            [db executeUpdate:sql_image];

            [db executeUpdate:sql_voice];

        }
        
        [db close];
    }];

}

-(NSArray *)queryChatAllImageDataWithToUserId:(NSString *)toUserId{
    [self open];
    NSMutableArray *array=[[NSMutableArray alloc] init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        NSString *sql=[NSString stringWithFormat:@"select *from chat_message_table where userid='%@' and toUserId='%@' and messageType='1' order by id desc",[ConstantObject sharedConstant].userInfo.phone,toUserId];
        FMResultSet *rs=[db executeQuery:sql];
        
        while ([rs next]) {
            NotesData *nd=[self getNotesData:rs];
            if ([nd.typeMessage isEqualToString:@"1"]) {
                //图片
                NSString *selectImageDataSql=[NSString stringWithFormat:@"select *from chat_message_image where messageId = '%@'",nd.contentsUuid];
                FMResultSet *imageData_rs=[db executeQuery:selectImageDataSql];
                while ([imageData_rs next]) {
                    /**
                     *  理论,这里只有一个结果
                     */
                    nd.imageCHatData=[self getImageChatData:imageData_rs];
                }
                [imageData_rs close];
                [array addObject:nd];
            }
        }
        
        [db close];
    }];
    
    return array;
}
-(NSString *)queryTempstrWithtoUserId:(NSString *)toUserId{
    [self open];
    __block NSString *rstr;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"select * from %@ where toUserId='%@'",chat_tempstr,toUserId];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            rstr=[rs stringForColumn:@"tempstr"];
            break;
        }
        [db close];
    }];
    return rstr;
}
#pragma mark  - 群组相关
-(void)insertDataToGroupTabel:(RoomInfoModel *)roomModel{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if ([roomModel.roomMemberListStr isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
            NSString *querySql=[NSString stringWithFormat:@"select * from %@ where roomJid='%@'",chat_group,roomModel.roomJid];
            if (![[db executeQuery:querySql] next]) {
                return;
            }
        }
        NSString *deleteSql=[NSString stringWithFormat:@"delete from %@ where roomJid='%@'",chat_group,roomModel.roomJid];
        BOOL result=[db executeUpdate:deleteSql];
        NSString *sql=[NSString stringWithFormat:@"insert into %@ ('userId','roomName','roomJid','roomMemberList') VALUES('%@','%@','%@','%@')",chat_group,[ConstantObject sharedConstant].userInfo.phone,roomModel.roomName,roomModel.roomJid,roomModel.roomMemberListStr];
        result=[db executeUpdate:sql];
//        if (result) {
//            DDLogInfo(@"插入群组成功");
//        }
        [db close];
    }];
}

-(RoomInfoModel *)getRoomInfoModelWithDb:(FMDatabase *)db roomJid:(NSString *)roomJid{
    NSString *queryGroupDataSql=[NSString stringWithFormat:@"select *from %@ where roomJid = '%@'",chat_group,roomJid];
    FMResultSet *rs=[db executeQuery:queryGroupDataSql];
    RoomInfoModel *rim=[[RoomInfoModel alloc] init];
    
    BOOL isExist=NO;
    
    while ([rs next]) {
        isExist=YES;
        rim.roomMemberListStr=[rs stringForColumn:@"roomMemberList"];
        rim.roomName=[rs stringForColumn:@"roomName"];
        rim.roomJid=roomJid;
        int mmcount=0;
        NSArray *memberList=[rim.roomMemberListStr componentsSeparatedByString:@";"];
        NSMutableArray *tempArray=[[NSMutableArray alloc] init];
        for (NSString *str in memberList) {
            if (str.length>0) {
                EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:str];
                if (em.imacct == nil) {
                    continue;
                }
                [tempArray addObject:em];
                mmcount++;
                if(mmcount>=3){
                    break;
                }
            }
        }
        rim.roomMemberList=tempArray;
        break;
        
    }
    if (!isExist) {
        //        rim.roomJid=roomJid;
        //        [[QFXmppManager shareInstance] getRoomInfo:roomJid];
        rim=nil;
    }
    return rim;
}

-(RoomInfoModel *)getRoomInfoModelWithroomJid:(NSString *)roomJid{
    [self open];
    RoomInfoModel *rim=[[RoomInfoModel alloc] init];
    __block BOOL isExist=NO;

    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        NSString *queryGroupDataSql=[NSString stringWithFormat:@"select *from %@ where roomJid = '%@'",chat_group,roomJid];
        FMResultSet *rs=[db executeQuery:queryGroupDataSql];

        while ([rs next]) {
            isExist=YES;
            rim.roomMemberListStr=[rs stringForColumn:@"roomMemberList"];
            rim.roomName=[rs stringForColumn:@"roomName"];
            rim.roomJid=roomJid;
            
            NSArray *memberList=[rim.roomMemberListStr componentsSeparatedByString:@";"];
            NSMutableArray *tempArray=[[NSMutableArray alloc] init];
            for (NSString *str in memberList) {
                if (str.length>0) {
                    EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:str];
                    if (em.imacct == nil) {
                        continue;
                    }
                    [tempArray addObject:em];
                }
            }
            rim.roomMemberList=tempArray;
            break;
        }

        [db close];
    }];
    if (!isExist) {
        
        rim=nil;
    }
    return rim;
}
-(NSArray *)queryAllRoomData{
    
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        select *from %@ order by id desc
//        order by id desc
        NSString *sql=[NSString stringWithFormat:@"select *from %@ ",chat_group];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            RoomInfoModel *rim=[[RoomInfoModel alloc] init];
            rim.roomName=[rs stringForColumn:@"roomName"];
            rim.roomJid=[rs stringForColumn:@"roomJid"];
            rim.roomMemberListStr=[rs stringForColumn:@"roomMemberList"];
            [array addObject:rim];
        }
        [db close];
    }];
    return array;
}
#pragma mark - 删除toUserId对应的消息
-(void)deleteChatDataWithToUserId:(NSString *)toUserId{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"delete from %@ where toUserId='%@'",chatTableName,toUserId];
        BOOL result=[db executeUpdate:sql];
        if (result) {
            DDLogInfo(@"删除消息成功");
        }
        
        [db close];
    }];
}
-(void)deleteTempstr:(NSString *)toUserId{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *deleteSql=[NSString stringWithFormat:@"delete from %@ where toUserId = '%@'",chat_tempstr,toUserId];
        BOOL result=[db executeUpdate:deleteSql];
        if (result) {
            DDLogInfo(@"草稿删除成功");
        }else{
            DDLogInfo(@"草稿删除失败");
        }
        [db close];
    }];
}
#pragma mark -  删除群组
-(void)deleteRoomWithRoomJid:(NSString *)roomJid{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"delete from %@ where roomJid='%@'",chat_group,roomJid];
        BOOL result=[db executeUpdate:sql];
        if (result) {
//            DDLogInfo(@"删除群组成功");
        }
        NSString *sql_chat=[NSString stringWithFormat:@"delete from %@ where toUserId ='%@'",chatTableName,roomJid];
        result=[db executeUpdate:sql_chat];
        if (result) {
//            DDLogInfo(@"删除room消息成功");
        }
        NSString *sql_list=[NSString stringWithFormat:@"delete from %@ where toUserId='%@'",chat_list,roomJid];
        result=[db executeUpdate:sql_list];
        if (result) {
//            DDLogInfo(@"删除room列表成功");
        }
        
        [db close];
    }];
}
-(BOOL)isExistGroupWithName:(NSString *)name{
    __block BOOL result=NO;
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=[NSString stringWithFormat:@"select *from %@ where roomName='%@'",chat_group,name];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            
            result=YES;
            continue;
        }
        [rs close];
        [db close];
    }];
    
    return result;
}

#pragma mark - 公告相关
/**
 *  插入数据
 *
 *  @param bm
 */
- (void)insertDataToBulletinData:(BulletinModel *)bm
{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db tableExists:chat_bulletin]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"title text",
                               @"bulletinID text",
                               @"msg_digest text",
                               @"picUrl text",
                               @"fileType text",
                               @"createTime text",
                               @"receiveTime text"];
            BOOL result=[self createTable:chat_bulletin columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"公告创建表成功");
            }
        }
        
        [db beginDeferredTransaction];
        NSString *insertSql=[NSString stringWithFormat:@"insert into %@ ('title','bulletinID','msg_digest','picUrl','fileType','createTime','receiveTime') values ('%@','%@','%@','%@','%@','%@','%@')",chat_bulletin,bm.title,bm.bulletinID,bm.msg_digest,bm.picUrl,bm.fileType,bm.createTime,bm.receiveTime];
        BOOL reslut=[db executeUpdate:insertSql];
        if (reslut) {
            DDLogInfo(@"公告插入成功");
        }
    
        [db commit];
        
        [db close];
    }];
    
}

- (void)insertDataToBulletinDataArray:(NSArray *)bms
{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
         if (![db tableExists:chat_bulletin]) {
             NSArray *columes=@[@"id integer primary key autoincrement",
                                @"title text",
                                @"bulletinID text",
                                @"msg_digest text",
                                @"picUrl text",
                                @"fileType text",
                                @"createTime text",
                                @"receiveTime text"];
             BOOL result=[self createTable:chat_bulletin columns:columes indexes:nil whithDb:db];
             if (result) {
                 DDLogInfo(@"公告创建表成功");
             }
         }

        [db beginDeferredTransaction];
 
        for (BulletinModel *bm in bms) {
            NSString *insertSql=[NSString stringWithFormat:@"insert into %@ ('title','bulletinID','msg_digest','picUrl','fileType','createTime','receiveTime') values ('%@','%@','%@','%@','%@','%@','%@')",chat_bulletin,bm.title,bm.bulletinID,bm.msg_digest,bm.picUrl,bm.fileType,bm.createTime,bm.receiveTime];
            BOOL reslut=[db executeUpdate:insertSql];
            if (reslut) {
                DDLogInfo(@"公告插入成功");
            }
        }
        
        [db commit];
        
        [db close];
    }];

}
-(NSArray *)queryBulletinDataWithBuID{
    [self open];
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db tableExists:chat_bulletin]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"title text",
                               @"bulletinID text",
                               @"msg_digest text",
                               @"picUrl text",
                               @"fileType text",
                               @"createTime text",
                               @"receiveTime text"];
            BOOL result=[self createTable:chat_bulletin columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"公告创建表成功");
            }
        }

        NSString *sql=@"select *from chat_bulletin";
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            BulletinModel *bm=[self getBulletinModelWithRs:rs];
            [array addObject:bm];
        }
        [db close];
    }];
    return array;
    
}

-(BulletinModel *)queryBulletinDataWithBuID:(NSString *)bmID{
    [self open];
    __block BulletinModel * bm=[[BulletinModel alloc]init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db tableExists:chat_bulletin]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"title text",
                               @"bulletinID text",
                               @"msg_digest text",
                               @"picUrl text",
                               @"fileType text",
                               @"createTime text",
                               @"receiveTime text"];
            BOOL result=[self createTable:chat_bulletin columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"公告创建表成功");
            }
        }
        
        NSString *sql=[NSString stringWithFormat:@"select *from chat_bulletin where bulletinID=%@",bmID];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            bm=[self getBulletinModelWithRs:rs];
        }
        [db close];
    }];
    return bm;
    
}


-(NSArray *)queryBulletinDataWithlocation:(int)location length:(int)length{
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        NSString *selectStr=[NSString stringWithFormat:@"select *from chat_bulletin order by id desc limit %d,%d",location,length];
        DDLogInfo(@"%@",selectStr);
        FMResultSet *rs=[db executeQuery:selectStr];
        while ([rs next]) {
            BulletinModel *bm=[self getBulletinModelWithRs:rs];
            
            [array addObject:bm];
        }
        
        [db close];
    }];
    
    return array;
}

-(BulletinModel *)getBulletinModelWithRs:(FMResultSet *)rs{
    BulletinModel *bm=[[BulletinModel alloc] init];
    bm.title=[rs stringForColumn:@"title"];
    bm.bulletinID=[rs stringForColumn:@"bulletinID"];
    bm.msg_digest=[rs stringForColumn:@"msg_digest"];
    bm.picUrl=[rs stringForColumn:@"picUrl"];
    bm.fileType=[rs stringForColumn:@"fileType"];
    bm.createTime=[rs stringForColumn:@"createTime"];
    bm.receiveTime=[rs stringForColumn:@"receiveTime"];

    return bm;
}

#pragma mark - 和企录团队相关
/**
 *  插入数据
 *
 *  @param tm
 */
- (void)insertDataToTeamMessageModelData:(TeamMessageModel *)tm
{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db tableExists:chat_teammessage]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"notify_title text",
                               @"notify_msgid text",
                               @"notify_summary text",
                               @"notify_picUrl text",
                               @"notify_fileType integer",
                               @"createTime text",
                               @"receiveTime text",
                               @"notify_link text",
                               @"with_pic text",
                               @"height_pic text"];
            BOOL result=[self createTable:chat_teammessage columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"和企录团队创建表成功");
            }
        }
        
        [db beginDeferredTransaction];
        NSString *insertSql=[NSString stringWithFormat:@"insert into %@ ('notify_title','notify_msgid','notify_summary','notify_picUrl','notify_fileType','createTime','receiveTime','notify_link', 'with_pic', 'height_pic') values ('%@','%@','%@','%@','%d','%@','%@','%@','%@','%@')",chat_teammessage,tm.notify_title,tm.notify_msgid,tm.notify_summary,tm.notify_picUrl,tm.notify_fileType,tm.createTime,tm.receiveTime,tm.notify_link,tm.with_pic,tm.height_pic];
        BOOL reslut=[db executeUpdate:insertSql];
        if (reslut) {
            DDLogInfo(@"和企录团队插入成功");
        }
        
        [db commit];
        
        [db close];
    }];
    
}

-(NSArray *)queryTeamMessageModelDataWithID{
    [self open];
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db tableExists:chat_teammessage]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"notify_title text",
                               @"notify_msgid text",
                               @"notify_summary text",
                               @"notify_picUrl text",
                               @"notify_fileType integer",
                               @"createTime text",
                               @"receiveTime text",
                               @"notify_link text",
                               @"with_pic text",
                               @"height_pic text"];
            BOOL result=[self createTable:chat_teammessage columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"和企录团队创建表成功");
            }
        }
        
        NSString *sql=@"select *from chat_teammessage";
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            TeamMessageModel *tm=[self getTeamMessageModelWithRs:rs];
            [array addObject:tm];
        }
        [db close];
    }];
    return array;
    
}

-(TeamMessageModel *)queryTeamMessageModelDataWithID:(NSString *)tmID{
    [self open];
    __block TeamMessageModel * tm=[[TeamMessageModel alloc]init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db tableExists:chat_teammessage]) {
            NSArray *columes=@[@"id integer primary key autoincrement",
                               @"notify_title text",
                               @"notify_msgid text",
                               @"notify_summary text",
                               @"notify_picUrl text",
                               @"notify_fileType integer",
                               @"createTime text",
                               @"receiveTime text",
                               @"notify_link text",
                               @"with_pic text",
                               @"height_pic text"];
            BOOL result=[self createTable:chat_teammessage columns:columes indexes:nil whithDb:db];
            if (result) {
                DDLogInfo(@"和企录团队创建表成功");
            }
        }
        
        NSString *sql=[NSString stringWithFormat:@"select *from chat_teammessage where notify_msgid=%@",tmID];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            tm=[self getTeamMessageModelWithRs:rs];
        }
        [db close];
    }];
    return tm;
    
}


-(NSArray *)queryTeamMessageModelDataWithlocation:(int)location length:(int)length{
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        //        NSString *myImacct=[ConstantObject sharedConstant].userInfo.imacct;
        NSString *selectStr=[NSString stringWithFormat:@"select *from chat_teammessage order by id desc limit %d,%d",location,length];
        DDLogInfo(@"%@",selectStr);
        FMResultSet *rs=[db executeQuery:selectStr];
        while ([rs next]) {
            TeamMessageModel *tm=[self getTeamMessageModelWithRs:rs];
            
            [array addObject:tm];
        }
        
        [db close];
    }];
    
    return array;
}

-(TeamMessageModel *)getTeamMessageModelWithRs:(FMResultSet *)rs{
    TeamMessageModel *tm=[[TeamMessageModel alloc] init];
    tm.notify_title=[rs stringForColumn:@"notify_title"];
    tm.notify_msgid=[rs stringForColumn:@"notify_msgid"];
    tm.notify_summary=[rs stringForColumn:@"notify_summary"];
    tm.notify_picUrl=[rs stringForColumn:@"notify_picUrl"];
    tm.notify_fileType=[[rs stringForColumn:@"notify_fileType"]integerValue];
    tm.createTime=[rs stringForColumn:@"createTime"];
    tm.receiveTime=[rs stringForColumn:@"receiveTime"];
    tm.notify_link=[rs stringForColumn:@"notify_link"];
    tm.with_pic=[rs stringForColumn:@"with_pic"];
    tm.height_pic=[rs stringForColumn:@"height_pic"];
    return tm;
}


#pragma mark - 公众号相关
/**
 *  插入数据
 *
 *  @param pm
 */
-(void)insertDataToPublicData:(NSArray *)pms{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        @[@"id integer primary key autoincrement",
//          @"pa_uuid text",
//          @"name text",
//          @"logo text",
//          @"sip_uri text"];
//        insert into %@ ('userId','roomName','roomJid','roomMemberList') VALUES('%@','%@','%@','%@'
        [db beginDeferredTransaction];
        
        for (PublicaccountModel *pm in pms) {
            NSString *deleteSql=[NSString stringWithFormat:@"delete from %@ where pa_uuid = '%@'",chat_public,pm.pa_uuid];
            BOOL reslut=[db executeUpdate:deleteSql];
            if (reslut) {
                DDLogInfo(@"删除成功");
            }
            NSString *insertSql=[NSString stringWithFormat:@"insert into %@ ('pa_uuid','name','logo','sip_uri') values ('%@','%@','%@','%@')",chat_public,pm.pa_uuid,pm.name,pm.logo,pm.sip_uri];
            reslut=[db executeUpdate:insertSql];
            if (reslut) {
                DDLogInfo(@"公众号插入成功");
            }
        }
        
        [db commit];
        
        [db close];
    }];
    
}
-(NSArray *)queryPublicDataWithPa_uuid{
    [self open];
    __block NSMutableArray *array=[[NSMutableArray alloc] init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *sql=@"select *from chat_public";
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            PublicaccountModel *pm=[self getPublicaccountModelWithRs:rs];
            [array addObject:pm];
        }
        [db close];
    }];
    return array;
    
}
-(PublicaccountModel *)getPublicaccountModelWithRs:(FMResultSet *)rs{
    PublicaccountModel *pm=[[PublicaccountModel alloc] init];
    pm.pa_uuid=[rs stringForColumn:@"pa_uuid"];
    pm.name=[rs stringForColumn:@"name"];
    pm.logo=[rs stringForColumn:@"logo"];
    pm.sip_uri=[rs stringForColumn:@"sip_uri"];
    return pm;
}
-(void)deletePublicDataWithPa_uuid:(NSString *)pa_uuid{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *deleteSql=[NSString stringWithFormat:@"delete from %@ where pa_uuid = '%@'",chat_public,pa_uuid];
        BOOL result=[db executeUpdate:deleteSql];
        if (result) {
            DDLogInfo(@"删除成功");
        }
        
        [db close];
    }];
}
-(ChatVoiceData *)queryVoice_tableByMessageid:(NSString*)messageId
{
    [self open];
    __block ChatVoiceData * voiceData=[[ChatVoiceData alloc]init];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
//        NSString *sql=@"select IsPlay from chat_message_voice_table where messageId='%@'";
        NSString * sql=[NSString stringWithFormat:@"select * from chat_message_voice_table where messageId='%@'",messageId];
        FMResultSet *rs=[db executeQuery:sql];
        while ([rs next]) {
            voiceData=(ChatVoiceData * )[self getChatVoiceData:rs];
        }
        [db close];
    }];
    return voiceData;
}

-(void)updateVoice_tableByMessageId:(NSString*)messageId
{
    [self open];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString * sql=[NSString stringWithFormat:@"update chat_message_voice_table set IsPlay =1 where messageId='%@'",messageId];
        [db executeUpdate:sql];
        [db close];
    }];
}
#pragma mark - 任务流
-(void)createTaskTable:(FMDatabase *)db
{
        if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS tasktable (user_id text, complete_state text,complete_time text,create_time text,creator_uid text,dead_line text,dispatched_uid text,mail_id text,org_id text,task_id text,task_logo text,task_name text,update_time text,task_member text,task_type text,description text, origin_type integer not null default 0)"])
        {
            DDLogInfo(@"create table %@ failed!",TASK_TABLE);
        }
}

-(void)createTaskStatusTable:(FMDatabase *)db
{
        if (![db executeUpdateWithFormat:@"CREATE TABLE IF NOT EXISTS taskstatustable (user_id text,audio_duration text,content text ,audio_name text,audio_url text,local_file_url text,create_time text,feature text,status_id text,packetid text,task_id text,task_name text,from_user_id text,original_pic text,original_pic_width_height text,thumbnail_pic VARCHAR(30),successed text,readed text,org_id text,listened text)"])
        {
            DDLogInfo(@"create table %@ failed!",TASK_STATUS_TABLE);
        }
}

#pragma mark - 任务流 插入

-(BOOL)insertTaskRecord:(NSDictionary *)dict andTableName:(NSString *)tableName
{
    [self open];
    __block BOOL result = YES;
    NSMutableString *query = [NSMutableString stringWithFormat:@"INSERT INTO %@",tableName];
    NSMutableString *keys = [NSMutableString stringWithFormat:@" ( "];
    NSMutableString *values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
    for (NSString *key in dict)
    {
        [keys appendString:[NSString stringWithFormat:@"%@,",key]];
        [values appendString:@"?,"];
        [arguments addObject:[dict objectForKey:key]];
    }
    
    [keys appendString:@"user_id"];
    [values appendString:@"?,"];
    [arguments addObject:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]];
    
    [keys appendString:@") "];
    [values appendString:@") "];
    [query appendFormat:@" %@ VALUES %@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db executeUpdate:query withArgumentsInArray:arguments])
        {
            result = NO;
        }
        [db close];
    }];
    return result;
}

-(BOOL)insertStatusRecord:(NSDictionary *)dict andTableName:(NSString *)tableName
{
    [self open];
    __block BOOL result = YES;
    NSMutableString *query = [NSMutableString stringWithFormat:@"INSERT INTO %@",tableName];
    NSMutableString *keys = [NSMutableString stringWithFormat:@" ( "];
    NSMutableString *values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
    for (NSString *key in dict)
    {
        [keys appendString:[NSString stringWithFormat:@"%@,",key]];
        [values appendString:@"?,"];
        [arguments addObject:[dict objectForKey:key]];
    }
    
    [keys appendString:@") "];
    [values appendString:@") "];
    [query appendFormat:@" %@ VALUES %@",
     [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
     [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        if (![db executeUpdate:query withArgumentsInArray:arguments])
        {
            result = NO;
        }
        [db close];
    }];
    return result;
}

#pragma mark - 任务流 查询

-(NSArray *)getColumnsFromTable:(NSString *)table_name
{
    [self open];
    __block NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *querySql = [NSString stringWithFormat:@"select column_name,data_type from information_schema.columns where table_name = N\'%@\'",table_name];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *resultSet = [db executeQuery:querySql];
        while ([resultSet next])
        {
            [msgArray addObject:[resultSet resultDictionary]];
        }
        [db close];
    }];
    return msgArray;
}

-(NSArray *)findSetWithTableName:(NSString *)tableName
                     orderKey:(NSString *)orderKey
                    orderFunc:(int)orderFunc
{
    return [self findSetWithDictionary:@{} andTableName:tableName groupBy:@"" orderBy:orderKey orderFunc:orderFunc];
}

-(NSArray *)findSetWithKey:(NSString *)key
                  andValue:(NSString *)value
              andTableName:(NSString *)tableName
{
    if (!value || !key || !tableName) {
        return nil;
    }
    return [self findSetWithDictionary:@{key:value} andTableName:tableName orderBy:nil orderFunc:2];
}

-(NSArray *)findSetWithKey:(NSString *)key
                  andValue:(NSString *)value
              andTableName:(NSString *)tableName
                  orderKey:(NSString *)orderKey
{
    if (key && value)
    {
        return [self findSetWithDictionary:@{key:value} andTableName:tableName orderBy:orderKey orderFunc:0];
    }
    return nil;
}
-(NSArray *)findSetWithKey:(NSString *)key
                  andValue:(NSString *)value
              andTableName:(NSString *)tableName
                  orderKey:(NSString *)orderKey
                 orderFunc:(int)orderFunc

{
    if (key && value)
    {
        return [self findSetWithDictionary:@{key:value} andTableName:tableName orderBy:orderKey orderFunc:orderFunc];
    }
    return nil;
}

-(NSArray *)findSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                          orderBy:(NSString *)orderKey
{
    return [self findSetWithDictionary:dict andTableName:tableName orderBy:orderKey orderFunc:1];
}

-(NSArray *)findSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                          orderBy:(NSString *)orderKey
                        orderFunc:(int)orderFunc
{
    return [self findSetWithDictionary:dict andTableName:tableName groupBy:@"" orderBy:orderKey orderFunc:orderFunc];
}

-(NSArray *)findSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                          groupBy:(NSString *)groupByKey
                          orderBy:(NSString *)orderKey
                        orderFunc:(int)orderFunc
{
    [self open];
    __block NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    if([dict count] > 0)
    {
        [query insertString:@" WHERE" atIndex:[query length]];
        for (NSString *key in dict)
        {
            [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
        }
        [query deleteCharactersInRange:NSMakeRange([query length]-3, 3)];
    }
    
    if ([groupByKey length] > 0)
    {
        [query appendFormat:@"GROUP BY %@ ",groupByKey];
    }
    
    if (orderKey && orderFunc == 0)
    {
        [query appendString:[NSString stringWithFormat:@"ORDER BY %@",orderKey]];
    }
    else if(orderKey && orderFunc == 1)
    {
        [query appendString:[NSString stringWithFormat:@"ORDER BY %@ DESC",orderKey]];
    }
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *resultSet = [db executeQuery:query];
        while ([resultSet next])
        {
            [msgArray addObject:[resultSet resultDictionary]];
        }
        [db close];
    }];
    
    return msgArray;
}

-(NSArray *)findTasksFromTaskStatusTable
{
    [self open];
    __block NSMutableArray *taskArray = [[NSMutableArray alloc] initWithCapacity:0];
     NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT DISTINCT task_id FROM %@ ",TASK_STATUS_TABLE];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *resultSet = [db executeQuery:query];
        while ([resultSet next])
        {
            [taskArray addObject:[resultSet resultDictionary]];
        }
        [db close];
    }];
    return taskArray;
}

-(NSDictionary *)findLatestStatusWithTaskId:(NSString *)task_id
{
    NSArray *statusArray = [self findSetWithKey:@"task_id" andValue:task_id andTableName:TASK_STATUS_TABLE orderKey:@"create_time"];
    return [statusArray lastObject];
}

-(NSDictionary *)findFirstStatusWithTaskId:(NSString *)task_id
{
    NSArray *statusArray = [self findSetWithKey:@"task_id" andValue:task_id andTableName:TASK_STATUS_TABLE orderKey:@"create_time"];
    return [statusArray firstObject];
}

-(NSArray *)findStatusArrayWithoutTipsWihtTaskId:(NSString *)taskId
                                         success:(NSString *)isSuccess
{
    [self open];
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    // and (feature = '1' OR feature = '2' OR feature = '3' OR feature = '7')
    NSArray *statusArray = [self findSetWithDictionary:@{@"task_id":taskId} andTableName:TASK_STATUS_TABLE orderBy:@"create_time"];
    for (int i=0; i<[statusArray count]; i++)
    {
        NSDictionary *statusDict = [statusArray objectAtIndex:i];
        if ([[statusDict objectForKey:@"feature"] intValue] == 1 ||
            [[statusDict objectForKey:@"feature"] intValue] == 2 ||
            [[statusDict objectForKey:@"feature"] intValue] == 3 ||
            [[statusDict objectForKey:@"feature"] intValue] == 7)
        {
            if (isSuccess)
            {
                if([[statusDict objectForKey:@"successed"] isEqualToString:isSuccess])
                {
                    [msgArray addObject:statusDict];
                }
                continue;
            }
            else
            {
                [msgArray addObject:statusDict];
            }
        }
    }
    
    return msgArray;
}

-(NSArray *)findStatusArrayWithoutTipsWihtTaskId:(NSString *)taskId
                                            from:(int)start
                                           count:(int)countPerPage
{
    [self open];
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    // and (feature = '1' OR feature = '2' OR feature = '3' OR feature = '7')
    NSArray *statusArray = [self findTaskStatusWithTaskId:taskId from:start count:countPerPage];
    for (int i=0; i<[statusArray count]; i++)
    {
        NSDictionary *statusDict = [statusArray objectAtIndex:i];
        if ([[statusDict objectForKey:@"feature"] intValue] == 1 ||
            [[statusDict objectForKey:@"feature"] intValue] == 2 ||
            [[statusDict objectForKey:@"feature"] intValue] == 3 ||
            [[statusDict objectForKey:@"feature"] intValue] == 7)
        {
            [msgArray addObject:statusDict];
        }
    }
    
    return msgArray;
}


#pragma mark - 分页查询任务流状态

-(NSArray *)findTaskStatusWithTaskId:(NSString *)task_id
                                from:(int)start
                               count:(int)countPerPage
{
    [self open];
    __block NSMutableArray *statusArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *queryStr = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE task_id = '%@' ORDER BY create_time desc LIMIT %d,%d",TASK_STATUS_TABLE,task_id,start,countPerPage];
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        FMResultSet *resultSet = [db executeQuery:queryStr];
        while ([resultSet next])
        {
            [statusArray addObject:[resultSet resultDictionary]];
        }
        [db close];
    }];
    return statusArray;
}

#pragma mark - 任务流 删除

-(BOOL)deleteTableDataFromTable:(NSString *)tableName
                            key:(NSString *)key
                          value:(NSString *)value
{
    [self open];
    __block BOOL result = YES;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *deleteSql;
        if (key && value)
        {
            deleteSql = [NSString stringWithFormat:@"delete from %@ where %@='%@'",tableName,key,value];
        }
        else
        {
            deleteSql = [NSString stringWithFormat:@"delete from %@",tableName];
        }
        
        if (![db executeUpdate:deleteSql])
        {
            DDLogInfo(@"delete table data failed");
            result = NO;
        }
        [db close];
    }];
    return result;
}

-(BOOL)deleteRecordWithDict:(NSDictionary *)dict andTableName:(NSString *)tableName
{
    [self open];
    __block BOOL result = YES;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSMutableString *query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"DELETE FROM %@ WHERE",tableName]];
        for (NSString *key in dict)
        {
            [query insertString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]] atIndex:[query length]];
        }
        NSString *queryStr = [query substringToIndex:[query length]-3];
        if (![db executeUpdate:queryStr])
        {
            result =  NO;
        }
        [db close];
    }];
    return  result;
}

#pragma mark - 任务流 更新

-(BOOL)updeteKey:(NSString *)key
         toValue:(NSString *)value
    withParaDict:(NSDictionary *)dict
    andTableName:(NSString *)tableName
{
    [self open];
    __block BOOL result = YES;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSMutableString *query = [NSMutableString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE",tableName,key,value];
        for (NSString *key in dict)
        {
            [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
        }
        NSString *queryStr = [query substringToIndex:[query length]-3];
        if (![db executeUpdate:queryStr])
        {
            result = NO;
        }
        [db close];
    }];
    return result;
}

#pragma mark - 添加表字段

-(BOOL)alterTableAdd:(NSString *)column
        defaultValue:(NSString *)defaultValue
        andTableName:(NSString *)tableName
{
    [self open];
    __block BOOL result = YES;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        NSString *altertableStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD '%@' text default '%@'",tableName,column,defaultValue];
        if (![db executeUpdate:altertableStr])
        {
            result = NO;
        }
        [db close];
    }];
    return result;
}


-(BOOL)columnExist:(NSString *)columnName
             table:(NSString *)tableName
{
    [self open];
    __block BOOL result = YES;
    [dataQueue inDatabase:^(FMDatabase *db) {
        [db open];
        result = [db columnExists:columnName inTableWithName:tableName];
        [db close];
    }];
    return result;
}

#pragma mark - 执行事物
- (BOOL)executeEventWithDatabase:(FMDatabase *)db
                            mode:(ExecuteMode)mode
                     executeBody:(BOOL(^)(FMDatabase *dataBase, NSDictionary *param))executor
                           param:(NSDictionary *)param
{
    BOOL result = NO;
    if (!db || !executor) {
        result = NO;
        goto FINISH;
    }
    [db open];
    
    switch (mode) {
        case ExecuteMode_ReadOnly:
            if (![db beginDeferredTransaction]) {
                result = NO;
                goto FINISH;
            }
            break;
            
        case ExecuteMode_Write:
        case ExecuteMode_ReadWrite:
            if (![db beginTransaction]) {
                result = NO;
                goto FINISH;
            }
            break;
            
        default:
            break;
    }
    
    BOOL isRollBack = NO;
    @try {
        result = executor(db, param);
    }
    @catch (NSException *exception) {
        isRollBack = YES;
        [db rollback];
    }
    @finally {
        if (!isRollBack) {
            if (![db commit]) {
                result = NO;
                goto FINISH;
            }
        }
    }
    
    
FINISH:
    [db close];
    return result;
}

#pragma mark - 离线消息 批量插入数据

- (BOOL)insertDataListToMessageData:(NSArray *)messageList
{
    __block BOOL result = NO;
    
    for (MessageModel *mm in messageList) {
        @autoreleasepool {
            __weak SqliteDataDao *weakSelf = self;
            [dataQueue inDatabase:^(FMDatabase *db) {
                SqliteDataDao *danceSelf = weakSelf;
                if (!danceSelf) {
                    result = NO;
                    return;
                }
                
                result = [danceSelf executeEventWithDatabase:db mode:ExecuteMode_Write executeBody:^BOOL(FMDatabase *dataBase, NSDictionary *param) {
                    
                    BOOL innerResult = NO;
                    MessageModel *message   = [param objectForKey:@"message"];
                    NSString *userId        = [ConstantObject sharedConstant].userInfo.phone;
                    NSString *receiveTime   = message.receivedTime;
                    NSString *messageID     = message.messageID;
                    NSString *toUserId      = message.to;
                    NSString *fromUserId    = message.from;
                    NSString *chatType      = [NSString stringWithFormat:@"%d", message.chatType];
                    NSString *content       = message.msg;
                    NSString *thread        = message.thread;
                    NSString *messageType   = [NSString stringWithFormat:@"%d", message.fileType];
                    
                    NSString *slecetStr = [NSString stringWithFormat:@"select *from chat_message_table where messageId='%@'", messageID];
                    FMResultSet *rs     = [dataBase executeQuery:slecetStr];
                    
                    BOOL isExist = NO;
                    while ([rs next]) {
                        isExist = YES;
                        innerResult = NO;
                        DDLogInfo(@"消息已经存在,跳过");
                        break;
                    }
                    NSString *isRead = @"0";
                    if (message.fileType == 7) {
                        //            isRead=@"1";
                    }
                    NSString *toUserId_str = message.to;
                    if (!isExist) {
                        NSString *sqlStr = @"insert into chat_message_table ('userId','receiveTime','messageId','toUserId','fromUserId','chatType','content','thread','messageType','isRead','isSendSucceed') VALUES(?,?,?,?,?,?,?,?,?,?,'0')";
                        [dataBase executeUpdate:sqlStr, userId, receiveTime, messageID, toUserId, fromUserId, chatType, content ? content : @"", thread ? thread : @"", messageType, isRead];
                        
                        if ([messageType isEqualToString:@"1"]) {
                            //图片
                            [danceSelf insertImageChatData:message withDb:dataBase];
                        }
                        else if ([messageType isEqualToString:@"2"]){
                            //声音
                            [danceSelf insertVoiceChatData:message withDb:dataBase];
                        }
                        else if ([messageType isEqualToString:@"4"]){
                            //视频
                            [danceSelf insertVideoChatData:message withDb:dataBase];
                        }
                        
                        //开始插入聊天回话表
                        //先查询是否存在
                        
                        if (message.chatType == 1 && message.fileType !=7 ) {
                            NSString *selectGroupChatListSql    = [NSString stringWithFormat:@"select *from chat_group_table where roomJid='%@'",message.to];
                            FMResultSet *chat_group_list_rs     = [dataBase executeQuery:selectGroupChatListSql];
                            if (![chat_group_list_rs next]) {
                                innerResult = NO;
                                return innerResult;
                            }
                        }
                    }
                    if ([message.to isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
                        //如果是发给我的消息,把from和to调换
                        toUserId_str = message.from;
                    }
                    NSString *selectChatListSql = [NSString stringWithFormat:@"select *from %@ where toUserId='%@'",chat_list,toUserId_str];
                    FMResultSet *chat_list_rs   = [dataBase executeQuery:selectChatListSql];
                    BOOL chat_list_isExist = NO;
                    while ([chat_list_rs next]) {
                        chat_list_isExist = YES;
                    }
                    
                    if (chat_list_isExist) {
                        //            UPDATE %@ set isSendSucceed = '%@' where messageId ='%@'",chatTableName,state,messageId
                        NSString *updateChatList = [NSString stringWithFormat:@"update %@ set isDelete = '0',lastSender='%@',lastTime='%@',lastMessageType ='%@',lastMessage ='%@',lastMessageId='%@' where toUserId='%@'", chat_list, fromUserId, receiveTime, messageType, content, messageID, toUserId_str];
                        BOOL result1 = [dataBase executeUpdate:updateChatList];
                        if (result1) {
                            DDLogInfo(@"更新聊天回话表成功");
                        }
                        innerResult = result1 && !isExist ;
                    }
                    else{
                        NSString *insertChatList = [NSString stringWithFormat:@"insert into %@(toUserId,fromUserId,chatType,lastMessage,lastTime,lastSender,toUserIdAvatar,isDelete,priority,chatName,lastMessageType,lastMessageId) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')", chat_list, toUserId_str, toUserId_str, chatType, content, receiveTime, fromUserId,@"",@"0", @"0", @"", messageType, messageID];
                        BOOL result1 = [dataBase executeUpdate:insertChatList];
                        if (result1) {
                            DDLogInfo(@"插入聊天回话表成功");
                        }
                        innerResult = result1;
                    }
                    
                    return innerResult;
                    
                } param:@{@"message":mm}];
                
            }];
        }
    }
    
FINISH:
    return result;
}

@end
