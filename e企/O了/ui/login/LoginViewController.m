//
//  UILoginViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-1-7.
//  Copyright (c) 2014年 royasoft. All rights reserved.
//

#define ROOT_PASSWORD @"jsydoa1234"
#define SUCCESS @"登录成功" //登录成功

#define EXIST @400      //已存在
#define VIEW_TAG 99 //登录区域的Tag


#import "LoginViewController.h"
#import "FindPasswordViewController.h"

#import "sys/utsname.h"

//#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import "FMDatabase.h"
#import "Keychain.h"
#import "ZipArchive.h"

#import "NSString+FilePath.h"


#import "AFClient.h"
#import "NSData+Base64.h"
#import "CrypoUtil.h"
#import "DataModels.h"
#import "EdData.h"
#import "CustomSelectView.h"

#import "mobileSDK.h"

@interface LoginViewController ()<UITextFieldDelegate,CustomSelectViewDelegate,UIAlertViewDelegate>{
    MBProgressHUD *_progressHUD;    ///<指示器
    
    NSString *_dynamicPhone;        ///<获取动态密码的手机号
    NSString *_dynamicPwd;          ///<动态密码
    LoginWaitView *wait;
    
    BOOL isKeyShow;//是否有键盘
    
    //  用来接受返回的登录信息
    NSDictionary *loginUserInfo;
    NSString *jsessionid;
    NSString * nonce;
    CustomSelectView * view;
    NSArray *moreCidArray;
    NSArray *moreGidArray;
}
@end

