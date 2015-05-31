
//
//  MainViewController.m
//  ConglomerateWeiChart
//
//  Created by 化召鹏 on 13-12-26.
//  Copyright (c) 2013年 化召鹏. All rights reserved.
//

#import "MainViewController.h"
#import "ContactsViewController.h"
#import "MoreMineViewController.h"
#import "HuiyiDetailViewController.h"


#import "SMSViewController.h"
#import "MailActRouter.h"
#import "AppDelegate.h"
#import "MailActController.h"
#import "FeedBackViewController.h"
#import "AboutViewController.h"
#import "AboutViewController.h"
#import "ChangePswViewController.h"
#import "NotifyViewController.h"

#import "H5ViewController.h"

#import "MainNavigationCT.h"
#import "ContactsViewController.h"

#import "ServiceNumberAllListViewController.h"

#import "VisibilityContactModel.h"

#import "ServiceNumberWebViewController.h"

#import "AFClient.h"

#import "ZipArchive.h"

#import "UIImage+Tint.h"
#import "JSONKit.h"
#import "SqlAddressData.h"
#import "SqlLiteCreate.h"
#import "PersonInfoViewController.h"
#import "TaskTools.h"
#import "HuiyiViewController.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "MoreMineViewController.h"
#import "Download.h"
#import "UIImageView+WebCache.h"
//动画持续时间，该时间与压栈和出栈时间相当
#define SLIDE_ANIMATION_DURATION 0.2

#define self_viewController_tag 10
#define left_viewController_tag 11

static int unReadCount = 0;

#define adress_update_tag 101
#define moa_down_tag 102

@interface MainViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,DownloadDelegate>
{
    __weak IBOutlet UIView *Navigation_View;
    NSDate * dateBegin;
    NSDate * dateEnd;
    __weak IBOutlet UIView *viewLine;
    CTCallCenter *_center;
    __weak IBOutlet UIButton *File_Transfer;
    __weak IBOutlet UIButton *Video_call;
}
@property(nonatomic,strong) UINavigationController *huiyiController;
//@property(nonatomic,strong)UIViewController *currentViewController;
@property (nonatomic) MailActRouter *mailActRouter;

@property (nonatomic, strong)NSString *string;
@end

@implementation MainViewController
@synthesize viewControllers = _viewControllers;
@synthesize seletedIndex = _seletedIndex;
@synthesize previousNavViewController = _previousNavViewController;
@synthesize isiOSInCall = _isiOSInCall;


