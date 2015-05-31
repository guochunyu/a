//
//  NotesData.h
//  O了
//
//  Created by 化召鹏 on 14-2-9.
//  Copyright (c) 2014年 QYB. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ImageChatData.h"
#import "ChatVoiceData.h"
#import "PublicDataParse.h"
#import "ChatVideoModel.h"
#import "BulletinModel.h"
@interface NotesData : NSObject
@property (copy,nonatomic) NSString       *sendContents;///<聊天内容
@property (copy,nonatomic) NSString       *contentsUuid;///<聊天内容id
@property (copy,nonatomic) NSString       *fromUserId;///<消息会话的参与人
@property (copy,nonatomic) NSString       *fromUserName;///<消息会话显示的名称
@property (copy,nonatomic) NSString       *serverTime;///<接收时间
@property (copy,nonatomic) NSString       *taskId;
@property (assign,nonatomic) NSInteger    chatType;///聊天类型
@property (copy,nonatomic) NSString       *typeMessage;///<文件类型,0为普通文本,1为图片,2为声音,7为群组创建信息,8为单点登录消息(收到要下线),3为服务号消息,4为视频消息, 5为草稿, 6为图文消息  9为视频通话类型，10为音频通话》
@property (copy,nonatomic) NSString       *serviceNews;///<服务号消息头内容 serviceNews
@property(copy,nonatomic)NSString *isSend;///<是否发送成功，0为正在发送，1为成功,2为失败

@property (strong,nonatomic) NSMutableArray *imageUrl;///<头像地址

@property (assign,nonatomic) NSInteger      unReadCount;
@property (assign,nonatomic) NSInteger      serviceMark;///<服务号标记，1为服务号消息
@property (assign,nonatomic) NSInteger      priority;///<优先级
@property (assign,nonatomic) NSInteger      imsType;///<服务好消息标识，1 为URL链接，在中间显示 imsType
@property (assign,nonatomic) NSInteger      isTask;///是否为任务消息 2 为任务消息  0为默认

@property(nonatomic,strong)ImageChatData *imageCHatData;///<图片信息
@property(nonatomic,strong)ChatVoiceData *chatVoiceData;///<语音信息
@property(nonatomic,strong)PublicDataParse *publicData;///<公众号消息
@property(nonatomic,strong)ChatVideoModel *chatVideoModel;///<视频消息
@property(nonatomic,strong)BulletinModel *BulletinModel;///<公告消息
@property(nonatomic,strong)TeamMessageModel *teamMsgModel;///和企录团队消息
//@property int Bulletinindex;

/**
 *  获取普通文本消息模型
 *
 *
 *  @return
 */
-(id)initWihtMessageUuid:(NSString *)uuid content:(NSString *)content fromUserName:(NSString *)fromUserName fromUserId:(NSString *)fromUserId typeMessage:(NSString *)typeMessage serverTime:(NSString *)serverTime;
/**
 *  图片信息
 *
 *  @return
 */
-(id)initWihtMessageUuid:(NSString *)uuid content:(NSString *)content fromUserName:(NSString *)fromUserName fromUserId:(NSString *)fromUserId typeMessage:(NSString *)typeMessage serverTime:(NSString *)serverTime middleLink:(NSString *)middleLink originalLink:(NSString *)originalLink smallLink:(NSString *)smallLink imageName:(NSString *)imageName imagePath:(NSString *)imagePath imageWidth:(int)imageWidth imageHeight:(int)imageHeight;
/**
 *  声音信息
 *
 *
 *  @return
 */
-(id)initWihtMessageUuid:(NSString *)uuid content:(NSString *)content fromUserName:(NSString *)fromUserName fromUserId:(NSString *)fromUserId typeMessage:(NSString *)typeMessage serverTime:(NSString *)serverTime voicePath:(NSString *)voicePath voiceUrl:(NSString *)voiceUrl voiceLength:(NSString *)voiceLength voiceName:(NSString *)voiceName;
@end
