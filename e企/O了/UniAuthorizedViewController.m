//
//  UniAuthorizedViewController.m
//  e企
//
//  Created by 许学 on 14/12/7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UniAuthorizedViewController.h"
#import "LoginViewController.h"
#import "NSData+Base64.h"
#import "CrypoUtil.h"
#import "AppDelegate.h"


@interface UniAuthorizedViewController ()
{
    NSString *nonce;
    NSInteger reqTimes;
    MBProgressHUD *_progressHUD;    ///<指示器
}

@end

@implementation UniAuthorizedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    reqTimes = 0;
    [self uniAuthor];
}

- (void)uniAuthor
{
    //初始化指示器
    if (!_progressHUD) {
        _progressHUD=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _progressHUD.detailsLabelText=@"认证中...";
    }
    
    _progressHUD.removeFromSuperViewOnHide=YES;
    

    NSString *passWord = [[NSUserDefaults standardUserDefaults]objectForKey:myPassWord];
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
    
    NSString *passMd5=[CrypoUtil md5:passWord];
    NSData *strData=[passMd5 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Md5=[strData base64EncodedString];
    NSString *md5Str=[NSString stringWithFormat:@"%@%@%@",nonce,phoneNum,base64Md5];
    
    NSString *md5Str_1=[CrypoUtil md5:md5Str];
    NSString *headStr=[[md5Str_1 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    
    reqTimes ++;
    AFClient *afClicent=[AFClient sharedClient];
    NSDictionary *dict;
    if (nonce) {
        [afClicent setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
        NSString *appkey = [[NSUserDefaults standardUserDefaults]objectForKey:@"appkey"];
        NSString *groupcode = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
        NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];
        dict=@{@"appkey": appkey,
               @"groupcode":groupcode,
               @"cid":cid};
        
    }
    else{
        NSString *appkey = [[NSUserDefaults standardUserDefaults]objectForKey:@"appkey"];
        NSString *groupcode = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
        NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];
        dict=@{@"appkey": appkey,
               @"groupcode":groupcode,
               @"cid":cid};
        
    }
    [afClicent postPath:@"eas/login" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic=[DataToDict dataToDict:responseObject];
        DDLogInfo(@"JSON: %@", operation.responseString);
        DDLogInfo(@"%@",dic);
        NSString *tokenid = [[dic objectForKey:@"uinfo"]objectForKey:@"tokenid"];
        DDLogInfo(@"%@",tokenid);
        
        if(tokenid == nil && reqTimes < 10)
        {
            NSDictionary *ddd=operation.response.allHeaderFields;
            DDLogInfo(@"ddd==%@",ddd);
            if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                nonce=[ddd objectForKey:@"Www-Authenticate"];
            }
            //            NSString *SetCookieStr=[ddd objectForKey:@"Set-Cookie"];
            //            NSArray *tempArray=[SetCookieStr componentsSeparatedByString:@";"];
            //            NSString *ssionId=tempArray[0];
            //            DDLogInfo(@"ssionId====%@",ssionId);
            [self uniAuthor];

        }
        else
        {
            if(tokenid == nil)
            {
                reqTimes = 0;
                [_progressHUD hide:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"认证失败!" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                return ;

            }
            reqTimes = 0;
            [_progressHUD hide:YES];

            NSString *appid = [[NSUserDefaults standardUserDefaults]objectForKey:@"appID"];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://eqi/?tokenid=%@&easip=%@",appid,tokenid,HTTP_IP]];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"认证成功!" isCue:0 delayTime:0 isKeyShow:NO];
            
            sleep(2);
            
            [(AppDelegate*)[UIApplication sharedApplication].delegate login];

            if([[UIApplication sharedApplication]canOpenURL:url])
            {
                [[UIApplication sharedApplication]openURL:url];
            }
            else
            {
                reqTimes = 0;
                [_progressHUD hide:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"跳转应用失败!" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];

            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSInteger stateCode = operation.response.statusCode;
        DDLogInfo(@"%d",stateCode);
        if(stateCode == 401 && reqTimes < 10)
        {
            NSDictionary *ddd=operation.response.allHeaderFields;
            DDLogInfo(@"ddd==%@",ddd);
            if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                nonce=[ddd objectForKey:@"Www-Authenticate"];
            }
            //            NSString *SetCookieStr=[ddd objectForKey:@"Set-Cookie"];
            //            NSArray *tempArray=[SetCookieStr componentsSeparatedByString:@";"];
            //            NSString *ssionId=tempArray[0];
            //            DDLogInfo(@"ssionId====%@",ssionId);
            [self uniAuthor];
            
        }
        else
        {
            reqTimes = 0;
            [_progressHUD hide:YES];

            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"认证失败!" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [(AppDelegate*)[UIApplication sharedApplication].delegate login];
   // [self removeFromParentViewController];
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
