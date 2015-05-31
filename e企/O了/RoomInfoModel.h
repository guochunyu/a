//
//  RoomInfoModel.h
//  e企
//
//  Created by roya-7 on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomInfoModel : NSObject
@property(nonatomic,copy)NSString *roomJid;///<房间jid
@property(nonatomic,copy)NSString *roomName;///<房间名字
@property(nonatomic,copy)NSArray *roomMemberList;///<房间成员列表
@property(nonatomic,copy)NSString *roomMemberListStr;///<房间成员列表,以;分割
@end
