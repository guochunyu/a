//
//  MoreMineViewController.m
//  e企
//
//  Created by royaMAC on 14-11-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MoreMineViewController.h"
#import "PersonInfoViewController.h"
#import "NotifyViewController.h"
#import "ChangePswViewController.h"
#import "InviteViewController.h"
#import "FeedBackViewController.h"
#import "AboutViewController.h"
#import "ContactsViewController.h"
#import "UIImageView+WebCache.h"
#import "MailActRouter.h"
#import "AppListTableViewController.h"
#import "H5ViewController.h"

#import "SqlAddressData.h"

#import "ZipArchive.h"
#import "CreateHttpHeader.h"

#import "MainNavigationCT.h"

#define CELL_CONTENT_WIDTH 290  //tableView行宽
#define DEFAULT_CELL_HEIGHT 44      //tableView默认行高
#define MYHEADERHEIGHT    80
#define FOOTERHEiGHT    100
#define DEFAULT_HEADERHEIGHT   10
#define exit_alert_tag 20//退出登录
#define update_alert_tag 21//更新

@interface MoreMineViewController ()<UIAlertViewDelegate>{
    NSArray *cellTitleArray;
    NSArray *cellTitleArray_1;
    UIImageView *imageView;
    UIImageView *imageView_0;
    UIImageView *imageView_01;
    UIImageView *imageView_1;
    UIImageView *imageView_2;
    UIImageView *imageView_3;
    UIImageView *imageView_4;
    UIImageView *imageView_5;
    UIImageView *imageView_6;
    UIImageView *imageView_7;
    UIImageView *imageView_8;

    UILabel *textLabel;
    UILabel *labelText_0;
    UILabel *labelText_01;
    UILabel *labelText_1;
    UILabel *labelText_2;
    UILabel *labelText_3;
    UILabel *labelText_4;
    UILabel *labelText_5;
    UILabel *labelText_6;
    UILabel *labelText_7;
    UILabel *labelText_8;

    UILabel *detailTextLabel;
    
    NSDictionary *dic;
    UIButton*back;
}

@end

@implementation MoreMineViewController
@synthesize currentH5Type;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"更多";
    
    back = [[UIButton alloc]init];
    back.frame = CGRectMake(10, 15, 50, 50);
    [back setBackgroundImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backff) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:back];
    
    dic = [[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
    NSLog(@"%@",dic[@"data"][@"customization"]);
    
    if ([dic[@"data"][@"customization"] integerValue] == 0) // 全部
    {
        cellTitleArray = @[@[@"头像"],@[@"切换团队"],@[@"应用中心",@"流量管理"],@[@"通知提醒",@"邮箱设置",@"修改密码",@"清空缓存",@"关于"]];
    }
    else
    {
        cellTitleArray = @[@[@"头像"],@[@"切换团队"],@[@"应用中心",@"流量管理"],@[@"通知提醒",@"邮箱设置",@"修改密码",@"清空缓存",@"关于"]];

    }

    _table=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height-50) style:UITableViewStyleGrouped];
    [self.view addSubview:self.table];
//    [self.table setSeparatorColor:[UIColor clearColor]];
    self.table.separatorInset = UIEdgeInsetsMake(0,45,0,0);
    self.table.backgroundColor = UIColorFromRGB(0xebebeb);
    self.table.delegate=self;
    self.table.dataSource=self;
    
    if (!IS_IOS_7) {
        //self.table.backgroundColor=[UIColor whiteColor];
        self.table.sectionIndexColor = [UIColor grayColor];

        self.table.backgroundView=nil;
    }
    if (IS_IOS_7) {
        self.table.sectionIndexBackgroundColor = [UIColor clearColor];
        self.table.sectionIndexColor = [UIColor grayColor];
        self.automaticallyAdjustsScrollViewInsets = YES;
        [self setExtendedLayoutIncludesOpaqueBars:YES];
    }
}

