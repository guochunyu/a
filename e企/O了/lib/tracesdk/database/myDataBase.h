//
//  myDataBase.h
//  MobileSDK
//
//  Created by Dora.Lin on 14-1-24.
//  Copyright (c) 2014年 LiPo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface myDataBase : NSObject
{
    NSMutableArray * _dataArray;
}
+(myDataBase *)sharedMyDataBase;
//创建数据库
-(void)createDataBase;
//创建表
-(void)createTable;
//插入数据
-(void)insertData:(NSString *)body groupID:(NSInteger)Id;
//读取数据
-(NSDictionary *)fillData;
//删除旧数据
-(void)removeDataWithId:(int)groupId;
////标记未成功发送的数据为1
//-(void)changeSaveMark:(int)num groupid:(int)Id;
//标记每行升序
-(NSInteger)getGroupID;
//降序
-(NSInteger)getID;
@property (nonatomic,retain)NSMutableArray * dataArray;
@end
