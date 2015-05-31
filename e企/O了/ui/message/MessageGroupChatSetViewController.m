//
//  RYGroupChatSetViewController.m
//  OChat
//
//  Created by 卢鹏达 on 14-1-8.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#define GROUPCHAT_SET @200          //登录成功
#define SECTION_HEIGHT 8            //TableView组间距
#define SET_ICON_XY 10              //头像距离x、y的坐标
#define SET_ICON_MARGIN_VERTICALITY 15 //垂直头像间距
#define SET_ICON_MARGIN_HORIZONTALITY 5 //水平头像间距
#define SET_ICON_WIDTH 59           //头像宽
#define SET_ICON_HEIGHT 80          //头像高
#define SET_ICON_MAXNUM 4           //每行最大显示数量
#import "MessageGroupmembersViewController.h"

#define TAG_CHATICON_START 200      //头像的开始tag
#define TAG_NOT_DISTRUB 199 //消息免打扰
#define tag_minus_butt 1000 //减人按钮的开始tag

#define butt_tag_invite 0//邀请
#define butt_tag_zhiding 1//置顶
#define butt_tag_clear 2//清空
#define butt_tag_exit 3//退出

#import "MessageGroupChatSetViewController.h"
#import "ButtonTopImageAndBottomTitle.h"
#import "MessageGroupChatSetNameViewController.h"
#import "menber_info.h"
#import "GroupChatInfo.h"
#import "MessageChatViewController.h"
#import "UserDetailViewController.h"
#import "AFClient.h"
#import "PersonInfoViewController.h"

#import "UIButton+WebCache.h"

static NSString *const haveSendMessage=@"haveSendMessage";


@interface MessageGroupChatSetViewController (){
    MBProgressHUD *_progressHUD;
    int priority;///<是否是优先级
}

@end

@implementation MessageGroupChatSetViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    priority=[[SqliteDataDao sharedInstanse] queryPriorityWithToUserId:self.roomInfoModel.roomJid];
    
    [self initialView];
}