-(void)backff{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    back.hidden = NO;
    NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
    EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
    self.UserPhoto = model.avatarimgurl;
   
       DDLogInfo(@"%f",self.view.bounds.size.height);
    if (!IS_Height_4) {
        if(self.view.bounds.size.height == 480)
        {
            self.table.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
        }
        else
        {
            self.table.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
        }
    }
    else
    {
        if(self.view.bounds.size.height == 568)
        {
            self.table.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
        }
        else
        {
            self.table.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
        }
        
    }
    [self.table reloadData];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWTABBAR object:nil userInfo:nil];
    //self.table.backgroundColor=[UIColor whiteColor];
    self.table.backgroundView=nil;
    [self.table reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    back.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return cellTitleArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [cellTitleArray[section] count];

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height=0;
    if (section==0) {
        height=0.1;
    }else
        height =DEFAULT_HEADERHEIGHT;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = 0;
//    if(section == 3){
    if(section == 4){
        height = FOOTERHEiGHT;
    }else
        height = 1.0;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *str=cellTitleArray[indexPath.section][indexPath.row];
    NSString * cellIdenttifier=[NSString stringWithFormat:@"cell_%d_%d",indexPath.row,indexPath.section];
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIdenttifier];
    if (cell==nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenttifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.separatorInset = UIEdgeInsetsZero;
        
//        if ([str isEqualToString:@"检查更新"])
//        {
////            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenttifier];
////            cell.accessoryType = UITableViewCellAccessoryNone;
//            
//            imageView_5 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
//            labelText_5 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_5.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_5.frame.size.width, 20)];
//            labelText_5.font = size14;
//            labelText_5.textColor = UIColorFromRGB(0x333333);
////            [cell.contentView addSubview:imageView_5];
////            [cell.contentView addSubview:labelText_5];
//        }
        if ([str isEqualToString:@"头像"])
        {
            
//            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenttifier];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
            imageView.layer.cornerRadius=29.0;
            imageView.clipsToBounds=YES;
            textLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, cell.frame.size.height/2, cell.frame.size.width - 25 - imageView.frame.size.width, 20)];
            [textLabel setFont:size16];
            detailTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 10, cell.frame.size.height/2 + 20, cell.frame.size.width - 25 - imageView.frame.size.width, 20)];
            [detailTextLabel setFont:size14];
            detailTextLabel.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView];
            [cell.contentView addSubview:textLabel];
            [cell.contentView addSubview:detailTextLabel];
            
        }
        else if ([str isEqualToString:@"应用中心"])
        {
            imageView_0 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_0 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_0.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_0.frame.size.width, 20)];
            labelText_0.font = size14;
            labelText_0.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_0];
            [cell.contentView addSubview:labelText_0];
        }
        else if ([str isEqualToString:@"应用推荐"])
        {
            imageView_0 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_0 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_0.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_0.frame.size.width, 20)];
            labelText_0.font = size14;
            labelText_0.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_0];
            [cell.contentView addSubview:labelText_0];
        }
        else if ([str isEqualToString:@"流量管理"])
        {
            imageView_01 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_01 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_01.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_01.frame.size.width, 20)];
            labelText_01.font = size14;
            labelText_01.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_01];
            [cell.contentView addSubview:labelText_01];
        }
        else if ([str isEqualToString:@"通知提醒"])
        {
//            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenttifier];
//            cell.accessoryType = UITableViewCellAccessoryNone;
            
            imageView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_1.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_1.frame.size.width, 20)];
            labelText_1.font = size14;
            labelText_1.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_1];
            [cell.contentView addSubview:labelText_1];
        }
        else if ([str isEqualToString:@"邮箱设置"])
        {
//            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenttifier];
//            cell.accessoryType = UITableViewCellAccessoryNone;
            
            imageView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_2.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_2.frame.size.width, 20)];
            labelText_2.font = size14;
            labelText_2.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_2];
            [cell.contentView addSubview:labelText_2];
        }
        else if ([str isEqualToString:@"修改密码"])
        {
            imageView_3 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_3 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_3.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_3.frame.size.width, 20)];
            labelText_3.font = size14;
            labelText_3.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_3];
            [cell.contentView addSubview:labelText_3];
        }
        else if ([str isEqualToString:@"清空缓存"])
        {
            imageView_4 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_4 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_4.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_4.frame.size.width, 20)];
            labelText_4.font = size14;
            labelText_4.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_4];
            [cell.contentView addSubview:labelText_4];
        }
