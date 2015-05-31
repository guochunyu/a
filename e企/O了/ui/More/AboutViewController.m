//
//  AboutViewController.m
//  e企
//
//  Created by 许学 on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "AboutViewController.h"
#import "FeedBackViewController.h"
#define update_alert_tag 21//更新
#define exit_alert_tag 20//退出登录



@interface AboutViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *yiqiImageView;
@property (nonatomic, strong)UIImageView *imagev;
@property (nonatomic, strong)UILabel *label;





@end

@implementation AboutViewController
NSDictionary *dic;


-(void)viewWillAppear:(BOOL)animated{

    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    dic = [[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
    // Do any additional setup after loading the view from its nib.
    //将关于标题隐藏
    //self.title = @"关于";
//    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"7_bg.png"]];
    NSString * versionNum =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * buildNum = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleVersion"];
    
    NSString *bundleIdentify = [[NSBundle mainBundle]bundleIdentifier];
    NSString *stageStr=@"";
    if ([[HTTP_IP pathExtension] isEqualToString:@"42"]) {
        stageStr=@"stage ";
    }
    
    NSString *text =[NSString stringWithFormat:@"当前版本 (%@%@-%@)",stageStr, versionNum, buildNum];
    _label_version.text = text;
    [_label_version setFont:[UIFont systemFontOfSize:14]];
 //   _label_version.textColor = [UIColor colorWithHex:0x36B0E2];
    //添加返回按钮
//    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_icon_back.@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    leftBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _imagev = [[UIImageView alloc]init];
    _imagev.frame = CGRectMake(3, 30, 25, 25);
    [_imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:_imagev];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(25, 32, 90, 20);
    _label.text = @"关于";
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:_label];
    
    _imagev.hidden = NO;
    _label.hidden = NO;
}

-(void)backView{
    //更多选项中关于返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
         //[self checkUpDate];
    }
    else if(indexPath.row == 1){
        FeedBackViewController *feedbackVC = [[FeedBackViewController alloc]init];
        feedbackVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:feedbackVC animated:YES];
    }
    _imagev.hidden = YES;
    _label.hidden = YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    numberOfRows = 2;
    return numberOfRows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIndertifier = @"cell";
    UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndertifier];
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIndertifier];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"检查更新";
        }
        else if (indexPath.row == 1){
            cell.textLabel.text = @"意见反馈";
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;

}






- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger numberOfSections = 0;
    numberOfSections = 1;
    return numberOfSections;
}

#pragma mark - checkUpdate

- (void)checkUpDate
{
    NSString *mybuild = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    BOOL isgray;
    //判断是否为开发者版
    isgray = NO;
    
    NSDictionary * dic_info=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
    DDLogInfo(@"dict=%@",dic_info);
    NSString * uid=[dic[@"data"] isKindOfClass:[NSDictionary class]]?(dic[@"data"][@"uid"]):@"";
    
    NSDictionary *dict=@{@"build": mybuild,
                         @"isgray": isgray? @"1":@"0",
                         @"imei": uid};
    
    //NSDictionary *dict=@{@"build": [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],
    //                     @"imei": [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE]};
    
    AFClient * client=[AFClient sharedClient];
    [client getPath:@"eas/appcheck" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"userinforData===%@",operation.responseString);
        NSDictionary * dic_check=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        DDLogInfo(@"dic====%@",dic_check);
        if([[dic_check objectForKey:@"status"]integerValue] == 1)
        {
            NSDictionary *dataDic = [dic_check objectForKey:@"data"];
            NSString *build = [dataDic objectForKey:@"build"];
            if([build integerValue] <= [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]integerValue])
            {
                //                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"当前已是最新版本" isCue:0 delayTime:1 isKeyShow:NO];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"当前已是最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [self.tableView reloadData];

                [alertView show];
            }
            else
            {
                NSString *fileURL = [dataDic objectForKey:@"fileurl"];
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

                if(fileURL){
                    self.plistUrl = [NSString stringWithString:fileURL];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"和企录版本更新" message:updateDesc delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"立即更新", nil];
                    [alertView show];
                    alertView.tag = update_alert_tag;
                }
            }
        }
        else
        {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:1 delayTime:1 isKeyShow:NO];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"检测更新失败" isCue:1 delayTime:1 isKeyShow:NO];
    }];
    
}
#pragma --mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (alertView.tag) {
        case update_alert_tag:{
            
            if(buttonIndex == 0)
            {
                [alertView removeFromSuperview];
                return;
            }
            UIView *overView = [[UIView alloc]initWithFrame:self.view.window.frame];
            overView.backgroundColor = [UIColor colorWithHex:0xbebebe alpha:0.4];
            [self.view.window addSubview:overView];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.plistUrl]];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
            [self.view.window addSubview:HUD];
            HUD.labelText = @"正在更新...";
            [HUD show:YES];
            
            break;
        }
        case exit_alert_tag:{
            //
            if (buttonIndex==0) {
                [alertView removeFromSuperview];
            }
            break;
        }
        default:
            break;
            
    }
    
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
