//
//  SqliteDataDao.h
//  e企
//
//  Created by roya-7 on 14/11/4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

#import "NotesData.h"
#import "ChatListModel.h"
#import "SqlAddressData.h"

#import "RoomInfoModel.h"
#import "PublicaccountModel.h"
#import "BulletinModel.h"

#pragma mark - 任务流

#define TASK_TABLE  @"tasktable"
#define TASK_STATUS_TABLE  @"taskstatustable"

typedef NS_ENUM(NSUInteger, ExecuteMode) {
    ExecuteMode_ReadOnly = 0,
    ExecuteMode_Write,
    ExecuteMode_ReadWrite
};

@interface SqliteDataDao : NSObject
+(SqliteDataDao *)sharedInstanse;///<初始化

#pragma mark - 创建数据库
-(void)creatTabel;

-(BOOL)insertDataToMessageData:(MessageModel *)mm;
/**
 *  查询toUserId对应的聊天信息
 *
 *  @param toUserId 接受人,
 *
 *  @return
 */
-(NSArray *)queryChatDataWithToUserId:(NSString *)toUserId;
/**
 *  查询toUserId对应的区间信息
 *
 *  @param toUserId 接受人,
 *  @param location 起始下标
 *  @param length 区间长度
 *  @return
 */
-(NSArray *)queryChatDataWithToUserId:(NSString *)toUserId location:(int)location length:(int)length;
/**
 *  根据messageID查询消息
 *  @param messageId 消息id
 *
 */
-(NotesData *)queryChatMessageWithMessageID:(NSString *)messageId;

/**
 *  更改发送状态
 *
 *  @param messageId 消息id
 *  @param state     0,接受的,1,发送成功,2发送失败，3发送中
 */
-(void)updateSendStateWithMessageID:(NSString *)messageId state:(NSString *)state;

/**
 *  根据消息id,更新图片信息
 *
 *  @param messageId
 */
-(void)updateImageChatDataWithMessageId:(NSString *)messageId imageChatData:(ImageChatData *)imageChatData;
/**
 *  更新语音信息表
 *
 *  @param messageId
 */
-(void)updateVoiceMessageDataWithMessageId:(NSString *)messageId voiceChatData:(ChatVoiceData *)voiceChatData;

/**
 *  更新群名称
 *
 *  @param roomjid   roomName
 */
-(void)updateRoomInfoWithRoomJid:(NSString *)roomjid RoomName:(NSString*)roomName;
/**
 * 查询消息列表
 *
 *  @return
 */
-(NSArray *)queryChatListDataWithToUserId;
/**
 * 根据touserid查询单条消息
 * @return 单个消息
 */
-(ChatListModel *)queryOneChatDataWithToUserId:(NSString *)toUserId;
/**
 *  根据toUserid删除回话
 *
 *  @param toUserId
 */
-(void)deleteChatListWithToUserId:(NSString *)toUserId;
/**
 *  根据toUserId改变置顶状态
 *
 *  @param toUserId
 */
-(void)updateChatListPriorityWithWithToUserId:(NSString *)toUserId priority:(int)priority;
/**
 *  根据toUserId获取置顶状态
 *
 *  @param toUserId
 */
-(int)queryPriorityWithToUserId:(NSString *)toUserId;
/**
 *  修改已读未读状态
 *
 *  @param toUserId
 */

-(void)updateReadStateWithToUserId:(NSString *)toUserId;

/**
 *  修改已读未读状态
 *
 *  @param
 */
-(void)updateReadStateWithToMessageId:(NSString *)messageId;

#pragma mark - 修改是否转为任务
-(void)updateTaskStateWithToMessageId:(NSString *)messageId;
/**
 *  删除消息
 *
 *  @param messageId
 */
-(void)deleteChatDataWithMessageId:(NSArray *)messageIds;
/**
 *  根据toUserId查询当前聊天中所有的图片
 *
 *  @param toUserId
 *
 *  @return
 */
-(NSArray *)queryChatAllImageDataWithToUserId:(NSString *)toUserId;
/**
 *  插入群组信息
 *
 *  @param roomModel
 */
-(void)insertDataToGroupTabel:(RoomInfoModel *)roomModel;

/**
 *  根据条件查询房间
 */
-(RoomInfoModel *)getRoomInfoModelWithroomJid:(NSString *)roomJid;
/**
 *  查询所有房间
 */
-(NSArray *)queryAllRoomData;
/**
 *  删除toUserId对应的消息
 *
 *  @param toUserId
 */
-(void)deleteChatDataWithToUserId:(NSString *)toUserId;

/**
 *  根据名字查看是否有重名的,如果有重名的不允许以这个名字命名创建房间
 *
 *  @param name 房间的名字
 *
 *  @return BOOL值,yes为存在一样的名字,NO为不存在
 */
-(BOOL)isExistGroupWithName:(NSString *)name;

/**
 *  删除群组
 *
 *  @param roomJid
 */
-(void)deleteRoomWithRoomJid:(NSString *)roomJid;

#pragma mark - 公告相关
/**
 *  插入数据
 *
 *  @param bm
 */
- (void)insertDataToBulletinData:(BulletinModel *)bm;
/**
 *  插入数据
 *
 *  @param bms
 */
- (void)insertDataToBulletinDataArray:(NSArray *)bms;

/**
 *  查询数据
 *
 *  @param bms
 */