- (void)viewDidAppear:(BOOL)animated
{
    //    if (self.groupChatInfo.allMember.count>2) {
    //        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    //        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //        [self.tableView reloadData];
    //    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark 初始化TableView

-(void)headImageList{
    //群成员设置——headerView
    
    UIView *bgView=[[UIView alloc] init];
    bgView.backgroundColor=[UIColor colorWithRed:0.970 green:0.971 blue:0.965 alpha:1.000];
    
    CGRect screenFrame=[UIScreen mainScreen].bounds;
    UIButton *inviteButt=[UIButton buttonWithType:UIButtonTypeCustom];
    inviteButt.frame=CGRectMake(SET_ICON_XY, SET_ICON_XY,screenFrame.size.width-2*SET_ICON_XY, 50);
    [inviteButt setBackgroundColor:[UIColor colorWithRed:0.471 green:0.721 blue:0.207 alpha:1.000]];
    [inviteButt addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
    inviteButt.layer.cornerRadius=3;
    [inviteButt setTitle:@"邀请他人加入聊天" forState:UIControlStateNormal];
    [bgView addSubview:inviteButt];
    
    UIImage *bgImage=[UIImage imageNamed:@"GroupChat_Set_Icon_Background.png"];
    UIImage *newImage=[bgImage stretchableImageWithLeftCapWidth:15 topCapHeight:20];
    UIImageView *backgroundView=[[UIImageView alloc]initWithImage:newImage];
    backgroundView.userInteractionEnabled=YES;
    
    //添加群成员头像
    int count=0;
    
    switch (self.chatType) {
        case 0:
        {
            count=1;
            break;
        }
        case 1:
        {
            count=self.roomInfoModel.roomMemberList.count;
            break;
        }
        case 2:
        {
            break;
        }
        default:
            break;
    }
    
    
    CGRect rect=CGRectMake(SET_ICON_XY, SET_ICON_XY, SET_ICON_WIDTH, SET_ICON_HEIGHT);
    for (int i=0; i<count; i++) {
        EmployeeModel *member=self.roomInfoModel.roomMemberList[i];
        //  DDLogInfo(@"member---%@-----member",member.phone);
        
        rect.origin.x=(SET_ICON_MARGIN_VERTICALITY+SET_ICON_WIDTH)*(i%SET_ICON_MAXNUM)+SET_ICON_XY;
        rect.origin.y=(SET_ICON_MARGIN_HORIZONTALITY+SET_ICON_HEIGHT)*(i/SET_ICON_MAXNUM)+SET_ICON_XY;
        ButtonTopImageAndBottomTitle *chatSetIcon=[[ButtonTopImageAndBottomTitle alloc]initWithFrame:rect];
        [chatSetIcon addTarget:self action:@selector(GoUserInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        
        chatSetIcon.tag=TAG_CHATICON_START+i;
        //       chatSetIcon.imageView.contentMode=UIViewContentModeScaleAspectFill;
        //[chatSetIcon addTarget:self action:@selector(goUserDetail:) forControlEvents:UIControlEventTouchUpInside];
        [chatSetIcon setTitle:member.name forState:UIControlStateNormal];
        
        
        [chatSetIcon setImageWithURL:[NSURL URLWithString:member.avatarimgurl] forState:UIControlStateNormal placeholderImage:defaultHeadImage];
        
        [backgroundView addSubview:chatSetIcon];
    }
    
    //头像添加按钮
    //    rect.origin.x=(SET_ICON_MARGIN_VERTICALITY+SET_ICON_WIDTH)*(count%SET_ICON_MAXNUM)+SET_ICON_XY;
    //    rect.origin.y=(SET_ICON_MARGIN_HORIZONTALITY+SET_ICON_HEIGHT)*(count/SET_ICON_MAXNUM)+SET_ICON_XY;
    //    ButtonTopImageAndBottomTitle *addSetIcon=[[ButtonTopImageAndBottomTitle alloc]initWithFrame:rect];
    //    [addSetIcon setImage:[UIImage imageNamed:@"GroupChat_Set_Icon_Add.png"] forState:UIControlStateNormal];
    //    [addSetIcon addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
    //    [backgroundView addSubview:addSetIcon];
    
    //    if ([@"" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]] && [self.groupChatInfo.taskType isEqualToString:@"1"]) {
    //
    //        //只有创建者才可以删减成员
    //        if (rect.origin.x==232) {
    //            //需要换行
    //            rect.origin.x=SET_ICON_XY;
    //            rect.origin.y=(SET_ICON_MARGIN_HORIZONTALITY+SET_ICON_HEIGHT)*(count/SET_ICON_MAXNUM)+SET_ICON_XY+SET_ICON_HEIGHT+SET_ICON_MARGIN_HORIZONTALITY;
    //        }else{
    //            //不需要换行
    //            rect.origin.x=(SET_ICON_MARGIN_VERTICALITY+SET_ICON_WIDTH)*(count%SET_ICON_MAXNUM)+SET_ICON_XY+SET_ICON_WIDTH+SET_ICON_MARGIN_VERTICALITY;
    //
    //        }
    //
    //        ButtonTopImageAndBottomTitle *minusSetIcon=[[ButtonTopImageAndBottomTitle alloc] init];
    //        minusSetIcon.frame=rect;
    //        [minusSetIcon setImage:[UIImage imageNamed:@"group_minus"] forState:UIControlStateNormal];
    //        [minusSetIcon addTarget:self action:@selector(minusGroup:) forControlEvents:UIControlEventTouchUpInside];
    //        [backgroundView addSubview:minusSetIcon];
    //    }
    
    
    //背影图片frame设置，自适应图片大小
    
    //    backgroundView.frame=CGRectMake(SET_ICON_XY, SET_ICON_XY+inviteButt.frame.origin.y+inviteButt.frame.size.height, screenFrame.size.width-2*SET_ICON_XY, rect.origin.y+rect.size.height+SET_ICON_XY);
    //    //    UIView *headerView=[[UIView alloc]init];
    //    //headerview的frame设置，自适应背景图片大小
    //    bgView.frame=CGRectMake(0, 0, 0, backgroundView.frame.size.height+backgroundView.frame.origin.y + 20);
    //    [bgView addSubview:backgroundView];
    //
    //    self.tableView.tableHeaderView=bgView;
}
//个人信息页面
-(void)GoUserInfoPage:(UIButton *)button{
    int count = self.roomInfoModel.roomMemberList.count;
    for (int i = 0; i < count; i ++) {
        if (button.tag - TAG_CHATICON_START == i) {
            EmployeeModel *member=self.roomInfoModel.roomMemberList[i];
                UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
                userDetail.userInfo = member;
            userDetail.organizationName = member.comman_orgName;
                userDetail.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:userDetail animated:YES];
                
                DDLogInfo(@"member.phone%@",member.imacct);
            
        }
    }
    
    DDLogInfo(@"hahahaah%d",self.roomInfoModel.roomMemberList.count);
    
}

- (void)initialView
{
    self.title=@"聊天信息";
    //leftBarButtonItem设置
    /*
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
    //组间距
    self.tableView.sectionFooterHeight=0;
    self.tableView.sectionHeaderHeight=11;
    
    //    [self headImageList];
    //退出按钮设置——footerView
    UIButton *exitButton=[UIButton buttonWithType:UIButtonTypeCustom];
    exitButton.frame=CGRectMake(10, 20,300,43);
    exitButton.tag=3;
    [exitButton setBackgroundColor:[UIColor colorWithRed:230/255.0 green:54/255.0 blue:65/255.0 alpha:1]];
    //[UIColor colorWithRed:0.987 green:0.224 blue:0.273 alpha:1.000]
    [exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    exitButton.layer.cornerRadius=3;
    [exitButton addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
    [exitButton setTitle:@"删除并退出群聊" forState:UIControlStateNormal];
    
    UIView *footerView=[[UIView alloc]init];
    footerView.frame=CGRectMake(0, 0, 0, 70);
    [footerView addSubview:exitButton];
    self.tableView.tableFooterView=footerView;
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 14, 0, 0)];
//    [self.tableView setSeparatorColor:[UIColor redColor]];

    //tableview的额外滚动区域设置
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
    self.tableView.backgroundColor=[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.chatType==0) {
        return 1;
    }else if (self.chatType==1){
        return 4;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 2;
    }else if(section==1){
        return 1;
    }else if(section==2){
        return  1;
    }else if (section==3){
        return 1;
    }
    return  1;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//    return nil;
//    if (self.chatType==1) {
//        UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 39)];
//        headerView.backgroundColor=[UIColor whiteColor];
//
//        UIMyLabel *label=[[UIMyLabel alloc] initWithFrame:CGRectMake(SET_ICON_XY, (headerView.frame.size.height-20)/2, 200, 20)];
//        label.text=@"接收新消息通知";
//        label.textAlignment=NSTextAlignmentLeft;
//        label.font=[UIFont systemFontOfSize:16];
//        [headerView addSubview:label];
//
//        UIButton *butt=[UIButton buttonWithType:UIButtonTypeCustom];
//        butt.frame=CGRectMake(tableView.frame.size.width-50-10, (headerView.frame.size.height-31)/2, 50, 31);
//        [butt addTarget:self action:@selector(chackButt:) forControlEvents:UIControlEventTouchUpInside];
//        [butt setBackgroundImage:[UIImage imageNamed:@"group_set_Chack_Close"] forState:UIControlStateSelected];
//        [butt setBackgroundImage:[UIImage imageNamed:@"Chack_Open.png"] forState:UIControlStateNormal];
//
//        NSMutableArray *arrayDistrub=[[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:NO_DISTURB_MEMBER];
//        if (arrayDistrub!=nil&&[arrayDistrub containsObject:self.roomInfoModel.roomJid]) {
//            butt.selected=YES;
//        }
//
//        [headerView addSubview:butt];
//
//        return headerView;
//    }else{
//        return nil;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0)
        return 0;
    else
        return 11;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        if(indexPath.row==0){
            return  30;
        }else{
            return  56;
        }
    }else if(indexPath.section==4){
        return 200;
    }else{
        return 44;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=nil;
    if(indexPath.section==0){
        if(indexPath.row==0){
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0-0"];
            cell.selectionStyle=UITableViewCellAccessoryNone;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(14, 0, 80, 30)];
            label1.font=[UIFont systemFontOfSize:13];
            label1.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
            label1.text=@"群成员";
            [cell addSubview:label1];
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(240, 0, 50, 30)];
            label.textAlignment=NSTextAlignmentRight;
            label.font=[UIFont systemFontOfSize:13];
            label.textColor=[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
            label.text=[NSString stringWithFormat:@"%d人",self.roomInfoModel.roomMemberList.count];
            UIView *linetop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
            linetop.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//                    linetop.backgroundColor=[UIColor redColor];
            [cell addSubview:label];
            [cell addSubview:linetop];
        }else{
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0-1"];
            cell.selectionStyle=UITableViewCellAccessoryNone;
            int count=self.roomInfoModel.roomMemberList.count;
            if(count>5)
                count=5;
            for(int i=0;i<count;i++){
                EmployeeModel *member=self.roomInfoModel.roomMemberList[i];
                ButtonTopImageAndBottomTitle *chatSetIcon=[[ButtonTopImageAndBottomTitle alloc]initWithFrame:CGRectMake(14+i*45, 12, 35, 35)];
                [chatSetIcon addTarget:self action:@selector(GoUserInfoPage:) forControlEvents:UIControlEventTouchUpInside];
                chatSetIcon.tag=TAG_CHATICON_START+i;
                [chatSetIcon setImageWithURL:[NSURL URLWithString:member.avatarimgurl] forState:UIControlStateNormal placeholderImage:defaultHeadImage];
                [cell addSubview:chatSetIcon];
            }
            UIButton *addmember=[[UIButton alloc]initWithFrame:CGRectMake(14+count*45, 12, 36, 36)];
            [addmember setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"2_btn_contact_add.png"]]];
            addmember.tag=butt_tag_invite;
            //            [addmember setBackgroundColor:[UIColor redColor]];
            [addmember addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:addmember];
            UIView *linebon=[[UIView alloc]initWithFrame:CGRectMake(0, 55.5, 320, 0.5)];
            linebon.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//            linebon.backgroundColor=[UIColor redColor];
            [cell addSubview:linebon];
        }
    }else if(indexPath.section==1){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"1-1"];
        cell.selectionStyle=UITableViewCellAccessoryNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(14, 2, 180, 40)];
        label1.font=[UIFont systemFontOfSize:15];
        label1.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label1.text=@"群组名称";
        [cell addSubview:label1];
//        cell.textLabel.text=@"群组名称";
//        cell.textLabel.textColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(320-190-30, 0, 190, 44)];
        label.textAlignment=NSTextAlignmentRight;
        label.font=[UIFont systemFontOfSize:14];
        label.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        label.text=[NSString stringWithFormat:@"%@",self.roomInfoModel.roomName];
        [cell addSubview:label];
        UIView *linetop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
        linetop.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//                linetop.backgroundColor=[UIColor redColor];
        [cell addSubview:linetop];
        UIView *linebon=[[UIView alloc]initWithFrame:CGRectMake(0,43.5, 320, 0.5)];
        linebon.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//        linebon.backgroundColor=[UIColor redColor];
        [cell addSubview:linebon];
        
    }else if(indexPath.section==2){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"2-1"];
        cell.selectionStyle=UITableViewCellAccessoryNone;
        UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(14, 2, 180, 40)];
        label1.font=[UIFont systemFontOfSize:15];
        label1.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label1.text=@"置顶会话";
        [cell addSubview:label1];
//        cell.textLabel.text=@"置顶会话";
//        cell.textLabel.textColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        UISwitch *button=[[UISwitch alloc]initWithFrame:CGRectMake(320-50-14, 6, 50, 36)];
        if(priority){
            [button setOn:YES];
        }else{
            [button setOn:NO];
        }
        button.onTintColor=[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1];
        button.tag=butt_tag_zhiding;
        [button addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:button];
        UIView *linetop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
        linetop.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//                linetop.backgroundColor=[UIColor redColor];
        [cell addSubview:linetop];
        UIView *linebon=[[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height-0.5, 320, 0.5)];
        linebon.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//        linebon.backgroundColor=[UIColor redColor];
        [cell addSubview:linebon];
    }else if(indexPath.section==3){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"3-1"];
        cell.selectionStyle=UITableViewCellAccessoryNone;
        UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(14, 0, 180, 44)];
        label1.font=[UIFont systemFontOfSize:15];
        label1.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label1.text=@"清空聊天记录";
        [cell addSubview:label1];
//        cell.textLabel.text=@"清空聊天记录";
//        cell.textLabel.textColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
        UIView *linetop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
        linetop.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//        linetop.backgroundColor=[UIColor redColor];
        [cell addSubview:linetop];
        UIView *linebon=[[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height-0.5, 320, 0.5)];
        linebon.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//            linebon.backgroundColor=[UIColor redColor];
        [cell addSubview:linebon];
    }
//    UIView *linetop=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
//    linetop.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//    [cell addSubview:linetop];
//    
//    UIView *linebon=[[UIView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height-0.5, 320, 0.5)];
//    linebon.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1];
//  
//    [cell addSubview:linebon];
    return  cell;
    /*
     int count=self.groupChatInfo.allMember.count;
     //群聊名称、全部成员
     if (count>2&&indexPath.section==0) {
     cell=[tableView dequeueReusableCellWithIdentifier:@"ChatName"];
     if (cell==nil) {
     cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ChatName"];
     cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
     cell.selectionStyle=UITableViewCellSelectionStyleNone;
     }
     cell.textLabel.text=@"群聊名称";
     cell.detailTextLabel.text=self.groupChatInfo.name;
     if (self.groupChatInfo.name==nil||[self.groupChatInfo.name isEqualToString:@""]) {
     cell.detailTextLabel.text=@"未命名";
     }
     return cell;
     }
     //置顶聊天
     if ((count>2&&indexPath.section==1)||(count<=2&&indexPath.section==0)) {
     cell=[tableView dequeueReusableCellWithIdentifier:@"StickChat"];
     if (cell==nil) {
     cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StickChat"];
     cell.selectionStyle=UITableViewCellSelectionStyleNone;
     UIImageView *accessoryView=[[UIImageView alloc]init];
     if (self.groupChatInfo.priority == 0) {
     accessoryView.image = [UIImage imageNamed:@"group_set_Chack_Close"];
     }else{
     accessoryView.image = [UIImage imageNamed:@"Chack_Open.png"];
     }
     
     accessoryView.bounds=CGRectMake(0, 0, 50, 31);
     cell.accessoryView=accessoryView;
     }
     cell.textLabel.text=@"置顶聊天";
     return cell;
     }
     if (count>2) {
     //消息免打扰
     cell=[tableView dequeueReusableCellWithIdentifier:@"StickChat"];
     if (cell==nil) {
     cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StickChat"];
     cell.selectionStyle=UITableViewCellSelectionStyleNone;
     NSArray *arrayNotDistrub=[[NSUserDefaults standardUserDefaults] arrayForKey:NO_DISTURB_MEMBER];
     UIImageView *accessoryView=nil;
     if (arrayNotDistrub!=nil&&[arrayNotDistrub containsObject:self.groupChatInfo.taskID]) {
     accessoryView.tag=TAG_NOT_DISTRUB;
     accessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Chack_Open.png"]];
     }else{
     accessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"group_set_Chack_Close"]];
     }
     accessoryView.bounds=CGRectMake(0, 0, 50, 31);
     cell.accessoryView=accessoryView;
     }
     cell.textLabel.text=@"群消息免打扰";
     }
     return cell;
     */
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        if (indexPath.row == 0) {
            MessageGroupmembersViewController * members = [[MessageGroupmembersViewController alloc]init];
            members.roomJid = self.roomInfoModel.roomJid;
            members.MembersArray = (NSMutableArray *)[NSMutableArray arrayWithArray:self.roomInfoModel.roomMemberList];
            members.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:members animated:YES];
        }
    }
    if(indexPath.section==1){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改群名称" message:@"请输入群聊名称:" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        UITextField *alertTextField=[alert textFieldAtIndex:0];
        alertTextField.delegate=self;
        alertTextField.text=self.roomInfoModel.roomName;
        alertTextField.placeholder=@"";
        alert.tag=1;
        [alert show];

        
        
    }
    if(indexPath.section==3){
        [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:self.roomInfoModel.roomJid];
        if (self.clearChatData) {
            self.clearChatData();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
        
        [[ConstantObject app] showWithCustomView:@"清空聊天记录成功" detailText:nil isCue:0 delayTime:1 isKeyShow:NO];
    }
    //    int count=self.groupChatInfo.allMember.count;
    //    //群聊名称
    //    if (count>2&&indexPath.section==0) {
    //        MessageGroupChatSetNameViewController *groupChatName=[[MessageGroupChatSetNameViewController alloc]initWithStyle:UITableViewStyleGrouped];
    //        groupChatName.hidesBottomBarWhenPushed=YES;
    //        groupChatName.groupChatInfo=self.groupChatInfo;
    //        [self.navigationController pushViewController:groupChatName animated:YES];
    //        return;
    //    }
    //    if ((count>2&&indexPath.section==1)||(count<=2&&indexPath.section==0)) {
    //        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    //        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
    //        if (self.groupChatInfo.priority !=0 ) {
    //            self.groupChatInfo.priority = 0;//取消置顶
    //            accessoryView.image=[UIImage imageNamed:@"group_set_Chack_Close"];
    //        }else{
    ////            self.groupChatInfo.priority = [SqliteDataDao queryMaxPriority] + 1;//置顶
    //
    //            accessoryView.image=[UIImage imageNamed:@"Chack_Open.png"];
    //        }
    ////        [SqliteDataDao updateTaskGroupPriority:self.groupChatInfo.priority ofTaskId:self.groupChatInfo.taskID];
    //
    //        return;
    //    }
    //    //消息免打扰
    //    if (count>2) {
    //        NSMutableArray *arrayDistrub=[[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:NO_DISTURB_MEMBER];
    //        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    //        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
    //        if (accessoryView.tag==TAG_NOT_DISTRUB) {
    //            accessoryView.tag=0;
    //            accessoryView.image=[UIImage imageNamed:@"group_set_Chack_Close"];
    //            [arrayDistrub removeObject:self.groupChatInfo.taskID];
    //        }else{
    //            accessoryView.tag=TAG_NOT_DISTRUB;
    //            accessoryView.image=[UIImage imageNamed:@"Chack_Open.png"];
    //            [arrayDistrub addObject:self.groupChatInfo.taskID];
    //        }
    //        [[NSUserDefaults standardUserDefaults]synchronize];
    //        return;
    //    }
}
#pragma mark -邀请人加入
-(void)GetArrayID:(RoomInfoModel *)roomModel{
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=1;
    detailViewController.roomInfoModel=roomModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
#pragma mark - Button按钮事件
-(void)buttClick:(UIButton *)butt{
    switch (butt.tag) {
        case butt_tag_invite:
        {
            //邀请
            
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
            NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
            nav_add.addScrollType=AddScrollTypeInvite;
            nav_add.delegate_addID = self;
            
            NSMutableArray *tempArray=[[NSMutableArray alloc] init];
            for (EmployeeModel *em in self.roomInfoModel.roomMemberList) {
                if(em.phone != nil){
                    [tempArray addObject:em.phone];
                }
            }
            nav_add.phoneArray=tempArray;
            nav_add.roomInfoModel=self.roomInfoModel;
            [self presentViewController:nav_add animated:YES completion:^{
                
            }];
            break;
        }
        case butt_tag_zhiding:
        {
            //置顶
            if (priority==0) {
                [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:self.roomInfoModel.roomJid priority:1];
                priority=1;
            }else{
                priority=0;
                [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:self.roomInfoModel.roomJid priority:0];
            }
            break;
        }
        case butt_tag_clear:
        {
            //清空
            [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:self.roomInfoModel.roomJid];
            if (self.clearChatData) {
                self.clearChatData();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
            
            [[ConstantObject app] showWithCustomView:@"清空聊天记录成功" detailText:nil isCue:0 delayTime:1 isKeyShow:NO];
            break;
        }
        case butt_tag_exit:
        {
            //退出群聊
            [self exitAndDelete:nil];
            break;
        }
        default:
            break;
    }
}
-(void)chackButt:(UIButton *)butt{
    NSMutableArray *arrayDistrub=[[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:NO_DISTURB_MEMBER];
    
    if (!butt.selected) {
        
        [arrayDistrub addObject:self.roomInfoModel.roomJid];
        
    }else{
        [arrayDistrub removeObject:self.roomInfoModel.roomJid];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    butt.selected=!butt.selected;
}
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 进入用户详情
- (void)goUserDetail:(UIButton *)sender
{
    //    DDLogInfo(@"用户详情");
    UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
    userDetail.hidesBottomBarWhenPushed=YES;
    userDetail.userInfo=self.roomInfoModel.roomMemberList[sender.tag-TAG_CHATICON_START];
    [self.navigationController pushViewController:userDetail animated:YES];
}
/*
 #pragma mark - 减少人员
 -(void)addSmailShanchuButt{
 int count=self.groupChatInfo.allMember.count;//成员数量
 for (int i=0; i<count; i++) {
 //        chatSetIcon.tag=TAG_CHATICON_START+i;
 menber_info *member=self.groupChatInfo.allMember[i];
 if ([member.telNum isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]]) {
 //不添加删除按钮
 }else{
 ButtonTopImageAndBottomTitle *headButt=(ButtonTopImageAndBottomTitle *)[self.view viewWithTag:TAG_CHATICON_START+i];
 
 UIButton *smailMinusButt=[UIButton buttonWithType:UIButtonTypeCustom];
 smailMinusButt.frame=CGRectMake(0, 0, 20, 20);
 smailMinusButt.tag=tag_minus_butt+i;
 [smailMinusButt setImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
 [smailMinusButt addTarget:self action:@selector(smailMinusButtClick:) forControlEvents:UIControlEventTouchUpInside];
 [headButt addSubview:smailMinusButt];
 }
 
 }
 }
 -(void)minusGroup:(id)sender{
 //
 ButtonAudioRecorder *butt;
 if (sender!=nil) {
 butt=sender;
 if (!butt.selected) {
 //首次点击
 [self addSmailShanchuButt];
 }else{
 self.tableView.tableHeaderView=nil;
 [self headImageList];
 }
 butt.selected=!butt.selected;
 }else{
 [self addSmailShanchuButt];
 }
 
 
 
 
 
 }
 #pragma mark - 删除操作
 -(void)smailMinusButtClick:(id)sender{
 
 }
 */
#pragma mark 添加群聊成员
- (void)addGroup:(UIButton *)sender
{
    
}
#pragma mark =====navigation_addIDDelegaet

//排序方法
NSComparator cmptrMenber = ^(id obj1, id obj2){
    menber_info *menb1 = obj1;
    menber_info *menb2 = obj2;
    return [menb1.telNum compare:menb2.telNum];
};

-(void)CreateDialogue:(NSMutableArray *)mutArray{
    
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
    
    [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
    [_HUD show:YES];
}
#pragma mark 删除并退出
- (void)exitAndDelete:(UIButton *)sender
{
    
    UIAlertView *exitAlert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定要退出群组？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [exitAlert show];
    
    
}
#pragma  mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){//修改群名称提示回调
        if(buttonIndex==1){//调用群名称修改
            UITextField *alertTextField=[alertView textFieldAtIndex:0];
            NSString *str=alertTextField.text;
            str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
           
            if(str.length>0){
                if(alertTextField.text.length>30){
                    [[ConstantObject app] showWithCustomView:nil detailText:@"群名不能超过30个字" isCue:1 delayTime:1 isKeyShow:YES];
                }else{
                    QFXmppManager *xmppManager=[QFXmppManager shareInstance];
                    [xmppManager  ChangeRoomName:self.roomInfoModel.roomJid name:alertTextField.text compltion:^(BOOL ret){
                        NSLog(@"修改群名称成功%d",ret);
                        self.roomInfoModel.roomName=alertTextField.text;
                        [self.tableView reloadData];
                    }];
                }
            }else{
                [[ConstantObject app] showWithCustomView:nil detailText:@"不能使用空的主题" isCue:1 delayTime:1 isKeyShow:YES];
            }
        }
        
    }else{//退出登录提示回调
        if (buttonIndex==1) {
            _progressHUD=[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            _progressHUD.removeFromSuperViewOnHide=YES;
            _progressHUD.minSize=CGSizeMake(140, 130);
            _progressHUD.labelFont=[UIFont systemFontOfSize:15];
            _progressHUD.labelText=@"退出中...";
            
            
            QFXmppManager *xmppManager=[QFXmppManager shareInstance];
            XMPPRoom *room=[xmppManager.roomDict objectForKey:self.roomInfoModel.roomJid];
            /*
             NSMutableArray *tempArray=[[NSMutableArray alloc] init];
             for (EmployeeModel *em in self.roomInfoModel.roomMemberList) {
             if ([em.imacct isEqualToString:[ConstantObject sharedConstant].userInfo.imacct] || em.imacct == nil) {
             continue;
             }
             [tempArray addObject:em];
             }
             room.roomMemberList=tempArray;
             */
            if (!room) {
                [_progressHUD hide:YES];
                [[ConstantObject app] showWithCustomView:@"退出失败,请稍候重试!" detailText:nil isCue:1 delayTime:1 isKeyShow:NO];
                return;
            }
            [xmppManager outRoom:room compltion:^(BOOL ret) {
                [_progressHUD hide:YES];
                if (ret) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    [[SqliteDataDao sharedInstanse] deleteRoomWithRoomJid:self.roomInfoModel.roomJid];
                    [xmppManager.roomDict removeObjectForKey:self.roomInfoModel.roomJid];
                    //                [xmppManager massGroupCreatMessage:room.roomMemberList room:room];
                    [[ConstantObject app] showWithCustomView:@"退出群组成功" detailText:nil isCue:0 delayTime:1 isKeyShow:NO];
                    //退出群聊，发通知刷新表
                    [[NSNotificationCenter defaultCenter] postNotificationName:haveSendMessage object:self userInfo:nil];
                }else{
                    [[ConstantObject app] showWithCustomView:@"退出失败,请稍候重试!" detailText:nil isCue:1 delayTime:1 isKeyShow:NO];
                }
            }];
        }
    }
}
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    
    if(alertView.tag==1){
        UITextField *alertTextField=[alertView textFieldAtIndex:0];
        if (alertTextField.text.length>30) {
            return NO;
        }
    }
    return YES;

}
#pragma mark 操作成功  退出群组
- (void)exitSuccess:(id)JSON
{
    DDLogInfo(@"%@",JSON);
    if ([JSON[@"result"] isEqualToNumber:GROUPCHAT_SET]) {
        _progressHUD.labelText=@"修改成功";
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        _progressHUD.labelText=@"修改失败";
    }
    [_progressHUD hide:YES afterDelay:1];
}
#pragma mark 操作失败
- (void)exitFailure:(id)JSON
{
    _progressHUD.labelText=@"修改失败";
    [_progressHUD hide:YES afterDelay:1];
}
@end
