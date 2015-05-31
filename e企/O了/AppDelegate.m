//
//  AppDelegate.m
//  O了
//
//  Created by 城云 官 on 14-1-7.
//  Copyright (c) 2014年 royasoft. All rights reserved.
//

#import "AppDelegate.h"
#import "QFXmppManager.h"
#import "AFClient.h"
#import "MainViewController.h"

#import "TaskViewController.h"

//#import "MoreViewController.h"
#import "MoreMineViewController.h"
#import "MailViewController.h"
#import "ContactsViewController.h"
#import "MessageViewController.h"
#import "MessageChatViewController.h"
#import "LoginViewController.h"
#import "MWWebViewController.h"
#import "AnalysisJsonUtil.h"
#import "UniAuthorizedViewController.h"
#import "HuiyiViewController.h"
#import "NSString+FilePath.h"
#import "MailBoardController.h"
#import "UserModel.h"
#import "MainNavigationCT.h"

#import "SoundWithMessage.h"

#import "MessageCell.h"
#import "DownManage.h"

#import "VersionComparison.h"

#import "LoginToServe.h"

#import "GuidePageViewController.h"
#import "SqlAddressData.h"
#import "SqlLiteCreate.h"

#import "SqliteDataDao.h"

#import "VoiceConverter.h"

#import "NSData+Base64.h"
#import "CrypoUtil.h"

#import "mobileSDK.h"  //trace统计

#import "AppDependencies.h"
#import "CoreDataManager.h"
#import "LogicHelper.h"
#import "MailBoardController.h"
#import "MailBoardRouter.h"
#import "MessageCell.h"
#import "VoIPViewController.h"

#import "TaskTools.h"
#import "ShowGuideViewController.h"
#define tidiao_alert_tag 10//踢下线
#define update_alert_tag 11//更新
#define MY_APP_KEY     "060db5d517f1c4290d236348"   //音视频接入Key

#define NewVersionString @"34029"//最新版的版本号


@interface AppDelegate ()
{
}

@end


@implementation AppDelegate {
    
    BOOL is_appLoginOpenFire;///<是否是打开应用的时候登录的openfire,默认为YES,登录后改为NO,如果为YES,从后台切换到前台不会进行登录openfire操作
    
    NSString *nonce;
    
    QFXmppManager *xmppManager;
}

NSString *updateUrl;//升级后的下载地址
NSString *updateMessage;//升级信息
BOOL isUpdateTo;//是否需要升级

