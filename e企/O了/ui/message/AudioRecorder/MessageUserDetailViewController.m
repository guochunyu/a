//
//  MessageUserDetailViewController.h
//  e企
//
//  Created by HC_hmc on 15/3/12.
//  Copyright (c) 2015年 QYB. All rights reserved.
//
#define SUCESS @200 //操作成功

#define CELL_CONTENT_WIDTH 290  //tableView行宽
#define DEFAULT_CELL_HEIGHT 44      //tableView默认行高
#define ICON_CELL_HEIGHT 80     //头像所在行高
#define FONT_SIZE 17            //tableview行内默认字体大小
#define MARGIN_BUTTON 10        //button按钮的间距
#define FIELDS_SORT @"fieldsSort"   //排序字段
#import "MessageUserDetailViewController.h"
#import "UserDetailCell.h"
#import "MessageChatViewController.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#import "AFClient.h"
#import "MainNavigationCT.h"
#import "MBProgressHUD.h"
//#import "ZJSwitch.h"
#import "UserDetailViewController.h"
#import "EmployeeModel.h"
/**
 * button功能类型
 */
typedef enum {
    ButtonFunctionTypeFreqContacts=1,   ///<常用联系人
    ButtonFunctionTypeSaveContact=2,     ///<保存到本地
    ButtonFunctionTypeMessage=3,        ///<发送短信
    ButtonFunctionTypeCallShortNum=4,   ///<拨打短号
    ButtonFunctionTypeCallMobilePhone=5,   ///<拨打电话
    ButtonFunctionTypeCallSendEmail ///<发送邮件
}ButtonFunctionType;

@interface MessageUserDetailViewController ()<UIAlertViewDelegate,ABUnknownPersonViewControllerDelegate>{
    MBProgressHUD *_progressHUD;
    NSMutableArray *_UserDetailColumnName;
    
    UIButton *_btnFreq;
    UIButton *_btnSave;
    BOOL      flag;
    int clickCount;
    int priority;///<优先级
    NSString       * userPhone;
}
@end

@implementation MessageUserDetailViewController
@synthesize userInfo=_userInfo,organizationName=_organizationName;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
    EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
    self.UserPhoto = model.avatarimgurl;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.detailType==1) {
        priority=[[SqliteDataDao sharedInstanse] queryPriorityWithToUserId:self.userInfo.imacct];
    }

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
    self.tableView.backgroundView=nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor=[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    
    UIView *footerView=[[UIView alloc]init];
    footerView.frame=CGRectMake(0, 0, 0, 70);
    self.tableView.tableFooterView=footerView;

    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    self.commanArray= [SqlAddressData selectCommanContact:uid];
    self.title=self.userInfo.name;
    
    for (EmployeeModel *comman in _commanArray) {
        if ([self.userInfo.name isEqualToString:comman.name]) {
            self.userInfo.freqFlag=1;
            break;
        }
    }
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidAppear:(BOOL)animated
{
}
#pragma mark - Table view data source
-(void)showBigHeadImg:(UIButton *)headerTap{
    

 
    UserDetailViewController *userDetailVC=[[UserDetailViewController alloc] init];
    userDetailVC.userInfo=self.userInfo;
    userDetailVC.hidesBottomBarWhenPushed=YES;
    userDetailVC.isFromChat=YES;
    [self.navigationController pushViewController:userDetailVC animated:YES];
    
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
#pragma mark tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0)
        return 0;
    else
        return 11;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return  56;
    }else{
        return 44;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=nil;
    if(indexPath.section==0){
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"0-1"];
        cell.selectionStyle=UITableViewCellAccessoryNone;
        //头像
        UIImageView * headImg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 36, 36)];
        headImg.layer.masksToBounds = YES;
        headImg.layer.cornerRadius = headImg.frame.size.width * 0.5;
        UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(14, 12, 36, 36);
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
        
        //
        UIButton *addmember=[[UIButton alloc]initWithFrame:CGRectMake(14+45, 12, 36, 36)];
        [addmember setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"2_btn_contact_add.png"]]];
        addmember.tag=1;
        //            [addmember setBackgroundColor:[UIColor redColor]];
        [addmember addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:addmember];
        
        
    }else if(indexPath.section==1){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"2-1"];
        cell.selectionStyle=UITableViewCellAccessoryNone;
        cell.textLabel.text=@"置顶会话";
        cell.textLabel.textColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        UISwitch *button=[[UISwitch alloc]initWithFrame:CGRectMake(320-50-14, 6, 50, 36)];
        if(priority){
            [button setOn:YES];
        }else{
            [button setOn:NO];
        }
        button.onTintColor=[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1];
        button.tag=2;
        [button addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
    }else if(indexPath.section==2){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"3-1"];
        cell.selectionStyle=UITableViewCellAccessoryNone;
        cell.textLabel.text=@"清空聊天记录";
        cell.textLabel.textColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    }
    return  cell;
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==2){
        [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:self.userInfo.imacct];
        if (self.clearChatData) {
            self.clearChatData();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
        
        [[ConstantObject app] showWithCustomView:@"清空聊天记录成功" detailText:nil isCue:0 delayTime:1 isKeyShow:NO];
    }
}

#pragma mark - 自定义target方法
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - buttClick
#pragma mark 邀请，置顶
-(void)buttClick:(id)sender{
    UIButton *button=(UIButton *)sender;
    if(button.tag==1){
        //邀请他人，创建群聊
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
    }else{
        //置顶
        if (self.detailType==1) {
            //置顶回话
            if (priority==0) {
                [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:self.userInfo.imacct priority:1];
                priority=1;
            }else{
                priority=0;
                [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:self.userInfo.imacct priority:0];
            }
        }
    }
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
    [self.tableView reloadData];
}
#pragma mark 隐藏指示器
- (void)hideProgressHud:(MBProgressHUD *)progressHUD withText:(NSString *)msg
{
    NSLog(@"显示view");
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