- (void)dealloc{
    //消息的通知
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    [center removeObserver:self name:@"test" object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _seletedIndex = -1;
        _center = [[CTCallCenter alloc] init];
        __weak MainViewController* weakSelf = self;
        _center.callEventHandler = ^(CTCall *call){
            DDLogInfo(@"current iOS Call State is %@", call.callState);
            if ([call.callState isEqualToString:CTCallStateConnected]
                || [call.callState isEqualToString:CTCallStateIncoming]
                || [call.callState isEqualToString:CTCallStateDialing])
            {
                weakSelf.isiOSInCall = YES;
            }
            else
            {
                weakSelf.isiOSInCall = NO;
            }
        };
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:56.0/255.0 green:108.0/255.0 blue:191.0/255.0 alpha:1.0];
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Huiyi" bundle:nil];
    _huiyiController=  [sb instantiateViewControllerWithIdentifier:@"huiyiNavigation"];
    
//    File_Transfer.imageView.image = [[UIImage imageNamed:@"icon_document.png"]imageWithTintColor:[UIColor blackColor]];
//    
//    Video_call.imageView.image = [[UIImage imageNamed:@"icon_vedio_small@3x.png"]imageWithTintColor:[UIColor blackColor]];
    
    _scrllView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 66, 320, 150)];
    //设置背景颜色
    _scrllView.backgroundColor = [UIColor clearColor];
    //分页效果
    _scrllView.pagingEnabled = YES;
    _scrllView.delegate = self;
    _scrllView.contentSize = CGSizeMake(SCREEN_WIDTH*4, 150);
    _scrllView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrllView];
    Download *down=[[Download alloc]initWithURLString:[NSString stringWithFormat:@"http://%@/eas/ads",HTTP_IP]];
    down.delegate=self;
    /*float _x = 0;
    for (_i = 1; _i<=5; _i++)
    {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0+_x, 20, 320, 180)];
        _imageName = [NSString stringWithFormat:@"beijing%d.jpg",_i];
        _imageView.image = [UIImage imageNamed:_imageName];
        _imageView.userInteractionEnabled = YES;
        [_scrllView addSubview:_imageView];
        _x+=320;
        
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        tap.delegate = self;
        
        UITapGestureRecognizer*tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1:)];
        tap1.numberOfTapsRequired = 1;
        tap1.numberOfTouchesRequired = 1;
        tap1.delegate = self;
        
        UITapGestureRecognizer*tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)];
        tap2.numberOfTapsRequired = 1;
        tap2.numberOfTouchesRequired = 1;
        tap2.delegate = self;
        
        UITapGestureRecognizer*tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap3:)];
        tap3.numberOfTapsRequired = 1;
        tap3.numberOfTouchesRequired = 1;
        tap3.delegate = self;
        
        UITapGestureRecognizer*tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap4:)];
        tap4.numberOfTapsRequired = 1;
        tap4.numberOfTouchesRequired = 1;
        tap4.delegate = self;
        
        if (_i==1) {
            [_imageView addGestureRecognizer:tap];
            
        }else if (_i==2){
            [_imageView addGestureRecognizer:tap1];
        }else if (_i==3){
            [_imageView addGestureRecognizer:tap2];
        }else if (_i==4){
            [_imageView addGestureRecognizer:tap3];
        }else if (_i==5){
            [_imageView addGestureRecognizer:tap4];
        }
       

    }
     */
    //设置点
    _pagControl = [[UIPageControl alloc]initWithFrame:CGRectMake(108, 190, 320, 30)];
    _pagControl.numberOfPages = 4;
    //设置点颜色
    //pagControl.pageIndicatorTintColor = [UIColor orangeColor];
    _pagControl.tag = 101;
    [self.view addSubview:_pagControl];
    
    
    
    
    viewLine.frame = CGRectMake(0, 0, self.view.frame.size.width, 0.5f);
    
    //    //   创建数据库
    //    [SqlLiteCreate getDataBase];
    //    //   创建个人信息表
    //    [SqlAddressData createPersoninfoTable];
    //    //   创建部门关系表
    //    [SqlAddressData createBranchTable];
    //    //   创建常用联系人表
    //    [SqlAddressData createCommenContact];
    //    //   创建联系人可见性表
    //    //    [SqlAddressData createVisibilityContactTable];
    //    [SqlAddressData createNewVisibilityTable];
    //    //   创建领导人可见性表
    //    [SqlAddressData createVisibilityLeaderTable];
    
    if (self.isFromLogin) {
        
    }
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.delegate=self;
    
    AppDelegate *ad =(AppDelegate *)[UIApplication sharedApplication].delegate;
    ad.noticeDelegate = self;
    
    
    _nomalImageArray = [[NSArray alloc]  initWithObjects:
                        @"icon_message.png",
                        @"icon_call-contact.png",
                        @"icon_SMS.png",
                        @"icon_email.png",
                        //                        @"public_icon_tabbar_apply_nm.png",
                        @"nav-bar_more.png",nil];
    
    _hightlightedImageArray = [[NSArray alloc]initWithObjects:
                               @"icon_message.png",
                               @"icon_call-contact.png",
                               @"icon_SMS.png",
                               @"icon_email.png",
                               //                               @"public_icon_tabbar_apply_pre.png",
                               @"nav-bar_more.png",nil];
    
    //    _nomalImageArray = [[NSArray alloc]  initWithObjects:@"public_icon_tabbar_msg_nm.png",@"public_icon_tabbar_ads_nm.png",@"mail",@"public_icon_tabbar_more_nm.png",nil];
    //
    //    _hightlightedImageArray = [[NSArray alloc]initWithObjects:@"public_icon_tabbar_msg_pre.png",@"public_icon_tabbar_ads_pre.png",@"mail_s",@"public_icon_tabbar_more_pre.png",nil];
    
    
    //设置图片的位置
    self.tabbarButt1.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    self.tabbarButt2.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    self.tabbarButtTask.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    self.tabbarButt3.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    //    self.tabbarButtAppstore.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    self.tabbarButt4.contentEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0);
    
    //设置提醒图片
    //    [self.tabbarButt1 setRemindImage:nil];
    
    //设置提醒数量
    [self.tabbarButt1 setRemindNum:0];
    [self.tabbarButt3 setRemindNum:[[[NSUserDefaults standardUserDefaults] objectForKey:@"未读个数"] integerValue]];
    
    //设置标题
    [self.tabbarButt1 setTabbarTitleLabel:@"消息"];
    [self.tabbarButt2 setTabbarTitleLabel:@"通讯录"];
    [self.tabbarButtTask setTabbarTitleLabel:@"短信群发"];
    [self.tabbarButt3 setTabbarTitleLabel:@"邮箱客户端"];
    //    [self.tabbarButtAppstore setTabbarTitleLabel:@"应用中心"];
    [self.tabbarButt4 setTabbarTitleLabel:@""];
    //    if (_seletedIndex == -1)
    //    {
    //        //用self.赋值默认会调set方法
    //        self.seletedIndex = 0;
    //    }
    //    else
    //    {
    //        //用self.赋值默认会调set方法
    //        self.seletedIndex = _seletedIndex;
    //    }
    if(ORG_ID)
    {
        NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
        //    self.tabbarButtTask.remindNum = [unReadArray count];
        if([unReadArray count] > 0)
        {
            self.tabbarButtTask.remindImage = NO;
        }
        else
        {
            self.tabbarButtTask.remindImage.hidden = YES;
        }
    }
    
    //首页为xib文件（MainViewController.xib）
    //首页右上角更多按钮
    _other = [[UIButton alloc]init];
    _other.frame = CGRectMake(260, 22, 60, 44);
   // [_other setBackgroundImage:[UIImage imageNamed:@"nav-bar_more.png"] forState:UIControlStateNormal];
    //_other.backgroundColor = [UIColor redColor];
    [_other addTarget:self action:@selector(ClickControlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_other];
    
    UIImageView*imgev = [[UIImageView alloc]init];
    imgev.frame = CGRectMake(280, 26, 30, 30);
    [imgev setImage:[UIImage imageNamed:@"nav-bar_more.png"]];
    [self.view addSubview:imgev];
    
    _grayView = [[UIView alloc]init];
    _grayView.backgroundColor = [UIColor blackColor];
    _grayView.alpha = 0.1;
    _grayView.frame = CGRectMake(0, 66, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    //_grayView.userInteractionEnabled = YES;
    [self.view addSubview:_grayView];
    //取消第一响应者
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress)];
    [_grayView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *singleTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress)];
    [Navigation_View addGestureRecognizer:singleTaps];
    
    
    self.tableView = [[UITableView alloc]init];
    
    if ([UIScreen mainScreen].bounds.size.width == 414&&[UIScreen mainScreen].bounds.size.height == 736) {
        NSLog(@"6Plus");
        self.tableView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width/3-10, 66, [UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height/2-18+38);
    }else if ([UIScreen mainScreen].bounds.size.width == 375&&[UIScreen mainScreen].bounds.size.height == 667){
        NSLog(@"6");
        self.tableView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width/3-10, 66, [UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height/2-18+38);
    }else if ([UIScreen mainScreen].bounds.size.width == 320&&[UIScreen mainScreen].bounds.size.height == 568){
        NSLog(@"5s&&5");
        self.tableView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width/3-10, 66, [UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height/2-18+38);
    }else if ([UIScreen mainScreen].bounds.size.width == 320&&[UIScreen mainScreen].bounds.size.height == 480){
        NSLog(@"4s&&4");
        self.tableView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.width/3-10, 66, [UIScreen mainScreen].bounds.size.width/3, [UIScreen mainScreen].bounds.size.height/2+25+38);
    }
    
    self.tableView.alpha = 1.0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataArray = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    //[self.tableView reloadData];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    //分割线顶格
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    //分割线颜色
    self.tableView.separatorColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    //隐藏多余分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    //禁止滚动
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.tableView];
    _tableView.hidden = YES;
    _grayView.hidden = YES;
    
    [self SMSsend];
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(changePic) userInfo:nil repeats:YES];
    _string = [[NSString alloc]init];
    
    //[self accept];
    
    
    _Meeting_Remind = [[UILabel alloc]init];
    _Meeting_Remind.frame = CGRectMake(45, 305, 14, 14);
    _Meeting_Remind.backgroundColor = [UIColor redColor];
    _Meeting_Remind.layer.cornerRadius = 7.0f;
    [[_Meeting_Remind layer] setMasksToBounds:YES];
    _Meeting_Remind.textColor = [UIColor whiteColor];
    _Meeting_Remind.textAlignment = NSTextAlignmentCenter;
    _Meeting_Remind.font = [UIFont systemFontOfSize:8.0f];
    [self.view addSubview:_Meeting_Remind];
    _Meeting_Remind.hidden = YES;
}
/*
//会议未读消息接受
-(void)accept {    //    NSNotificationCenter*centercxd=[NSNotificationCenter defaultCenter];
    //    //找到通知中心,注册收听某主题的广播
    //    [centercxd addObserver:self selector:@selector(jiasjisa:) name:noticecxd object:nil];
    NSNotificationCenter*centerwqqwwq = [NSNotificationCenter defaultCenter];
    [centerwqqwwq addObserver:self selector:@selector(jieshoujieshou:) name:noticecxd object:nil];
}

-(void)jieshoujieshou:(NSNotification*)sender {
    //取出字典里的值
    NSString *str2 = [sender.userInfo valueForKey:@"testq"];
    DDLogCInfo(@"通知里面的str2：%@（（（",str2);
    _Meeting_Remind.text = str2;
    if ([str2 isEqualToString:@"0"]) {
        _Meeting_Remind.hidden = YES;
    }else {
        _Meeting_Remind.hidden = NO;
    }
}
*/

