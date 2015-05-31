//
//  HuiyiData.h
//  e企
//
//  Created by a on 15/5/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HuiyiData : NSObject

@property(nonatomic,copy) NSString *address;//会议地点
@property(nonatomic,copy) NSString *conf_id;
@property(nonatomic,copy) NSString *conf_name;
@property(nonatomic,copy) NSString *conf_time;
@property(nonatomic,copy) NSString *confirmed;//是否确认@“0”:未确认，@“1”：已确认

@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *create_time;
@property(nonatomic,copy) NSString *creator_gid;
@property(nonatomic,copy) NSString *creator_uid;
@property(nonatomic,copy) NSString *notify_type;//通知类型 0:网络通知，1：短信通知
@property(nonatomic,copy) NSArray *confirmed_members;//已经确认
@property(nonatomic,copy) NSArray *noconfirm_members;//未确认

//@property(nonatomic,assign)BOOL isRead;//是否已读

-(instancetype)initWithDictionary:(NSDictionary*)dict;
-(HuiyiData*)setDateWithDictionary:(NSDictionary*)dict;
@end
