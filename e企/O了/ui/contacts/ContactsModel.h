//
//  ContactsModel.h
//  e企
//
//  Created by royaMAC on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmployeeModel.h"

@interface ContactsModel : NSObject
@property (nonatomic,assign)int             contactsID;
@property (nonatomic,strong)EmployeeModel * personList;
@property (nonatomic,assign)int             parentId;
@property (nonatomic,strong)NSString      * name;
@property (nonatomic,assign)int             actionType;
@property (nonatomic,assign)int             updateTime;
@property (nonatomic,strong)NSMutableArray  * personArray;
- (id)initWithDictionary:(NSDictionary *)dictionary;
+ (id)jsonWithDictionary:(NSDictionary *)dictionary;

@end
