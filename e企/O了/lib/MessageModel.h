//
//  MessageModel.h
//  ChatDemo
//

//

#import <Foundation/Foundation.h>
#import "ImageChatData.h"
#import "ChatVoiceData.h"
#import "ChatVideoModel.h"
#import "TeamMessageModel.h"

#define PropertyString(s) @property (nonatomic, copy) NSString *s
@interface MessageModel : NSObject {
    NSString *_msg;
    NSString *_from;
    NSString *_to;
    NSString *_receivedTime;
}
- (UIImage *) image;
PropertyString(msg);
PropertyString(from);
PropertyString(to);
PropertyString(receivedTime);

@property(nonatomic,assign)NSInteger chatType;///<聊天类型,0为单聊,1为群聊,3为群发消息 ,2为公众号, 4为公告, 5为和企录团队
@property(nonatomic,assign)NSInteger fileType;///<文件类型,0为普通文本,1为图片,2为声音,7为群组创建信息,8为单点登录消息(收到要下线),3为服务号消息,4为视频消息, 5为草稿, 6为图文消息  9为视频通话类型，10为音频通话
@property(nonatomic,assign)BOOL isOffline;  //离线消息标识

@property(nonatomic,copy)NSString *messageID;///<消息id
@property(nonatomic,copy)NSString *thread;///<消息提thread
@property(nonatomic,copy)NSString *roomInfo;///<房间的jid

@property(nonatomic,copy)NSString *nameListStr;///<如果聊天类型是群发消息,名字

@property (nonatomic, assign) NSInteger purpose;    // 用途（1预留，转任务2，默认0）.

@property(nonatomic,strong)ImageChatData *imageChatData;///<图片对象
@property(nonatomic,strong)ChatVoiceData *chatVoiceData;///<语音对象
@property(nonatomic,strong)ChatVideoModel *chatVideoModel;///<视频对象
@property(nonatomic,strong)TeamMessageModel *teamMsgModel; ///和企录团队消息对象

+ (id)messageModelWithXMPPMessage:(XMPPMessage *)message;

@end
