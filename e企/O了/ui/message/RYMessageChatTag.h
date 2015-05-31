//
//  RYMessageChatTag.h
//  O了
//
//  Created by 化召鹏 on 14-4-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVAudioSession.h>
#import "RYAssetsPickerController.h"



#import "MoreButton.h"
#import "AppDelegate.h"
#import "MessageGroupChatSetViewController.h"
#import "VideoUtil.h"

#import "NotesData.h"
#import "MemberData.h"

#import "AFClient.h"
#import "MainNavigationCT.h"

#import "NSString+FilePath.h"
#import "menber_info.h"
#import "GroupChatInfo.h"
#import "MBProgressHUD.h"
#import "UserDetailViewController.h"

#import "SoundWithMessage.h"

#import "ServiceNumberWebViewController.h"
#import "ServiceNumberDetailViewController.h"
#import "ServiceNumberMsgDetailViewController.h"
#import "ButtonAboveTitleAndBelowImage.h"
#import "CustomButtonNewsDetail.h"

#import "ChatCell.h"

#import "PhotoViewController.h"

#import "EncodeVideo.h"

#import "MoreViewButton.h"


#import "UIView+myChat.h"
#import "ChatView.h"

#import "TransmitSendMessage.h"

#import "RemindMemberViewController.h"

#import "UIMyTextView.h"


#import "MLChatView.h"

#import "SqliteDataDao.h"

#import "MyImageView.h"

#import "ActivituViewBg.h"

#import "SendMassMessage.h"

#import "PersonInfoViewController.h"


#ifndef O__RYMessageChatTag_h
#define O__RYMessageChatTag_h

//表情符号


#define inputText_tag 21//输入框背景
#define butt_face_tag 22//表情
#define butt_add_tag 23//添加
#define text_input_tag 24//输入框
#define butt_voice_tag 25//录制
#define butt_make_voice_tag 26//录制声音
#define actionSheet_tag 27

#define alert_deleta_content 28//是否删除信息的alert

#define MIDDLE_MARGIN_TOP 10   //中间显示的消息的上边距
#define MIDDLE_MARGIN_LEFT 15  //中间显示的消息的边距
#define MIDDLE_TAG_BASE 20000  //中间消息的起始Tag


#define multipleButt_tag 30000//多选时的转发和删除按钮

#define last_tag 999999

#define time_jiange 300 //两个时间label的间隔

#define INPUT_HEIGHT 46.0f

#define SERVICE_MAINMENU_TAG_BASE 400       //服务号主菜单每个Button的tag
#define SERVICE_SUBMENU_TAG_BASE 600        //服务号子菜单整个view的tag
#define SERVICE_HEIGHT_SUBMENU 40       //服务号子菜单每一项的高
#define SERVICE_MARGIN_LEFT_SUBMENU 10  //服务号子菜单的左边距
#define SERVICE_SUBMENU_ANM_DUR 0.1 //子菜单动画持续时间

#define message_sendFaild_tag 50000//发送失败的tag

#define activityView_tag 51000//菊花的开始tag

#define sendFailedButt_tag 100000//发送失败的按钮开始bug**

#define actionSheet_message_send_again 200000//再次发送的actionSheet  tag

#define actionSheet_Notele 3000000 //没有固话

#define actionSheet_NoshortNum 4000000 //没有短号

#define actionSheet_AllNumber 500000 //全部都能获取到固话短号

#define activityViewBackgroundView_tag 210000//菊花背景view的开始tag

#define image_url_null @"imageUrl_null"

#endif
