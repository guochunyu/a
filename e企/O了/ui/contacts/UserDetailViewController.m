//
//  UserDetailViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-1-9.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#define SUCESS @200 //操作成功

#define CELL_CONTENT_WIDTH 290  //tableView行宽
#define DEFAULT_CELL_HEIGHT 44      //tableView默认行高
#define DEFAULT_CELL_HEIGHT1 63    ////tableView前两行高
#define ICON_CELL_HEIGHT 160     //头像所在行高
#define FONT_SIZE 17            //tableview行内默认字体大小
#define MARGIN_BUTTON 10        //button按钮的间距
#define FIELDS_SORT @"fieldsSort"   //排序字段

#import "CBG.h"

#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"
#import "UIViewAdditions.h"
#import "UserDetailViewController.h"
#import "UserDetailCell.h"
#import "MessageChatViewController.h"
#import "VoIPViewController.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "UIImage+vImage.h"
#import "MailBoardRouter.h"
#import "AFClient.h"
#import "MainNavigationCT.h"
#import "MBProgressHUD.h"
#import "TaskCreateViewController.h"
#import "TaskViewController.h"
#import "MailEditController.h"
//#import "ZJSwitch.h"
#import "MailBoardController.h"
#import "EmployeeModel.h"
#import "MailBoardHandler.h"
#import "MailEditRouter.h"
#import "MailEditHandler.h"
/**
 * button功能类型
 */
typedef enum {
    ButtonFunctionTypeFreqContacts=1,   ///<常用联系人
    ButtonFunctionTypeSaveContact=2,     ///<保存到本地
    ButtonFunctionTypeMessage=3,        ///<发送短信
    ButtonFunctionTypeCallShortNum=4,   ///<拨打短号
    ButtonFunctionTypeCallMobilePhone=5,///<拨打电话
    ButtonFunctionTypeSendTask=6,///发起任务
    ButtonFunctionTypeMovieChat=7,///视频聊天
    ButtonFunctionTypefreeeChat=8,///免费通话
    ButtonFunctionTypeCallSendEmail ///<发送邮件
}ButtonFunctionType;

@interface UserDetailViewController ()<UIAlertViewDelegate,ABUnknownPersonViewControllerDelegate>{
    MBProgressHUD *_progressHUD;
    NSMutableArray *_UserDetailColumnName;
    
    UIButton *_btnFreq;
    UIButton *_btnSave;
    BOOL      flag;
    int clickCount;
    int priority;///<优先级
    
    __weak IBOutlet UITableView *tableViewUserDetail;
    __weak IBOutlet UIButton *buttonPrevious;
    
    NSString       * userPhone;
}
@end

@implementation UserDetailViewController
@synthesize userInfo=_userInfo,organizationName=_organizationName;
- (id)initWithStyle:(UITableViewStyle)style
{
    //    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];

    self.searchBarContacts.hidden = NO;
    
    self.navigationController.navigationBar.hidden = YES;
    
    //    MainNavigationCT *mainNavCT1 = maivc.viewControllers[1];
    //    [mainNavCT1.navigationBar setBackgroundImage:[UIImage imageNamed:IS_IOS_7 ? @"top_ios7.png" : @"top.png"] forBarMetrics:UIBarMetricsCompact];
    
//    MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
//    MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
//    MainNavigationCT *mainNavCT1 = maivc.viewControllers[2];
//    [mainNavCT1.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
    [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
    
    
    NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
    NSString *myImacct =[ConstantObject sharedConstant].userInfo.imacct;
    self.myImacct = myImacct;
    EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
    self.UserPhoto = model.avatarimgurl;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.shadowImage = nil;
    self.tableViewSearch.hidden = NO;
    self.viewSearchBG.hidden = NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
        
        self.navigationController.navigationBar.alpha = 0.1f;
        self.navigationController.navigationBar.translucent = YES;
        
        
    }
    else
    {
        self.navigationController.navigationBar.alpha = 1;
        
        self.navigationController.navigationBar.tintColor = nil;
        
        self.navigationController.navigationBar.translucent = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
       [buttonPrevious addTarget:self action:@selector(buttonPreviousAction) forControlEvents:UIControlEventTouchUpInside];
    
    //    [self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsCompact];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"任务" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    if (self.detailType==1) {
        priority=[[SqliteDataDao sharedInstanse] queryPriorityWithToUserId:self.userInfo.imacct];
    }
    
    _btnFreq=[UIButton buttonWithType:UIButtonTypeCustom];
    _btnFreq.tag=ButtonFunctionTypeFreqContacts;
    //  _btnFreq.frame=CGRectMake(cell.frame.size.width-25,29, 22, 22);
    _btnFreq.layer.cornerRadius=3;
    /*
     //navigation 返回
     UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
     leftButton.titleLabel.font=[UIFont systemFontOfSize:15];
     leftButton.bounds=CGRectMake(0, 0, 50, 29);
     [leftButton setTitle:@"  返回" forState:UIControlStateNormal];
     [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
     [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back_pre.png"] forState:UIControlStateHighlighted];
     [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
     UIBarButtonItem *leftBar=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
     self.navigationItem.leftBarButtonItem=leftBar;
     */
    //tableView设置
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    
    NSLog(@"%@", NSStringFromCGRect(rect));
    tableViewUserDetail.frame = CGRectMake(0, -20, 320, rect.size.height+40);
    
    tableViewUserDetail.backgroundColor=UIColorFromRGB(0xebebeb);
    tableViewUserDetail.backgroundView=nil;
   
  
    
    //    NSString * phone=[[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    self.commanArray= [SqlAddressData selectCommanContact:uid];
    self.title=self.userInfo.name;
    
    for (EmployeeModel *comman in _commanArray) {
        if ([self.userInfo.name isEqualToString:comman.name]) {
            self.userInfo.freqFlag=1;
            break;
        }
    }
    
    [tableViewUserDetail reloadData];
    
}
#pragma mark ---- TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:{
//            if ((self.userInfo.shotNum == nil || self.userInfo.shotNum.length == 0)) {
//                NSLog(@"%@",self.userInfo.shotNum);

                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.phone]]];
                        //   }