@implementation LoginViewController
#pragma mark - 生命周期
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [mobileSDK endActivityWithClassName:[NSString stringWithUTF8String:object_getClassName(self)]];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [wait removeFromSuperview];
    wait=nil;
}
- (void)viewWillAppear:(BOOL)animated
{
    [mobileSDK startActivityWithClassName:[NSString stringWithUTF8String:object_getClassName(self)]];
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    //注册键盘显示通知
    [center addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //注册键盘隐藏通知
    [center addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    if([ConstantObject app].isSwitchEnterPrise)
    {
        [self Login:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"7_bg.png"]]];
    self.txtPhone.layer.masksToBounds = YES;
    self.txtPhone.layer.cornerRadius = 5;
    self.txtPassword.layer.masksToBounds = YES;
    self.txtPassword.layer.cornerRadius= 5;
    self.ZYlabel.frame = CGRectMake((self.view.frame.size.width-92)/2, self.view.frame.size.height-35, 92, 21);
    [self.btnLogin setBackgroundImage:[UIImage imageNamed:@"7_login_btn_nm.png"] forState:UIControlStateNormal];
    [self.btnLogin setBackgroundImage:[UIImage imageNamed:@"7_login_btn_click.png"] forState:UIControlStateHighlighted];

    NSString *logourl = [[NSUserDefaults standardUserDefaults]objectForKey:@"logoURL"];
    self.centerLogo.layer.masksToBounds = YES;
    self.centerLogo.layer.cornerRadius = 3;
    
    [self.centerLogo setImageWithURL:[NSURL URLWithString:logourl] placeholderImage:[UIImage imageNamed:@"qinghai_7_logo"]];
    
    if (IS_IOS_7) {
        [[UINavigationBar appearance]setBarStyle:UIBarStyleDefault];
        [[UINavigationBar appearance]setBarTintColor:[UIColor blackColor]];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
//    NSMutableDictionary *userNameDict = (NSMutableDictionary *)[Keychain load:KEY_USER_NAME_IN_KEYCHAIN];
//    NSString *userName=[userNameDict objectForKey:KEY_USERNAME];
    NSString *userName=[[NSUserDefaults standardUserDefaults] objectForKey:myLastLoginUser];
    if (userName.length>0) {
        self.txtPhone.text=userName;
    }
//    if (self.txtPhone.text.length>0) {
//        self.btnGetPassword.enabled=YES;
//    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[LOGIN_FLAG filePathOfCaches]]) {
        //登录过
         [self Login:nil];
    }
    
    AppDelegate *loginApp=[ConstantObject app];
    loginApp.loginOpenFireState=^(BOOL rec){
        if (!rec) {
            //登录失败
            [self LoginFailure:@"用户名或密码错误"];
            DDLogInfo(@"%@",@"登录openfire失败");
        }else{
            [_progressHUD hide:YES];
        }
    };

}
-(void)restart{
    if(wait){
        [wait restart];
    }else{
        DDLogCInfo(@"没有加载动画");
    }

}
-(void)stop{
    if(wait){
        [wait removeFromSuperview];
        wait=nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark 资源销毁
- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
#pragma mark 监听View点击事件
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:NO];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [view removeFromSuperview];
    self.view.alpha=1.0;
    _progressHUD.hidden=YES;
    _progressHUD=nil;
}
#pragma mark - 通知
#pragma mark 键盘显示时调用
- (void)keyBoardWillShow:(NSNotification *)notification
{
    isKeyShow=YES;
    //获取LoginArea的视图
    UIView *LoginArea=[self.view viewWithTag:VIEW_TAG];
    //获取LoginArea的Rect
    CGRect loginAreaRect=LoginArea.frame;
    //键盘Rect
    CGRect keyBoardRect=[[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    //偏移量
    CGFloat distance=keyBoardRect.origin.y-(loginAreaRect.origin.y+loginAreaRect.size.height);
    if (distance<0) {
        [self animationWithUserInfo:notification.userInfo bloack:^{
            if (self.view.frame.size.height == 480) {
                self.view.transform=CGAffineTransformTranslate(self.view.transform, 0, distance - 20);
                
            }
            else{
                self.ZYlabel.transform=CGAffineTransformTranslate(self.ZYlabel.transform, 0, distance);
                self.view.transform=CGAffineTransformTranslate(self.view.transform, 0, distance);
            }
//            self.ZYlabel.transform = CGAffineTransformTranslate(self.ZYlabel.transform, 0, distance);
        }];
    }
    
}
#pragma mark 键盘隐藏时调用
- (void)keyBoardWillHidden:(NSNotification *)notification
{
    isKeyShow=NO;
    [self animationWithUserInfo:notification.userInfo bloack:^{
        self.view.transform=CGAffineTransformIdentity;
        self.ZYlabel.transform = CGAffineTransformIdentity;
    }];

}
#pragma mark 键盘动画
- (void)animationWithUserInfo:(NSDictionary *)userInfo bloack:(void (^)(void))block
{
    // 取出键盘弹出的时间
    CGFloat duration=[userInfo[UIKeyboardAnimationDurationUserInfoKey]floatValue];
    // 取出键盘弹出动画曲线
    NSInteger curve=[userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
    //开始动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    //调用bock
    block();
    [UIView commitAnimations];
}
#pragma mark - delegate
#pragma mark textField的委托事件 是否允许修改
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL result=YES;
    if (textField.tag==100&&textField.text.length==11&&range.length!=1) {
        result=NO;
    }
    return result;
}
#pragma mark textField 键盘return事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag==200&&![self.txtPhone.text isEqualToString:@""]&&![self.txtPassword.text isEqualToString:@""]) {
        [self Login:nil];
    }
    return YES;
}
#pragma mark - target调用方法

#pragma mark 找回密码

- (IBAction)getPassword:(UIButton *)sender {
    //    [self.view endEditing:YES];
    FindPasswordViewController * passVC=[[FindPasswordViewController alloc]init];
    passVC.userName=self.txtPhone.text;
//    DDLogInfo(@"用户名:===%@",self.txtPhone.text);
    [self presentViewController:passVC animated:YES completion:nil];
}

#pragma mark -----登录

int login_count =0;//重复获取id次数

- (IBAction)Login:(id)sender {
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    
//    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@".image11"];
//    if ([fileManager fileExistsAtPath:fullPath]) {
//        [fileManager removeItemAtPath:fullPath error:nil];
//    }
    NSString *phoneNum;
    NSString *password;
    
    if([ConstantObject app].isSwitchEnterPrise)
    {
        phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
        password = [[NSUserDefaults standardUserDefaults]objectForKey:myPassWord];
        //[ConstantObject app].isSwitchEnterPrise = NO;
    }else
    {
        
        if (self.txtPhone.text.length!=11) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请输入正确的手机号！" isCue:1 delayTime:1 isKeyShow:NO];
            return;
        }
        
        //结束textfile编辑
        
        //用户名及密码
        phoneNum=self.txtPhone.text;
        password=self.txtPassword.text;
        if ([phoneNum isEqualToString:@""]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"用户名不能为空" isCue:1 delayTime:1 isKeyShow:NO];
            return;
        }
        if ([password isEqualToString:@""]) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"密码不能为空" isCue:1 delayTime:1 isKeyShow:NO];
            return;
        }
        
        [self.view endEditing:YES];
        [[NSUserDefaults standardUserDefaults] setObject:phoneNum forKey:MOBILEPHONE];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[[ConstantObject app] checkUpDate];
        });
        
        if (!_progressHUD) {
            _progressHUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _progressHUD.detailsLabelText=@"登录中";
        }
        
        _progressHUD.removeFromSuperViewOnHide=YES;
        
    }

    NSString *passMd5=[CrypoUtil md5:password];
    NSData *strData=[passMd5 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Md5=[strData base64EncodedString];
    NSString *md5Str=[NSString stringWithFormat:@"%@%@%@",nonce,phoneNum,base64Md5];
    
    NSString *md5Str_1=[CrypoUtil md5:md5Str];
    NSString *headStr=[[md5Str_1 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];

    AFClient *afClicent=[AFClient sharedClient];
    
    if (nonce) {
        [afClicent setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
    }else{
        //处理通讯录串号的问题
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:LATESTUPDATETIME];
        //删除原来的cookies
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [storage cookies];
        for (NSHTTPCookie *cookie in cookies) {
            [storage deleteCookie:cookie];
        }
    }
    
    [afClicent postPath:@"eas/login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        login_count=0;
        
        
        NSDictionary *dic=[DataToDict dataToDict:responseObject];
        NSLog(@"---------------%@",dic);
        
        loginUserInfo=dic;
        DDLogInfo(@"JSON: %@", operation.responseString);
        if (dic[@"uinfo"]) {
            moreCidArray=dic[@"uinfo"][@"cid"];
            moreGidArray=dic[@"uinfo"][@"gid"];
            [[NSUserDefaults standardUserDefaults] setObject:moreGidArray forKey:myLoginUserInfo];

           // DDLogInfo(@"%@",dic);
            if (moreGidArray.count>1) {
                __block typeof(self) myself=self;
                view=[[CustomSelectView alloc]initWithTitle:@"选择所在企业" delegate:myself data:dic];
                view.center=self.view.center;
                [view show];
                self.view.alpha=0.5;
            }else{
                CGRect rx = [ UIScreen mainScreen ].bounds;
                //初始化指示器
                wait=[[LoginWaitView alloc] initWithFrame:rx];
                [self.view addSubview:wait];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:phoneNum forKey:MOBILEPHONE];
        [[NSUserDefaults standardUserDefaults] setObject:phoneNum forKey:myLastLoginUser];
        //存储密码
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:myPassWord];
        [ConstantObject app].isSwitchEnterPrise = NO;
        [self LoginAlert:dic];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        login_count++;
        
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                jsessionid=cookie.value;
                [[NSUserDefaults standardUserDefaults]setObject:jsessionid forKey:JSSIONID];
                [[NSUserDefaults standardUserDefaults]synchronize];
             }
        }
        NSDictionary *ddd=operation.response.allHeaderFields;
        DDLogInfo(@"ddd==%@",ddd);
        if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
            nonce=[ddd objectForKey:@"Www-Authenticate"];
        }
