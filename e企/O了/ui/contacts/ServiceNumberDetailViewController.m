//
//  ServiceNumberDetailViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-3-5.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define SUCCESS @200    //成功的状态码
#define EXIST @400      //已存在

#define CELL_CONTENT_WIDTH 290  //tableView行宽
#define DEFAULT_CELL_HEIGHT 44      //tableView默认行高
#define ICON_CELL_HEIGHT 80     //头像所在行高
#define FONT_SIZE 17            //tableview行内默认字体大小

#import "ServiceNumberDetailViewController.h"
#import "ServiceNumberDetailCell.h"
#import "MessageChatViewController.h"
#import "MBProgressHUD.h"

#import "PublicAccountClient.h"

static NSString *const haveSendMessage=@"haveSendMessage";


@interface ServiceNumberDetailViewController ()<UIAlertViewDelegate>{
    UIButton *_subscribButton;
    
    AFHTTPRequestOperation *_operation;
}

@end

@implementation ServiceNumberDetailViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}
-(void)getDetailData{
    [self addHUD:@"正在获取"];
    _operation=[[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"getpublicdetail" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlGetpublicdetailWithPa_uuid:self.publicaccontModel.pa_uuid] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hudWasHidden:nil];
//        <body>
//        <publicaccount>
//        <account>hr</account>
//        <company>IOS版和企录</company>
//        <logo>http://218.205.81.12/upload/picture/small/b544eface53244ea9f756886ae21b72f_small.jpg</logo>
//        <menutimestamp>2014-11-24 17:42:22</menutimestamp>
//        <name>hr</name>
//        <pa_uuid>5472fd7e24ac9b648a6e6cef</pa_uuid>
//        <recommendlevel>1</recommendlevel>
//        <sip_uri>padata1@pubacct.li726-26</sip_uri>
//        <subscribestatus>0</subscribestatus>
//        <type>0</type>
//        <updatetime>2014-11-24 17:42:22</updatetime>
//        </publicaccount> 
//        </body>
        NSError *error=nil;
        NSXMLElement *content_message=[[DDXMLElement alloc] initWithXMLString:operation.responseString error:&error];
        if (error) {
            DDLogInfo(@"解析出错");
        }
        NSXMLElement *x=[content_message elementForName:@"publicaccount"];
        NSString *subscribestatus=[[x elementForName:@"subscribestatus"] stringValue];
        if ([subscribestatus isEqualToString:@"0"]) {
            _subscribestatusType=0;
        }else{
            _subscribestatusType=1;
        }
        [self footView];
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        [self.navigationController popViewControllerAnimated:YES];
        [self faild];
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=self.publicaccontModel.name;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //后台执行
    [self getDetailData];
}
-(void)footView{
    
    
    
    UIView *footerView=[[UIView alloc]init];
    footerView.frame=CGRectMake(0, 0, 0, 60);
    
    UIButton *butt=[UIButton buttonWithType:UIButtonTypeCustom];
    butt.frame=CGRectMake(10, 10, 300, 40);
    [butt setTitle:_subscribestatusType==0?@"关注":@"取消关注" forState:UIControlStateNormal];
    [butt setBackgroundColor:_subscribestatusType==0?[UIColor colorWithRed:0.471 green:0.721 blue:0.207 alpha:1.000]:[UIColor colorWithRed:0.987 green:0.224 blue:0.273 alpha:1.000]];
    butt.layer.cornerRadius=3;
    [butt addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:butt];
    
    //退出按钮设置——footerView
    
    self.tableView.tableFooterView=footerView;
    //tableview的额外滚动区域设置
    self.tableView.contentInset=UIEdgeInsetsMake(0, 0, 10, 0);
//    self.tableView.scrollEnabled=NO;
    self.tableView.showsHorizontalScrollIndicator=NO;
    self.tableView.showsVerticalScrollIndicator=NO;
}
- (void)viewDidAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - 取消关注和关注
-(void)buttClick:(UIButton *)butt{
    [self addHUD:@"请求中..."];
    if (_subscribestatusType==0) {
        [[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"addsubscribe" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlAddsubscribeWithPa_uuid:self.publicaccontModel.pa_uuid] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self hudWasHidden:nil];
            DDLogInfo(@"公众号--%@",operation.responseString);
            
//            NSString * publicArray=[]
            _subscribestatusType=1;
            [butt setTitle:@"取消关注" forState:UIControlStateNormal];
            [butt setBackgroundColor:[UIColor colorWithRed:0.987 green:0.224 blue:0.273 alpha:1.000]];
            
            
//            [[SqliteDataDao sharedInstanse] insertDataToPublicData:]
            
            [self.tableView reloadData];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [self faild];
            
        }];
    }else{
        [[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"cancelsubscribe" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlAddsubscribeWithPa_uuid:self.publicaccontModel.pa_uuid] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"--");
            [self hudWasHidden:nil];
            _subscribestatusType=0;
            [butt setTitle:@"关注" forState:UIControlStateNormal];
            [butt setBackgroundColor:[UIColor colorWithRed:0.471 green:0.721 blue:0.207 alpha:1.000]];
            [self.tableView reloadData];
            
            //清空
            [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:self.publicaccontModel.pa_uuid];
            [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:self.publicaccontModel.pa_uuid];
            [[SqliteDataDao sharedInstanse] deletePublicDataWithPa_uuid:self.publicaccontModel.pa_uuid];
            //  关注公众号，刷新聊天列表
            [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
            
            if (self.removePublic) {
                self.removePublic();
            }
            
            if (self.isFromMessage) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self faild];
        }];
    }
    
    
}
-(void)faild{
    [self hudWasHidden:nil];
    [[ConstantObject app] showWithCustomView:nil detailText:@"获取失败" isCue:1 delayTime:1 isKeyShow:NO];
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
    _HUD.dimBackground = NO;
    _HUD.labelText = labelStr;
    _HUD.delegate=self;
    
    _HUD.userInteractionEnabled=YES;
    
    [self.view.superview addSubview:_HUD];
    [_HUD show:YES];
}
#pragma mark 后台获取服务号详情信息
- (void)backgroundGetSNInfo
{
    
}
#pragma mark - target 事件
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 订阅
- (void)subscribe:(UIButton *)sender{
    
}
#pragma mark 获取服务号菜单信息
- (NSArray *)serviceNumberMenu:(NSArray *)arrayMenu
{
    NSMutableArray *temMenu=[[NSMutableArray alloc]init];

    return temMenu;
}
#pragma mark - Table view data source
#pragma mark section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_subscribestatusType==0) {
        return 2;
    }
    return 4;
}
#pragma mark row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 2;
    }else{
        return 1;
    }
}
#pragma mark rowHeight
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&indexPath.row==0) {
        return 70;
    }
    return 50;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 10;
    }
    return 20;
}
#pragma mark uitableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    //头像Cell设置
    if (indexPath.section==0&&indexPath.row==0) {
        UIImageView *headImage=[[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 60, 60)];
        [headImage setImageWithURL:[NSURL URLWithString:self.publicaccontModel.logo] placeholderImage:defaultHeadImage];
        
        headImage.layer.cornerRadius=3;
        [headImage.layer setMasksToBounds:YES];
        
        [cell.contentView addSubview:headImage];
        cell.textLabel.text=[NSString stringWithFormat:@"             %@",self.publicaccontModel.name];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"                  服务号:-"];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
    }
    if (indexPath.section==0&&indexPath.row==1) {
        cell.textLabel.text=@"功能介绍：";
        cell.textLabel.font=[UIFont systemFontOfSize:16];
        cell.detailTextLabel.text=@"";
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section==1&&indexPath.row==0) {
        cell.textLabel.text=@"历史消息";
        cell.textLabel.font=[UIFont systemFontOfSize:16];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        if (_subscribestatusType==0) {
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-1, cell.frame.size.width, 1)];
            lineView.backgroundColor=[UIColor colorWithRed:0.931 green:0.931 blue:0.926 alpha:1.000];
            [cell.contentView addSubview:lineView];
        }
    }
    if (indexPath.section==2&&indexPath.row==0) {
        cell.textLabel.text=@"接收消息";
        cell.textLabel.font=[UIFont systemFontOfSize:16];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSArray *arrayNotDistrub=[[NSUserDefaults standardUserDefaults] arrayForKey:NO_DISTURB_MEMBER];
        UIImageView *accessoryView=nil;
        if (arrayNotDistrub!=nil&&[arrayNotDistrub containsObject:self.publicaccontModel.pa_uuid]) {
            
            accessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"group_set_Chack_Close"]];
        }else{
            accessoryView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Chack_Open.png"]];
        }
        accessoryView.bounds=CGRectMake(0, 0, 50, 31);
        cell.accessoryView=accessoryView;
    }
    if (indexPath.section==3&&indexPath.row==0) {
        cell.textLabel.text=@"查看消息";
        cell.textLabel.font=[UIFont systemFontOfSize:16];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        
        if (_subscribestatusType==1) {
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-1, cell.frame.size.width, 1)];
            lineView.backgroundColor=[UIColor colorWithRed:0.931 green:0.931 blue:0.926 alpha:1.000];
            [cell.contentView addSubview:lineView];
        }
    }
    return cell;
}
#pragma mark - 委托事件
#pragma makr alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}
#pragma mark tableview
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1&&indexPath.row==0){
        //历史消息
        [self getHistory];
    }else if (indexPath.section==2&&indexPath.row==0){
        //消息提醒
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
        
        NSMutableArray *arrayDistrub=[[NSUserDefaults standardUserDefaults] mutableArrayValueForKey:NO_DISTURB_MEMBER];
        
        if (![arrayDistrub containsObject:self.publicaccontModel.pa_uuid]) {
            [arrayDistrub addObject:self.publicaccontModel.pa_uuid];
            accessoryView.image=[UIImage imageNamed:@"group_set_Chack_Close"];
        }else{
            [arrayDistrub removeObject:self.publicaccontModel.pa_uuid];
            accessoryView.image=[UIImage imageNamed:@"Chack_Open.png"];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if (indexPath.section==3&&indexPath.row==0){
        //查看消息
        //历史消息
        
        if (self.isFromMessage) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        //更新已读状态
        [[SqliteDataDao sharedInstanse] updateReadStateWithToUserId:self.publicaccontModel.pa_uuid];
        MessageChatViewController *messageVC=[[MessageChatViewController alloc] init];
        messageVC.chatType=2;
        messageVC.hidesBottomBarWhenPushed=YES;
        messageVC.publicModel=self.publicaccontModel;
        [self.navigationController pushViewController:messageVC animated:YES];
    }
}
//获取历史消息
-(void)getHistory{
    [self addHUD:@"获取历史消息..."];
    [[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"getpremessage" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlGetpremessageWithPa_uuid:self.publicaccontModel.pa_uuid withNumber:@"20"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hudWasHidden:nil];
        
        NSError *error=nil;
        NSXMLElement *x=[[NSXMLElement alloc] initWithXMLString:operation.responseString error:&error];
        if (error) {
            DDLogInfo(@"解析出错,error:%@",error);
        }

        NSArray *array=[[x elementForName:@"msglist"] elementsForName:@"msg_content"];
        NSMutableArray *ndArray=[[NSMutableArray alloc] init];
        for (NSXMLElement *parse in array) {
            NotesData *nd=[[NotesData alloc] init];
            
            NSString *creatTime=[[parse elementForName:@"create_time"] stringValue];
            if (creatTime.length<=0) {
                continue;
            }
            
            nd.sendContents=[parse XMLString];
            nd.typeMessage=@"3";
            nd.serverTime=creatTime;
            nd.fromUserId=self.publicaccontModel.pa_uuid;
            nd.contentsUuid=[NSString stringWithFormat:@"public_%@_%@",nd.serverTime,self.publicaccontModel.pa_uuid];
            [ndArray addObject:nd];
        }
        
        MessageChatViewController *messageVC=[[MessageChatViewController alloc] init];
        messageVC.chatType=2;
        messageVC.historyArray=ndArray;
        messageVC.hidesBottomBarWhenPushed=YES;
        messageVC.messageChatType=MessageChatTypePublicCountHistory;
        [self.navigationController pushViewController:messageVC animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self faild];
    }];
    
}
@end
