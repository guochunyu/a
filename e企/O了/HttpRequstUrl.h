//
//  HttpRequstUrl.h
//  O了
//
//  Created by 化召鹏 on 14-1-20.
//  Copyright (c) 2014年 QYB. All rights reserved.
//


#define MOBILEPHONE @"telNum"                   //手机号码(用户名)


#define USERCOMPANY @"MyUserCompany"            //保存公司名称

#define MyUserInfo  @"MyUserInfo"               //我的个人信息

#define myLoginUserInfo @"myLoginUserInfo"      //我的登录信息

#define myGID         @"myGid"                      //我的集团号
#define myCID         @"myCid"                      //我的号

#define myPassWord @"myPassWord"                //我的密码
#define myOpenFireUserName @"myOpenFireUserName" //openFire用户名
#define myLastLoginUser @"myLastLoginUser"      //上次登录的用户名

#define leaderPhoneVisibility @"leaderPhoneVisibility" //领导手机可见性
#define leaderVisibility      @"leaderVisibility"     //领导可见性
#define isSeeView       @"isSeeUodateView"      //是否展示更新通讯录view
#define isSee_Round @"isSee_animation"//通讯录加载的时候是否可以看到
#define time_long @"time_long"//时间差

//音视频服务器地址和端口
#define HTTP_VOIP   @"http_Voip"
#define HTTP_VOIPPORT   @"http_VoipPort"

//网络请求类
//SettingBundle

//10服务器
//#define HTTP_IP @"218.205.81.10" //ip地址
//#define HTTP_PORT @"80"       //端口号
//
//#define HTTP_ADCIP @"218.205.81.13"   //ip地址应用中心
//
//#define openfire_ip @"218.205.81.28"
//#define openfire_port 5222
//#define file_update_url @"http://218.205.81.10/pafs/rest/uploadservices/uploadbynewimagetype"///<文件上传服务器
//#define hms_ip @"218.205.81.10"   //历史消息服务器

//42服务器
/*
#define HTTP_IP @"218.205.81.42" //ip地址eas
#define HTTP_PORT @"80"       //端口号

#define openfire_ip @"218.205.81.40"
#define HTTP_ADCIP @"218.205.81.42"   //ip地址应用中心
#define openfire_port 5222
#define file_update_url @"http://218.205.81.40/pafs/rest/uploadservices/uploadbynewimagetype"///<文件上传服务器
#define hms_ip @"218.205.81.10"  //历史消息服务器
*/

//12服务器
#define HTTP_IP @"218.205.81.12" //ip地址
#define HTTP_PORT @"80"       //端口号
#define openfire_ip @"218.205.81.43"
#define HTTP_ADCIP @"218.205.81.12"   //ip地址应用中心
#define openfire_port 5222

#define file_update_url @"http://218.205.81.43/pafs/rest/uploadservices/uploadbynewimagetype"///<文件上传服务器
#define hms_ip @"218.205.81.10"  //历史消息服务器

/*
#define HTTP_IP [[NSUserDefaults standardUserDefaults]stringForKey:@"HTTP_IP"] //ip地址
#define HTTP_PORT [[NSUserDefaults standardUserDefaults]stringForKey:@"HTTP_PORT"]       //端口号
#define SOCKET_PORT [[NSUserDefaults standardUserDefaults]integerForKey:@"SOCKET_PORT"]        //socket端口号
*/






//地址拼接(主要用于头像url的快速拼接)
#define Head_Image_url(url) [NSString stringWithFormat:@"http://%@:%@/%@",HTTP_IP,HTTP_PORT,url]

#define LOGIN_FLAG @"alreadyLogon" //已登录的标识
#define UPDATEBUILD @"updatebuild" //版本更新标示
#define image_path @"/file/img/"//图片沙盒目录
#define voice_path @"/file/voice/"//语音沙盒目录
#define video_path @"/file/video/"//视频沙盒目录
//验证码获取
//"O了"登录

#define SHOW_ALERT(_message_) UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:_message_ delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil]; \
[alert show];

#define the_http_str [NSString stringWithFormat:@"%@_%@_%d",HTTP_IP,HTTP_PORT,SOCKET_PORT]

//sqlite保存路径 联系人
#define SQLITE_PATH [NSString stringWithFormat:@"/sqlModel/groupAddress.sqlite"]
//通讯录数据库保存路径

