//
//  MessageChatViewController.h
//  O了
//
//  Created by 化召鹏 on 14-1-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchTable.h"
#import <QuartzCore/QuartzCore.h>
#import "FaceView.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "ButtonAudioRecorder.h"
#import <MediaPlayer/MPMoviePlayerController.h>

#import <AVFoundation/AVFoundation.h>
#import "RYAssetsPickerController.h"
#import "GCDAsyncSocket.h"

#import "UIScrollViewTouches.h"
#import "FaceButton.h"
#import "MoreView.h"

#import "MBProgressHUD.h"

#import "CalculateCharLength.h"

#import "RegexKitLite.h"

#import "MenuButton.h"

#import "TransmitViewController.h"

#import "MLEmojiLabel.h"

#import "CustomViewServiceListView.h"
#import "EmployeeModel.h"
#import "TaskCreateViewController.h"

#import "NavigationVC_AddID.h"

static NSString  *const authority_type = @"authority_type";//服务号操作权限

@class ServiceNumberInfo;
/**
 *  聊天类型
 */


typedef enum {
    MessageChatTypeCommon,          ///<普通
    MessageChatTypeServiceNumber,   ///<服务号
    MessageChatTypePublicCountHistory,     ///<查看历史消息
}MessageChatType;

@interface MessageChatViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,TouchTableDelegate,UITextViewDelegate,ShowReceivedMessageDelegate,ButtonAudioRecorderDelegate,RYAssetsPickerDelegate,FaceButtonDelegate,AVAudioPlayerDelegate,UIScrollViewTouchesDelegate,UIImagePickerControllerDelegate,MoreViewDelegate,MBProgressHUDDelegate,UIActionSheetDelegate,UIAlertViewDelegate,MLEmojiLabelDelegate,navigation_addIDDelegaet,CreateTaskDelegate>{


    TouchTable *_chatTable;
    UIView *_inputView;
    int keyboadHeight;
    FaceView *_faceView;
    
    UIView *_headTableView;
    
    int pageIndex;
    
//    AVAudioPlayer *player;
    
    //
    GCDAsyncSocket * _dataSocket;
    
    
    UIImageView *_lastImageView;
    
    UIView *_viewServiceNumber;

    AFHTTPRequestOperation *operation;      //创建请求管理（用于上传和下载）
    
    NSMutableArray *_imageArray;//存放图片的数组
    
    MBProgressHUD *_HUD;
    
    int send_message_again_select_now;//再次发送的索引
    
    BOOL is_select_imagePicker;//是否选择图片或者视频
    
    NSMutableArray *activtyBackViewArray;//存放菊花背景view
    NSMutableArray *activtyViewArray;//存放菊花view
    NSMutableArray *chatNotesDataArrayIndexArray;//存放索引

    //网络断开提醒条
    UIView *noNetworkView;
    UILabel *noNetworkViewLabel;
    NSTimer *noNetworkTimer;//提醒条定时器
    
    BOOL isEdite;///<是否是编辑状态
    
    NSString *_selfTitle;
    NSMutableDictionary * _isReadFlag;

}
///消息类型
@property (nonatomic,assign) MessageChatType         messageChatType;

@property (nonatomic,strong) UIButton                *leftButt;//返回按钮。
@property (nonatomic,strong) UIButton                *rightButt;//添加按钮
@property (nonatomic,strong) NSArray                 *chatMemberArray;//聊天人员数组
@property (nonatomic,strong) NSMutableArray          *chatNotesDataArray;//聊天记录数组
@property (nonatomic,strong) MPMoviePlayerController * moviePlayer;
@property (nonatomic,strong) NSArray                 *member_infoArray;//群发消息,对象

@property (nonatomic,strong)EmployeeModel *member_userInfo;///<发送对象
@property (nonatomic,assign)NSInteger chatType;///<默认为0,为单聊,1为群聊,2为公共号 4公告
@property (nonatomic,strong)RoomInfoModel *roomInfoModel;///<如果为群聊
@property (nonatomic,strong)AVAudioPlayer *player;



@property (strong,nonatomic) UIScrollViewTouches     *myScrollView;
@property (strong,nonatomic) UIImageView             *myImageView;
///服务号信息
@property (nonatomic,strong) ServiceNumberInfo       *snInfo;

@property(nonatomic,assign)BOOL isService;//是否是服务号

@property(nonatomic,assign)BOOL isHaveAppLog;///<是否已经记录过应用日志,默认为no

@property(nonatomic,assign)BOOL isCompelService;//是否是强制服务号
#pragma mark - 转发相关
@property(nonatomic,assign)BOOL isTranmist;///<是否是转发
@property(nonatomic,strong)NSArray *tranmistMessageArray;///<需要转发的消息

@property (nonatomic,retain ) NSArray   *previousNavViewController;//导航控制器中的视图数组 就是第一个

#pragma mark - 公众号相关
@property(nonatomic,strong)NSArray *historyArray;///<公众号历史消息
@property(nonatomic,strong)PublicaccountModel *publicModel;///<服务号对象


@property(nonatomic,assign)BOOL isFromGroupList;///<是否从群聊列表进来
@property(nonatomic,assign)BOOL isNoToRootViewWhenBack;///<当返回的时候是否不返回主界面,默认为NO返回,为YES是不返回

@property(nonatomic,assign) long long originalSize;

@end
