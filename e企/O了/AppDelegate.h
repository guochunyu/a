//
//  AppDelegate.h
//  O了
//
//  Created by 城云 官 on 14-1-7.
//  Copyright (c) 2014年 royasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageModel.h"
#import "MBProgressHUD.h"
#import "Reachability.h"

#import "JSONKit.h"

#import "BWQuincyManager.h"
#import "AppDependencies.h"

#import "Keychain.h"

#import "CrashLog.h"

#import "AFClient.h"

#import "ContactsCheck.h"

#import "zmf.h"
#import "mtc_api.h"


typedef enum VOIP_STATE
{
    CALLSTATE_NONE,
    CALLSTATE_CALLING,
    CALLSTATE_TERMED_BG,
    CALLSTATE_TERMED,        /**< @brief callTermed */
    CALLSTATE_COMMING       /**< @brief callComming */
} VOIP_STATE;

typedef enum GROUPCALL_STATE
{
    GROUPCALLSTATE_NONE,
    GROUPCALLSTATE_WAITING,
    GROUPCALLSTATE_CALLING,
    GROUPCALLSTATE_TERMED,        /**< @brief callTermed */
} GROUPCALL_STATE;

typedef void(^NetWorkChange)(NSNotification *nitification);

/**
 *  是否登录openfire成功
 *
 *  @param rec
 */
typedef void(^LoginOpenFireState)(BOOL rec);


static NSString * const version_last =@"version";
static NSString * const httpIp_last =@"httpIp_last";

@class Reachability;
@class MainViewController;

@protocol ShowReceivedMessageDelegate <NSObject>
//聊天页面
-(void)showReceivedMsgByOwnerType:(MessageModel *)mm;

@end

@protocol NoticeUnreadMessageDelegate <NSObject>
//回话列表
-(void) noticeReceivedMsg:(MessageModel *)mm;

@end
@protocol ShowUnreadDelegate <NSObject>
//回话列表
-(void) showUnreadMsgCount:(MessageModel *)mm;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,MBProgressHUDDelegate,BWQuincyManagerDelegate,ContactsCheckDelegate>{
 
//    UINavigationController *nav3;
//    UINavigationController *nav4;
    
    Reachability *reachability;
    MBProgressHUD*      _HUD;
    MBProgressHUD*      _progressHUD;
    /**
     *  判断是否从登录界面登录，如果为YES，收到踢掉线通知，不做处理
     */
    BOOL isFromLogin;
    
    AFClient *client;
    
}

- (void)enterMain;
-(void)login;
@property (strong, nonatomic) UIWindow                    *window;
@property (strong, nonatomic) id<ShowReceivedMessageDelegate> showReceivedDelegate;
@property (strong,nonatomic ) id<NoticeUnreadMessageDelegate> noticeDelegate;
@property (strong,nonatomic ) id<ShowUnreadDelegate         > showUnreadDelegate;
@property (nonatomic,assign ) BOOL                        is_touxiang_cunzai;
@property (nonatomic,assign ) BOOL                        is_update;
@property (nonatomic, strong) NSString                    *plistURL;
@property (nonatomic,assign) BOOL showflag;
@property (nonatomic,strong) AppDependencies *dependencies;

@property(nonatomic,strong)NetWorkChange netChange;//网络变化通知

@property(nonatomic,copy)LoginOpenFireState loginOpenFireState;///<是否登录openfire成功

@property(nonatomic,assign)BOOL is_offline;

- (void)showWithCustomView:(NSString*)showText detailText:(NSString*)detailText isCue:(int)isCue delayTime:(CGFloat)delayTime isKeyShow:(BOOL)isKeyboardShow;

@property(strong,nonatomic)NSString *chatTaskId;

@property(nonatomic,assign)NSInteger unReadNum;//未读消息数量

@property(nonatomic,assign)BOOL isChangeIp;//改变了ip地址

@property(nonatomic,assign)BOOL isNetwork;//是否有网络,默认为NO

@property(nonatomic,assign)VOIP_STATE callState;//是否有来电，默认为NO;

@property(nonatomic,strong)MessageModel *msg_voip; //后台音视频消息

@property(nonatomic,assign)ZUINT callid_voip;

@property(nonatomic,assign)ZUINT termedCallid;

@property(nonatomic,assign)BOOL isLoginedVoip;   //是否登录音视频SDK

@property(nonatomic,assign)GROUPCALL_STATE groupCallState;

@property(nonatomic,assign)BOOL isForceUpDate;

@property(nonatomic,assign)BOOL isCheckedUpDate;

@property(nonatomic,assign)BOOL isSwitchEnterPrise;
@property(nonatomic,strong) MainViewController  *mainVC;
//会议未读
//@property (nonatomic, assign) int Meeting_Unread;
//邮箱未读
//@property (nonatomic, assign) int Email_Unread;
//消息未读
//@property (nonatomic, assign) int Message_Unread;

- (void)checkUpDate;
//登录openfire
-(void)loginOpenFire;
-(void)getDelegate:(MessageModel *)mm;
-(void)timeout;
@end