//检测更新
- (void)checkUpDate
{
    NSString *mybuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    BOOL isgray = NO;
    //判断是否为开发者版
    /*
    if([version rangeOfString:@"dev"].location !=NSNotFound)//_roaldSearchText
    {
        isgray = YES;
    }
    else
    {
        isgray = NO;
    }
     */
    NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    if(uid == nil)
        return;
    
    DDLogInfo(@"uid=%@",uid);
    NSDictionary *dict=@{@"build": mybuild,
                         @"isgray": isgray? @"1":@"0",
                         @"imei": uid};
    
    [[AFClient sharedClient] getPath:@"eas/appcheck" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"userinforData===%@",operation.responseString);
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        DDLogInfo(@"检测更新dic====%@",dic);
        if([[dic objectForKey:@"status"]integerValue] == 1)
        {

            NSDictionary *dataDic = [dic objectForKey:@"data"];
            NSString *build = [dataDic objectForKey:@"build"];
            NSString *voip = [[dic objectForKey:@"servers"]objectForKey:@"voip"];
            [[NSUserDefaults standardUserDefaults]setObject:voip forKey:HTTP_VOIP];

            if([build integerValue] <= [mybuild integerValue])
            {
                //[(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"当前已是最新版本" isCue:0 delayTime:1 isKeyShow:NO];
            }
            
            else
            {
                self.isForceUpDate = [[dataDic objectForKey:@"force"]boolValue];
                NSString *fileURL = [dataDic objectForKey:@"fileurl"];
                self.plistURL = [NSString stringWithString:fileURL];
                NSString *updateDesc = [dataDic objectForKey:@"desc"];
                DDLogInfo(@"%@",updateDesc);
                NSArray *descData = [updateDesc componentsSeparatedByString:@"；"];
                DDLogInfo(@"%@",descData);

                for(NSString *desc_str in descData)
                {
                    if([desc_str length] == 0)
                    {
                        updateDesc=[updateDesc substringToIndex:updateDesc.length-1];
                    }
                }

                UIAlertView *alertView;
                if(fileURL){
                    if(self.isForceUpDate)
                    {
                        DDLogInfo(@"%@",@"强制更新");
                        alertView = [[UIAlertView alloc]initWithTitle:@"一起版本更新" message:updateDesc delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        
                    }else
                    {
                        DDLogInfo(@"%@",@"非强制更新");
                        if(self.isCheckedUpDate)
                        {
                            return ;
                        }
                        alertView = [[UIAlertView alloc]initWithTitle:@"一起版本更新" message:updateDesc delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"立即更新", nil];
                        self.isCheckedUpDate = YES;
                    }
                    
                    [alertView show];

                    alertView.tag = update_alert_tag;

                }
            }

        }
        else
        {

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _showflag=YES;
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger* fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    
    NSString* logDir = [[fileLogger logFileManager] logsDirectory];
    [[NSUserDefaults standardUserDefaults] setObject:logDir forKey:@"DDLogDir"];
    DDLogInfo(@"%@",launchOptions);
    
    Zmf_AudioInitialize(NULL);
    Zmf_VideoInitialize(NULL);
    if (Mtc_Init(MY_APP_KEY) != ZOK) {
        return NO;
    }
    _isLoginedVoip = NO;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(loginOk) name:@MtcLoginOkNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(loginPassword) name:@MtcLoginPasswordNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(loginFailed:) name:@MtcLoginDidFailNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(didLogout) name:@MtcDidLogoutNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(logouted) name:@MtcLogoutedNotification object:nil];
    //重新注册UserDefault
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    NSString *http_str=[NSString stringWithFormat:@"%@:%@",HTTP_IP,HTTP_PORT];
    DDLogInfo(@"当前连接地址为:%@",http_str);
    NSString *lastHttp_str=[userDefaults objectForKey:httpIp_last];
    self.isChangeIp=NO;
    /*
     ** 判断ip切换更新通讯录
     */
    if (lastHttp_str.length!=0 && ![http_str isEqualToString:lastHttp_str]) {
        //和上次的ip地址不一样
        self.isChangeIp=YES;
    }

    
    if([launchOptions objectForKey:@"appkey"] != nil)
    {
        [self uniAuthorizedLogin];
        
        return YES;
    }
    
    xmppManager=[QFXmppManager shareInstance];
    
    self.isNetwork=YES;
    is_appLoginOpenFire=YES;

    [CrashLog setDefaultHandler];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:0.22 green:0.22 blue:0.22 alpha:1];
    
    self.chatTaskId=@"0";
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    //聊天记录
    
    if ([userDefaults objectForKey:httpIp_last]) {
        [userDefaults setObject:http_str forKey:httpIp_last];
    }
    

    [userDefaults setObject:http_str forKey:httpIp_last];
    //开启新线程
    /*
     化
     */
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filePath_01 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"/avatar.png"];
    self.is_touxiang_cunzai=[fileManager fileExistsAtPath:filePath_01 isDirectory:NO];
    
    
    //trace 统计数据
    //mobileSDK *mobileiOS = [mobileSDK sharedMobileSDK];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[self checkUpDate];
    });

    if (IS_IOS_8)
    {
        //ios8注册通知
         
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    else
    {
        
        //注册通知
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    }
    self.isCheckedUpDate = NO;
    self.isSwitchEnterPrise = NO;
    _groupCallState = GROUPCALLSTATE_NONE;
    _callState = CALLSTATE_NONE;
    _msg_voip = [[MessageModel alloc]init];

    [self login];
 
    [self initBackButton];
    [self initbarButton];

    _dependencies = [AppDependencies new];
    
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)login{

    if( _showflag&& [self.window.rootViewController isKindOfClass:[ShowGuideViewController class]]){
        return ;
    }
    if([appBuild isEqualToString:NewVersionString]){//最新版本，取showflage判断，
        NSString * VersionString=  [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
        if(VersionString&&[VersionString isEqualToString:NewVersionString]){
            //显示的版本号为最新版本号 不显示引导页
            DDLogCInfo(@"最新版本，并且已经显示，不重复显示");
        }else{
            //需要显示
            ShowGuideViewController *showview=[[ShowGuideViewController alloc]init];
            __weak typeof(self) blockSelf=self;
            showview.blockEnterApp=^(){
                blockSelf.showflag=NO;
                [blockSelf login];
            };
            self.window.rootViewController=showview;
            [[NSUserDefaults standardUserDefaults] setObject:NewVersionString forKey:@"version"];
            return;
        }
    }
    

//    if([appBuild isEqualToString:@"34029"]){//最新版本，取showflage判断，
//        NSString *filename=[self getnewpath:@"newpath"];
//        NSMutableDictionary *data1 = [[NSMutableDictionary alloc] initWithContentsOfFile:filename];
//        if( [[data1 objectForKey:@"version"] isEqualToString:@"34029"]){
//            DDLogInfo(@"已经显示过引导页");
//        }else{
//            _needlogin=NO;
//            ShowGuideViewController *showview=[[ShowGuideViewController alloc]init];
//            __weak typeof(self) blockSelf=self;
//            showview.blockEnterApp=^(){
//                blockSelf.needlogin=YES;
//                [blockSelf login];
//            };
//            self.window.rootViewController=showview;
//            return;
//        }
//    }
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![SqlAddressData isExitSomeColumn])
    {
        [[NSUserDefaults standardUserDefaults]setObject:0 forKey:LATESTUPDATETIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SqlAddressData releaseDataQueue];
        self.isChangeIp = YES;
    }
    
    if([appBuild isEqualToString:@"33720"] && ![fileManager fileExistsAtPath:[UPDATEBUILD filePathOfCaches]])
    {
        [fileManager createDirectoryAtPath:[UPDATEBUILD filePathOfCaches] withIntermediateDirectories:YES attributes:nil error:nil];
        self.isChangeIp = YES;
    }
 
    [[SqliteDataDao sharedInstanse]isExitSomeColumn];

    if (![fileManager fileExistsAtPath:[LOGIN_FLAG filePathOfCaches]] || self.isChangeIp) {
        
        /**
         *  如果不存在登录文件夹,或者改变了ip地址,
         */

        [self loginOutVoipSDK];

//        if(self.window.rootViewController&&[self.window.rootViewController isKindOfClass:[LoginViewController class]]){
//            [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
//            self.window.rootViewController=nil;
//        }

        //进入登录界面
        LoginViewController *loginViewController=[[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        loginViewController.blockEnterMain=^(){
            
//            //创建文件夹标识登录信息
//            [fileManager createDirectoryAtPath:[LOGIN_FLAG filePathOfCaches] withIntermediateDirectories:YES attributes:nil error:nil];
#pragma mark 创建数据库表
            //   创建数据库
            [SqlLiteCreate getDataBase];
            //   创建个人信息表
            [SqlAddressData createPersoninfoTable];
            //   创建部门关系表
            [SqlAddressData createBranchTable];
            //   创建常用联系人表
            [SqlAddressData createCommenContact];
            [SqlAddressData adapterContactSomeColumn];
            //   创建联系人可见性表
      //    [SqlAddressData createVisibilityContactTable];
            [SqlAddressData createNewVisibilityTable];
            //   创建领导人可见性表
            [SqlAddressData createVisibilityLeaderTable];
            
            [[SqliteDataDao sharedInstanse] creatTabel];

#pragma  mark 刷新通讯录
            ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
            contactsCheck.contactsCheckDelegate = self;
            [contactsCheck execute];
        };
        [[ConstantObject sharedConstant] releaseAllValue];
        [[AFClient sharedClient] releaseAFClient];

        [[SqliteDataDao sharedInstanse] releaseData];
        [SqlAddressData releaseDataQueue];
        [[QFXmppManager shareInstance] releaseXmppManager];

        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:MyUserInfo];
        [userDefaults removeObjectForKey:myGID];
        [userDefaults removeObjectForKey:myCID];
        [userDefaults synchronize];
        [ConstantObject sharedConstant].userInfo = nil;
        self.isCheckedUpDate = NO;

        self.window.rootViewController=loginViewController;
    }else{
        [SqlAddressData adapterContactSomeColumn];
        
        //直接进入主控制器
        isFromLogin=NO;
        [LoginToServe loginToServe];
        
        [[QFXmppManager shareInstance] registerForMessage:^(MessageModel *mm) {
            [self messageManage:mm];
        }];
        __weak typeof(self) blockSelf=self;
        xmppManager=[QFXmppManager shareInstance];
        xmppManager.receviedGroupManagerMessage=^(MessageModel *mm){
            //收到群聊管理消息
            //首先根据roominfo初始化聊天室
            [blockSelf getRoom:mm];
        };
        [self loginOpenFire];
        [self enterMain];
        
    }
}
#pragma mark 通讯录刷新
-(void)beginUpdate{
    ;
}
-(void)endUpdate:(bool)hasUpdate{
    
    if(hasUpdate){//通讯录更新完成
        NSFileManager *fileManager=[NSFileManager defaultManager];
//        isFromLogin=YES;
        NowLoginUserInfo *userIfno=[ConstantObject sharedConstant].userInfo;
        NSString *userName=userIfno.imacct;
        NSString *passWord=[[NSUserDefaults standardUserDefaults] objectForKey:myPassWord];
        is_appLoginOpenFire=YES;
        [[QFXmppManager shareInstance] loginUser:userName withPassword:passWord withCompletion:^(BOOL ret, NSError *err) {
            DDLogInfo(@"%@:登录openFire%@",self.class,ret?@"成功":@"失败");
            
            //收到消息
            if(ret){
                [[QFXmppManager shareInstance] registerForMessage:^(MessageModel *mm) {
                    [self messageManage:mm];
                }];
                __weak typeof(self) blockSelf=self;
                xmppManager=[QFXmppManager shareInstance];
                xmppManager.receviedGroupManagerMessage=^(MessageModel *mm){
                    //收到群聊管理消息
                    //首先根据roominfo初始化聊天室
                    [blockSelf getRoom:mm];
                };
            }else{
                LoginViewController *ddd=(LoginViewController * ) self.window.rootViewController;
                [ddd stop];
                
            }
            //登录voipSDK
            [self loginVoipSDK:userIfno.imacct];

            [[QFXmppManager shareInstance]sendTokenToOpenfireWithCompletion:^(BOOL ret, NSError *err)
             {
                 DDLogInfo(@"上传deviceToken%@",ret?@"成功":@"失败");
             }];
            
            [[QFXmppManager shareInstance]openMessageCount];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回到主线程
                
                if (self.loginOpenFireState) {
                    self.loginOpenFireState(ret);
                }
                
                is_appLoginOpenFire=NO;
                if (ret) {
                    [self enterMain];
                    //创建文件夹标识登录信息
                    [fileManager createDirectoryAtPath:[LOGIN_FLAG filePathOfCaches] withIntermediateDirectories:YES attributes:nil error:nil];

                }else{
                    [[ConstantObject sharedConstant] releaseAllValue];
                    [[AFClient sharedClient] releaseAFClient];
                    [[SqliteDataDao sharedInstanse] releaseData];
                    [fileManager removeItemAtPath:[LOGIN_FLAG filePathOfCaches] error:nil];
                }
            });
            
        }];
    }
}