//            else{
//            NSString * shortNUmber = [NSString stringWithFormat:@"短号  %@",self.userInfo.shotNum];
//            NSString * MoblilePhone = [NSString stringWithFormat:@"手机  %@",self.userInfo.phone];
//            UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:MoblilePhone,shortNUmber, nil];
//            [actionSheet setActionSheetStyle:UIBarStyleBlackTranslucent];
  //          [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
            break;

            }
        case 2:{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.tele]]];
            break;
        }
        case 3:{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.shotNum]]];
            break;
        }
        case 4:
        {
            [self sendEmail];
            break;
        }
        case 5:
        {
            if (self.isFromChat) {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            
            MessageChatViewController *messageVC = [[MessageChatViewController alloc]init];
            messageVC.member_userInfo=self.userInfo;
            messageVC.chatType=0;
            [messageVC setHidesBottomBarWhenPushed:YES];
            [self setHidesBottomBarWhenPushed:NO];
//            MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
//            MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
//            maivc.isToRootViewController = YES;
//            [maivc setSeletedIndex:0];
//            MainNavigationCT *mainNavCT1 = maivc.viewControllers[0];
//            [mainNavCT1 pushViewController:messageVC animated:YES];
            [self.navigationController pushViewController:messageVC animated:YES];
            break;

        }
            //将创建任务、视频聊天、免费通话功能屏蔽
        /*
        case 6:
        {
            TaskCreateViewController *taskCreateVC = [[TaskCreateViewController alloc] init];
            NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
            if (![imacct isEqual:self.userInfo.imacct]) {
                taskCreateVC.array = [NSMutableArray arrayWithObject:self.userInfo];
            }
            self.searchBarContacts.hidden = YES;
            taskCreateVC.hidesBottomBarWhenPushed = YES;
            taskCreateVC.isFromContact = YES;
            [self.navigationController pushViewController:taskCreateVC animated:YES];
            break;
        }
        case 7:
        {
            [self videoCall];
            break;

        }
        case 8:
        {
            [self voiceCall];
            break;
        }
         */
            
            
        default:
            break;
    }


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidAppear:(BOOL)animated
{
}

-(void)buttonPreviousAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
#pragma mark sectionNumber
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //    tableView.backgroundColor = [UIColor blackColor];
    return 1;
}
#pragma mark rowNumber
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return 9;
    
}

