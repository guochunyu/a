//
//  EmployeeModel.h
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmployeeModel : NSObject
@property (nonatomic,strong)NSString * phone;///<手机号
@property (nonatomic,strong)NSString * position;
@property (nonatomic,strong)NSString * avatarimgurl;///<头像url
@property (nonatomic,strong)NSString * personID;
@property (nonatomic,strong)NSString * actionType;
@property (nonatomic,strong)NSString * updateTime;
@property (nonatomic,strong)NSString * orgId;
@property (nonatomic,strong)NSString * title;
@property (nonatomic,strong)NSString * tele;
@property (nonatomic,strong)NSString * email;///<邮箱
@property (nonatomic,strong)NSString * imacct;///<imacct,openfire帐号
@property (nonatomic,strong)NSString * name;///<名字
@property (nonatomic,strong)NSString * shotNum;///<短号
@property (nonatomic,strong)NSString * pinyin_name;///<汉语拼音
@property (nonatomic,strong)NSString * first_name;///<拼音首字母

@property (nonatomic,strong)NSString * orgName;///<部门名字
@property (nonatomic,strong)NSString * nameSuoXie;///<名字首字母缩写

@property (nonatomic,assign)int  cycle_count;//模型的次数

@property (nonatomic,assign)NSInteger  leaderType;///<领导可见性 1代表设置了不可见///常用联系人
@property (assign, nonatomic)NSInteger freqFlag;///<标记是否是常用联系人 1代表是0代表否
@property (assign, nonatomic)NSInteger type;///<标记是否是群组 1代表联系人2代表部门
@property (nonatomic,strong)NSString * comman_orgName;///<获取部门

- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (id)jsonWithDictionary:(NSDictionary *)dictionary;

@end
