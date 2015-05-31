//
//  ChatListModle.h
//  O了
//
//  Created by 化召鹏 on 14-3-26.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatListModle : NSObject
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *taskId;
@property(nonatomic,copy)NSString *persons;
@property(nonatomic,copy)NSString *groupName;
@property(nonatomic,copy)NSString *fromUserId;
@property(nonatomic,copy)NSString *fromUserName;
@property(nonatomic,copy)NSString *lastContent;
@property(nonatomic,copy)NSString *lastTime;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *typeMessage;
@property(nonatomic,copy)NSString *chengyuenName;
@property(nonatomic,assign)NSInteger serviceMark;
@property(nonatomic,assign)NSInteger imsType;
@property(nonatomic,copy)NSString *serviceNews;
@end