-(void)initbarButton{
    
//    if (!IS_IOS_7) {
//        UIImage *buttonImage = [[UIImage imageNamed:@"top_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//        //    UIImage *button24 = [[UIImage imageNamed:@"top_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//        [[UIBarButtonItem appearance] setBackgroundImage:buttonImage forState:UIControlStateNormal
//                                              barMetrics:UIBarMetricsDefault];
//    }
    
    
//    [[UIBarButtonItem appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//        [UIColor whiteColor],
//        UITextAttributeTextColor,[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0], UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
//        UITextAttributeTextShadowOffset,[UIFont fontWithName:@"AmericanTypewriter" size:0.0], UITextAttributeFont,nil]
//             forState:UIControlStateNormal];
}

-(void)timeout{
    
    if([self.window.rootViewController isKindOfClass:[LoginViewController class]]){
        //        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"网络异常" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        LoginViewController *temploginvc=(LoginViewController * ) self.window.rootViewController;
        [temploginvc stop];
    }
    
}

-(void)initBackButton{
    UIImage *buttonBack30 = [[UIImage imageNamed:@"nv_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    if (!IS_IOS_7) {
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30 forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
}

-(void)netWorkChange:(NSNotification *)nitification{
    
    if (self.netChange) {
        self.netChange(nitification);
    }
    
    Reachability* curReach = [nitification object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    DDLogInfo(@"网络=====%d",netStatus);
//    reachability=YES;
    NSString *stateStr=nil;
    
    if (netStatus == NotReachable) {
        /**
         *  没有网络连接
         */
        self.isNetwork=NO;
        [self showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];

        stateStr=@"0";
//        [[LogRecord sharedWriteLog] writeLog:@"检测到没有网络"];
       
    }else {
        self.isNetwork=YES;
        [self showWithCustomView:@"网络重连了" detailText:nil isCue:1.5 delayTime:1 isKeyShow:NO];

        stateStr=@"1";
//        [[LogRecord sharedWriteLog] writeLog:@"检测到有网络"];
        //登录openfire
        /**
         *  多加一层判断,如果不存在这个文件夹,不进行登录openfire操作
         */
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[LOGIN_FLAG filePathOfCaches]] &&is_appLoginOpenFire){
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){
                //在前台才会登录
                [self loginOpenFire];
            }
            
        }
    
    }
}