//-(void)Meeting_Unread_red {
////    int i= [[[NSUserDefaults standardUserDefaults]objectForKey:@"unconfirm_count"] integerValue];
////    DDLogCInfo(@"::::::::::::::::%d",i);
////    //会议提醒红点
////    NSString *str = [[NSString alloc]initWithFormat:@"%d",i];
//    _Meeting_Remind = [[UILabel alloc]init];
//    _Meeting_Remind.frame = CGRectMake(45, 305, 14, 14);
//    _Meeting_Remind.backgroundColor = [UIColor redColor];
//    _Meeting_Remind.layer.cornerRadius = 7.0f;
//    [[_Meeting_Remind layer] setMasksToBounds:YES];
//    _Meeting_Remind.textColor = [UIColor whiteColor];
//    _Meeting_Remind.textAlignment = NSTextAlignmentCenter;
//    _Meeting_Remind.font = [UIFont systemFontOfSize:8.0f];
//    [self.view addSubview:_Meeting_Remind];
//    
//}

-(void)downloadDidFinishLoading:(Download *)download
{
    NSLog(@"qqqqqqq:%@",download.downloadDictionary);
    NSArray *imageArr=[download.downloadDictionary objectForKey:@"ads"];
    for (int i=0; i<imageArr.count; i++) {
        NSDictionary *dict=imageArr[i];
        UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, 150)];
        imageview.userInteractionEnabled=YES;
        //imageview.backgroundColor=[UIColor redColor];
        [imageview setImageWithURL:[NSURL URLWithString:dict[@"picUrl"]] placeholderImage:[UIImage imageNamed:@"beijing1"]];
        UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        tap.identifyTag=[dict objectForKey:@"pageUrl"];
        [imageview addGestureRecognizer:tap];
        [_scrllView addSubview:imageview];
    }
    _scrllView.contentSize=CGSizeMake(SCREEN_WIDTH*imageArr.count, 150);
}

