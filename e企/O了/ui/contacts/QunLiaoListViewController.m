//
//  QunLiaoListViewController.m
//  O了
//
//  Created by 化召鹏 on 14-3-20.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "QunLiaoListViewController.h"
#import "SqliteDataDao.h"
#import "MessageChatViewController.h"
#import "MainViewController.h"
#import "MainNavigationCT.h"
#import "HeadImageDown.h"

#import "UIImageView+WebCache.h"


#import "AFClient.h"

@interface QunLiaoListViewController (){
    NSArray * qunliaoListArray;
    UIButton *_rightButton;
    UIButton *_leftButt;
    NSMutableArray *_imageArrayArray;
    NSMutableArray *_imageViewArray;
    RoomInfoModel *_selectQunliaoM;
    int list_table_hight;
}
@end

@implementation QunLiaoListViewController
@synthesize qunliao_list_table=_qunliao_list_table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //存放(头像数组)
    //    _imageArrayArray=[[NSMutableArray alloc] initWithCapacity:0];
    //    [self getUrlImageHead];
    
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"群聊";
    
    if (self.isSelect) {
        self.title=@"发送到";
    }
    list_table_hight=self.view.bounds.size.height-44;
    if (IS_IOS_7) {
        list_table_hight=[UIScreen mainScreen].bounds.size.height-64;
    }
    
    if (self.isFromMultiple) {
        list_table_hight=self.view.bounds.size.height;
    }
    _qunliao_list_table=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, list_table_hight) style:UITableViewStylePlain];
    
    _qunliao_list_table.delegate=self;
    _qunliao_list_table.dataSource=self;
    _qunliao_list_table.rowHeight=64;
    //    _qunliao_list_table.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_qunliao_list_table];
    /*
     //隐藏系统的item
     [self.navigationItem setHidesBackButton:YES];
     
     _leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
     float button_y=0;
     if (IS_IOS_7) {
     button_y=20;
     }else{
     button_y=0;
     }
     
     _leftButt.frame=CGRectMake(10, (44-29)/2+button_y, 53, 29);
     [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
     [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
     NSString *leftButtTitle=@"  通讯录";
     if (self.isSelect) {
     
     leftButtTitle=@"  返回";
     }
     [_leftButt setTitle:leftButtTitle forState:UIControlStateNormal];
     _leftButt.titleLabel.font=[UIFont systemFontOfSize:14];
     _leftButt.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
     [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
     */
    
    
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.backgroundColor = [UIColor clearColor];
    [_rightButton setImage:[UIImage imageNamed:@"nav-bar_add.png"] forState:UIControlStateNormal];
    //    [_rightButton setBackgroundImage:[UIImage imageNamed:@"top_right.png"] forState:UIControlStateNormal];
    //    [_rightButton setBackgroundImage:[UIImage imageNamed:@"top_right_pre.png"] forState:UIControlStateHighlighted];
    if (IS_IOS_7) {
        _rightButton.frame=CGRectMake(320-48, 0 + 20, 44, 44);
    }else{
        _rightButton.frame=CGRectMake(320-48, 0, 44, 44);
    }
    if (self.isSelect) {
        _rightButton.hidden=YES;
    }
    [_rightButton addTarget:self action:@selector(newChatGroupInQunLiao) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isFromMultiple) {
        _rightButton.hidden=YES;
    }
    
    _imageViewArray=[[NSMutableArray alloc] initWithCapacity:0];
    
    [self getImGroupList];
    [self hideMoreLine];
}

-(void)hideMoreLine
{
    UIView *hide_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _qunliao_list_table.frame.size.width, 1)];
    hide_line.backgroundColor = [UIColor clearColor];
    [_qunliao_list_table setTableFooterView:hide_line];
}