//        else if ([str isEqualToString:@"意见反馈"])
//        {
//            imageView_6 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
//            labelText_6 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_6.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_6.frame.size.width, 20)];
//            labelText_6.font = size14;
//            labelText_6.textColor = UIColorFromRGB(0x333333);
//        }
        else if ([str isEqualToString:@"关于"])
        {
            imageView_7 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_7 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_7.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_7.frame.size.width, 20)];
            labelText_7.font = size14;
            labelText_7.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_7];
            [cell.contentView addSubview:labelText_7];
        }
        else if ([str isEqualToString:@"切换团队"])
        {
            imageView_8 = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, 20, 20)];
            labelText_8 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView_8.frame)+10, cell.frame.size.height/2-10, cell.frame.size.width-25-imageView_8.frame.size.width, 20)];
            labelText_8.font = size14;
            labelText_8.textColor = UIColorFromRGB(0x333333);
            [cell.contentView addSubview:imageView_8];
            [cell.contentView addSubview:labelText_8];
        }
        else
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdenttifier];
            cell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    
    if ([str isEqualToString:@"头像"]) {
        NSDictionary * mydic=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
        DDLogInfo(@"dict=%@",mydic);
        NSString * uid=[mydic[@"data"] isKindOfClass:[NSDictionary class]]?(mydic[@"data"][@"uid"]):@"";
        NSString * gid=[[NSUserDefaults standardUserDefaults]objectForKey:myGID];
        NSString * filename=[NSString stringWithFormat:@"/%@%@.image11.txt",uid,gid];
        NSArray *directoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [directoryPath objectAtIndex:0];
        NSString *filePath = [documentDirectory stringByAppendingString:filename];
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:filePath];
               if (savedImage) {
            imageView.image = savedImage;
        [imageView setImageWithURL:[NSURL URLWithString:self.UserPhoto] placeholderImage:savedImage];
        }
        else{
            [imageView setImageWithURL:[NSURL URLWithString:self.UserPhoto] placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
        }
    
        NSString *myName=[ConstantObject sharedConstant].userInfo.name;
        NSString *myTel=[ConstantObject sharedConstant].userInfo.phone;
        textLabel.text=myName;
        detailTextLabel.text=[NSString stringWithFormat:@"手机号: %@",myTel];
        detailTextLabel.font = [UIFont systemFontOfSize:12];
        detailTextLabel.textColor = UIColorFromRGB(0x333333);
        
    }
    else if ([str isEqualToString:@"应用中心"])
    {
        imageView_0.image = [UIImage imageNamed:@"use_icon8"];
        labelText_0.text = str;
    }
    else if ([str isEqualToString:@"应用推荐"])
    {
        imageView_0.image = [UIImage imageNamed:@"use_icon8"];
        labelText_0.text = str;
    }
    else if ([str isEqualToString:@"流量管理"])
    {
        imageView_01.image = [UIImage imageNamed:@"icon_flow"];
        labelText_01.text = str;
    }
    else if ([str isEqualToString:@"通知提醒"])
    {
        imageView_1.image = [UIImage imageNamed:@"more_icon1."];
        labelText_1.text = str;
    }
    else if ([str isEqualToString:@"邮箱设置"])
    {
        imageView_2.image = [UIImage imageNamed:@"more_icon2."];
        labelText_2.text = str;
    }
    else if ([str isEqualToString:@"修改密码"])
    {
        imageView_3.image = [UIImage imageNamed:@"more_icon3."];
        labelText_3.text = str;
    }
    else if ([str isEqualToString:@"清空缓存"])
    {
        imageView_4.image = [UIImage imageNamed:@"more_icon4."];
        labelText_4.text = str;
    }
