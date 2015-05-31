//
//  TeamMessageModel.m
//  e企
//
//  Created by xuxue on 15/4/20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TeamMessageModel.h"

@implementation TeamMessageModel

- (id)initWithMessage:(DDXMLElement *)content_message
{
    if(self = [super init])
    {
        NSString *createTime = [[content_message elementForName:@"create_time"]stringValue];
        NSString *msg_Content = [[content_message elementForName:@"msg_content"]stringValue];
        self.notify_msgid = [[content_message elementForName:@"msgid"]stringValue];
        NSDictionary *contDic = [msg_Content objectFromJSONString];
        self.notify_title = contDic[@"notify_title"];
        self.notify_summary = contDic[@"notify_summary"];
        self.notify_picUrl = contDic[@"notify_imgs"];
        self.notify_link = contDic[@"notify_link"];
        self.notify_fileType = [contDic[@"notify_type"]integerValue];
        self.createTime = createTime;
        NSDate *date=[NSDate date];
        NSString *nowTimeStr=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        self.receiveTime=nowTimeStr;
        NSString *image_measure = contDic[@"imgs_measure"];
        NSArray *imageArray = [image_measure componentsSeparatedByString:@"|"];
        NSArray *picArray = [[imageArray objectAtIndex:0] componentsSeparatedByString:@"_"];
        self.with_pic = picArray[1];
        self.height_pic = picArray[2];
    }
    return self;
}


@end
