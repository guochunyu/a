//
//  ContactsModel.m
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ContactsModel.h"
#import "EmployeeModel.h"

@implementation ContactsModel
@synthesize contactsID=_contactsID,personList=_personList,
parentId=_parentId,name=_name,actionType=_actionType,personArray=_personArray,
updateTime=_updateTime;
- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self=[super init];
    if (self) {
        self.contactsID=[[dictionary objectForKey:@"id"]intValue];
        self.parentId=[[dictionary objectForKey:@"parentId"]intValue];
        self.name=[dictionary objectForKey:@"name"];
        self.actionType=[[dictionary objectForKey:@"actionType"]intValue];
        self.updateTime=[[dictionary objectForKey:@"updateTime"]intValue];
        self.personArray=[dictionary objectForKey:@"personList"];
        for (NSDictionary * dic in self.personArray) {
            self.personList=[EmployeeModel jsonWithDictionary:dic];
        }
    }
    return self;
}
+ (id)jsonWithDictionary:(NSDictionary *)dictionary
{
    return [[self alloc]initWithDictionary:dictionary];
}
@end