//            NSString *SetCookieStr=[ddd objectForKey:@"Set-Cookie"];
//            NSArray *tempArray=[SetCookieStr componentsSeparatedByString:@";"];
//            NSString *ssionId=tempArray[0];
//            DDLogInfo(@"ssionId====%@",ssionId);
        if (error && login_count<5) {
            [self Login:sender];
        }else{
            [afClicent releaseAFClient];
            nonce=nil;
            login_count=0;
            [ConstantObject app].isSwitchEnterPrise = NO;
            [_progressHUD hide:YES];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        }
    }];

    

}
//回调方法
- (void)myAlertView:(CustomSelectView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSInteger index=buttonIndex-100-1;
    DDLogInfo(@"%d",index);
    
    [self getMineInfoWithGid:moreGidArray[index] cid:moreCidArray[index]];
    
    NSString *logoUrl = [[[loginUserInfo objectForKey:@"uinfo"]objectForKey:@"clogo"]objectAtIndex:index];
  
    NSString * cname = [[[loginUserInfo objectForKey:@"uinfo"]objectForKey:@"cname"]objectAtIndex:index];
    [[NSUserDefaults standardUserDefaults]setObject:cname forKey:USERCOMPANY];
           DDLogInfo(@"%@----",logoUrl);
    if (![logoUrl isEqual:[NSNull null]]) {
         [[NSUserDefaults standardUserDefaults]setObject:logoUrl forKey:@"logoURL"];
    }

    [[NSUserDefaults standardUserDefaults]synchronize];

    [view removeFromSuperview];
    self.view.alpha=1.0;
    CGRect rx = [ UIScreen mainScreen ].bounds;
    //初始化指示器
    wait=[[LoginWaitView alloc] initWithFrame:rx];
    [self.view addSubview:wait];
}
#pragma mark-获得个人信息
-(void)getMineInfoWithGid:(NSString *)gid cid:(NSString *)cid
{
    [[NSUserDefaults standardUserDefaults]setObject:gid forKey:myGID];
    [[NSUserDefaults standardUserDefaults] setObject:cid forKey:myCID];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSDictionary *dict=@{@"cid": cid?cid:@"",
                         @"gid":gid?gid:@"",
                         @"version": nowVersion?nowVersion:@""};
//    NSMutableArray * userArray=[NSMutableArray arrayWithCapacity:0];
    AFClient * client=[AFClient sharedClient];
    [client postPath:@"eas/userinfo" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"userinforData===%@",operation.responseString);
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        DDLogInfo(@"dic====%@",dic);

//        NSString * msg=dic[@"msg"];
//        if ([msg isEqualToString:@"获取个人信息失败"]) {
//            [self LoginFailure:@"获取个人信息失败"];
//        }
//        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
//        [userDefaults setObject:dic forKey:MyUserInfo];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//         self.blockEnterMain();
        
        NSString *status = [dic objectForKey:@"status"];
        if([status integerValue] == 0)
        {
            NSString *msg = [dic objectForKey:@"msg"];
            [self LoginFailure:msg];

        }
        else
        {
            [[dic objectForKey:@"data"]setObject:gid forKey:@"gid"];
            NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
            [userDefaults setObject:dic forKey:MyUserInfo];
            [ConstantObject sharedConstant].userInfo=[[NowLoginUserInfo alloc] initWithDictionary:dic];
            DDLogInfo(@"%@",[ConstantObject sharedConstant].userInfo.imacct);
            [[NSUserDefaults standardUserDefaults] synchronize];
            
             self.blockEnterMain();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"获取个人信息失败");
        [self LoginFailure:@"登录失败,错误的用户名或密码"];
    }];
    
}
#pragma mark - 网络调用
#pragma mark 正常连接
- (void)LoginAlert:(id)JSON
{
    if(JSON[@"uinfo"]){
        
//        NSString *phoneNum=self.txtPhone.text;
//        存用户名
//        NSMutableDictionary *keyChainDict=[NSMutableDictionary dictionary];
//        [keyChainDict setObject:phoneNum forKey:KEY_USERNAME];
//        [Keychain save:KEY_USER_NAME_IN_KEYCHAIN data:keyChainDict];
        
        //userdefaults设置
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        //提醒设置
        if ([userDefaults objectForKey:REMIND_MSG]==nil) {
            [userDefaults setBool:YES forKey:REMIND_MSG];//消息提醒
            [userDefaults setBool:YES forKey:REMIND_SOUND];//声音
            [userDefaults setBool:YES forKey:REMIND_SHAKE];//振动
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:22*60] forKey:NO_DISTURB_STARTTIME];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:8*60] forKey:NO_DISTURB_ENDTIME];
            
