//
//  ChatListModel.h
//  e企
//
//  Created by roya-7 on 14/11/10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmployeeModel.h"
#import "RoomInfoModel.h"
#import "PublicaccountModel.h"

@interface ChatListModel : NSObject
@property (copy,nonatomic) NSString       *toUserId;///<to
@property (copy,nonatomic) NSString       *fromUserId;///<from

@property (copy,nonatomic) NSString       *lastMessage;///<最后一条消息
@property (copy,nonatomic) NSString       *lastTime;///<最后一条消息时间
@property (copy,nonatomic) NSString       *lastSender;///<最后一条消息的发送人

@property (copy,nonatomic) NSString       *toUserIdAvatar;///<头像
@property(nonatomic,copy)NSString *chatName;

@property (assign,nonatomic) NSInteger lastMessageType;///<消息类型,0为文本,1为图片,2声音,5草稿，
                                                                  //8视频通话，9音频通话频
@property (assign,nonatomic) NSInteger       chatType;///<会话类型
@property(assign,nonatomic)NSInteger isDelete;///<列表是否删除
@property(assign,nonatomic)NSInteger priority;///<优先级,用户置顶排序.1为置顶
@property(nonatomic,strong)EmployeeModel *memberInfo;
@property(nonatomic,assign)NSInteger unReadCount;///<未读消息数量
@property(nonatomic,copy)NSString *unReadPublic;///<第一个公众号的未读消息数量

@property(nonatomic,strong)RoomInfoModel *roomInfoModel;///<房间对象

#pragma mark - 公众号相关
@property(nonatomic,strong)PublicaccountModel *publicModel;///<公众号
@property(nonatomic,strong)NSArray *publicModelArray;///<存放公众号数组


@end