#pragma mark - 获取头像地址
-(void)getUrlImageHead:(NSArray *)groupArray{
    
    
    //存放头像
    
    CGRect headFrame1 =CGRectMake(0, 0, 44, 44);
    CGRect headFrame =CGRectMake(10, 10, 45, 45);
    
    for (RoomInfoModel *qm in qunliaoListArray) {
        
        UIImageView *headImage_view=[[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 44, 44)];
        headImage_view.backgroundColor=[UIColor clearColor];
        headImage_view.layer.cornerRadius=5;
        
        NSArray *strArray=[qm.roomMemberListStr componentsSeparatedByString:@";"];
        
        int imageCount=strArray.count>9?9:strArray.count;
        if (imageCount > 3) {
            imageCount = 3;
        }
        for (int i=0; i<imageCount; i++) {
            CGRect frame=CGRectZero;
            
            if (i==9) {
                break;
            }
            
            if (imageCount>=9) {
                CGFloat width=headFrame.size.width/3;
                CGFloat height=headFrame.size.height/3;
                frame=CGRectMake(width*(i%3), height*(i/3), width, height);
            }else{
                switch (imageCount) {
                    case 3:
                    {
                        if (i == 0) {
                            frame = CGRectMake(12, 0, 20, 20);
                        }
                        else if (i == 1){
                            frame = CGRectMake(2, 18, 20, 20);
                        }
                        else if (i == 2){
                            frame = CGRectMake(21, 18, 20, 20);
                        }
                        
                        break;
                        
                        break;
                    }
                    case 4:
                    {
                        CGFloat width=headFrame.size.width/2;
                        CGFloat height=headFrame.size.height/2;
                        frame=CGRectMake(width*(i%2), height*(i/2), width, height);
                        break;
                    }
                    default:
                    {
                        int firstCount=imageCount%3;
                        int extraCount=imageCount/3;
                        int rowCount=extraCount+(firstCount>0?1:0);
                        int colCount=extraCount>0?3:firstCount;
                        CGFloat width=headFrame1.size.width/colCount;
                        CGFloat height=headFrame1.size.height/rowCount;
                        if (width<height) {
                            height=width;
                        }
                        CGFloat xOffset=0;
                        CGFloat yOffset=(headFrame1.size.height-height*rowCount)*0.5;
                        int xIndex=0;
                        int yIndex=0;
                        if (i<firstCount) {
                            xIndex=i;
                            xOffset=(headFrame1.size.width-firstCount*width)*0.5;
                        }else{
                            int addCount=0;
                            if (firstCount!=0) {
                                addCount=colCount-firstCount;
                            }
                            xIndex=(i+addCount)%colCount;
                            yIndex=(i+addCount)/colCount;
                        }
                        frame=CGRectMake(width*xIndex+xOffset, height*yIndex+yOffset, width, height);
                        break;
                    }
                }
            }
            UIImageView * imageView = [[UIImageView alloc]init];
            
            EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:[strArray objectAtIndex:i]];
            
            NSString *head_path=em.avatarimgurl;
            head_path=[head_path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSURL *headImage_url=[NSURL URLWithString:head_path];
            [imageView setImageWithURL:headImage_url placeholderImage:defaultHeadImage];
            //            imageView.contentMode=UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = 10;
            imageView.frame = frame;
            
            [headImage_view addSubview:imageView];
            
        }
        
        [_imageViewArray addObject:headImage_view];
    }
    
    //    [_qunliao_list_table reloadData];
    
}

-(void)getImGroupList{
    
    qunliaoListArray=[[SqliteDataDao sharedInstanse] queryAllRoomData];
    
    [self getUrlImageHead:qunliaoListArray];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];

    [self.navigationController.view addSubview:_rightButton];
    
    list_table_hight=[UIScreen mainScreen].bounds.size.height-44;
    if (IS_IOS_7) {
        list_table_hight=[UIScreen mainScreen].bounds.size.height-64;
    }
    //    MainViewController * main=[[MainViewController alloc]init];
    //    BOOL isHidden =main.tabbarView.hidden;
    //BOOL isSelfHidden=self.hidesBottomBarWhenPushed;
    //DDLogInfo(@"群聊隐藏性:%d",isSelfHidden);
    //    DDLogInfo(@"隐藏性：%d",isHidden);
    //if (isSelfHidden) {
        
    //}else{
    //    list_table_hight-=50;
    //}
    if (self.isFromMultiple) {
        list_table_hight=self.view.bounds.size.height-64;
    }
    _qunliao_list_table.frame = CGRectMake(0, 0, 320, list_table_hight);
    [self getImGroupList];
    [_qunliao_list_table reloadData];
    [self.qunliao_list_table setSeparatorColor:[UIColor clearColor]];
}

-(void)viewDidDisappear:(BOOL)animated{
    
}
-(void)viewDidUnload{
    
    //置为空
    _leftButt=nil;
    _rightButton=nil;
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [_rightButton removeFromSuperview];
    [_leftButt removeFromSuperview];
}