-(void)tap:(UITapGestureRecognizer*)tap
{
    NSLog(@"%@",tap.identifyTag);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tap.identifyTag]];
}

//scrllView自动滚动
-(void)changePic
{
    //执行一次
    static NSInteger x = 0;
    if (x<3) {
        x++;
    }else{
        x = 0;
    }
    _scrllView.contentOffset= CGPointMake(320*x, 0);
    
}


-(void)SMSsend{
    UIButton*Smssend = [[UIButton alloc]init];
    Smssend.frame = CGRectMake(100, 308, 44, 44);
    [Smssend addTarget:self action:@selector(launchpage) forControlEvents:UIControlEventTouchUpInside];
    [Smssend setImage:[UIImage imageNamed:@"icon_SMS.png"] forState:UIControlStateNormal];
    [self.view addSubview:Smssend];
}
//短信群发去除动画效果
-(void)launchpage{
    SMSViewController*SView = [[SMSViewController alloc]init];
    [self presentViewController:SView animated:NO completion:nil];
    DDLogCInfo(@"Note_短信群发");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString*cellName = @"Cell";
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    //分割线顶格
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    //[cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    cell.textLabel.textColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
    //选中后颜色不变
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
            case 0:
            cell.textLabel.text = @"个人中心";
            break;
        case 1:
            cell.textLabel.text = @"通知提醒";
            break;
        case 2:
            cell.textLabel.text = @"邮箱设置";
            break;
        case 3:
            cell.textLabel.text = @"修改密码";
            break;
        case 4:
            cell.textLabel.text = @"清空缓存";
            break;
        case 5:
            cell.textLabel.text = @"检查更新";
            break;
        case 6:
            cell.textLabel.text = @"建议反馈";
            break;
        case 7:
            cell.textLabel.text = @"关于";
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 38;
    
}
//更多选项去除动画效果
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        DDLogCInfo(@"Note_个人中心");
        PersonInfoViewController*PersVC = [[PersonInfoViewController alloc]init];
        UINavigationController*nc = [[UINavigationController alloc]initWithRootViewController:PersVC];
        nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self presentViewController:nc animated:NO completion:nil];
    }else if (indexPath.row == 1) {
        DDLogCInfo(@"Note_通知提醒");
        NotifyViewController * notifyVC=[[NotifyViewController alloc]init];
        UINavigationController*nc = [[UINavigationController alloc]initWithRootViewController:notifyVC];
        nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
        //字体颜色
        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self presentViewController:nc animated:NO completion:nil];
    }else if (indexPath.row == 2){
        DDLogCInfo(@"Note_邮箱设置");
//        MailActController*mailAC = [[MailActController alloc]init];
//        [self presentViewController:mailAC animated:YES completion:nil];
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        MailActRouter *router = [app.dependencies actRouter];
        [router push:self];
    }else if (indexPath.row == 3){
        DDLogCInfo(@"Note_修改密码");
        ChangePswViewController *changePswVC = [[ChangePswViewController alloc]init];
        UINavigationController*nc = [[UINavigationController alloc]initWithRootViewController:changePswVC];
        nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
        //字体颜色
        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self presentViewController:nc animated:NO completion:nil];
    }else if (indexPath.row == 4){
        DDLogCInfo(@"Note_清空缓存");
        [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
    }else if (indexPath.row == 5){
        DDLogCInfo(@"Note_检查更新");
        AboutViewController *aboutVC = [[AboutViewController alloc]init];
        UINavigationController*nc = [[UINavigationController alloc]initWithRootViewController:aboutVC];
        nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
        //字体颜色
        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self presentViewController:nc animated:NO completion:nil];
    }else if (indexPath.row == 6){
        DDLogCInfo(@"Note_意见反馈");
        FeedBackViewController*feedVC = [[FeedBackViewController alloc]init];
        UINavigationController*nc = [[UINavigationController alloc]initWithRootViewController:feedVC];
        nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
        //字体颜色
        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self presentViewController:nc animated:NO completion:nil];
    }else if (indexPath.row == 7){
        DDLogCInfo(@"Note_关于");
        AboutViewController *aboutVC = [[AboutViewController alloc]init];
        UINavigationController*nc = [[UINavigationController alloc]initWithRootViewController:aboutVC];
        nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
        //字体颜色
        nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        [self presentViewController:nc animated:NO completion:nil];
    }
    _tableView.hidden = YES;
    _grayView.hidden = YES;
}