//    else if ([str isEqualToString:@"意见反馈"])
//    {
//        imageView_6.image = [UIImage imageNamed:@"more_icon6."];
//        labelText_6.text = str;
//    }
    else if ([str isEqualToString:@"关于"])
    {
        imageView_7.image = [UIImage imageNamed:@"more_icon7."];
        labelText_7.text = str;
    }
    else if ([str isEqualToString:@"切换团队"])
    {
        imageView_8.image = [UIImage imageNamed:@"icon_Switching-business"];
        labelText_8.text = str;
    }
    
//    else if ([str isEqualToString:@"检查更新"])
//    {
//        imageView_5.image = [UIImage imageNamed:@"more_icon5."];
//        labelText_5.text = str;
//    }
//    
    else{
        cell.textLabel.text=str;
    }
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    cell.detailTextLabel.textColor = UIColorFromRGB(0x999999);

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *str=cellTitleArray[indexPath.section][indexPath.row];
    
    if ([str isEqualToString:@"头像"]){
        return  MYHEADERHEIGHT;
    }
    return DEFAULT_CELL_HEIGHT;
}

#pragma mark -UITableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if ([dic[@"data"][@"customization"] integerValue] == 0) // 全部
    {
        if(!(section == 3 && row == 3))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
        }

        
    }else
    {
        
        if(!(section == 3 && row == 3))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
        }
    }
    if (indexPath.section == 0) // 个人信息
    {
        PersonInfoViewController * pVC=[[PersonInfoViewController alloc]initWithNibName:@"PersonInfoViewController" bundle:nil];
        [pVC useThePersoninfoImageChangeOther:^(UIImage *UserImage) {
            
            [self saveImage:UserImage withName:@".image11"];
            
        }];
        pVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:pVC animated:YES];
    }
    else if(section == 1)
    {
        // 切换团队
       [self switchEnterprise];
    }

    else if (section == 2)
    {
        if (row == 0)
        {
            NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/eas/AppCenter/",HTTP_IP]];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            H5ViewController *h5VC = [[H5ViewController alloc] initWithNibName:@"H5ViewController" bundle:nil withRequest:request];
            h5VC.title = @"应用中心";
            h5VC.hidesBottomBarWhenPushed = YES;
            h5VC.currentH5Types = AppRecommendationType;
            [self.navigationController pushViewController:h5VC animated:YES];
        }
        if (row == 1)
        {
            NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
            //NSString *strUrl = [NSString stringWithFormat:@"http://%@/eas/views/app/index.html?phone=%@",HTTP_IP,phoneNum];
            NSString *strUrl = [NSString stringWithFormat:@"http://183.131.13.102/PayPlatformE/Eqi/html/changeBuy.html?phone=%@",phoneNum];

            NSURL *url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            H5ViewController *h5VC = [[H5ViewController alloc] initWithNibName:@"H5ViewController" bundle:nil withRequest:request];
            h5VC.title = @"流量管理";
            h5VC.hidesBottomBarWhenPushed = YES;
            h5VC.currentH5Types = TrafficManagement;
            [self.navigationController pushViewController:h5VC animated:YES];
        }
      
    }
    else if (section == 3)
    {
        switch (row)
        {
            case 0: // 通知提示
            {
                NotifyViewController * notifyVC=[[NotifyViewController alloc]init];
                //notifyVC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:notifyVC animated:YES];
            }
                break;
                
            case 1: // 邮箱设置
            {
                AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                MailActRouter *router = [app.dependencies actRouter];
                [router push:self];
            }
                break;
                
            case 2: // 修改密码
            {
                ChangePswViewController *changePswVC = [[ChangePswViewController alloc]init];
                changePswVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:changePswVC animated:YES];
            }
                break;
                
            case 3: // 清空缓存
            {
                // 上传日志
                [self zipAndUploadLogs];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *filePath_Voice=[[NSString stringWithFormat:@"%@temp",voice_path] filePathOfCaches];
                    NSString *filePath_Image=[[NSString stringWithFormat:@"%@temp",image_path] filePathOfCaches];
                    NSArray *subFiles = [NSArray arrayWithObjects:filePath_Voice, filePath_Image, nil];
                                   
                    for (NSString *cache in subFiles)
                    {
                        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cache];
                                       
                        DDLogInfo(@"files :%d",[files count]);
                        for (NSString *p in files)
                        {
                            NSError *error;
                            NSString *path = [cache stringByAppendingPathComponent:p];
                            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
                            {
                                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                            }
                        }
                    }
                    [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];});
            }
                break;
                
            case 4: // 关于
            {
                AboutViewController *aboutVC = [[AboutViewController alloc]init];
                //aboutVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }

}
-(void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    NSDictionary * mydic=[[NSUserDefaults standardUserDefaults]objectForKey:MyUserInfo];
    DDLogInfo(@"dict=%@",mydic);
    NSString * uid=[mydic[@"data"] isKindOfClass:[NSDictionary class]]?(mydic[@"data"][@"uid"]):@"";
    NSString * gid=[[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString * filename=[NSString stringWithFormat:@"/%@%@%@.txt",uid,gid,imageName];
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.3);
    NSArray *directoryPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPath objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingString:filename];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath]){
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }

    DDLogInfo(@"%@",filePath);
    [imageData writeToFile:filePath atomically:YES];
}