BOOL is_first_tidiao;
#pragma mark - 踢掉线,没有用到
-(void)offLine{
    //下线
    [[QFXmppManager shareInstance] goOffline];
    //  更新一次可见性表
    [SqlAddressData deleteLeadertable];
    [SqlAddressData deleteVisilityContact];
    [[ConstantObject sharedConstant] releaseAllValue];
    [[AFClient sharedClient] releaseAFClient];
    [[SqliteDataDao sharedInstanse] releaseData];
    [SqlAddressData releaseDataQueue];
    //       删除登录标识
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[LOGIN_FLAG filePathOfCaches] error:nil];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:myPassWord];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:JSSIONID];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:MyUserInfo];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:MOBILEPHONE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:myGID];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //要把openfire下线
    [[QFXmppManager shareInstance] releaseXmppManager];
    
    is_appLoginOpenFire=YES;
    //提掉线后要把通知移除
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"踢下线" object:nil];
    [_mainVC removeFromParentViewController];
    [self login];

    [self showWithCustomView:nil detailText:@"你的帐号已在其他设备上登录." isCue:1 delayTime:2 isKeyShow:NO];

}

#pragma mark - 登录open fire


-(void)loginOpenFire{
    NowLoginUserInfo *userIfno=[ConstantObject sharedConstant].userInfo;
    DDLogInfo(@"777777");
    [self loginVoipSDK:userIfno.imacct];
    NSString *userName=userIfno.imacct;
    is_appLoginOpenFire=YES;
    NSString *passWord=[[NSUserDefaults standardUserDefaults] objectForKey:myPassWord];
    [ConstantObject sharedConstant].isHaveLoadRoomList=NO;
    [[QFXmppManager shareInstance] loginUser:userName withPassword:passWord withCompletion:^(BOOL ret, NSError *err) {
        is_appLoginOpenFire=NO;
        
        DDLogInfo(@"openfire登录%@",ret?@"成功":@"失败");
//        [xmppManager creatRoomWithName:@"cb3403ba-f434-4167-a4c2-42fc9de60d1d"];
        [[QFXmppManager shareInstance]sendTokenToOpenfireWithCompletion:^(BOOL ret, NSError *err)
         {
             DDLogInfo(@"上传deviceToken%@",ret?@"成功":@"失败");
         }];

    }];
}
-(void)sendNotifactionToMessageChatList:(NSString *)retStr{
    NSDictionary *notificationDict=@{@"ret": retStr};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveOffline"object:nil userInfo:notificationDict];
}
#pragma mark 进入主控制器

-(void)tintColor:(MainNavigationCT *)nav{
    nav.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    nav.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    nav.navigationController.navigationBar.translucent = NO;
}

