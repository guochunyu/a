//
//  ChangePswViewController.m
//  e企
//
//  Created by xuxue on 14/11/18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ChangePswViewController.h"
#import "AFClient.h"
#import "DesEncrypt.h"
#import "CreateHttpHeader.h"

@interface ChangePswViewController ()
{
    MBProgressHUD *_progressHUD;    ///<指示器
    NSString *headStr;
    NSInteger reqTimes;
    UIImageView*imagev;
    UILabel*label;
}

@end

@implementation ChangePswViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor colorWithHex:0xffffff alpha:1.0]];
    //将修改密码的标题隐藏
    //self.title = @"修改密码";
    reqTimes = 0;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backGroundSingleTap)];
    [self.scrollView addGestureRecognizer:singleTap];
    [singleTap setNumberOfTouchesRequired:1];//触摸点个数
    [singleTap setNumberOfTapsRequired:1];//点击次数
    self.scrollView.scrollEnabled = NO;
    
    [self eShowNavRightButtonMethod];
//    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_icon_back.@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];    leftBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBtn;
    //将修改密码中得确定按钮改为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 90, 20);
    label.text = @"修改密码";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:label];
}

-(void)backView{
    //更多选项中修改密码返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated
{
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    //注册键盘显示通知
    [center addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //注册键盘隐藏通知
    [center addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - 显示导航栏右边按钮
- (void)eShowNavRightButtonMethod
{
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(changePsw:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

-(void)viewDidLayoutSubviews{
    
    if (!IS_Height_4) {
        
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 100);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 64);
    }

}

#pragma mark - 通知
#pragma mark 键盘显示时调用
- (void)keyBoardWillShow:(NSNotification *)notification
{
    self.scrollView.scrollEnabled = YES;
    DDLogInfo(@"键盘出来时调用");
}

#pragma mark 键盘隐藏时调用
- (void)keyBoardWillHidden:(NSNotification *)notification
{
    CGPoint newOffset = self.scrollView.contentOffset;
    newOffset.y = 0;
    [self.scrollView setContentOffset:newOffset animated:YES];
    self.scrollView.scrollEnabled = NO;
}

#pragma mark - 键盘return
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)changePsw:(id)sender
{
    [self backGroundSingleTap];
    if(![self isValidPsw])
    {
        return;
    }
    NSString *oPsd = [DesEncrypt encryptWithText:_text_oldPsw.text];
    DDLogInfo(@"%@",oPsd);
    NSString *nPsd = [DesEncrypt encryptWithText:_text_newPsw.text];
    DDLogInfo(@"%@",nPsd);
    NSString *rPsd = [DesEncrypt encryptWithText:_text_reNewPsw.text];
    DDLogInfo(@"%@",rPsd);
   // NSString *depsw = [DesEncrypt decryptWithText:rPsd];
   // DDLogInfo(@"%@",depsw);
    NSDictionary *dict=@{@"oPsd": oPsd,
                         @"nPsd": nPsd,
                         @"rPsd": rPsd};
    reqTimes ++;
    AFClient *client = [AFClient sharedClient];
    NSString *groupcode = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];

    [client postPath:[NSString stringWithFormat:@"eas/updatepsd?gid=%@&cid=%@",groupcode,cid]parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        DDLogInfo(@"userinforData===%@",operation.responseString);
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        DDLogInfo(@"dic====%@",dic);
        
        if([[dic objectForKey:@"status"]integerValue] == 1)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:[dic objectForKey:@"msg"] message:@"请重新登录和企录" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        else
        {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:1 delayTime:1 isKeyShow:NO];

        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSInteger stateCode = operation.response.statusCode;
        DDLogInfo(@"%d",stateCode);
        if(stateCode == 401 && reqTimes <= 10)
        {
            NSDictionary *ddd=operation.response.allHeaderFields;
            if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                NSString *nonce=[ddd objectForKey:@"Www-Authenticate"];
                headStr = [CreateHttpHeader createHttpHeaderWithNoce:nonce];
                NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
                [client setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
                
                [self changePsw:sender];
                
            }
        }else
        {
            reqTimes = 0;
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"修改密码失败!" isCue:1 delayTime:1 isKeyShow:NO];
            [_progressHUD hide:YES];
            
        }
    }];
}

- (BOOL)isValidPsw
{
    BOOL isValidPsw = YES;
    if([_text_oldPsw.text length] == 0)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请输入当前密码" isCue:1 delayTime:1 isKeyShow:NO];
        isValidPsw = NO;
    }else if([_text_newPsw.text length] == 0 | [_text_reNewPsw.text length] == 0)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请输入新密码" isCue:1 delayTime:1 isKeyShow:NO];
        isValidPsw = NO;

    }
    else if([_text_oldPsw.text isEqualToString:_text_newPsw.text])
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"新密码不能与旧密码相同" isCue:1 delayTime:1 isKeyShow:NO];
        isValidPsw = NO;
        
    }else if(![_text_newPsw.text isEqualToString:_text_reNewPsw.text])
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"两次输入的新密码不一致" isCue:1 delayTime:1 isKeyShow:NO];
        isValidPsw = NO;
    }
    
    return isValidPsw;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //关闭推送计数
    [[QFXmppManager shareInstance]closeMessageCount];

    //要把openfire下线
    [[QFXmppManager shareInstance] goOffline];
//  更新一次可见性表
    [SqlAddressData deleteLeadertable];
    [SqlAddressData deleteVisilityContact];
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:keyWindow];
    [keyWindow addSubview:HUD];
    HUD.labelText = @"正在退出登录...";
    [HUD showAnimated:YES whileExecutingBlock:^{
        [[ConstantObject sharedConstant] releaseAllValue];
        [[AFClient sharedClient] releaseAFClient];
        
        [[SqliteDataDao sharedInstanse] releaseData];
        [SqlAddressData releaseDataQueue];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:myGID];
        //       删除登录标识
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[LOGIN_FLAG filePathOfCaches] error:nil];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:myPassWord];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:JSSIONID];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MyUserInfo];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MOBILEPHONE];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[QFXmppManager shareInstance] releaseXmppManager];
    } completionBlock:^{
        AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
        [app login];
    }];
    
}


- (void)backGroundSingleTap
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
