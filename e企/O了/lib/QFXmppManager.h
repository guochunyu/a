//
//  QFXmppManager.h
//  ChatDemo
//

//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "UserModel.h"
#import "MessageModel.h"
#import "XMPPRoom.h"


static NSString *const key_messageText = @"messageText";///<文本

static NSString *const key_messageImage_middle_link = @"key_messageImage_middle_link";///<缩略图,
static NSString *const key_messageImage_original_link = @"key_messageImage_original_link";///<原图片
static NSString *const key_messageImage_image_name =@"key_messageImage_image_name";///<图片名字
static NSString *const key_messageImage_small_link=@"key_messageImage_small_link";///<小图
static NSString *const key_messageImage_fileLength=@"key_messageImage_fileLength";///<文件长度
static NSString *const key_messageImage_image_width=@"key_messageImage_image_width";///图片宽
static NSString *const key_messageImage_image_height=@"key_messageImage_image_height";///图片高
static NSString *const key_messageVoice_url = @"messageVoice_url";///<声音url
static NSString *const key_messageVoice_path = @"messageVoice_url";///<声音url
static NSString *const key_messageVoice_length = @"messageVoice_length";///<声音长度
static NSString *const key_messageVoice_name = @"messageVoice_name";///声音名字

static NSString *const key_public_pa_uuid =@"key_public_pa_uuid";///<公众号上行的pa_uuid
static NSString *const key_public_creat_time=@"key_public_creat_time";///<公众号创建的时间
static NSString *const key_public_sip_uri=@"key_public_sip_uri";///<公众号上行的jid

#define creadGroupMessage @"建群消息"
#define inviteGroupMessage @"邀请消息"

extern NSArray *faceNameArray;
extern NSArray *faceExpressionArray;

typedef enum {
    kMsgText = 0,///<文本
    kMsgImage = 1,///<图片
    kMsgVoice = 2,///<声音
    kMsgImageUrl = 4,
    kMsgVoiceUrl = 5,
}MessageType;


typedef void(^ReceviedGroupManagerMessage)(MessageModel *sender);///<群管理消息
typedef void(^SaveOfflineMessage)();
typedef void(^CreatRoomSuccess)(BOOL ret,XMPPRoom *sender);
typedef void(^AddMemberJidToRoom)(BOOL ret);
typedef void(^ChangeRoomName) (BOOL ret);
typedef void(^LeaveRoom)(BOOL ret);

@class XMPPRoomCoreDataStorage;

@interface QFXmppManager : NSObject{
    // nsurlconnection
    
    void (^saveRegCb)(BOOL ret, NSError *err);
    void (^saveLoginCb)(BOOL ret, NSError *err);
    void (^saveFriendsCb) (NSArray *) ;
    void (^saveMessageCb) (MessageModel *mm);
    void (^saveSendMessageFinishCb)(BOOL ret,NSString *siID);
    void (^saveSendDeviceTokenFinishCb)(BOOL ret, NSError *err);
    
    
    BOOL  isConnectWithTimeout;///<是否能够连接上服务器
    
    UserModel *_currUser;
    BOOL isInRegisting;
    NSMutableArray *_allFriendList;
    
    BOOL isChangeName;
    
    NSString *openFireNameStr;///<openfire服务器名字
    
    dispatch_queue_t queue2;
    
    NSString *getRoomMessageId;///<获取房间列表时候用到的id
    
    NSMutableDictionary *newRoomListDict;///<新的房间列表,如果是新的房间,先获取房间信息后在去通知用户
    NSMutableDictionary *sendSuccsetodoWaitQueue;
    //NSArray *faceNameArray;
    //NSArray *faceExpressionArray;
    
}