-(void)clearCacheSuccess
{
    [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"清理完成" isCue:0 delayTime:1 isKeyShow:NO];
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
                [alertView show];
            }
            else
            {
                NSString *fileURL = [dataDic objectForKey:@"fileurl"];
                if(fileURL){
                self.plistUrl = [NSString stringWithString:fileURL];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"新版本是否更新?" delegate:self cancelButtonTitle:@"稍后再说" otherButtonTitles:@"立即更新", nil];
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

//#pragma mark - UIAlertViewDelegate
//-(void)quitButtonClick:(UIButton*)sender
//{
//    if (sender.tag==2001) {
//        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"退出后不会删除任何历史数据，下次登录仍然可以使用本账号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出登录", nil];
//        alertView.tag = exit_alert_tag;
//        [alertView show];
//    }
//}
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)postLogFileUrl:(NSString*)url
{
    DDLogInfo(@"Enter...");
    __block int reqtimes = 0;
    // 客户端平台
    NSString* platform =[[UIDevice currentDevice] model];
    // 客户端操作系统版本
    NSString* osversion = [[UIDevice currentDevice] systemVersion];
    // 客户端设备类型
    NSString* device = [[UIDevice currentDevice] systemName];
    // 程序版本
    NSString* appversion = [NSString stringWithFormat:@"%@ %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    //位置信息
    //NSString* address;
    
    reqtimes++;
    AFClient *client = [AFClient sharedClient];
    
    NSDictionary *dict=@{@"platform": platform,
                         @"osversion": osversion,
                         @"device": device,
                         @"appversion": appversion,
                         @"logurl": url,
                         };

    [client postPath:@"eas/logurl" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject){
         DDLogInfo(@"客户端手动上传日志%@",operation.responseString);
         NSDictionary * dicdata=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
         int status=[[dicdata objectForKey:@"status"] intValue];
         NSString *str=[dicdata objectForKey:@"msg"];
         
         DDLogInfo(@"status = %d, msg = %@", status, str);
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSInteger stateCode = operation.response.statusCode;
         DDLogInfo(@"%d",stateCode);
         if(stateCode == 401  && reqtimes<=10)
         {
             NSDictionary *ddd=operation.response.allHeaderFields;
             if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                 NSString *tmpnonce=[ddd objectForKey:@"Www-Authenticate"];
                 NSString* headStr = [CreateHttpHeader createHttpHeaderWithNoce:tmpnonce];
                 NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
                 [client setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
                 [self postLogFileUrl:url];
                 
             }
         }
         else
         {
             reqtimes = 0;
             DDLogError(@"post log url error!");
         }
         
     }];
    
}