int badgeNumber=0;
- (void)enterMain
{
    //会议未读消息通知
    //[self accept_Meeting];
    //[self accept_Email];
    //[self accept_Message];
    
    if (IS_IOS_7) {
        [[UINavigationBar appearance]setBarStyle:UIBarStyleBlackOpaque];
        [[UINavigationBar appearance]setBarTintColor:[UIColor whiteColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    if (_mainVC) {
        _mainVC=nil;
        DDLogInfo(@"-----%@",_mainVC);
    }
    _mainVC=[[MainViewController alloc] init];
    _mainVC.isFromLogin=isFromLogin;
    MessageViewController *messageVC=[[MessageViewController alloc] init];
    MainNavigationCT *nav1=[[MainNavigationCT alloc] initWithRootViewController:messageVC];
    nav1.mainVC = _mainVC;
    if (IS_IOS_7) {
        nav1.interactivePopGestureRecognizer.enabled=YES;
    }

    
    UIStoryboard *storyboard_contacts=[UIStoryboard storyboardWithName:@"Storyboard_contacts" bundle:nil];
    MainNavigationCT *nav2 = [[MainNavigationCT alloc] initWithRootViewController:storyboard_contacts.instantiateInitialViewController];
    
    nav2.mainVC = _mainVC;
    if (IS_IOS_7) {
        nav2.interactivePopGestureRecognizer.enabled=YES;
    }
    
    TaskViewController *taskVC = [[TaskViewController alloc] init];
    MainNavigationCT *navTask = [[MainNavigationCT alloc] initWithRootViewController:taskVC];
    navTask.mainVC = _mainVC;
    if (IS_IOS_7) {
        navTask.interactivePopGestureRecognizer.enabled = YES;
    }
    
    
    UIViewController *workVC = [_dependencies createRootView];
    MainNavigationCT *nav3=[[MainNavigationCT alloc] initWithRootViewController:workVC];
    nav3.mainVC=_mainVC;
    if (IS_IOS_7) {
        nav3.interactivePopGestureRecognizer.enabled=YES;
    }
    
//    UIStoryboard * meVC = [UIStoryboard storyboardWithName:@"MeViewController" bundle:nil];
    MoreMineViewController *moreVC=[[MoreMineViewController alloc] init];
    MainNavigationCT *nav4 = [[MainNavigationCT alloc]initWithRootViewController:moreVC];
    nav4.mainVC=_mainVC;
    if (IS_IOS_7) {
        nav4.interactivePopGestureRecognizer.enabled=YES;
    }
    
    [nav1.navigationBar setBackgroundImage:[self imageWithColor:cor6] forBarMetrics:UIBarMetricsDefault];
    nav1.navigationBar.translucent = NO;
    [nav1.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
    
    [nav2.navigationBar setBackgroundImage:[self imageWithColor:cor6] forBarMetrics:UIBarMetricsDefault];
    
    nav2.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [nav2.tabBarController.tabBar setBarTintColor:[UIColor colorWithRed:50/255.0 green:114/255.0 blue:240/255.0 alpha:1]];

    
    [navTask.navigationBar setBackgroundImage:[self imageWithColor:cor6] forBarMetrics:UIBarMetricsDefault];
    [navTask.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
    
    //邮箱导航栏颜色
    [nav3.navigationBar setBackgroundImage:[self imageWithColor:cor6] forBarMetrics:UIBarMetricsDefault];
  
   [nav3.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
  
    
    [nav4.navigationBar setBackgroundImage:[self imageWithColor:cor6] forBarMetrics:UIBarMetricsDefault];
//    [nav4.navigationBar setTintColor:[UIColor whiteColor]];
    [nav4.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
    
    NSArray *array=[NSArray arrayWithObjects:nav1,nav2,navTask,nav3,nav4,nil];
    
    _mainVC.viewControllers=array;
   // mainVC.seletedIndex=0;
    

    
    __weak MainViewController *tmpMainVC = _mainVC;
    xmppManager.receiveTaskPushInAppDelegate = ^(NSDictionary *taskStatusDict){
        //收到任务流推送 tabbar 处理
        NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
//        tmpMainVC.tabbarButtTask.remindNum = [unReadArray count];
        if([unReadArray count] > 0)
        {
            tmpMainVC.tabbarButtTask.isRemind = YES;
        }
        else
        {
            tmpMainVC.tabbarButtTask.isRemind= NO;
        }
        
      //  [ConstantObject app].unReadNum = tmpMainVC.tabbarButt1.remindNum + [unReadArray count];
        
    };
    _isChangeIp = NO;
    self.window.rootViewController=_mainVC;
    
    /*
    //会议未读
    int Meeting_Unread= [[[NSUserDefaults standardUserDefaults]objectForKey:@"unconfirm_count"] integerValue];
    DDLogCInfo(@"Meeting_Unread：%d",Meeting_Unread);
    //邮箱未读
    int Email_Unread = [[[NSUserDefaults standardUserDefaults]objectForKey:@"未读个数"] integerValue];
    DDLogCInfo(@"Email_Unread：%d",Email_Unread);
    NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
    //消息未读
    int Message_Unread = tmpMainVC.tabbarButt1.remindNum + [unReadArray count];
    DDLogCInfo(@"Message_Unread：%d",Message_Unread);
    //app上面的红点
    int All_Unread = Meeting_Unread+Email_Unread+Message_Unread;
    DDLogCInfo(@"All_Unread：%d",All_Unread);
    [ConstantObject app].unReadNum = All_Unread;
    DDLogCInfo(@"[ConstantObject app].unReadNum：%d",[ConstantObject app].unReadNum);
    //是否显示红点判断
    if ([ConstantObject app].unReadNum != 0) {
        [ConstantObject app].unReadNum = All_Unread;
    }else {
        [ConstantObject app].unReadNum = 0;
    }
     */
    
}


/*
//会议未读消息接受
-(void)accept_Meeting {
    NSNotificationCenter*centerwqqwwq = [NSNotificationCenter defaultCenter];
    [centerwqqwwq addObserver:self selector:@selector(jieshoujieshou:) name:noticecxd object:nil];
}

-(void)jieshoujieshou:(NSNotification*)sender {
    NSString *str2 = [sender.userInfo valueForKey:@"testq"];
    
    _Meeting_Unread = [str2 integerValue];
    DDLogCInfo(@"AppDelegate里的红点值是:%d",_Meeting_Unread);
}
//邮箱未读消息接受
- (void)accept_Email {
    NSNotificationCenter*center_accept_Meeting=[NSNotificationCenter defaultCenter];
    //找到通知中心,注册收听某主题的广播
    [center_accept_Meeting addObserver:self selector:@selector(recrive:) name:notificationEmail object:nil];
}
- (void)recrive:(NSNotification*)sender {
    NSString *str2 = [sender.userInfo valueForKey:@"product"];
    _Email_Unread = [str2 integerValue];
    NSLog(@"邮箱未读消息接受：%d",_Email_Unread);
}

//消息未读消息接受
- (void)accept_Message {
    NSNotificationCenter*center_accept_Message = [NSNotificationCenter defaultCenter];
    [center_accept_Message addObserver:self selector:@selector(Message_Unread_Methods:) name:notificationMessage object:nil];
}
 
- (void)Message_Unread_Methods:(NSNotification*)sender {
    NSString *str = [sender.userInfo valueForKey:@"product"];
    _Message_Unread = [str integerValue];
    NSLog(@"消息未读消息接受：%d",_Message_Unread);
}
*/
- (void)dealloc{
    //移除通知
    
 //   [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"test" object:nil];
    
    NSNotificationCenter *center_accept_Email=[NSNotificationCenter defaultCenter];
    [center_accept_Email removeObserver:self name:@"Unread" object:nil];
    
//    NSNotificationCenter *Message_Unread=[NSNotificationCenter defaultCenter];
//    [Message_Unread removeObserver:self name:@"WWDC" object:nil];
}

-(void)getRoom:(MessageModel *)mm{
//    [self.showUnreadDelegate showUnreadMsgCount:mm];
    [self getDelegate:mm];
}
#pragma mark 消息处理

-(void)messageManage:(MessageModel *)mm{
    /*
     if (mm.fileType==2) {
     [[DownManage sharedDownload] downloadWhithUrl:mm.chatVoiceData.voiceUrl fileName:mm.chatVoiceData.voiceName type:2 downFinish:^(NSString *filePath) {
     
     NSString *fileExtention = [filePath pathExtension];
     if([fileExtention isEqualToString:@"amr"])
     {
     [self voiceAmrToWavMm:mm savePath:filePath];
     }else
     {
     mm.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,mm.chatVoiceData.voiceName];
     
     [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
     [self getDelegate:mm];
     [SoundWithMessage loadRemindWithTaskID:mm.to];
     }
     
     } downFail:^(NSError *error) {
     
     }];
     }else
     */
    if (mm.fileType==8){
        [self offLine];
        return;
    }else{
        
        //        if([mm.from isEqualToString:@"EEC_DEVTEAM_NOTIFY_PUSH"]||[mm.from isEqualToString:@"EMS_BIZ_NOTIFY_PUSH"]){
        //            ;
        //        }else{
        //            if([mm.from isEqualToString:mm.to]){
        //                //自己发给自己的消息
        //                return ;
        //            }
        //        }
        if([mm.from isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]){
            return;
        }
        
        BOOL result= [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
        if (result) {
            [SoundWithMessage loadRemindWithTaskID:mm.to];
            [self getDelegate:mm];
        }else{
            DDLogInfo(@"收到消息，插入失败");
        }
        
    }
    
    
    
}
NSDate *lastTimeDate;
/**
 *  是否实现代理,
 *
 *  @return bool;如果需要立即实现,返回yes延时1秒
 */
-(BOOL)shouldImmediatelyGetMessageDelegate{
    
    
    if (!lastTimeDate) {
        
        return YES;
    }else{
        
        NSTimeInterval timeDifference=[[NSDate date] timeIntervalSinceDate:lastTimeDate];
        if (timeDifference>2) {
            lastTimeDate=[NSDate date];
            return YES;
        }
    }
    
    return NO;
}

-(void)getDelegate:(MessageModel *)mm{

    static long lastTime;
    //long refreshInterval = 100;
   
    lastTime = [[NSDate date] timeIntervalSince1970];
    //double delayInSeconds = refreshInterval/1000.0;
    //dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_async(dispatch_get_main_queue(), ^{
        //回到主线程
        [self.showReceivedDelegate showReceivedMsgByOwnerType:mm];
        [self.showUnreadDelegate showUnreadMsgCount:mm];

    });
    /*
    dispatch_after(popTime,dispatch_get_main_queue(), ^{
        //回到主线程
        [self.showReceivedDelegate showReceivedMsgByOwnerType:mm];
        [self.showUnreadDelegate showUnreadMsgCount:mm];
       
    });
     */
}

//amr&wav convert

- (void)voiceAmrToWavMm:(MessageModel *)mm savePath:(NSString *)filePath
{
    NSString *wavfilePath=[[NSString stringWithFormat:@"%@%@",voice_path,mm.chatVoiceData.voiceName] filePathOfCaches];
    [VoiceConverter amrToWav:[filePath filePathOfCaches] wavSavePath:wavfilePath];

    mm.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,mm.chatVoiceData.voiceName];
    [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
    [self getDelegate:mm];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and pit begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [UIApplication sharedApplication].applicationIconBadgeNumber= _unReadNum;
    
}
//NSTimer *timerCode;
//当程序被推送到后台的时候调用。所以要设置后台继续运行，则在这个函数里面设置即可
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    
    MainNavigationCT *ttt=[_mainVC.viewControllers objectAtIndex:0];
    for(UIViewController *vc in ttt.viewControllers){
        if([vc isKindOfClass:[MessageChatViewController class]]){
            MessageChatViewController *messagevc=(MessageChatViewController *)vc;
            [messagevc.player stop];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationEnterBackground object:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    timerCode=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
    
    [[CoreDataManager sharedInstance] save];
    
    //记录Activity结束时间
    [mobileSDK setTerminateProgram];

//    [UIApplication sharedApplication].applicationIconBadgeNumber= _unReadNum;
    
    if (is_appLoginOpenFire) {
        is_appLoginOpenFire=NO;
    }
    
    [[QFXmppManager shareInstance]setUnReadMessageCount:_unReadNum];
    [[QFXmppManager shareInstance] goOffline];
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setKeepAliveTimeout:600 handler:^{
        NSLog(@"===>keepAlive");
        Mtc_CliRefresh();
    }];
    //显示所有红点
    /*DDLogCInfo(@"_Meeting_Unread：%d",_Meeting_Unread);
    DDLogCInfo(@"_Email_Unread：%d",_Email_Unread);
    DDLogCInfo(@"_Message_Unread：%d",_Message_Unread);
    int all_Unread = _Email_Unread + _Meeting_Unread + _Message_Unread;
     */
    NSUserDefaults *ud= [NSUserDefaults standardUserDefaults];
    NSInteger Meeting_Unread=[[ud objectForKey:@"unconfirm_count"] integerValue];
    NSInteger Email_Unread=[[ud objectForKey:@"未读个数"] integerValue];
    NSLog(@"消息数：%d",_mainVC.tabbarButt2.remindNum);
    [ConstantObject app].unReadNum = _mainVC.tabbarButt2.remindNum+Meeting_Unread+Email_Unread;
    //[UIApplication sharedApplication].applicationIconBadgeNumber= _unReadNum;

}
//当程序从后台将要重新回到前台时候调用。
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if([appBuild isEqualToString:@"33720"] && ![fileManager fileExistsAtPath:[UPDATEBUILD filePathOfCaches]])
    {
        [fileManager createDirectoryAtPath:[UPDATEBUILD filePathOfCaches] withIntermediateDirectories:YES attributes:nil error:nil];
        self.isChangeIp = YES;
        [self login];
    }
    
    if([self.window.rootViewController isKindOfClass:[LoginViewController class]]){
        LoginViewController *ddd=(LoginViewController * ) self.window.rootViewController;
        [ddd restart];
    }
    if(![SqlAddressData isExitSomeColumn])
    {
        [[NSUserDefaults standardUserDefaults]setObject:0 forKey:LATESTUPDATETIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SqlAddressData releaseDataQueue];
        self.isChangeIp = YES;
        if(![self.window.rootViewController isKindOfClass:[LoginViewController class]]){
             [self login];
        }
    }
    [[SqliteDataDao sharedInstanse]isExitSomeColumn];

    //进入前台检测更新
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //[self checkUpDate];
    });
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setKeepAliveTimeout:600 handler:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        Mtc_CliRefresh();
    });
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    /**
     *  从后台切换到前台的处理
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if([appBuild isEqualToString:@"33720"] && ![fileManager fileExistsAtPath:[UPDATEBUILD filePathOfCaches]])
    {
        [fileManager createDirectoryAtPath:[UPDATEBUILD filePathOfCaches] withIntermediateDirectories:YES attributes:nil error:nil];
        self.isChangeIp = YES;
        [self login];
    }
    
    //记录Activity开始时间，并获得该页面类名作为className参数
    [mobileSDK startWithAppkey:@"14177687814187dcf5e7626b2fcdeece"];
    
    if (!is_appLoginOpenFire) {
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[LOGIN_FLAG filePathOfCaches]]){
            QFXmppManager *qfxm=(QFXmppManager *)[QFXmppManager shareInstance];
            
            if (qfxm.xmppStream) {
                if (!qfxm.xmppStream.isConnected) {
                    //不在线
                    DDLogInfo(@"不在线");
                    
                    [self loginOpenFire];
                    
                }else{
                    DDLogInfo(@"在线");
                }
            }
        }
    }
    
    
    //先设置为0,是为了清除通知栏中得通知
//    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
//    [UIApplication sharedApplication].applicationIconBadgeNumber= _unReadNum;
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    long long int dateTime=(long long int) nowTime;
    
    NSDate *nowTimeDate = [NSDate dateWithTimeIntervalSince1970:dateTime];
    
    NSDate *lastTimeDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"update_last_time"];
    
    NSTimeInterval time_interval=[nowTimeDate timeIntervalSinceDate:lastTimeDate];
    
    if (time_interval>3600*2) {
        //超过一个小时才会检测更新

    }
    if(_callState == CALLSTATE_TERMED_BG)
    {
        [self getDelegate:_msg_voip];
        _callState = CALLSTATE_NONE;
    }
    if(_callState == CALLSTATE_COMMING)
    {
        _callState = CALLSTATE_CALLING;

        BOOL isVideo = Mtc_CallPeerOfferVideo(_callid_voip);
        
        ZCONST ZCHAR *pcPhone = Mtc_CallGetPeerName(_callid_voip);
        NSString *imacct = [NSString stringWithUTF8String:pcPhone];
        EmployeeModel *emodel = [SqlAddressData queryMemberInfoWithImacct:imacct];
        NSString *headImageurl = emodel.avatarimgurl;
        
        VoIPViewController *callingViewController = [[VoIPViewController alloc] init];
        callingViewController.isIncoming = YES;
        callingViewController.isVideo = isVideo;
        callingViewController.callId = _callid_voip;
        callingViewController.emodel = emodel;
        callingViewController.phoneNumber = emodel.phone;
        callingViewController.headImageUrl = headImageurl;
        [_mainVC presentViewController:callingViewController animated:YES completion:^{
        }];
        Mtc_CallAlert(_callid_voip, 0, EN_MTC_CALL_ALERT_RING, ZFALSE);
        DDLogInfo(@"Mtc_CallAlert%d",_callid_voip);

    }
    
    
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

//    获取终端设备标识，这个标识需要通过接口发送到服务器端，服务器端推送消息到APNS时需要知道终端的标识，APNS通过注册的终端标识找到终端设备。
//    DDLogInfo(@"My token is:%@", token);
    
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    DDLogInfo(@"--%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"remote notification %@",userInfo);
}

#pragma -mark 本地通知

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(_callState == CALLSTATE_TERMED_BG)
    {
        [self getDelegate:_msg_voip];
        _callState = CALLSTATE_NONE;
        return;
    }
    
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    
    if(dwCallId == _termedCallid)
    {
        _callState = CALLSTATE_TERMED;
        _termedCallid = -1;
        return;
    }
    _callState = CALLSTATE_CALLING;

    BOOL isVideo = Mtc_CallPeerOfferVideo(dwCallId);
    
    ZCONST ZCHAR *pcPhone = Mtc_CallGetPeerName(dwCallId);
    NSString *imacct = [NSString stringWithUTF8String:pcPhone];
    EmployeeModel *emodel = [SqlAddressData queryMemberInfoWithImacct:imacct];
    NSString *headImageurl = emodel.avatarimgurl;
    
    VoIPViewController *callingViewController = [[VoIPViewController alloc] init];
    callingViewController.isIncoming = YES;
    callingViewController.isVideo = isVideo;
    callingViewController.callId = dwCallId;
    callingViewController.emodel = emodel;
    callingViewController.phoneNumber = emodel.phone;
    callingViewController.headImageUrl = headImageurl;
    [_mainVC presentViewController:callingViewController animated:YES completion:^{
    }];
    Mtc_CallAlert(dwCallId, 0, EN_MTC_CALL_ALERT_RING, ZFALSE);
    DDLogInfo(@"Mtc_CallAlert%d",dwCallId);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSString *error_str = [NSString stringWithFormat: @"%@", error];
    DDLogInfo(@"Failed to get token, error:%@", error_str);
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[CoreDataManager sharedInstance] save];
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}

#pragma mark -第三方应用认证入口
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([[url scheme] isEqualToString:@"eqi"])
    {
        NSString *appId = [url host];
        
        [[NSUserDefaults standardUserDefaults]setObject:appId forKey:@"appID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *query = [url query];
        
        if([query length] >0)
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
            NSArray *array = [query componentsSeparatedByString:@"="];
            NSString *appKey = [array objectAtIndex:1];
            DDLogInfo(@"%@",appKey);
            [[NSUserDefaults standardUserDefaults]setObject:appKey forKey:@"appkey"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [dic setValue:[array objectAtIndex:1] forKey:@"appkey"];
            
            [self application:application didFinishLaunchingWithOptions:dic];
            
            //[self uniAuthorizedLogin];

        }
        return YES;

    }
    return NO;
}

- (void)uniAuthorizedLogin
{
   
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:[LOGIN_FLAG filePathOfCaches]] || self.isChangeIp)
    {
        [self login];
        return;
        
    }
    else
    {
        UniAuthorizedViewController *authorViewControl=[[UniAuthorizedViewController alloc]initWithNibName:@"UniAuthorizedViewController" bundle:nil];
        self.window.rootViewController = authorViewControl;

    }

}


#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (alertView.tag) {
        case update_alert_tag:{
            if(!self.isForceUpDate)
            {
                if(buttonIndex == 0)
                {
                    return;
                }
            }
            
            //MWWebViewController *webViewController = [MWWebViewController new];
            //webViewController.mode = MWWebBrowserModeModal;
            //webViewController.URL = [NSURL URLWithString:self.plistURL];
            //self.window.rootViewController=webViewController;
            UIView *overView = [[UIView alloc]initWithFrame:self.window.frame];
            overView.backgroundColor = [UIColor colorWithHex:0xbebebe alpha:0.4];
            [self.window addSubview:overView];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.plistURL]];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.window];
            [self.window addSubview:HUD];
            HUD.labelText = @"正在更新...";
            [HUD show:YES];


            break;
        }
        case tidiao_alert_tag:{
            
            
            if (buttonIndex==0) {
                //重新登录
                [self loginOpenFire];
            }
            
            break;
        }
        default:
            break;
    }
    
}
#pragma mark -  hud
- (void)showWithCustomView:(NSString*)showText
                detailText:(NSString*)detailText
                     isCue:(int)isCue
                 delayTime:(CGFloat)delayTime isKeyShow:(BOOL)isKeyboardShow{
    
    if (_HUD) {
        _HUD=nil;
    }
    
    if(!_HUD)
    {
        _HUD = [[MBProgressHUD alloc] initWithView:self.window];
        [self.window addSubview:_HUD];
    }
    if(isKeyboardShow)
    {
        _HUD.yOffset = -50;
    }
    
	

	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
    if(isCue == 1)
    {
        //警告
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cue.png"]];
    }
    else if(isCue == 0)
    {
        //成功
        _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    }
	
	
	// Set custom view mode
	_HUD.mode = MBProgressHUDModeCustomView;
	_HUD.userInteractionEnabled=NO;
	_HUD.delegate = self;
	_HUD.labelText = showText;
    _HUD.detailsLabelText = detailText;
	
    [_HUD show:YES];
	[_HUD hide:YES afterDelay:delayTime];
    
    
}

-(UIImage*) imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - 音视频接入
#pragma mark - click action
- (void)loginVoipSDK:(NSString *)user
{
    NSString *host = [[NSUserDefaults standardUserDefaults]objectForKey:HTTP_VOIP];
    NSDictionary *dic = @{@"MtcServerAddressKey" : host? host:@""};
    if (_isLoginedVoip == NO) {
        if (user.length != 0) {
            ZINT ret = Mtc_Login((ZCHAR *)[user UTF8String], dic);
            if (ret == ZOK) {
                DDLogInfo(@"登录voipSDK成功");
            }
        }
    }
}

- (void)loginOutVoipSDK
{
    if(_isLoginedVoip == YES)
    {
        _isLoginedVoip = NO;
        Mtc_Logout();
    }
}

#pragma mark - UIAlertViewDelegate

#pragma mark - Notification callbacks
- (void)loginOk
{
    _isLoginedVoip = YES;
}

- (void)loginPassword
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Enter The Verferication Code" delegate:self cancelButtonTitle:@"Cancle" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)loginFailed:(NSNotification *)notification
{
    ZUINT dwStatusCode = [[notification.userInfo objectForKey:@MtcCliStatusCodeKey] unsignedIntValue];
    DDLogInfo(@"====>>loginFailed,%d",dwStatusCode);
    NowLoginUserInfo *userIfno=[ConstantObject sharedConstant].userInfo;
    [self loginVoipSDK:userIfno.imacct];

    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Login failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alertView show];
}

- (void)didLogout
{
    
}

- (void)logouted
{
    DDLogInfo(@"%@",@"音视频账号登出");
    _isLoginedVoip = NO;
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"音视频账号已在其他终端登录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alertView show];
}


@end