//            [userDefaults setObject:NO_DISTURB_ONLY_NIGHT forKey:@"noDisturbFlag"];
        }
        [userDefaults synchronize];
        
        
        NSArray *cidArray=JSON[@"uinfo"][@"cid"];
        NSArray *gidArray=JSON[@"uinfo"][@"gid"];
        if (gidArray.count==1) {
            NSString * cname = [[[JSON objectForKey:@"uinfo"]objectForKey:@"cname"]objectAtIndex:0];
            [[NSUserDefaults standardUserDefaults]setObject:cname forKey:USERCOMPANY];
            //单企业直接获取个人信息
            DDLogInfo(@"%@*****%@",cidArray,gidArray);
            [self getMineInfoWithGid:gidArray[0] cid:cidArray[0]];
        }
    }else{
//        [_progressHUD hide:YES afterDelay:1];
        [self LoginFailure:@"用户名或密码错误"];
    }

}

#pragma mark 连接异常
- (void)LoginFailure:(NSString *)failMessage
{
    [[AFClient sharedClient] releaseAFClient];
    nonce=nil;
    _progressHUD.detailsLabelText=failMessage;
    _progressHUD.mode=MBProgressHUDModeText;
    _progressHUD.userInteractionEnabled=NO;
    [_progressHUD hide:YES afterDelay:1];
    _progressHUD=nil;
}
#pragma mark 常用联系人获取

#pragma mark 服务号数据获取

#pragma mark 获取服务号菜单信息

@end