- (void)zipAndUploadLogs
{
    NSString* ddlogDir = [[NSUserDefaults standardUserDefaults] objectForKey:@"DDLogDir"];
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:ddlogDir];
    
    DDLogInfo(@"files :%d",[files count]);
    
    NSDate *curDate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMddHHMMSS"];
    NSString *curDateStr = [dateformatter stringFromDate:curDate];
    NSString* zipFileName = [[@"eQiiOS_Log_" stringByAppendingString:curDateStr] stringByAppendingString:@".zip"];
    NSString* filePath = [[ddlogDir stringByAppendingString:@"/"] stringByAppendingString:zipFileName];
    ZipArchive *za = [[ZipArchive alloc] init];
    if (![za CreateZipFile2:filePath]) {
        DDLogError(@"create zip log file error!");
        return;
    };
    for (NSString *file in files)
    {
        [za addFileToZip:[[ddlogDir stringByAppendingString:@"/"] stringByAppendingString:file] newname:file];
    }
    if (![za CloseZipFile2]) {
        DDLogError(@"close zip log file error!");
        return;
    }

    NSData *fileData=[NSData dataWithContentsOfFile:filePath];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:file_update_url parameters:@{@"newimagetype":@"6",@"fileName":zipFileName} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:fileData name:zipFileName fileName:zipFileName mimeType:@"application/octet-stream"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *resultDict=[DataToDict dataToDict:responseObject];
        
        NSString* logurl = resultDict[@"original_link"];
        
        DDLogInfo(@"upoad log file success, logurl = %@", logurl);
        
        [self postLogFileUrl:logurl];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //上传日志文件失败
        DDLogError(@"upload log file error!");
        
    }];

    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}


#pragma mark -----登录

- (void)switchEnterprise {
    
    NSArray *myGid = [[NSUserDefaults standardUserDefaults]objectForKey:myLoginUserInfo];
    
    if([myGid count] == 1)
    {
        NSString *gidName = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[NSString stringWithFormat:@"当前只归属%@，无法选择其他企业",gidName] isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }

    
    //关闭推送计数
    [[QFXmppManager shareInstance]closeMessageCount];
    
    //要把openfire下线
    [[QFXmppManager shareInstance] goOffline];
    //                   更新一次可见性表
    //                ContactsViewController * updateSee=[[ContactsViewController alloc]init];
    
    [SqlAddressData deleteLeadertable];
    [SqlAddressData deleteVisilityContact];
    //                [updateSee  requestAdressBookVisible];
    
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:keyWindow];
    [keyWindow addSubview:HUD];
    HUD.labelText = @"正在切换企业...";
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        [[ConstantObject sharedConstant] releaseAllValue];
        [[AFClient sharedClient] releaseAFClient];
        [[SqliteDataDao sharedInstanse] releaseData];
        [SqlAddressData releaseDataQueue];
        [[QFXmppManager shareInstance] releaseXmppManager];
        
        
        
        //       删除登录标识
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[LOGIN_FLAG filePathOfCaches] error:nil];
        //[[NSUserDefaults standardUserDefaults]removeObjectForKey:myPassWord];
        //[[NSUserDefaults standardUserDefaults]removeObjectForKey:JSSIONID];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MyUserInfo];
        //[[NSUserDefaults standardUserDefaults]removeObjectForKey:MOBILEPHONE];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:myGID];
        //                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:isSeeView];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //                  退出登录把通知栏的未读消息数置为0
        [self cancleApplicationNotification];
        MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
        MainViewController *maivc = (MainViewController *)mainct.mainVC;
        [maivc.tabbarButt3 setRemindNum:0];
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"未读个数"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } completionBlock:^{
        AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
        app.isSwitchEnterPrise = YES;
        [app login];
    }];
}

-(void)cancleApplicationNotification
{
    
    [ConstantObject app].unReadNum=0;
    
}

@end