#pragma mark - bar button
-(void)leftButtItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 创建新的会话
-(void)newChatGroupInQunLiao{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    
    nav_add.addScrollType=AddScrollTypeCreatGroup;
    nav_add.delegate_addID = self;
    MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainct.mainVC;
    [maivc presentViewController:nav_add animated:YES completion:^{
        
    }];
    
}
#pragma mark =====navigation_addIDDelegaet


-(void)GetArrayID:(RoomInfoModel *)roomModel{
    MessageChatViewController *messageVC = [[MessageChatViewController alloc]init];
    messageVC.chatType=1;
    messageVC.roomInfoModel=roomModel;
    [messageVC setHidesBottomBarWhenPushed:YES];
    [self setHidesBottomBarWhenPushed:NO];
    
    MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
    maivc.isToRootViewController = YES;
    //    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"is_to_chat"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    [maivc setSeletedIndex:0];
    
    MainNavigationCT *mainNavCT1 = maivc.viewControllers[0];
    
    [mainNavCT1 pushViewController:messageVC animated:YES];
}

-(void)sendMassMessage:(NSArray *)memberArray{
    MessageChatViewController *messageVC = [[MessageChatViewController alloc]init];
    messageVC.chatType=0;
    messageVC.member_userInfo=memberArray[0];
    [messageVC setHidesBottomBarWhenPushed:YES];
    [self setHidesBottomBarWhenPushed:NO];
    MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
    maivc.isToRootViewController = YES;
    //    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"is_to_chat"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    [maivc setSeletedIndex:0];
    
    MainNavigationCT *mainNavCT1 = maivc.viewControllers[0];
    
    [mainNavCT1 pushViewController:messageVC animated:YES];
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

#pragma mark - UITableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [qunliaoListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIndentifier=@"groupNameCell";
    QunliaoListCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"QunliaoListCell" owner:self options:nil] lastObject];
    }
    RoomInfoModel *qunliaoM=[qunliaoListArray objectAtIndex:indexPath.row];
    if (qunliaoM.roomName.length>0) {
        cell.nameLabel.text=[NSString stringWithFormat:@"%@",qunliaoM.roomName];
    }else{
        cell.nameLabel.text=qunliaoM.roomJid;
    }
    
    UIImageView *tempImage=[_imageViewArray objectAtIndex:indexPath.row];
    tempImage.layer.masksToBounds = YES;
    tempImage.layer.cornerRadius = 22.0;
    UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(63,59.5, 320, 0.5)];
    _lineView.opaque             = YES;
    _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
    if (indexPath.row == qunliaoListArray.count - 1) {
        _lineView.frame = CGRectMake(0,59.5, 320, 0.5);
    }
    
    [cell.contentView addSubview:_lineView];
    [cell.headImageView addSubview:tempImage];
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    RoomInfoModel *qunliaoM=[qunliaoListArray objectAtIndex:indexPath.row];
    if (self.isSelect) {
        //转发
        _selectQunliaoM=qunliaoM;
        NSString *groupName=qunliaoM.roomName;
        if (groupName.length<=0) {
            groupName=qunliaoM.roomJid;
        }
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"确定发送给:" message:groupName delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是",nil];
        [alert show];
        
    }else if(self.isFromMultiple){
        NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
        [nav selectOneRoom:qunliaoM];
    }else{
        
        MessageChatViewController *messageVC = [[MessageChatViewController alloc] init];
        //[self setHidesBottomBarWhenPushed:NO];
        messageVC.hidesBottomBarWhenPushed=YES;
        messageVC.chatType=1;
        
        
        NSArray *tempArray=[qunliaoM.roomMemberListStr componentsSeparatedByString:@";"];
        NSMutableArray *emArray=[[NSMutableArray alloc] init];
        for (NSString *imacc in tempArray) {
            EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:imacc];
            [emArray addObject:em];
        }
        qunliaoM.roomMemberList=emArray;
        messageVC.roomInfoModel=qunliaoM;
        messageVC.isFromGroupList=YES;
        
        //        MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
        //        MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
        //        maivc.isToRootViewController = YES;
        //        [maivc setSeletedIndex:0];
        //
        //        MainNavigationCT *mainNavCT1 = maivc.viewControllers[0];
        [self.navigationController pushViewController:messageVC animated:YES];
        //        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    
}
#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        //转发
        self.isTransmit(_selectQunliaoM);
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