-(void)backView{
    DDLogCInfo(@"backView");
}


- (MailActRouter *)actRouter
{
    return _mailActRouter;
}


-(void)clearCacheSuccess
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"清理完成" isCue:0 delayTime:1 isKeyShow:NO];
}

-(void)ClickControlAction:(UIButton*)button{
    DDLogCInfo(@"Note_更多");
//    if (_bools) {
//        _tableView.hidden = YES;
//        _grayView.hidden = YES;
//        _bools = NO;
//    }else{
//        _tableView.hidden = NO;
//        _grayView.hidden = NO;
//        _bools = YES;
//    }
    if (_tableView.hidden == NO) {
        _tableView.hidden = YES;
        _grayView.hidden = YES;
    }else{
        _tableView.hidden = NO;
        _grayView.hidden = NO;
    }
    
}

- (void)buttonpress {
    DDLogCInfo(@"呵呵呵呵");
    _tableView.hidden = YES;
    _grayView.hidden = YES;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isMemberOfClass:[UITableView class]])
    {
    }
    else
    {
        int current = scrollView.contentOffset.x/320;
        UIPageControl*pageControl = (UIPageControl*)[self.view viewWithTag:101];
        pageControl.currentPage = current;
        
    }
}


-(void)getAddressbook
{
    
}
-(void)saveState:(BOOL)isSee forKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults]setBool:isSee forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark-
#pragma mark HUD

- (void)hudWasHidden:(MBProgressHUD *)hud{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}
-(void)addHUD:(NSString *)labelStr{
    _HUD=[[MBProgressHUD alloc] initWithView:self.view];
    _HUD.dimBackground = YES;
    _HUD.labelText = labelStr;
    _HUD.delegate=self;
    
    [self.view addSubview:_HUD];
    [_HUD show:YES];
}

-(void)noticeReceivedMsg:(NSDictionary *)resultDict{
    
}

#pragma mark-
#pragma mark notification 通知tabbar读了多少信息
-(void)markHasReadChatCountMain:(NSNotification *)notification{
    
    int notUnReadCount=[[notification.userInfo objectForKey:@"count"] intValue];
    
    unReadCount = unReadCount - notUnReadCount;
    self.tabbarButt1.remindNum = unReadCount>0?unReadCount:0;
    
    AppDelegate *app=[ConstantObject app];
    if (app.unReadNum>=notUnReadCount) {
        app.unReadNum=app.unReadNum-notUnReadCount;
    }
}

#pragma mark notification 通知tabbar未读信息数
-(void)markUnReadChatCountMain:(NSNotification *)notification{
    
    //    unReadCount = [SqliteDataDao queryAllUnReadCount];
    unReadCount = [[notification object] intValue];
    self.tabbarButt1.remindNum = unReadCount>0?unReadCount:0;
}

#pragma mark - view appear
-(void)viewDidAppear:(BOOL)animated{
    //    [self showTabBar:SlideDirectionLeft animated:NO];
    
}
-(void)viewWillAppear:(BOOL)animated{
  //  [self registerNotificationCenter];
}

