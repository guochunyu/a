//
//  EmployeeModel.m
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "EmployeeModel.h"

@implementation EmployeeModel
@synthesize phone=_phone,position=_position,avatarimgurl=_avatarimgurl,personID=_personID,actionType=_actionType,updateTime=_updateTime,orgId=_orgId,
email=_email,imacct=_imacct,name=_name,shotNum=_shotNum,freqFlag=_freqFlag,type=_type,pinyin_name=_pinyin_name,first_name=_first_name,nameSuoXie=_nameSuoXie;
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self=[super init];
    if (self) {
        self.title = [dictionary objectForKey:@"title"];
        self.phone=[dictionary objectForKey:@"phone"];
        self.position=[dictionary objectForKey:@"position"];
        self.avatarimgurl=[dictionary objectForKey:@"avatarimgurl"];
        self.first_name= [dictionary objectForKey:@"first_name"];
        self.actionType=[dictionary objectForKey:@"actionType"];
        self.updateTime=[dictionary objectForKey:@"updateTime"];
        self.orgId=[dictionary objectForKey:@"orgId"];
        self.email=[dictionary objectForKey:@"email"];
        self.name=[dictionary objectForKey:@"name"];
        self.shotNum=[dictionary objectForKey:@"shotNum"];
        self.imacct=[dictionary objectForKey:@"imacct"];
        
    }
    return self;
}
+ (id)jsonWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc]initWithDictionary:dictionary];
}

@end
