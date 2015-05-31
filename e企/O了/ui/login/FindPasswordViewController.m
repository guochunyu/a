//
//  FindPasswordViewController.m
//  e企
//
//  Created by royaMAC on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "FindPasswordViewController.h"

@interface FindPasswordViewController ()<UIAlertViewDelegate>
{
     int count;
}
@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//     [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    self.MarkedWords.text=@"请填写您的手机号，我们将密码以短信的形式发送至您的手机。";
//    self.textField.text=[[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
    self.textField.text =self.userName;
    UIImageView * backImage=[[UIImageView  alloc]initWithFrame:CGRectMake(10, 30, 15, 15)];
    backImage.image=[UIImage imageNamed:@"public_btnback_titlebar_nm"];
    [self.view addSubview:backImage];
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font=[UIFont systemFontOfSize:16];
    button.frame=CGRectMake(20, 20, 80, 35);
    [button setTitleColor:[UIColor colorWithRed:3.0/255 green:115.0/255 blue:175.0/255 alpha:1] forState:UIControlStateNormal];
    [button setTitle:@"找回密码" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    UIView * lineView=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(backImage.frame) + 10, 320, 1)];
    lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    [self.view addSubview:lineView];
}
//返回按钮
-(void)backView:(UIButton*)sender
{
    //更多选项中修改密码返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)findPassword:(id)sender {
      count++;
    if (count==5) {
        SHOW_ALERT(@"操作频繁，请稍候");
        [self performSelector:@selector(resetCount) withObject:nil afterDelay:3];
        return;
    }
    if ([self.textField.text isEqualToString:@""]) {
        SHOW_ALERT(@"手机号不能为空");
        return;
    }
    if (self.textField.text.length!=11) {
        SHOW_ALERT(@"输入的手机号有误");
        return;
    }
    AFClient * client=[AFClient sharedClient];
    NSDictionary * parameters=@{@"uid":self.textField.text};
    [client postPath:@"eas/findpsd" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"success==%@",operation.responseString);
        NSDictionary *dic=[DataToDict dataToDict:responseObject];
        NSInteger status=[dic[@"status"]integerValue];
        if (status==1) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.labelText = @"正在操作...";
            [HUD showAnimated:YES whileExecutingBlock:^{
                
            } completionBlock:^{
                
                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:0 delayTime:1 isKeyShow:NO];

                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            }];
        }if (status==0) {
           // SHOW_ALERT(@"该号码不存在");
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
          
            [HUD showAnimated:YES whileExecutingBlock:^{
                
            } completionBlock:^{
                
                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:0 delayTime:1 isKeyShow:NO];
                
              
                return ;
            }];
            
            
            return ;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"error==%@",operation.responseString);

    }];
}
-(void)resetCount
{
    count=0;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textField resignFirstResponder];
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