#pragma mark - 注册通知

/*
-(void)registerNotificationCenter{
    //消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markHasReadChatCountMain:) name:NOTIFICATION_READ object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markUnReadChatCountMain:) name:NOTIFICATION_UNREAD object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginToServeSucceed:) name:@"loginToServeSucceed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideTabBar:) name:NOTIFICATION_HIDETABBAR object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTabBar:) name:NOTIFICATION_SHOWTABBAR object:nil];
    
}
#pragma mark - 界面消失
-(void)viewWillDisappear:(BOOL)animated{
    //移除掉所有的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
*/
 
#pragma mark - 切换页面
- (void)setSeletedIndex:(int)aIndex

{
    //_selectIndex = aIndex;赋值
    // self. selectIndex = aIndex;死循环
    
    
    
    //如果索引值没有改变不做其他操作
    // if (_seletedIndex == aIndex) return;
    
    //如果索引值改变了需要做操作
    /*
     安全性判断
     如果_seletedIndex表示当前显示的有视图
     需要把原来的移除掉，然后把对应的TabBar按钮设置为正常状态
     */
    if (_seletedIndex >= 0)
        
    {
        //找出对应索引的视图控制器
        //UIViewController *priviousViewController = [_viewControllers objectAtIndex:_seletedIndex];
        //移除掉
        //[priviousViewController.view removeFromSuperview];
        //找出对应的TabBar按钮
        BarButton *previousButton = (BarButton *)[self.view viewWithTag:_seletedIndex + 1];
        //设置为正常状态下的图片
        [previousButton setImage:[UIImage imageNamed:[_nomalImageArray objectAtIndex:_seletedIndex]] forState:UIControlStateNormal];
        [previousButton setBarButtonTitleColor:0];
        
    }
    
    /*
     记录当前索引，采用属性直接赋值的方式
     更改TabBar按钮状态为高亮状态
     添加视图
     */
    
    //记录一下当前的索引
    _seletedIndex = aIndex;
    
    //取消点击后的高亮显示
    //获得对应的按钮并且设置为高亮状态下的图片
//    BarButton *currentButton = (BarButton *)[self.view viewWithTag:(aIndex + 1)];
//    [currentButton setImage:[UIImage imageNamed:[_hightlightedImageArray objectAtIndex:aIndex]] forState:UIControlStateNormal];
//    [currentButton setBarButtonTitleColor:1];
    //获得对应的视图控制器
    UIViewController *currentViewController = [_viewControllers objectAtIndex:aIndex];
    //如果次条件成立表示当前是第一个，即“导航控制器”
    
    
    if ([currentViewController isKindOfClass:[UINavigationController class]])
    {
        //设置导航控制器的代理
        ((UINavigationController *)currentViewController).delegate = self;
        UINavigationController *nav = (UINavigationController *)currentViewController;
        
        if (self.isToRootViewController == 1) {
            //官
            [nav popToRootViewControllerAnimated:YES];
            self.isToRootViewController = NO;
            
        }
    }
    
    //设置当前视图的大小
    currentViewController.view.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height-50);
    
    //添加到Tab上
    [self.view addSubview:currentViewController.view];
    
    //把视图放到TabBar下面
    // [self.view sendSubviewToBack:currentViewController.view];
    //通讯录、消息、邮箱去除动画效果
    [self presentViewController:currentViewController animated:NO completion:nil];
}


#pragma mark -
#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    // UIViewController：栈顶的视图控制器；n和m
    
    if (!_previousNavViewController)
        
    {
        //导航控制器中的视图数组
        self.previousNavViewController = navigationController.viewControllers;
    }
    
    
    
    /*
     是否为压栈的标记，初始化为NO
     如果原来的控制器数不大于当前导航的视图控制器数表示是压栈
     */
    
    
    BOOL isPush = NO;
    if ([_previousNavViewController count] <= [navigationController.viewControllers count])
        
    {
        isPush = YES;
    }
    /*
     if (!isPush) {
     UIViewController *vc=[_previousNavViewController lastObject];
     if (_previousNavViewController.count>2 && [vc isKindOfClass:[MessageChatViewController class]]) {
     NSMutableArray *tempArray=[[NSMutableArray alloc] init];
     [tempArray addObject:[_previousNavViewController firstObject]];
     
     _previousNavViewController=tempArray;
     navigationController.viewControllers=tempArray;
     
     }
     }
     */
    /*
     上一个视图控制器当压栈的时候底部条是否隐藏
     当前视图控制器当压栈的时候底部条是否隐藏
     这两个视图控制器有可能是同一个
     */
    //操作签的栈顶元素和操作后的栈顶元素，者两个控制器内容
    //设置隐藏了系统的tablebar，相当于一个标记内容来；
    BOOL isPreviousHidden = [[_previousNavViewController lastObject] hidesBottomBarWhenPushed];
    BOOL isCurrentHidden = viewController.hidesBottomBarWhenPushed;
    
    //重新记录当前导航器中的视图控制器数组
    self.previousNavViewController = navigationController.viewControllers;
    
    /*
     如果状态相同不做其他操作
     如果上一个显示则隐藏TabBar
     如果上一个隐藏则显示TabBar
     */
    if (!isPreviousHidden && !isCurrentHidden)
    {
        return;
    }
    else if(isPreviousHidden && isCurrentHidden)
    {
        return;
    }
    else if(isPreviousHidden && !isCurrentHidden)
    {
        //显示tabbar ［出栈］secondviewcontroller回到第一个控制器；
        //   [self showTabBar:isPush ? SlideDirectionLeft : SlideDirectionRight animated:animated];
    }
    
}

