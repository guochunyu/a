//
//  GroupChatInfo.h
//  O了
//
//  Created by roya on 14-2-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupChatInfo : NSObject

@property (nonatomic,strong) NSString *taskID;
@property (nonatomic,strong) NSString *name;
@property (strong, nonatomic) NSArray *allMember;
@property (assign,nonatomic) NSInteger priority;

@property(nonatomic,copy)NSString *taskType;///<群组类型

@end