-(NSArray *)queryBulletinDataWithBuID;
/**
 *  插入数据
 *
 *  @param bm
 */
-(BulletinModel *)queryBulletinDataWithBuID:(NSString *)bmID;
/**
 *  插入数据
 *
 *  @param bms
 */
-(NSArray *)queryBulletinDataWithlocation:(int)location length:(int)length;

#pragma mark - 和企录团队相关
/**
 *  插入数据
 *
 *  @param tm
 */
- (void)insertDataToTeamMessageModelData:(TeamMessageModel *)tm;
/**
 *  插入数据
 *
 *  @param tms
 */
- (void)insertDataToTeamMessageModelDataArray:(NSArray *)tms;

/**
 *  查询数据
 *
 *  @param tms
 */
-(NSArray *)queryTeamMessageModelDataWithID;
/**
 *  插入数据
 *
 *  @param tm
 */
-(TeamMessageModel *)queryTeamMessageModelDataWithID:(NSString *)tmID;
/**
 *  插入数据
 *
 *  @param tms
 */
-(NSArray *)queryTeamMessageModelDataWithlocation:(int)location length:(int)length;

#pragma mark - 公众号相关
/**
 *  插入数据
 *
 *  @param pm 
 */
-(void)insertDataToPublicData:(NSArray *)pms;

/**
 *  离线消息
 *
 *  @param MessageList
 *
 *  @return
 */
- (BOOL)insertDataListToMessageData:(NSArray *)messageList;

/**
 *  获取公众号
 *
 *  @param pa_uuid
 *
 *  @return
 */
-(NSArray *)queryPublicDataWithPa_uuid;
/**
 *  删除服务号
 *
 *  @param pm
 */
-(void)deletePublicDataWithPa_uuid:(NSString *)pa_uuid;
/**
 *   查询声音是否未读
 *
 *
 *
 */
-(ChatVoiceData *)queryVoice_tableByMessageid:(NSString*)messageId;
/**
 *   修改声音是否未读状态
 *
 *
 *
 */
-(void)updateVoice_tableByMessageId:(NSString*)messageId;
/**
 *  置空
 */
-(void)releaseData;
/**
 *  插入会话草稿
 */
-(BOOL)insertTempstr:(NSString *)toUserId tempstr:(NSString *)str;
/**
 *  删除会话草稿
 */
-(void)deleteTempstr:(NSString *)toUserId;
/**
 *  字段查询
 */
-(BOOL)isExitSomeColumn;

-(NSString *)queryTempstrWithtoUserId:(NSString *)toUserId;

#pragma mark - 任务流

-(BOOL)insertTaskRecord:(NSDictionary *)dict andTableName:(NSString *)tableName;
-(BOOL)insertStatusRecord:(NSDictionary *)dict andTableName:(NSString *)tableName;

#pragma mark - 任务流 查询

-(NSArray *)getColumnsFromTable:(NSString *)table_name;

-(NSArray *)findSetWithTableName:(NSString *)tableName
                        orderKey:(NSString *)orderKey
                       orderFunc:(int)orderFunc;

-(NSArray *)findSetWithKey:(NSString *)key
                  andValue:(NSString *)value
              andTableName:(NSString *)tableName;

-(NSArray *)findSetWithKey:(NSString *)key
                  andValue:(NSString *)value
              andTableName:(NSString *)tableName
                  orderKey:(NSString *)orderKey;

-(NSArray *)findSetWithKey:(NSString *)key
                  andValue:(NSString *)value
              andTableName:(NSString *)tableName
                  orderKey:(NSString *)orderKey
                 orderFunc:(int)orderFunc;

-(NSArray *)findTasksFromTaskStatusTable;

-(NSArray *)findSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                          orderBy:(NSString *)orderKey;

-(NSArray *)findSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                          orderBy:(NSString *)orderKey
                        orderFunc:(int)orderFunc;

-(NSArray *)findSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                          groupBy:(NSString *)groupByKey
                          orderBy:(NSString *)orderKey
                        orderFunc:(int)orderFunc;

-(NSDictionary *)findLatestStatusWithTaskId:(NSString *)task_id;

-(NSDictionary *)findFirstStatusWithTaskId:(NSString *)task_id;

-(NSArray *)findStatusArrayWithoutTipsWihtTaskId:(NSString *)taskId
                                         success:(NSString *)isSuccess;

-(NSArray *)findStatusArrayWithoutTipsWihtTaskId:(NSString *)taskId
                                            from:(int)start
                                           count:(int)countPerPage;

#pragma mark - 分页查询任务流状态

-(NSArray *)findTaskStatusWithTaskId:(NSString *)task_id
                                from:(int)start
                               count:(int)countPerPage;
#pragma mark - 任务流 删除

-(BOOL)deleteTableDataFromTable:(NSString *)tableName
                            key:(NSString *)key
                          value:(NSString *)value;
-(BOOL)deleteRecordWithDict:(NSDictionary *)dict andTableName:(NSString *)tableName;

-(BOOL)updeteKey:(NSString *)key
         toValue:(NSString *)value
    withParaDict:(NSDictionary *)dict
    andTableName:(NSString *)tableName;

-(BOOL)alterTableAdd:(NSString *)column
        defaultValue:(NSString *)defaultValue
        andTableName:(NSString *)tableName;

-(BOOL)columnExist:(NSString *)columnName
             table:(NSString *)tableName;

@end