@property(nonatomic,strong)XMPPStream *xmppStream;
@property(nonatomic,strong)XMPPRoom *creatingRoom;///<房间
@property(nonatomic, assign) XMPPRoomCoreDataStorage* storage;
@property(nonatomic,copy)ReceviedGroupManagerMessage receviedGroupManagerMessage;///<接受到群聊管理消息
@property(nonatomic,copy)SaveOfflineMessage saveOfflineMessage;  //处理离线消息
@property(nonatomic,copy)CreatRoomSuccess creatRoomSuccess;///<是否创建成功
@property(nonatomic,copy)AddMemberJidToRoom addMemberJidToRoom;///<添加群成员是否成功
@property(nonatomic,copy)ChangeRoomName changeRoomName;
@property(nonatomic,copy)LeaveRoom haveleaveRoom;

@property(nonatomic,strong)NSMutableDictionary *roomDict;///<已经初始化的xmmppRoom对象

@property(nonatomic, strong)NSArray *createRoomJIDs;

@property(nonatomic, strong)NSArray *addMemberJIDs;

#pragma mark - 任务流
@property (nonatomic, copy) void (^receiveTaskPushInAppDelegate)(NSDictionary *pushDict);
@property (nonatomic, copy) void (^receiveTaskPushInTaskView)(NSDictionary *pushDict);
@property (nonatomic, copy) void (^receiveTaskPushInTaskCreate)(NSDictionary *pushDict);

+ (id) shareInstance;
// Jabber ID
//- (void) registerUser:(NSString *)jid withPassword:(NSString *)pass withCompletion:( void (^) (BOOL ret, NSError *err))cb;

- (void) loginUser:(NSString *)jid
         withPassword:(NSString *)pass
       withCompletion:( void (^) (BOOL ret, NSError *err))cb;

- (void) goOnline;
-(void)goOffline;
- (void) getAllFriends:( void (^) (NSArray *) ) cb;

// callback
- (void) registerForMessage:( void (^) (MessageModel *mm) )cb;

- (void) sendMessage:(NSDictionary *)msgDict chatType:(int)chatType withType:(MessageType)type toUser:(NSString *)toUser messageId:(NSString *)messageID withCompletion:(void (^)(BOOL ret,NSString *siID))cb;
- (void)updatejuhua:(NSString *)messageID withCompletion:(void (^)(BOOL ret,NSString *siID))cb;

- (void)sendTokenToOpenfireWithCompletion:(void(^)(BOOL ret,NSError *err))cb;  //发送device token
- (void)CancelPushNotification; //关闭推送

#pragma -mark 开启计数功能
- (void)openMessageCount;
- (void)setUnReadMessageCount:(NSInteger)count;

#pragma -mark关闭计数功能
- (void)closeMessageCount;

#pragma mark - 创建聊天室
-(void)creatRoomWithName:(NSString *)roomName jids:(NSArray *)jids compltion:(CreatRoomSuccess)creatSuccess;
/**
 *  聊天室添加用户
 *
 *  @param sender
 *  @param jids
 */
-(void)addMemberJidToRoom:(XMPPRoom *)sender jids:(NSArray *)jids compltion:(AddMemberJidToRoom)addMemberToRoom;
-(NSString *)checkJid:(NSString *)jid;
/**
 *  退出房间
 *
 *  @param room
 *  @param leaveRoom
 */
-(void)outRoom:(XMPPRoom *)room compltion:(LeaveRoom)leaveRoom;
/**
 *  群发消息
 *
 *  @param memberList
 *  @param sender     
 */
-(void)massRoomMessageType:(NSString*)type withMember:(NSArray *)memberList room:(XMPPRoom *)sender;

/**
 *  群配置处理
 *
 *  @param Message
 *  @param mm
 */
//- (void)dealRoomConfigMessage:(XMPPMessage *)message MessageModel:(MessageModel *)mm;

-(void)getRoomInfo:(NSString *)roomJid name:(NSString *)roomName;
-(void)releaseXmppManager;
/**
 *  修改群名称
 *  @param room 
 *  @param name
 *  @param  changeRoomName  回调
 */
-(void)ChangeRoomName:(NSString *)roomJid name:(NSString *)name compltion:(ChangeRoomName)changeRoomName;
@end