- (void)showTabBar:(NSNotification *)notification
{
    //根据压栈还是出栈设置TabBar初始位置
    CGRect tempRect = _tabbarView.frame;
    //tempRect.origin.x = self.view.bounds.size.width * ( (direction == SlideDirectionLeft) ? 1 : -1);
    //_tabbarView.frame = tempRect;
    tempRect.origin.x = 0;
    _tabbarView.frame = tempRect;
    
    UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
    
    CGRect viewRect = currentViewController.view.frame;
    viewRect.size.height = self.view.bounds.size.height - 44;
    currentViewController.view.frame = viewRect;
    
}

- (void)hideTabBar:(NSNotification *)notification
{
    SlideDirection direction = SlideDirectionRight;
    //获得当前视图控制器
    UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
    
    //压栈时，移除手势
    for (UIGestureRecognizer * recognizer in self.view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            [self.view removeGestureRecognizer:recognizer];
        }
    }
    
    //重置高度 重新分配窗口的大小 43的白色按钮
    CGRect viewRect = currentViewController.view.frame;
    viewRect.size.height = self.view.bounds.size.height;
    currentViewController.view.frame = viewRect;
    
    //设置TabBar的位置 设置动画签的位置 然后隐藏；
    CGRect tempRect = _tabbarView.frame;
    tempRect.origin.x = 0;
    _tabbarView.frame = tempRect;
    
    //根据压栈还是出栈设置动画效果
    tempRect.origin.x = self.view.bounds.size.width * (direction == SlideDirectionLeft ? -2 : 1);
    _tabbarView.frame = tempRect;
    
}

/*
 显示底部TabBar相关
 需要重置当前视图控制器View的高度为整个屏幕的高度-TabBar的高度
 */
/*
 - (void)showTabBar:(SlideDirection)direction animated:(BOOL)isAnimated
 {
 //出栈时，创建手势
 
 
 //根据压栈还是出栈设置TabBar初始位置
 CGRect tempRect = _tabbarView.frame;
 //tempRect.origin.x = self.view.bounds.size.width * ( (direction == SlideDirectionLeft) ? 1 : -1);
 //_tabbarView.frame = tempRect;
 tempRect.origin.x = 0;
 _tabbarView.frame = tempRect;
 
 UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
 
 CGRect viewRect = currentViewController.view.frame;
 viewRect.size.height = self.view.bounds.size.height - 44;
 currentViewController.view.frame = viewRect;
 
 //执行动画
 [UIView animateWithDuration:isAnimated ? SLIDE_ANIMATION_DURATION : 0 delay:0 options:0 animations:^
 {
 //动画效果
 CGRect tempRect = _tabbarView.frame;
 tempRect.origin.x = 0;
 _tabbarView.frame = tempRect;
 
 }completion:^(BOOL finished)
 
 {
 
 //动画结束时
 //重置当前视图控制器View的高度为整个屏幕的高度-TabBar的高度
 UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
 
 CGRect viewRect = currentViewController.view.frame;
 viewRect.size.height = self.view.bounds.size.height - 44;
 currentViewController.view.frame = viewRect;
 }];
 
 }
 */
/*
 隐藏底部TabBar相关
 需要重置当前视图控制器View的高度为整个屏幕的高度
 */