#pragma mark UITableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    //    }
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    //头像Cell设置
    if (indexPath.section==0) {
        switch (indexPath.row) {
            case 0:
            {
//                NSString * fileURL=self.userInfo.avatarimgurl;
//                NSURL *url = [NSURL URLWithString:fileURL];
                UIImageView * imageview1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
//                UIImageView * imageview2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//                [imageview2 setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
    //          imageview1.image = [self imageFromImage:imageview2.image inRect:CGRectMake(0, 10, 320, 160)];
    //            imageview1.image = [imageview1.image applyLightEffect];
                imageview1.image = [UIImage imageNamed:@"2_contact_layer_bg.png"];
                imageview1.alpha =1.0;
                [cell.contentView addSubview:imageview1];
                UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
                imageView.image = [UIImage imageNamed:@"2_contact_layer_bg.png"];
                [cell.contentView addSubview:imageView];
                
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0,ICON_CELL_HEIGHT-0.5, tableViewUserDetail.frame.size.width, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                UIImageView * headImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
                headImg.layer.masksToBounds = YES;
                headImg.layer.cornerRadius = headImg.frame.size.width * 0.5;
                UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
                button.frame = CGRectMake(23, 85, 60, 60);
                [button addSubview:headImg];
                [button addTarget:self action:@selector(showBigHeadImg:) forControlEvents:UIControlEventTouchUpInside];
                NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
                if ([self.userInfo.imacct isEqual:imacct]) {
                    NSURL *url = [NSURL URLWithString:self.UserPhoto];
                    [headImg setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
                }else{
                    NSString * fileURL=self.userInfo.avatarimgurl;
                    NSURL *url = [NSURL URLWithString:fileURL];
                    [headImg setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
                }
                [cell.contentView addSubview:button];
                UILabel * name=nil;
                name=(UILabel*)[cell viewWithTag:88];
                if (name==nil) {
                    name=[[UILabel alloc]init];
                    name.tag=88;
                    [cell.contentView addSubview:name];
                }
                name.font=[UIFont systemFontOfSize:16];
                name.text=self.userInfo.name;
                name.textColor = [UIColor whiteColor];
                CGSize Size=[name.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                if (Size.width > 80) {
                    Size.width = 80;
                }
                name.frame=CGRectMake(button.right + 13, button.top + 10 , Size.width, 20);
                [cell.contentView addSubview:name];
                UILabel * position=nil;
                position=(UILabel*)[cell viewWithTag:89];
                if (position==nil) {
                    position=[[UILabel alloc]init];
                    position.tag=89;
                    // [cell.contentView addSubview:position];
                }
                position.text=self.organizationName;
                position.font=[UIFont systemFontOfSize:13];
                CGSize Size1=[position.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                if (Size1.width > 150) {
                    Size1.width = 150;
                }
                position.frame=CGRectMake(80, 35, Size1.width, 20);
                
                UILabel * organization=nil;
                organization=(UILabel*)[cell viewWithTag:90];
                if (organization==nil) {
                    organization=[[UILabel alloc]init];
                    organization.tag=90;
                    [cell.contentView addSubview:organization];
                }
                organization.text=self.organizationName;
                //    self.addcompanyname (organization.text);
                DDLogInfo(@"%@------",organization.text);
                CGSize Size2=[organization.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                organization.font=[UIFont systemFontOfSize:12];
                organization.frame=CGRectMake(name.left,name.bottom + 5, Size2.width, 20);
                organization.textColor = [UIColor whiteColor];
                
                _btnFreq.frame=CGRectMake(cell.frame.size.width-45,name.bottom - 18,44, 44);
                if (self.detailType==1) {
                    [_btnFreq setBackgroundColor:[UIColor colorWithRed:0.056 green:0.458 blue:0.801 alpha:1.000]];
                    [_btnFreq setTitle:priority==0?@"置顶会话":@"取消置顶会话" forState:UIControlStateNormal];
                }else{
                    // [_btnFreq setBackgroundColor:[UIColor colorWithRed:0.471 green:0.721 blue:0.207 alpha:1.000]];
                    //[_btnFreq setBackgroundImage:[UIImage imageNamed:@"2_icon_not-collect.png"] forState:UIControlStateNormal];
                    
                    if (self.userInfo.freqFlag==1) {
                        [_btnFreq setBackgroundImage:[UIImage imageNamed:@"2_icon_collect.png"] forState:UIControlStateNormal];
                    }else {
                        [_btnFreq setBackgroundImage:[UIImage imageNamed:@"2_icon_not-collect.png"] forState:UIControlStateNormal];
                    }
                }
                [_btnFreq addTarget:self action:@selector(commanContactClick:) forControlEvents:UIControlEventTouchUpInside];
//                if (![self.myImacct isEqual:self.userInfo.imacct]) {
//                    [cell.contentView addSubview:_btnFreq];
//                }
                    [cell.contentView addSubview:_btnFreq];
                
                break;
            }
            case 1:{
                
                //                    cell.textLabel.text=@"手机";
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT1-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                
                UILabel * label=nil;
                label=(UILabel*)[cell viewWithTag:96];
                if (label==nil) {
                    label=[[UILabel alloc]init];
                    label.tag=96;
                    [cell.contentView addSubview:label];
                }
                label.font=[UIFont systemFontOfSize:15];
                label.textAlignment = NSTextAlignmentLeft;
                label.text=self.userInfo.phone;
                label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
                CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label.frame=CGRectMake(cell.textLabel.left + 15, 15, Size.width, 17);
                UILabel * label1 = nil;
                if (label1 == nil) {
                    label1 = [[UILabel alloc]init];
                    [cell.contentView addSubview:label1];
                }
                label1.font = [UIFont systemFontOfSize:12];
                label1.text = @"电话";
                CGSize Size1=[label1.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label1.frame=CGRectMake(label.left,label.bottom+5, Size1.width, 12);
                label1.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
                button.frame=CGRectMake(cell.frame.size.width-35, 20, 22, 22);
                [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                button.tag=ButtonFunctionTypeCallMobilePhone;
                [button setImage:[UIImage imageNamed:@"2_icon_phone_nm.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"2_icon_phone_pre.png"] forState:UIControlStateHighlighted];
                
                [cell.contentView addSubview:button];
                break;
            }
            case 2:{
                if (self.userInfo.tele == nil || self.userInfo.tele.length == 0) {
                    cell.hidden = YES;
                }
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT1-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                
                UILabel * label=nil;
                label=(UILabel*)[cell viewWithTag:96];
                if (label==nil) {
                    label=[[UILabel alloc]init];
                    label.tag=96;
                    [cell.contentView addSubview:label];
                }
                label.font=[UIFont systemFontOfSize:15];
                label.textAlignment = NSTextAlignmentLeft;
                label.text=self.userInfo.tele;
                label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
                CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label.frame=CGRectMake(cell.textLabel.left + 15, 15, Size.width, 17);
                UILabel * label1 = nil;
                if (label1 == nil) {
                    label1 = [[UILabel alloc]init];
                    [cell.contentView addSubview:label1];
                }
                label1.font = [UIFont systemFontOfSize:12];
                label1.text = @"固话";
                CGSize Size1=[label1.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label1.frame=CGRectMake(label.left,label.bottom+5, Size1.width, 12);
                label1.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
                button.frame=CGRectMake(cell.frame.size.width-35, 20, 22, 22);
                [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                button.tag=ButtonFunctionTypeCallMobilePhone;
                [button setImage:[UIImage imageNamed:@"2_icon_phone_nm.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"2_icon_phone_pre.png"] forState:UIControlStateHighlighted];
                
                [cell.contentView addSubview:button];
                break;
            }
            case 3:{
                if (self.userInfo.shotNum == nil || self.userInfo.shotNum.length == 0) {
                    cell.hidden = YES;
                }

                //                    cell.textLabel.text=@"手机";
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT1-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                
                UILabel * label=nil;
                label=(UILabel*)[cell viewWithTag:96];
                if (label==nil) {
                    label=[[UILabel alloc]init];
                    label.tag=96;
                    [cell.contentView addSubview:label];
                }
                label.font=[UIFont systemFontOfSize:15];
                label.textAlignment = NSTextAlignmentLeft;
                label.text=self.userInfo.shotNum;
                label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
                CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label.frame=CGRectMake(cell.textLabel.left + 15, 15, Size.width, 17);
                UILabel * label1 = nil;
                if (label1 == nil) {
                    label1 = [[UILabel alloc]init];
                    [cell.contentView addSubview:label1];
                }
                label1.font = [UIFont systemFontOfSize:12];
                label1.text = @"短号";
                CGSize Size1=[label1.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label1.frame=CGRectMake(label.left,label.bottom+5, Size1.width, 12);
                label1.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
                button.frame=CGRectMake(cell.frame.size.width-35, 20, 22, 22);
                [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                button.tag=ButtonFunctionTypeCallShortNum;
                [button setImage:[UIImage imageNamed:@"2_icon_phone_nm.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"2_icon_phone_pre.png"] forState:UIControlStateHighlighted];
                
                [cell.contentView addSubview:button];
                break;
            }

            case 4:{
                if (self.userInfo.email == nil || self.userInfo.email.length == 0) {
                    cell.hidden = YES;
                }
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT1-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                UILabel * label=nil;
                label=(UILabel*)[cell viewWithTag:97];
                if (label==nil) {
                    label=[[UILabel alloc]init];
                    label.tag=97;
                    [cell.contentView addSubview:label];
                }
                label.font=[UIFont systemFontOfSize:15];
                label.text=self.userInfo.email;
                CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label.textAlignment = NSTextAlignmentLeft;
                label.frame=CGRectMake(cell.textLabel.left + 15, 15,tableViewUserDetail.frame.size.width - 80, 17);
                label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
                UILabel * label1 = nil;
                if (label1 == nil) {
                    label1 = [[UILabel alloc]init];
                    [cell.contentView addSubview:label1];
                }
                label1.font = [UIFont systemFontOfSize:12];
                label1.text = @"邮箱";
                CGSize Size1=[label1.text sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                label1.frame=CGRectMake(label.left, label.bottom+5, Size1.width, 12);
                label1.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                UIButton * button = nil;
                button = (UIButton*)[cell viewWithTag:98];
                if(button == nil){
                    button=[UIButton buttonWithType:UIButtonTypeCustom];
                    button.tag = 98;
                    [cell.contentView addSubview:button];
                }
                button.frame=CGRectMake(cell.frame.size.width-35, 20, 22, 22);
                [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                button.tag=ButtonFunctionTypeCallSendEmail;;
                [button setImage:[UIImage imageNamed:@"2_icon_mail_nm.png"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"2_icon_mail_pre.png"] forState:UIControlStateHighlighted];
                /*
                 button=[UIButton buttonWithType:UIButtonTypeCustom];
                 button.frame=CGRectMake(cell.frame.size.width-25, 10, 20, 20);
                 [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                 button.tag=ButtonFunctionTypeCallSendEmail;
                 [button setImage:[UIImage imageNamed:@"public_icon_content_mail_nm.png"] forState:UIControlStateNormal];
                 */
                
               
                break;
            }
                
            case 5:{
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                UIButton * sendMessage = nil;
                sendMessage = (UIButton*)[cell viewWithTag:95];
                sendMessage=[UIButton buttonWithType:UIButtonTypeCustom];
                    sendMessage.tag = 95;
                    [cell.contentView addSubview:sendMessage];
                [sendMessage setTitle:@"发送消息" forState:UIControlStateNormal];
                [sendMessage setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
                sendMessage.titleLabel.textAlignment = NSTextAlignmentLeft;
                sendMessage.titleLabel.font = [UIFont systemFontOfSize:15];
                CGSize Size=[sendMessage.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                sendMessage.frame=CGRectMake(cell.textLabel.left + 15, 7, Size.width, 30);
                [sendMessage addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                sendMessage.tag=ButtonFunctionTypeMessage;
                //  [sendMessage setImage:[UIImage imageNamed:@"public_icon_content_message_nm.png"] forState:UIControlStateNormal];
                
                break;
            }
//            case 6:{
//                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
//                _lineView.opaque             = YES;
//                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
//                [cell.contentView addSubview:_lineView];
//                UIButton * sendTask = nil;
//                if (sendTask == nil) {
//                    sendTask = [UIButton buttonWithType:UIButtonTypeCustom];
//                    [cell.contentView addSubview:sendTask];
//                }
//                [sendTask setTitle:@"发起任务" forState:UIControlStateNormal];
////                [sendTask setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
//                [sendTask setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//                sendTask.titleLabel.textColor = [UIColor blueColor   ];
//                sendTask.titleLabel.font = [UIFont systemFontOfSize:15];
//                CGSize Size=[sendTask.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
//                sendTask.frame=CGRectMake(cell.textLabel.left + 15, 7, Size.width, 30);
//                [sendTask addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
//                sendTask.tag=ButtonFunctionTypeSendTask;
//                
//                break;
//                
//            }
            case 6:{
                NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
                
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(15,DEFAULT_CELL_HEIGHT-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                UIButton * movieChat = nil;
                if (movieChat == nil) {
                    movieChat = [UIButton buttonWithType:UIButtonTypeCustom];
                    if (![imacct isEqual:self.userInfo.imacct]) {
                        [cell.contentView addSubview:movieChat];
                    }
                    else{
                        cell.hidden = YES;
                    }
                                    }
                [movieChat setTitle:@"视频聊天" forState:UIControlStateNormal];
//                [movieChat setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
                [movieChat setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                movieChat.titleLabel.textColor = [UIColor blueColor   ];
                movieChat.titleLabel.font = [UIFont systemFontOfSize:15];
                CGSize Size=[movieChat.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                movieChat.frame=CGRectMake(cell.textLabel.left + 15, 7, Size.width, 30);
        //        [movieChat addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                movieChat.tag=ButtonFunctionTypeMovieChat;
                
                break;
                
            }
            case 7:{
                 NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
                self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0,DEFAULT_CELL_HEIGHT-0.5, tableViewUserDetail.frame.size.width - 15, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [cell.contentView addSubview:_lineView];
                UIButton * freeChat = nil;
                if (freeChat == nil) {
                    freeChat = [UIButton buttonWithType:UIButtonTypeCustom];
                    if (![imacct isEqual:self.userInfo.imacct]) {
                        [cell.contentView addSubview:freeChat];
                    }
                    else{
                        cell.hidden = YES;
                    }
                    
                }
                [freeChat setTitle:@"免费通话" forState:UIControlStateNormal];
//                [freeChat setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
                [freeChat setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                freeChat.titleLabel.textColor = [UIColor blueColor   ];
                freeChat.titleLabel.font = [UIFont systemFontOfSize:15];
                CGSize Size=[freeChat.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                freeChat.frame=CGRectMake(cell.textLabel.left + 15, 7, Size.width, 30);
      //          [freeChat addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                freeChat.tag=ButtonFunctionTypefreeeChat;
                
            }
                /*
                 case 1:
                 {
                 if (self.userInfo.shotNum == nil || self.userInfo.shotNum.length == 0 || [self.userInfo.shotNum isEqualToString:@"null"]|| [self.userInfo.shotNum isEqualToString:@"(null)"]){
                 cell.hidden = YES;
                 break;
                 }
                 
                 cell.textLabel.text=@"短号";
                 cell.textLabel.font=[UIFont systemFontOfSize:14];
                 
                 UILabel * label=nil;
                 label=(UILabel*)[cell viewWithTag:93];
                 if (label==nil) {
                 label=[[UILabel alloc]init];
                 label.tag=93;
                 [cell.contentView addSubview:label];
                 }
                 if ([self.userInfo.shotNum isEqualToString:@"(null)"]) {
                 label.text=@"";
                 }else{
                 label.text=self.userInfo.shotNum;
                 }
                 CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                 label.frame=CGRectMake(60, 5, Size.width, 30);
                 label.font=[UIFont systemFontOfSize:14];
                 
                 UIButton * button = nil;
                 button = (UIButton*)[cell viewWithTag:94];
                 if(button == nil){
                 button=[UIButton buttonWithType:UIButtonTypeCustom];
                 button.tag = 94;
                 [cell.contentView addSubview:button];
                 }
                 button.frame=CGRectMake(cell.frame.size.width-25, 10, 20, 20);
                 [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                 button.tag=ButtonFunctionTypeCallShortNum;
                 [button setImage:[UIImage imageNamed:@"public_icon_content_phone_nm.png"] forState:UIControlStateNormal];
                 break;
                 }
                 case 2:
                 {
                 cell.textLabel.text=@"手机";
                 cell.textLabel.font=[UIFont systemFontOfSize:14];
                 UILabel * label=nil;
                 label=(UILabel*)[cell viewWithTag:96];
                 if (label==nil) {
                 label=[[UILabel alloc]init];
                 label.tag=96;
                 [cell.contentView addSubview:label];
                 }
                 label.font=[UIFont systemFontOfSize:14];
                 label.text=self.userInfo.phone;
                 CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                 label.frame=CGRectMake(60, 5, Size.width, 30);
                 UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
                 button.frame=CGRectMake(cell.frame.size.width-25, 10, 20, 20);
                 [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                 button.tag=ButtonFunctionTypeCallMobilePhone;
                 [button setImage:[UIImage imageNamed:@"public_icon_content_phone_nm.png"] forState:UIControlStateNormal];
                 [cell.contentView addSubview:button];
                 
                 UIButton * sendMessage = nil;
                 sendMessage = (UIButton*)[cell viewWithTag:95];
                 NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
                 if(sendMessage == nil && ![self.userInfo.imacct isEqual:imacct] ){
                 sendMessage=[UIButton buttonWithType:UIButtonTypeCustom];
                 sendMessage.tag = 95;
                 [cell.contentView addSubview:sendMessage];
                 }
                 sendMessage.frame=CGRectMake(cell.frame.size.width-65, 10, 20, 20);
                 [sendMessage addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                 sendMessage.tag=ButtonFunctionTypeMessage;
                 [sendMessage setImage:[UIImage imageNamed:@"public_icon_content_message_nm.png"] forState:UIControlStateNormal];
                 break;
                 }
                 case 3:
                 {
                 cell.textLabel.text=@"邮箱";
                 cell.textLabel.font=[UIFont systemFontOfSize:14];
                 UILabel * label=nil;
                 label=(UILabel*)[cell viewWithTag:97];
                 if (label==nil) {
                 label=[[UILabel alloc]init];
                 label.tag=97;
                 [cell addSubview:label];
                 }
                 label.font=[UIFont systemFontOfSize:14];
                 if ([self.userInfo.email isEqualToString:@"(null)"]) {
                 label.text=@"";
                 }else{
                 label.text=self.userInfo.email;
                 }
                 CGSize Size=[label.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAXFLOAT, 31) lineBreakMode:NSLineBreakByCharWrapping];
                 label.frame=CGRectMake(60, 5, Size.width, 30);
                 UIButton * button = nil;
                 button = (UIButton*)[cell viewWithTag:98];
                 if(button == nil){
                 button=[UIButton buttonWithType:UIButtonTypeCustom];
                 button.tag = 98;
                 //[cell.contentView addSubview:button];
                 }
                 button=[UIButton buttonWithType:UIButtonTypeCustom];
                 button.frame=CGRectMake(cell.frame.size.width-25, 10, 20, 20);
                 [button addTarget:self action:@selector(playPhone:) forControlEvents:UIControlEventTouchUpInside];
                 button.tag=ButtonFunctionTypeCallSendEmail;
                 [button setImage:[UIImage imageNamed:@"public_icon_content_mail_nm.png"] forState:UIControlStateNormal];
                 break;
                 }
                 */
            default:
                break;
        }
        
    }
    /*if(indexPath.section==1) {
     if (cell==nil) {
     cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
     cell.textLabel.text=@"接受消息通知";
     cell.textLabel.font=[UIFont systemFontOfSize:14];
     UIButton * button = nil;
     button = (UIButton*)[cell viewWithTag:9909];
     if(button == nil){
     button=[UIButton buttonWithType:UIButtonTypeCustom];
     button.tag = 9909;
     [cell.contentView addSubview:button];
     }
     
     button.frame=CGRectMake(cell.frame.size.width-50-10, 6.5, 50, 31);
     //        NSUserDefaults * userDefaults=[NSUserDefaults standardUserDefaults];
     //        [userDefaults setBool:button.selected forKey:REMIND_MSG];
     //        [userDefaults synchronize];
     //        [button setImage:[UIImage imageNamed:button.selected?@"Chack_Open.png":@"group_set_Chack_Close.png"] forState:UIControlStateNormal];
     //        [self.tableView reloadData];
     //        if (button.selected) {
     
     [button setImage:[UIImage imageNamed:@"group_set_Chack_Close.png"] forState:UIControlStateSelected];
     [button setImage:[UIImage imageNamed:@"Chack_Open.png"] forState:UIControlStateNormal];
     NSMutableArray *arrayDistrub=[[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:NO_DISTURB_MEMBER];
     if (arrayDistrub&&[arrayDistrub containsObject:self.userInfo.imacct]) {
     button.selected=YES;
     }
     [button addTarget:self action:@selector(recieveMessage:) forControlEvents:UIControlEventTouchUpInside];
     
     
     }
     */
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}

-(void)showBigHeadImg:(UIButton *)headerTap{
    MJPhoto *photo = [[MJPhoto alloc] init];
    
    NSString * str=self.userInfo.avatarimgurl;
    str = [str stringByReplacingOccurrencesOfString:@"middle" withString:@"original"];
    str = [str stringByReplacingOccurrencesOfString:@"_original" withString:@""];
    if ([str length] > 0)
    {
        NSURL * strUrl = [NSURL URLWithString:str];
        photo.url = strUrl;
    }
    else
    {
        photo.image = [UIImage imageNamed:@""];
    }
    
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = [NSArray arrayWithObject:photo];
    [photoBroser show];
    
    
}

-(void)recieveMessage:(UIButton*)sender
{
    
    NSMutableArray *arrayDistrub=[[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:NO_DISTURB_MEMBER];
    
    if (sender.selected) {
        [arrayDistrub removeObject:self.userInfo.imacct];
    }else{
        [arrayDistrub addObject:self.userInfo.imacct];
    }
    sender.selected=!sender.selected;
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)playPhone:(UIButton*)sender
{
    switch (sender.tag) {
        case ButtonFunctionTypeFreqContacts:
            if (self.userInfo.freqFlag==1) {
                UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"移除常用联系人" message:@"你确认要移除该常用联系人吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alertView show];
            }else{
                [self operationFreq];
            }
            break;
        case ButtonFunctionTypeCallSendEmail:
           // [self sendEmail];
            DDLogInfo(@"发送邮件，跳转有问题");
            break;
            //      发送消息
        case ButtonFunctionTypeSendTask:{
            DDLogInfo(@"发起任务");
            
            TaskCreateViewController *taskCreateVC = [[TaskCreateViewController alloc] init];
            NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
            if (![imacct isEqual:self.userInfo.imacct]) {
                taskCreateVC.array = [NSMutableArray arrayWithObject:self.userInfo];
            }
            self.searchBarContacts.hidden = YES;
            taskCreateVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:taskCreateVC animated:YES];
             
            break;
        }
        case ButtonFunctionTypeMovieChat:{
            DDLogInfo(@"视频聊天");
            
            [self videoCall];
            
            break;
        }
        case ButtonFunctionTypefreeeChat:{
            DDLogInfo(@"免费通话");
            
            [self voiceCall];
            
            break;
        }
        case ButtonFunctionTypeMessage:
        {
            
            if (self.isFromChat) {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            
            MessageChatViewController *messageVC = [[MessageChatViewController alloc]init];
            messageVC.member_userInfo=self.userInfo;
            messageVC.chatType=0;
            [messageVC setHidesBottomBarWhenPushed:YES];
            [self setHidesBottomBarWhenPushed:NO];
//            MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
//            MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
//            maivc.isToRootViewController = YES;
//            [maivc setSeletedIndex:0];
//            MainNavigationCT *mainNavCT1 = maivc.viewControllers[0];
//            [mainNavCT1 pushViewController:messageVC animated:YES];
            [self.navigationController pushViewController:messageVC animated:YES];
            break;
        }
            //       拨打短号
        case ButtonFunctionTypeCallShortNum:
        {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.shotNum]]];
            break;
        }
            //        拨打手机号
        case ButtonFunctionTypeCallMobilePhone:{
           
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.phone]]];
            
            break;
        }
            //        保存到本地
        case ButtonFunctionTypeSaveContact:
        {
            [self visiteAddressBook];
            //            [self showUnknowPerson];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark 
#pragma mark ------UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.phone]]];
            break;
        }
        case 1:{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.shotNum]]];
            break;
        }
        default:
            break;
    }
    
}

-(void)visiteAddressBook
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        ABAddressBookRef ab = AddressBookCreate();
        //访问通讯录
        ABAddressBookRef book = ABAddressBookCreateWithOptions(NULL, NULL);
        
        //请求通讯录权限
        ABAddressBookRequestAccessWithCompletion(book, ^(bool granted, CFErrorRef error) {
            NSArray * peopleArray=[[NSArray alloc]init];
            //把所有的联系人复制到数组中
            peopleArray =  (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(book);
            //            NSString * user=self.userInfo.name;
            //            NSArray* arrayByName = (__bridge NSArray*)ABAddressBookCopyPeopleWithName(ab, CFSTR("%@"));
            
            NSMutableArray  *nameArray = [[NSMutableArray alloc] initWithCapacity:peopleArray.count];
            
            for (int i = 0; i<peopleArray.count; i++) {
                ABRecordRef person = (__bridge ABRecordRef)([peopleArray objectAtIndex:i]);
                NSString *name = (__bridge NSString *)ABRecordCopyCompositeName(person);
                
                ABMultiValueRef ref = ABRecordCopyValue(person, kABPersonPhoneProperty);
                //查看有几个电话
                int number = ABMultiValueGetCount(ref);
                DDLogInfo(@"查看有多少个电话号码:%d",number);
                //            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(ref, 0));
                //            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",phone,@"phone", nil];
                if (name != nil) {
                    [nameArray addObject:name];
                }
                
            }
            if ([nameArray containsObject:self.userInfo.name]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD * hud=[MBProgressHUD showHUDAddedTo:tableViewUserDetail animated:YES];
                    [self hideProgressHud:hud withText:@"此联系人已经存在"];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showUnknowPerson];
                });
            }
            
        });
        
    });
}
#pragma mark-----保存本地通讯录
-(void)showUnknowPerson{
    //        //    访问通讯录
    //
    //        //创建一条新记录
    //        // 初始化并创建通讯录对象，记得释放内存
    //
    //        //    ABAddressBookRef addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
    //        //
    //        //    //获取通讯录权限
    //        //
    //        //    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    //        //
    //        //    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
    //        //
    //        //    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //        ABUnknownPersonViewController *unknown=[[ABUnknownPersonViewController alloc]init];
    //        // 获取通讯录中所有的联系人
    //        NSString *phone=self.userInfo.phone;
    //
    //        // 遍历所有的联系人并修改指定的联系人
    //        //创建一条新记录
    //        ABRecordRef person = ABPersonCreate();
    //        //修改公司(单位)
    //        CFErrorRef error=nil;
    //        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)self.userInfo.name, &error);
    //        //电话
    //        //读取电话多值
    //
    //        ABMultiValueRef phoneMV =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //        ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(phoneMV,(__bridge CFStringRef)phone,(__bridge CFStringRef)@"手机", &mi);
    //
    ////      ABMultiValueAddValueAndLabel(ABMutableMultiValueRef multiValue, CFTypeRef value, CFStringRef label, ABMultiValueIdentifier *outIdentifier)
    //
    //        if (![self.userInfo.shotNum isEqualToString:@"(null)"]) {
    //            ABMultiValueIdentifier short_mi = ABMultiValueAddValueAndLabel(phoneMV,(__bridge CFStringRef)self.userInfo.shotNum,(__bridge CFStringRef)@"短号", &short_mi);
    //        }
    //        // 设置phone属性
    //        ABRecordSetValue(person, kABPersonPhoneProperty, phoneMV, NULL);
    //
    //
    //        //邮箱
    //        ABMultiValueRef mv = nil;
    //        if (self.userInfo.email.length>0) {
    //            //获取email多值
    //            mv =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    //
    //            ABMultiValueIdentifier email_mi = ABMultiValueAddValueAndLabel(mv,(__bridge CFStringRef)self.userInfo.email, (__bridge CFStringRef)@"邮箱", &email_mi);
    //
    //            // 设置email属性
    //            ABRecordSetValue(person, kABPersonEmailProperty, mv, NULL);
    //        }
    //        //     保存修改的通讯录对象
    //        //    ABAddressBookSave(addressBooks, NULL);
    //        //    // 释放通讯录对象的内存
    //        //    if (addressBooks) {
    //        //        CFRelease(addressBooks);
    //        //    }
    //        //    ABRecordSetValue(person, kABPersonOrganizationProperty, (CFStringRef)@"上海若雅", NULL);
    //        // 保存修改的通讯录对象
    //        unknown.displayedPerson=person;
    //        unknown.allowsAddingToAddressBook=YES;//允许添加
    //        unknown.unknownPersonViewDelegate=self;
    //
    //
    //        //使用UINavigationController包装ABUnknownPersonViewController
    //        UINavigationController* nav=[[UINavigationController alloc] initWithRootViewController:unknown];
    //        //    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:IS_IOS_7 ? @"top_ios7.png" : @"top.png"] forBarMetrics:UIBarMetricsDefault];
    //        unknown.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
    //                                                    initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
    //                                                    action:@selector(dismissContactView:)];
    //
    //        [self presentViewController:nav animated:YES completion:^{
    //            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //        }];
    //
    //        if (phoneMV) {
    //            CFRelease(phoneMV);
    //        }
    //        if (mv) {
    //            CFRelease(mv);
    //        }
    //        if (person) {
    //            CFRelease(person);
    //        }
    
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreateWithOptions(NULL,NULL);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) {
        
        // we're on iOS 6
        DDLogInfo(@"on iOS 6 or later, trying to grant access permission");
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(iPhoneAddressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        DDLogInfo(@"on iOS 5 or older, it is OK");
        accessGranted = YES;
    }
    
    if (!accessGranted) {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请在设置-隐私中设置访问权限！" isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }
    
    ABRecordRef newPerson = ABPersonCreate();
    CFErrorRef error = NULL;
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)self.userInfo.name, &error);
    //phone number
    ABMultiValueRef phoneMV =ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueIdentifier mi = ABMultiValueAddValueAndLabel(phoneMV,(__bridge CFStringRef)self.userInfo.phone,(__bridge CFStringRef)@"手机", &mi);
    
    if (![self.userInfo.shotNum isEqualToString:@"(null)"]) {
        ABMultiValueIdentifier short_mi = ABMultiValueAddValueAndLabel(phoneMV,(__bridge CFStringRef)self.userInfo.shotNum,(__bridge CFStringRef)@"短号", &short_mi);
    }
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, phoneMV, &error);
    CFRelease(phoneMV);
    //email
    ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(multiEmail,(__bridge CFStringRef)self.userInfo.email, kABWorkLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonEmailProperty, multiEmail, &error);
    CFRelease(multiEmail);
    //picture
    //NSData *dataRef = UIImagePNGRepresentation();
    //ABPersonSetImageData(newPerson, (CFDataRef)dataRef, &error);
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    if(ABAddressBookSave(iPhoneAddressBook, &error))
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"保存到本地通讯录成功!" isCue:0 delayTime:1 isKeyShow:NO];
    }else
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"保存到本地通讯录失败!" isCue:1 delayTime:1 isKeyShow:NO];
    }
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);
    
    //    }
    //
}
#pragma mark---
-(BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    //    ABMultiValueRef ref = ABRecordCopyValue(person, property);
    //
    //    //根据选择的信息的identifier获得这个identifier的索引
    //    long index = ABMultiValueGetIndexForIdentifier(ref, identifier);
    //
    //    //根据电话的索引，从所有电话ref中取出点击的这个电话
    //    NSString *phone = (__bridge NSString *) ABMultiValueCopyValueAtIndex(ref, index);
    //
    //    if ([phone isKindOfClass:[NSString class]]) {
    //
    //        DDLogInfo(@"%@",phone);
    //        userPhone = [self trimString:phone];
    //    }
    return NO;
}
#pragma mark----去掉括号
- (NSString *)trimString:(NSString *)string{
    NSMutableString *mutStr = [NSMutableString stringWithString:string];
    
    //找到左括号的位置
    NSRange range = [mutStr rangeOfString:@"("];
    //判断有没有这个字符
    if (range.location != NSNotFound) {
        //删除这个位置的字符
        [mutStr deleteCharactersInRange:range];
    }
    
    range = [mutStr rangeOfString:@")"];
    if (range.location != NSNotFound) {
        [mutStr deleteCharactersInRange:range];
    }
    
    range = [mutStr rangeOfString:@"-"];
    while (range.location != NSNotFound) {
        //直到所有空格删除完毕，退出循环
        [mutStr deleteCharactersInRange:range];
        range = [mutStr rangeOfString:@"-"];
    }
    
    range = [mutStr rangeOfString:@" "];
    while (range.location != NSNotFound) {
        //直到所有空格删除完毕，退出循环
        [mutStr deleteCharactersInRange:range];
        range = [mutStr rangeOfString:@" "];
    }
    
    range = [mutStr rangeOfString:@" "];
    while (range.location != NSNotFound) {
        //直到所有空格删除完毕，退出循环
        [mutStr deleteCharactersInRange:range];
        range = [mutStr rangeOfString:@" "];
    }
    
    
    return [NSString stringWithString:mutStr];
}

-(void)dismissContactView:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}
- (void)unknownPersonViewController:(ABUnknownPersonViewController*)unknownPersonView didResolveToPerson:(ABRecordRef)person{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    
    if(person){
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"保存到本地通讯录成功!" isCue:0 delayTime:1 isKeyShow:NO];
    }
    //隐藏包装unknownPersonView的导航控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark heightForRow
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight=DEFAULT_CELL_HEIGHT;
    if (indexPath.section==0) {
        //头像所在高度
        if (indexPath.row==0) {
            cellHeight=ICON_CELL_HEIGHT;
        }else{
            if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4) {
                cellHeight = DEFAULT_CELL_HEIGHT1;
            }
            else {
            cellHeight=DEFAULT_CELL_HEIGHT;
            }
        }
        int row = indexPath.row;
        NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
        
        if (row == 7 && [self.userInfo.imacct isEqual:imacct]){
            cellHeight = 0;
        }
        if (row == 8 && [self.userInfo.imacct isEqual:imacct]){
            cellHeight = 0;
        }
        if (row == 4 && (self.userInfo.email == nil || self.userInfo.email.length == 0)) {
            cellHeight = 0;
        }
        if (row == 3 && (self.userInfo.shotNum == nil || self.userInfo.shotNum.length == 0)) {
            cellHeight = 0;
        }
        if (row == 2 && (self.userInfo.tele == nil || self.userInfo.tele.length == 0)) {
            cellHeight = 0;
        }

    }
    
    return cellHeight;
}
#pragma mark footerView
/*
 - (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
 {
 if (section==0) {
 CGRect footerRect=[self.tableView rectForFooterInSection:section];
 UIView *view=[[UIView alloc]init];
 view.bounds=CGRectMake(0, 0, footerRect.size.width, footerRect.size.height);
 CGFloat frameX=(footerRect.size.width-CELL_CONTENT_WIDTH)*0.5;
 CGRect rectButton=CGRectMake(frameX, MARGIN_BUTTON, CELL_CONTENT_WIDTH, DEFAULT_CELL_HEIGHT);
 //常用联系人
 _btnFreq=[UIButton buttonWithType:UIButtonTypeCustom];
 _btnFreq.tag=ButtonFunctionTypeFreqContacts;
 _btnFreq.frame=CGRectMake(frameX, MARGIN_BUTTON, 22, 22);
 _btnFreq.layer.cornerRadius=3;
 
 if (self.detailType==1) {
 [_btnFreq setBackgroundColor:[UIColor colorWithRed:0.056 green:0.458 blue:0.801 alpha:1.000]];
 [_btnFreq setTitle:priority==0?@"置顶会话":@"取消置顶会话" forState:UIControlStateNormal];
 }else{
 // [_btnFreq setBackgroundColor:[UIColor colorWithRed:0.471 green:0.721 blue:0.207 alpha:1.000]];
 [_btnFreq setBackgroundImage:[UIImage imageNamed:@"2_icon_not-collect.png"] forState:UIControlStateNormal];
 
 if (self.userInfo.freqFlag==1) {
 [_btnFreq setBackgroundImage:[UIImage imageNamed:@"2_icon_collect.png"] forState:UIControlStateNormal];
 }else {
 [_btnFreq setBackgroundImage:[UIImage imageNamed:@"2_icon_not-collect.png"] forState:UIControlStateNormal];
 }
 }
 
 
 [_btnFreq addTarget:self action:@selector(commanContactClick:) forControlEvents:UIControlEventTouchUpInside];
 //     [view addSubview:_btnFreq];
 
 _btnSave=[UIButton buttonWithType:UIButtonTypeCustom];
 _btnSave.tag=ButtonFunctionTypeSaveContact;
 _btnSave.frame=CGRectMake(frameX,MARGIN_BUTTON+_btnFreq.frame.origin.y+_btnFreq.frame.size.height,CELL_CONTENT_WIDTH , DEFAULT_CELL_HEIGHT);
 if (self.detailType==1) {
 [_btnSave setBackgroundColor:[UIColor colorWithRed:0.056 green:0.458 blue:0.801 alpha:1.000]];
 [_btnSave setTitle:@"清空聊天记录" forState:UIControlStateNormal];
 }else{
 [_btnSave setBackgroundColor:[UIColor colorWithRed:0.056 green:0.458 blue:0.801 alpha:1.000]];
 [_btnSave setTitle:@"保存到本地" forState:UIControlStateNormal];
 }
 
 _btnSave.layer.cornerRadius=3;
 _btnSave.clipsToBounds=YES;
 
 [_btnSave addTarget:self action:@selector(commanContactClick:) forControlEvents:UIControlEventTouchUpInside];
 // [view addSubview:_btnSave];
 return view;
 }
 return nil;
 }
 
 #pragma mark section footer height
 - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
 {
 CGFloat height=5;
 if (section==0) {
 height=DEFAULT_CELL_HEIGHT+MARGIN_BUTTON;
 height*=3;
 }
 return height;
 }
 */
#pragma mark section header height
/*
 - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
 {
 CGFloat height=1;
 if (section==0) {
 if (self.detailType) {
 
 height=70;
 }
 }
 if (section==1) {
 height=10;
 }
 return height;
 }
 
 - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
 if (self.detailType==1 && section==0) {
 UIView *bgView=[[UIView alloc] init];
 bgView.backgroundColor=[UIColor colorWithRed:0.970 green:0.971 blue:0.965 alpha:1.000];
 
 UIButton *inviteButt=[UIButton buttonWithType:UIButtonTypeCustom];
 inviteButt.frame=CGRectMake(10, 10,tableView.frame.size.width-2*10, 50);
 [inviteButt setBackgroundColor:[UIColor colorWithRed:0.471 green:0.721 blue:0.207 alpha:1.000]];
 [inviteButt addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
 inviteButt.layer.cornerRadius=3;
 [inviteButt setTitle:@"邀请他人加入聊天" forState:UIControlStateNormal];
 [bgView addSubview:inviteButt];
 
 bgView.frame=CGRectMake(0, 0, tableView.frame.size.width, inviteButt.frame.size.height+10+inviteButt.frame.origin.y);
 
 return bgView;
 }else{
 return nil;
 }
 }
 */
#pragma mark didselect 工作圈 文件
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section==1) {
//        if (indexPath.row==0) {
//        }
//        if (indexPath.row==1) {
//        }
//    }
//}
#pragma mark - 自定义target方法
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark button点击事件
- (void)commanContactClick:(UIButton *)sender
{
    switch (sender.tag) {
            //        添加或者移除联系人
        case ButtonFunctionTypeFreqContacts:
        {
            
            if (self.detailType==1) {
#pragma mark - 置顶会话
                //置顶回话
                if (priority==0) {
                    [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:self.userInfo.imacct priority:1];
                    priority=1;
                }else{
                    priority=0;
                    [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:self.userInfo.imacct priority:0];
                }
                [sender setTitle:priority==0?@"置顶会话":@"取消置顶会话" forState:UIControlStateNormal];
                
                
            }else{
                if (self.userInfo.freqFlag==1) {
                    
                    [self operationFreq];
                    self.userInfo.freqFlag=0;
                    
                    
                    if (self.addComman) {
                        self.addComman(NO);
                    }
                    
                    //  [alertView show];
                }else {
                    [self operationFreq];
                    
                    self.userInfo.freqFlag=1;
                    
                    if (self.addComman) {
                        DDLogInfo(@"%@",self.organizationName);
                        
                        self.addComman(YES);
                    }
                }
            }
            
            
            break;
        }
            //         发送邮件
        case ButtonFunctionTypeCallSendEmail:
            [self sendEmail];
            break;
            //          发送短信
        case ButtonFunctionTypeMessage:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",self.userInfo.phone]]];
            break;
            //           短号拨打
        case ButtonFunctionTypeCallShortNum:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.shotNum]]];
            break;
            //            拨打手机号
        case ButtonFunctionTypeCallMobilePhone:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.userInfo.phone]]];
            break;
            //            保存到本地
        case ButtonFunctionTypeSaveContact:
        {
            DDLogInfo(@"保存到本地");
            if (self.detailType==1) {
#pragma mark - 清空消息记录
                [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:self.userInfo.imacct];
                
                if (self.clearChatData) {
                    self.clearChatData();
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
                
                [[ConstantObject app] showWithCustomView:@"清空聊天记录成功" detailText:nil isCue:0 delayTime:1 isKeyShow:NO];
            }else{
                //                [self showUnknowPerson];
                [self visiteAddressBook];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark -开启音视频会话

- (void)voiceCall
{
    [self callWithVideo:NO];
}

- (void)videoCall
{
    [self callWithVideo:YES];
}

- (void)callWithVideo:(BOOL)isVideo
{
    if (![Reachability isNetWorkReachable])
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        return;
    }
    NSString *imacct = self.userInfo.imacct;
    NSString *headImageurl = self.userInfo.avatarimgurl;
    ZUINT callId = Mtc_Call((ZCHAR *)[imacct UTF8String], 0, ZTRUE, isVideo);
    VoIPViewController *callingViewController = [[VoIPViewController alloc] init];
    callingViewController.callId = callId;
    callingViewController.isVideo = isVideo;
    callingViewController.emodel = self.userInfo;
    callingViewController.phoneNumber = self.userInfo.phone;
    callingViewController.headImageUrl = headImageurl;
    callingViewController.isIncoming = NO;
    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDele.callState = CALLSTATE_CALLING;
    [self presentViewController:callingViewController animated:YES completion:nil];
}

#pragma mark 发送消息
- (void)sendEmail
{
   
    MainNavigationCT *mainNavCT1 = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainNavCT1.mainVC;
    
     MailBoardController *board=[maivc.viewControllers[3] viewControllers].firstObject;
    
    if (board.accounts.count==0) {
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"提示" message:@"无法发送邮件，请先登录邮箱" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [a show];
    }else{
        [maivc setSeletedIndex:3];
        [board sendemail:_userInfo];
    }
    NSLog(@"%@",board);
   }
#pragma mark -邀请人加入
-(void)GetArrayID:(RoomInfoModel *)roomModel{
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=1;
    detailViewController.roomInfoModel=roomModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - buttClick

 -(void)buttClick:(id)sender{
 UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
 NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
 nav_add.addScrollType=AddScrollTypeCreatGroupFromOneChat;
 nav_add.delegate_addID = self;
 nav_add.empModel=self.userInfo;
 NSMutableArray *tempArray=[[NSMutableArray alloc] init];
 [tempArray addObject:self.userInfo.phone];
 
 nav_add.phoneArray=tempArray;
 [self presentViewController:nav_add animated:YES completion:^{
 
 }];
 }

#pragma mark - delegate
#pragma mark alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self operationFreq];
        self.userInfo.freqFlag=0;
        if (self.addComman) {
            self.addComman(NO);
        }
    }
}
#pragma mark - CustomMethod

- (void)operationFreq
{
    //   添加联系人的信息，这是处理本地的操作
    [SqlAddressData updateCommenContact:self.userInfo OrgName:self.organizationName];
    [tableViewUserDetail reloadData];
}
#pragma mark 隐藏指示器
- (void)hideProgressHud:(MBProgressHUD *)progressHUD withText:(NSString *)msg
{
    DDLogInfo(@"显示view");
    progressHUD.mode=MBProgressHUDModeText;
    progressHUD.dimBackground=NO;
    progressHUD.margin=10;
    progressHUD.opacity=0.7;
    progressHUD.yOffset=150.f;
    progressHUD.labelFont=[UIFont systemFontOfSize:12];
    progressHUD.labelText=msg;
    progressHUD.userInteractionEnabled=NO;
    [progressHUD hide:YES afterDelay:1];
    
}
@end
