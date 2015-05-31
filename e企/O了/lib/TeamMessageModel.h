//
//  TeamMessageModel.h
//  e企
//
//  Created by xuxue on 15/4/20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamMessageModel : NSObject

@property (nonatomic,copy)NSString *notify_title;            //标题
@property (nonatomic,copy)NSString *notify_msgid;            //消息ID
@property (nonatomic,copy)NSString *notify_summary;       //摘要
@property (nonatomic,copy)NSString *notify_picUrl;           //图片地址
@property (nonatomic,assign)NSInteger notify_fileType;         //消息内容类型
@property (nonatomic,copy)NSString *createTime;       //公告创建时间
@property (nonatomic,copy)NSString *receiveTime;      //公告接收时间
@property (nonatomic,copy)NSString *notify_link;       //链接
@property (nonatomic,copy)NSString *with_pic;         //图片宽度
@property (nonatomic,copy)NSString *height_pic;       //图片高度

- (id)initWithMessage:(DDXMLElement *)content_message;

@end