/*
 - (void)hideTabBar:(SlideDirection)direction animated:(BOOL)isAnimated
 {
 //获得当前视图控制器
 UIViewController *currentViewController = [_viewControllers objectAtIndex:_seletedIndex];
 
 //压栈时，移除手势
 for (UIGestureRecognizer * recognizer in self.view.gestureRecognizers) {
 if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
 [self.view removeGestureRecognizer:recognizer];
 }
 }
 
 //重置高度 重新分配窗口的大小 43的白色按钮
 CGRect viewRect = currentViewController.view.frame;
 viewRect.size.height = self.view.bounds.size.height;
 currentViewController.view.frame = viewRect;
 
 //设置TabBar的位置 设置动画签的位置 然后隐藏；
 CGRect tempRect = _tabbarView.frame;
 tempRect.origin.x = 0;
 _tabbarView.frame = tempRect;
 
 //采用Block的形式开启一个动画
 [UIView animateWithDuration:isAnimated ? SLIDE_ANIMATION_DURATION : 0 delay:0 options:0 animations:^(void)
 {
 //根据压栈还是出栈设置动画效果
 CGRect tempRect = _tabbarView.frame;
 tempRect.origin.x = self.view.bounds.size.width * (direction == SlideDirectionLeft ? -2 : 1);
 _tabbarView.frame = tempRect;
 
 }
 completion:^(BOOL finished){
 
 }
 ];
 
 }
 */


- (IBAction)selectTabbar:(id)sender {
    
    //获得索引
    //    DDLogInfo(@"%d",sende);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"is_to_chat"] isEqualToString:@"1"]) {
        /**
         *  判读是否是发起聊天回话的操作，如果是，设置rootView
         */
        self.isToRootViewController=YES;
        [userDefaults setObject:@"0" forKey:@"is_to_chat"];
        [userDefaults synchronize];
    }
    
    BarButton *btn = (BarButton *)sender;
    int index = btn.tag - 1;
    
    if (self.tabbarButtonClick) {
        self.tabbarButtonClick(index);
    }
    //用self.赋值默认会调set方法 伴随着控制器自动切换的过程
    self.seletedIndex = index;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)toRootView{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if ([[userDefaults objectForKey:@"is_to_chat"] isEqualToString:@"1"]) {
        /**
         *  判读是否是发起聊天会话的操作，如果是，设置rootView
         */
        self.isToRootViewController=YES;
        [userDefaults setObject:@"0" forKey:@"is_to_chat"];
        [userDefaults synchronize];
    }
}
#pragma mark - notification 消息进入前台检查到新工作圈消息 或者消息被评论或赞
-(void)noticeNewWorkMessage:(NSNotification *)not{
    
    [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"显示小红点,%@",not.userInfo]];
    
    NSDictionary * dict = [not userInfo];
    if ([[dict valueForKey:@"replyCount"] intValue] > 0) {//评论或赞显示数量，优先级高
        //        self.tabbarButt3.remindNum = [[dict valueForKey:@"replyCount"] intValue];
        //        self.tabbarButt3.remindNum = -1;
    }else if([[dict valueForKey:@"msgCount"] intValue] > 0) {//新消息只显示红点，优先级低
        //        self.tabbarButt3.remindNum = -1;
    }else if ([dict valueForKeyPath:@"uuid"]!=nil){
        //        self.tabbarButt3.remindNum = -1;
    }else{
        //        self.tabbarButt3.isRemind = NO;
        //        self.tabbarButt3.remindNum = 0;
    }
#pragma mark - 显示小红点
    AppDelegate *appDel=(AppDelegate *)([UIApplication sharedApplication].delegate);
    if (appDel.is_update) {
        //有更新
        self.tabbarButt4.remindNum = -1;
    }else{
        self.tabbarButt4.remindNum = 0;
    }
}
-(void)loginToServeSucceed:(id)sender{
    //    [self requestAddressBook];
}

- (IBAction)buttobClink:(UIButton *)sender {
    NSLog(@"敬请期待");
    
    
    UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"😜" message:@"敬请期待" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [a show];
}
- (IBAction)appCenter:(UIButton *)sender {
    
//    ViewController * vC=[[ViewController alloc]init];
//    [self presentViewController:vC animated:YES completion:^{
//        
//    }];
    
    
    
   
    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/eas/AppCenter/",HTTP_IP]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    H5ViewController *h5VC = [[H5ViewController alloc] initWithNibName:@"H5ViewController" bundle:nil withRequest:request];

   
    h5VC.hidesBottomBarWhenPushed = YES;
    h5VC.currentH5Types = AppRecommendationType;
   
    
    //应用中心去除动画效果
    [self presentViewController:h5VC animated:NO completion:^{
        DDLogCInfo(@"Note_应用中心");
    }];

}
//会议通知去除动画效果
- (IBAction)huiyi:(UIButton *)sender {
    [self presentViewController:_huiyiController animated:NO completion:nil];
    DDLogCInfo(@"Note_会议通知");
}

#pragma mark - alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case adress_update_tag:{
            if (buttonIndex==0) {
                //下载通讯录
                
            }
            
            break;
        }
        case moa_down_tag:{
            if (buttonIndex == 0) {
                
            }
            break;
        }
            
            
        default:
            break;
    }
    
}






@end
