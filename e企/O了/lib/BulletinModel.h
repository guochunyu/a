//
//  BulletinModel.h
//  e企
//
//  Created by xuxue on 15/3/28.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BulletinModel : NSObject

@property (nonatomic,copy)NSString *title;            //标题
@property (nonatomic,copy)NSString *bulletinID;       //公告消息ID，用于拉全文
@property (nonatomic,copy)NSString *msg_digest;       //摘要
@property (nonatomic,copy)NSString *picUrl;           //图片地址
@property (nonatomic,copy)NSString *fileType;         //消息内容类型
@property (nonatomic,copy)NSString *createTime;       //公告创建时间
@property (nonatomic,copy)NSString *receiveTime;      //公告接收时间
@property (nonatomic,copy)NSString *with_pic;         //图片宽度
@property (nonatomic,copy)NSString *height_pic;       //图片高度

- (id)initWithMessage:(DDXMLElement *)content_message;

@end
