//
//  HuiyiData.m
//  e企
//
//  Created by a on 15/5/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "HuiyiData.h"

@implementation HuiyiData
-(instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self=[super init]) {
        [self setDateWithDictionary:dict];
    }
    return self;
}

-(HuiyiData*)setDateWithDictionary:(NSDictionary*)dict
{
    self.address=dict[@"address"];
    self.conf_id=[NSString stringWithFormat:@"%@",dict[@"conf_id"]];
    self.conf_name=dict[@"conf_name"];
    //if ([dict[@"conf_time"] integerValue]) {
    self.conf_time=[NSString stringWithFormat:@"%@",dict[@"conf_time"]];
    //}
    self.confirmed_members=dict[@"confirmed_members"];
    self.content=dict[@"content"];
    self.create_time=[NSString stringWithFormat:@"%@",dict[@"create_time"]];
    self.creator_gid=[NSString stringWithFormat:@"%@",dict[@"creator_gid"]];
    self.creator_uid=[NSString stringWithFormat:@"%@",dict[@"creator_uid"]];
    self.noconfirm_members=dict[@"noconfirm_members"];
    self.notify_type=[NSString stringWithFormat:@"%@",dict[@"notify_type"]];
    return self;
}

@end
