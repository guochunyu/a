//
//  BulletinModel.m
//  e企
//
//  Created by xuxue on 15/3/28.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "BulletinModel.h"
#import "DDXML.h"

@implementation BulletinModel

- (id)initWithMessage:(DDXMLElement *)content_message
{
    if(self = [super init])
    {
        NSString *createTime = [[content_message elementForName:@"create_time"]stringValue];
        NSString *msg_digest = [[content_message elementForName:@"msg_digest"]stringValue];
        NSString *msg_Content = [[content_message elementForName:@"msg_content"]stringValue];
        NSDictionary *contDic = [msg_Content objectFromJSONString];
        self.title = contDic[@"title"];
        self.bulletinID = contDic[@"id"];
        self.msg_digest = msg_digest;
        self.picUrl = contDic[@"picUrl"];
        self.createTime = createTime;
        NSDate *date=[NSDate date];
        NSString *nowTimeStr=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        self.receiveTime=nowTimeStr;
        self.fileType = @"0";
    }
    return self;
}

@end
