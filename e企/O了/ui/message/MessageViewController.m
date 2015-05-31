//
//  MessageViewController.m
//  O了
//
//  Created by macmini on 14-01-08.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageChatViewController.h"
#import "MessageCell.h"
#import "QFXmppManager.h"
#import "AppDelegate.h"
#import "NotesData.h"
#import "AFClient.h"
#import "MainNavigationCT.h"
//QunLiaoListViewController.m
#import "QunLiaoListViewController.h"

#import "CBG.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"
#import "CreateHttpHeader.h"
//#pragma mark 任务流
//#import "TaskViewController.h"
//#import "TaskFlowCell.h"
//#import "TaskTools.h"


#import "MemberData.h"
#import "MyImageView.h"

#import "UIImageView+WebCache.h"

#import "VoIPViewController.h"
#define alert_app 10010
#define alert_oa_app 10011

#import "TaskTools.h"

@interface MessageViewController()
{
    UIButton*back;
    UIImageView*imagevs;
    UILabel*labels;
    
    UIButton * _rightButton;
    UIActivityIndicatorView *_activityView;
    
    BOOL isNetwork;//是否有网络
    
    NSMutableDictionary *cellDict;///<存放cell
    UIButton*Group_Chat;//发起聊天
    UIButton*Phone_Meeting;//电话会议
    UILabel*label;
    UILabel*label1;
    UIImageView*imagev;
    UIImageView*imagev1;
    BOOL bools;
    ChatListModel *_nowSelectListModel;///<当前选择的cell上边的对象
    
    UIImageView *add_group_ngImage;///<创建群聊的菜单view
    UIView *add_view;
    //    UIView *addbcview;
    UIView *addbutton1;
    UIView *addbutton2;
    PublicAccountListViewController *publicListVC;
    
    NSString *headStr;
    NSInteger reqtimes;
    UIView *tipview;
    
#pragma mark 任务流
    //OperationDB *db;
    NSDictionary *latestCreateTaskStatusDict;
    //#pragma mark 任务流
    //    NSDictionary *latestCreateTaskStatusDict;
}

@property (strong,nonatomic) NSMutableArray * messagesArray;
@property (strong,nonatomic) NSMutableDictionary * unRead;
@end

@implementation MessageViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"markTheChatRead" object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:offlinf_message_receive_finish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receiveOffline" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@MtcCallIncomingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@MtcCallTermedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@MtcCallNetworkStatusChangedNotification object:nil];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        //       [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar_mainframe.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar_mainframeHL.png"]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callIncoming:) name:@MtcCallIncomingNotification object:nil];

    }
    return self;
}
/*
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWTABBAR object:nil userInfo:nil];

    if (IS_IOS_7) {
        
        if (self.view.bounds.size.height==416 || self.view.bounds.size.height==504) {
            
            self.tableView.frame=CGRectMake(0, 64, 320, self.view.bounds.size.height-50);
        }
        
    }
    
}
*/
-(void)viewWillDisappear:(BOOL)animated{
    back.hidden = YES;
    imagevs.hidden = YES;
    labels.hidden = YES;
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
    [_rightButton removeFromSuperview];
    //self.title=@"和企录";
}
-(void)viewDidDisappear:(BOOL)animated{
    self.tableView.delegate=nil;
    self.tableView.dataSource=nil;
    if(tipview){
        [tipview removeFromSuperview];
        tipview=nil;
    }
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //插入假数据
#pragma mark 任务流
    //    latestCreateTaskStatusDict = [[[SqliteDataDao sharedInstanse]findSetWithDictionary:@{} andTableName:TASK_STATUS_TABLE orderBy:@"create_time"] firstObject];
    
    /**
     *  数据初始化
     */
    
    self.unRead = [[NSMutableDictionary alloc]init];
    self.messagesArray = [[NSMutableArray alloc]initWithCapacity:0];
    [self loadTab];
    
    if (!cellDict) {
        cellDict=[[NSMutableDictionary alloc] init];
    }
    
    back = [[UIButton alloc]init];
    back.frame = CGRectMake(0, 19, 80, 45);
    //[back setBackgroundImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backff) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:back];
    
    imagevs = [[UIImageView alloc]init];
    imagevs.frame = CGRectMake(3, 30, 25, 25);
    [imagevs setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagevs];
    
    labels = [[UILabel alloc]init];
    labels.frame = CGRectMake(25, 32, 70, 20);
    labels.text = @"消息";
    labels.textColor = [UIColor whiteColor];
    labels.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:labels];
    
    
    //导航条标题
    //self.title=@"和企录";
    AppDelegate * ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    ad.showUnreadDelegate = self;
    self.tableView.rowHeight=60;
    
    UILongPressGestureRecognizer *longGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.tableView addGestureRecognizer:longGesture];
    
    MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
    maivc.tabbarButtonClick=^(int index){
        [self hideMenu];
    };
    
    //    [self receiveOffline];
    isNetwork=YES;
    [self.tableView setSeparatorColor:[UIColor clearColor]];//cell中间消除白线
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(markReaded:) name:@"markTheChatRead" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveSendMessage:) name:haveSendMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callTermed:) name:@MtcCallTermedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:@MtcCallNetworkStatusChangedNotification object:nil];

    [self setExtraCellLineHidden:self.tableView];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTaskStatusInMessageView) name:ReceiveNewTaskPush object:nil];
    
    //群组聊天
    Group_Chat = [[UIButton alloc]init];
//    Group_Chat.frame = CGRectMake(220, 0, 100, 30);
    Group_Chat.frame = CGRectMake(180, 0, 130, 45);
    [Group_Chat setBackgroundColor:[UIColor whiteColor]];
   // [Group_Chat setTitle:@"发起聊天" forState:UIControlStateNormal];
    [Group_Chat setBackgroundImage:[UIImage imageNamed:@"layer2"] forState:UIControlStateNormal];
    [Group_Chat.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [Group_Chat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [Group_Chat addTarget:self action:@selector(Group_chat_methods) forControlEvents:UIControlEventTouchUpInside];
    Group_Chat.hidden = YES;
    [self.view addSubview:Group_Chat];
    
    label = [[UILabel alloc]init];
    label.text = @"发起聊天";
    label.frame = CGRectMake(50, 6, 120, 30);
    label.font = [UIFont systemFontOfSize:14];
    [Group_Chat addSubview:label];
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(15, 10, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"public_icon_dropdown_group.png"]];
    //imagev.backgroundColor = [UIColor blueColor];
    [Group_Chat addSubview:imagev];
    /*
    //电话会议
    Phone_Meeting = [[UIButton alloc]init];
    Phone_Meeting.frame = CGRectMake(220, 0+30, 100, 30);
    [Phone_Meeting setBackgroundColor:[UIColor whiteColor]];
    [Phone_Meeting.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [Phone_Meeting setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [Phone_Meeting addTarget:self action:@selector(Phone_Meeting_methods) forControlEvents:UIControlEventTouchUpInside];
    Phone_Meeting.hidden = YES;
    [self.view addSubview:Phone_Meeting];
    label1 = [[UILabel alloc]init];
    label1.text = @"电话会议";
    label1.frame = CGRectMake(35, 0, 120, 30);
    label1.font = [UIFont systemFontOfSize:14];
    [Phone_Meeting addSubview:label1];
    imagev1 = [[UIImageView alloc]init];
    imagev1.frame = CGRectMake(0, 0, 30, 30);
    //[imagev setImage:[UIImage imageNamed:@"9.jpg"]];
    imagev1.backgroundColor = [UIColor orangeColor];
    [Phone_Meeting addSubview:imagev1];
     */
    
}

-(void)backff{
    Group_Chat.hidden = YES;
    Phone_Meeting.hidden = YES;
    //消息返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}




#pragma mark - 更新聊天列表中的最后一条任务信息
//-(void)reloadTaskStatusInMessageView
//{
//    latestCreateTaskStatusDict = [[[SqliteDataDao sharedInstanse]findSetWithDictionary:@{} andTableName:TASK_STATUS_TABLE orderBy:@"create_time"] firstObject];
//    [self.tableView reloadData];
////    刷新单行失败
////    NSIndexPath *taskIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
////    NSArray *indexPaths = @[taskIndexPath];
////    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//}

#pragma mark - 单元格长按
//显示菜单
-(BOOL) canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(zhiding:) || action == @selector(myDelete:)) {
        return YES;
    }
    return NO;
}
int xiaoxisuoyin;
-(void)longPress:(id)sender{
    if ([sender isMemberOfClass:[UILongPressGestureRecognizer class]]){
        UILongPressGestureRecognizer * longGesture = (UILongPressGestureRecognizer *)sender;
        CGPoint p = [longGesture locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:p];
        
        //#pragma mark 任务流
        //        if (indexPath.row == 0) {
        //            return;
        //        }
        
#pragma mark 普通消息
        
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        MessageCell *cell_message=(MessageCell *)cell;
        ChatListModel *clm=cell_message.message;
        _nowSelectListModel=clm;
        if ((p.y > (cell.frame.origin.y + cell.frame.size.height))) {
            return;
        }
        if(longGesture.state == UIGestureRecognizerStateBegan){
            [cell becomeFirstResponder];
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(myDelete:)];
            NSString * zhidingTitle = @"置顶";
            if (clm.priority==1) {
                zhidingTitle = @"取消置顶";
            }
            
            UIMenuItem *zhiding = [[UIMenuItem alloc] initWithTitle:zhidingTitle action:@selector(zhiding:)];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            if(clm.chatType == 4)
            {
                [menu setMenuItems:[NSArray arrayWithObject:delete]];
            }else
            {
                [menu setMenuItems:[NSArray arrayWithObjects:delete,zhiding,nil]];
            }
            
            [menu setTargetRect:cell.frame inView:cell.superview];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}
#pragma mark-----删除消息列表中的消息
-(void)myDelete:(id)sender{
    //删除
    [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:_nowSelectListModel.toUserId];
    // 清空消息记录
    //[[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:_nowSelectListModel.toUserId];
    [self loadBaseData];
}
-(void)zhiding:(id)sender{
    
    if (_nowSelectListModel.priority==1) {
        [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:_nowSelectListModel.toUserId priority:0];
    }else{
        [[SqliteDataDao sharedInstanse] updateChatListPriorityWithWithToUserId:_nowSelectListModel.toUserId priority:1];
    }
    
    [self loadBaseData];
}

#pragma mark -
#pragma mark - 添加新的聊天群组
//发送消息和发起群聊
-(void)createGroup:(id)sender{
    
    [_rightButton setImage:[UIImage imageNamed:@"nav-bar_add.png"] forState:UIControlStateNormal];
    [self hideMenu];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    
    UIButton *butt=(UIButton *)sender;
    switch (butt.tag) {
        case 0:
        {
            nav_add.addScrollType=AddScrollTypeSendMessage;
            break;
        }
        case 1:
        {
            nav_add.addScrollType=AddScrollTypeCreatGroup;
            
            break;
        }
        case 2:
        {
            MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
            MainViewController *maivc = (MainViewController *)mainct.mainVC;
            if (maivc.isiOSInCall)
            {
                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"正在通话中..." detailText:@"请结束通话后重试!" isCue:1.5 delayTime:3 isKeyShow:NO];
                DDLogWarn(@"current iPhone is on calling, can not create conf!");
                return;
            }
            nav_add.addScrollType = AddScrollTypeCreateConf;
            break;
        }
        default:
            break;
    }
    DDLogInfo(@"#####scrollType = %d#####", nav_add.addScrollType);
    nav_add.delegate_addID = self;
    [self presentViewController:nav_add animated:YES completion:^{
    }];
    
}
-(void)initaddview{
    if (!add_view) {
        CGSize imageSize = [[UIScreen mainScreen] bounds].size;
        if (NULL != UIGraphicsBeginImageContextWithOptions) {
            UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        }
        else
        {
            UIGraphicsBeginImageContext(imageSize);
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        for (UIWindow * window in [[UIApplication sharedApplication] windows]) {
            if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, [window center].x, [window center].y);
                CGContextConcatCTM(context, [window transform]);
                CGContextTranslateCTM(context, -[window bounds].size.width*[[window layer] anchorPoint].x, -([window bounds].size.height)*[[window layer] anchorPoint].y);
                [[window layer] renderInContext:context];
                
                CGContextRestoreGState(context);
            }
        }
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        add_view=[[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320,568)];
        add_view.userInteractionEnabled=YES;
        add_view.backgroundColor=[UIColor colorWithPatternImage:[image applyLightEffect]];
        UIView *ddd=[[UIView alloc]initWithFrame:CGRectMake(0,0, add_view.frame.size.width, add_view.frame.size.height)];
        ddd.backgroundColor=[UIColor whiteColor];
        ddd.alpha=0.5;
        [add_view  addSubview:ddd];
        //        addbcview=[[UIView alloc]initWithFrame:CGRectMake(0,0, add_view.frame.size.width, 420)];
        //        addbcview.backgroundColor=[UIColor clearColor];
        //        [add_view addSubview:addbcview];
        UILabel *closelb=[[UILabel alloc]initWithFrame:CGRectMake(100, add_view.frame.size.height-70, 120, 30)];
        closelb.font=[UIFont systemFontOfSize:16];
        closelb.text=@"关闭";
        closelb.textAlignment=NSTextAlignmentCenter;
        closelb.textColor=cor3;
        [add_view addSubview:closelb];
        [[UIApplication sharedApplication].keyWindow addSubview:add_view];
        
        NSArray *array=@[@"发起聊天",@"电话会议"];
        NSArray *imgarray=@[@"msg_icon_Initiate-a-chat_nm.png",@"msg_icon_groupcall_chat_nm.png"];
        
        for (int i = 0; i < array.count; i++) {
            UIButton *butt=[UIButton buttonWithType:UIButtonTypeCustom];
            butt.tag=i+1;
            [butt addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
            butt.frame = CGRectMake(12.5,0, 55, 55);
            butt.layer.cornerRadius=27.5;
            butt.layer.masksToBounds=YES;
            [butt setBackgroundImage:[UIImage imageNamed:[imgarray objectAtIndex:butt.tag-1]] forState:UIControlStateNormal];
            //            [addbcview addSubview:butt];
            
            UIMyLabel *label=[[UIMyLabel alloc] init];
            label.frame=CGRectMake(butt.frame.origin.x-3, butt.frame.origin.y+butt.frame.size.height+5, butt.frame.size.width+6, 20);
            label.font=[UIFont systemFontOfSize:12];
            label.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
            label.text=array[i];
            //            [addbcview addSubview:label];
            if(i==0){
                addbutton1=[[UIView alloc]initWithFrame:CGRectMake(120, 85, 80, 80)];
                [addbutton1 addSubview:butt];
                [addbutton1 addSubview:label];
                addbutton1.backgroundColor=[UIColor clearColor];
                [add_view addSubview:addbutton1];
            }else{
                addbutton2=[[UIView alloc]initWithFrame:CGRectMake(120, 85+120, 80, 80)];
                [addbutton2 addSubview:butt];
                [addbutton2 addSubview:label];
                addbutton2.backgroundColor=[UIColor clearColor];
                [add_view addSubview:addbutton2];
            }
        }
        UITapGestureRecognizer *add_viewtap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addviewtap)];
        add_viewtap.numberOfTapsRequired=1;
        addbutton1.layer.transform=CATransform3DMakeScale(1.75, 1.75, 1.75);
        addbutton2.layer.transform=CATransform3DMakeScale(1.75, 1.75, 1.75);
        [add_view addGestureRecognizer:add_viewtap];
        add_view.alpha=0;
    }
}
//群聊点击事件
-(void)showaddview{
    
    if (Group_Chat.hidden == YES) {
        Group_Chat.hidden = NO;
        Phone_Meeting.hidden = NO;
    }else {
        Group_Chat.hidden = YES;
        Phone_Meeting.hidden = YES;
    }
    
    
//    [self initaddview];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//    [UIView setAnimationDuration:0.3];
//    [UIView setAnimationDidStopSelector:@selector(animation2)];
//    add_view.alpha=1;
//    addbutton1.layer.transform=CATransform3DMakeScale(0.8, 0.8, 0.8);
//    addbutton2.layer.transform=CATransform3DMakeScale(0.8, 0.8, 0.8);
//    [UIView commitAnimations];

//    [_rightButton setImage:[UIImage imageNamed:@"nav-bar_add.png"] forState:UIControlStateNormal];
//    [self hideMenu];
    
    
    

//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
//    [self.view addGestureRecognizer:singleTap];
//    
//    
//    UITapGestureRecognizer *SsingleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
//    [self.navigationController.view addGestureRecognizer:SsingleTap];
    
    
    
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
//    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
//    
//    nav_add.addScrollType=AddScrollTypeCreatGroup;
//    nav_add.delegate_addID = self;
//    [self presentViewController:nav_add animated:YES completion:^{
//    }];
    
}


//-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer {
//    Group_Chat.hidden = YES;
//    Phone_Meeting.hidden = YES;
//}



-(void)Group_chat_methods{
    DDLogCInfo(@"发起聊天");
    Group_Chat.hidden = YES;
    Phone_Meeting.hidden = YES;
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
        NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    
        nav_add.addScrollType=AddScrollTypeCreatGroup;
        nav_add.delegate_addID = self;
        [self presentViewController:nav_add animated:YES completion:^{
        }];
}

-(void)Phone_Meeting_methods{
    DDLogCInfo(@"电话会议");
}
-(void)animation2{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.1];
    addbutton1.layer.transform=CATransform3DMakeScale(1, 1, 1);
    addbutton2.layer.transform=CATransform3DMakeScale(1, 1, 1);
    [UIView commitAnimations];
}
-(void)addviewtap{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(hideMenu)];
    add_view.alpha=0;
    addbutton1.layer.transform=CATransform3DMakeScale(1.75, 1.75, 1.75);
    addbutton2.layer.transform=CATransform3DMakeScale(1.75, 1.75, 1.75);
    [UIView commitAnimations];
}
-(UIImage *)getImageFromImage:(UIImage *)ttimage inRect:(CGRect)rect{
    UIImage* bigImage= ttimage;
    CGImageRef imageRef = bigImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    CGSize size;
    size.width = rect.size.width;
    size.height = rect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
    
}
-(void)hideMenu{
    if (add_view) {
        [add_view removeFromSuperview];
        add_view=nil;
        addbutton1=nil;
        addbutton2=nil;
    }
}
#pragma mark - 多选通讯录
-(void)GetArrayID:(RoomInfoModel *)roomModel{
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=1;
    detailViewController.roomInfoModel=roomModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}
-(void)sendMassMessage:(NSArray *)memberArray{
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    if (memberArray.count>1) {
        detailViewController.chatType=3;
        detailViewController.member_infoArray=memberArray;
    }else{
        detailViewController.chatType=0;
        detailViewController.member_userInfo=memberArray[0];
    }
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)createConf:(NSArray*)memberArray
{
    NSString *caller = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
    NSString *callee = nil;
    
    //    DDLogInfo(@"当前呼叫数量%d",[memberArray count]);
    for ( EmployeeModel *member in memberArray )
    {
        if (nil == callee)
        {
            callee = member.phone;
        }
        else
        {
            callee = [callee stringByAppendingString:@";"];
            callee = [callee stringByAppendingString:member.phone];
        }
        
        
    }
    
    reqtimes ++;
    NSDictionary *dict=@{@"caller": caller,
                         @"callee": callee? callee : @""
                         };
    //    DDLogInfo(@"电话会议字典%@",dict);
    NSString *gid = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];
    [[AFClient sharedClient] postPath:[NSString stringWithFormat:@"eas/createConf?gid=%@&cid=%@",gid,cid]parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogInfo(@"电话会议回执%@",operation.responseString);
         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
         int status=[[dic objectForKey:@"status"] intValue];
         NSString *str=[dic objectForKey:@"msg"];
         reqtimes = 0;
         if(status==1){
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:0 delayTime:1 isKeyShow:NO];
         }else{
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:1 delayTime:1 isKeyShow:NO];
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSInteger stateCode = operation.response.statusCode;
         DDLogInfo(@"服务器返回错误码%d",stateCode);
         DDLogInfo(@"呼叫次数%d",reqtimes);
         if(stateCode == 401  && reqtimes<=10)
         {
             NSDictionary *ddd=operation.response.allHeaderFields;
             if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                 NSString *nonce=[ddd objectForKey:@"Www-Authenticate"];
                 headStr = [CreateHttpHeader createHttpHeaderWithNoce:nonce];
                 NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
                 [client setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
                 [self createConf:memberArray];
                 
             }
         }else
         {
             reqtimes = 0;
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"呼出失败，请稍后再试" isCue:1 delayTime:1 isKeyShow:NO];
         }
         
     }];
}

#pragma mark 添加电话会议人员
//- (void)addMemberJoinConf
//{
//    NSString *myPhone = [ConstantObject sharedConstant].userInfo.phone;
//    NSDictionary *dict=@{@"confId": confID,
//                         @"phone": confPhone,
//                         @"caller": myPhone,
//                         @"callee": [NSString stringWithFormat:@"%@;%@",@"18867101270",@"18867102003"]};
//    //    DDLogInfo(@"电话会议字典%@",dict);
//    AFClient *client = [AFClient sharedClient];
//
//    [client postPath:[NSString stringWithFormat:@"eas/joinConf"]parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
//     {
//         DDLogInfo(@"电话会议回执%@",operation.responseString);
//         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
//         int status=[[dic objectForKey:@"status"] intValue];
//         NSString *str=[dic objectForKey:@"msg"];
//
//         if(status==1){
//             callsucceedTime=[NSDate date];
//             confPhone = [dic objectForKey:@"phone"];
//             confID = [dic objectForKey:@"conferenceId"];
//             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:0 delayTime:1 isKeyShow:NO];
//         }else{
//             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:str isCue:1 delayTime:1 isKeyShow:NO];
//         }
//
//     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//         [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"呼出失败，请稍后再试" isCue:1 delayTime:1 isKeyShow:NO];
//
//     }];
//
//}

#pragma mark-
#pragma mark HUD

- (void)hudWasHidden:(MBProgressHUD *)hud{
    
    //    if (!hud) {
    //        return;
    //    }
    
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

BOOL is_load_updae;//是否在前台更新消息列表
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"进入主XXXX");
    back.hidden = NO;
    imagevs.hidden = NO;
    labels.hidden = NO;
    reqtimes = 0;
    NSString * str = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
    DDLogInfo(@"%@",str);
    if (str == nil || str == 0) {
        UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"公司名称获取不到" message:@"请重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        alter.delegate = self;
        [alter show];
    }
    
    publicListVC=nil;
    
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
    
    if (self.tableView.delegate==nil) {
        self.tableView.delegate=self;
        
    }
    if (self.tableView.dataSource==nil) {
        self.tableView.dataSource=self;
    }
    
    [_rightButton addTarget:self action:@selector(showaddview) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_rightButton];
    
    __block BOOL blockIsNetwork=isNetwork;
    __block typeof(self) blockSelf=self;
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            //网络未知,或者没有网络
            blockIsNetwork=NO;
            [blockSelf loadNotNetWork];
        }else{
            [blockSelf hideNotNetWork];
        }
    }];
    AFNetworkReachabilityStatus afnStatus = afNetworkReachabilityManager.networkReachabilityStatus;
    if (afnStatus == AFNetworkReachabilityStatusNotReachable) {
        [self loadNotNetWork];
    }else{
        [self hideNotNetWork];
    }
    
    ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
    contactsCheck.contactsCheckDelegate = self;
    [contactsCheck execute];
    [self loadTab];
}

-(void)showtipview{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *huiyistr=COFRENCE_ASSiSTANT;
        if([huiyistr isEqualToString:@"main"]){
            if (self.messagesArray.count!=0) {
                if(tipview){
                    [tipview removeFromSuperview];
                    tipview=nil;
                }
            }else{
                if(tipview){
                    [tipview removeFromSuperview];
                    tipview=nil;
                }
                tipview=[[UIView alloc]initWithFrame:self.tableView.frame];
                tipview.backgroundColor=[UIColor whiteColor];
//                self.tableView.scrollEnabled=NO;
                UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(0, 148-64, 320, 15)];
                title.text=@"欢迎使用和企录";
                title.textColor=cor3;
                title.font=[UIFont systemFontOfSize:15];
                title.textAlignment=NSTextAlignmentCenter;
                [tipview addSubview:title];
                UILabel *content=[[UILabel alloc]initWithFrame:CGRectMake(0, 148-64+15+10, 320, 18)];
                content.textColor=cor3;
                content.numberOfLines=3;
                content.font=[UIFont systemFontOfSize:15];
                content.textAlignment=NSTextAlignmentCenter;
                content.lineBreakMode=NSLineBreakByCharWrapping;
                content.text=@"点击“+”发起聊天";
                [tipview addSubview:content];
                [self.view addSubview:tipview];
            }
            
        }
    });
}
-(void)beginUpdate{
    //    DDLogInfo(@"beginUpdate");
}
-(void)endUpdate:(bool)hasUpdate{
    //    DDLogInfo(@"endUpdate");
    
}
-(void)timeout{
    
}
-(void)loadNotNetWork{
    isNetwork=NO;
    self.title=@"和企录(未连接)";
    //    [self.tableView reloadData];
    //    id value=[self.messagesArray objectAtIndex:0];
    //    if (![value isKindOfClass:[NSString class]]){
    //        [self.messagesArray insertObject:@"1" atIndex:0];
    //        [cellDict removeAllObjects];
    //        [self.tableView reloadData];
    //    }
}
-(void)hideNotNetWork{
    isNetwork=YES;
    //self.title=@"和企录";
    //    [self.tableView reloadData];
    //    if (self.messagesArray.count>0) {
    //        id value=[self.messagesArray objectAtIndex:0];
    //        if ([value isKindOfClass:[NSString class]]){
    //            [self.messagesArray removeObjectAtIndex:0];
    //            [cellDict removeAllObjects];
    //            [self.tableView reloadData];
    //            self.title=@"消息";
    //        }
    //    }
}

-(void)loadTab{
    DDLogInfo(@"loadTab =========");
    [self loadBaseData];
}
#pragma mark -
#pragma mark 接收到信息的回调
-(void)showUnreadMsgCount:(MessageModel *)mm{ //msg参数暂时不用到
    //  mm.to; 用
    //    [self loadBaseData];
    //    DDLogInfo(@"%@ ---%@",mm.from,mm.to);
    //    DDLogInfo(@"消息体：%@",mm.msg);
    int  position=0;
    int temppos=-1;
    for(int i=0;i<_messagesArray.count;i++){
        ChatListModel *message=_messagesArray[i];
        if(message.priority==1){
            position++;
        }
        if([message.toUserId isEqualToString:mm.to]){
            temppos=i;
            break;
        }
    }
    ChatListModel *ssmessage=[[SqliteDataDao sharedInstanse]queryOneChatDataWithToUserId:mm.to];
    //    DDLogInfo(@"!!!!!%@",mm.to);
    //    DDLogInfo(@"message:%@-%@-%@-%@",ssmessage.fromUserId,ssmessage.toUserId,ssmessage.lastMessage,ssmessage.roomInfoModel.roomName);
    if(mm.to&&ssmessage.toUserId){
        if(temppos==-1){
            if(ssmessage.chatType == 4)
               [_messagesArray insertObject:ssmessage atIndex:0];
            else
                [_messagesArray insertObject:ssmessage atIndex:position];
            
        }else{
            ChatListModel *tempmessage=_messagesArray[temppos];
            if(tempmessage.priority==1){
                [_messagesArray removeObjectAtIndex:temppos];
                [_messagesArray insertObject:ssmessage atIndex:0];
            }else{
                [_messagesArray removeObjectAtIndex:temppos];
                [_messagesArray insertObject:ssmessage atIndex:position];
            }
        }

        NSString *cellDict_key=[NSString stringWithFormat:@"message_chat_cell_%@",mm.to];
        [cellDict removeObjectForKey:cellDict_key];
        int all_unRead_count=0;
        for (ChatListModel *clm in self.messagesArray) {
            all_unRead_count=all_unRead_count+clm.unReadCount;
        }
        MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
        MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
        maivc.tabbarButt1.remindNum=all_unRead_count;
        [ConstantObject app].unReadNum=all_unRead_count;
        [ConstantObject app].unReadNum = maivc.tabbarButtTask.remindNum+all_unRead_count;
        //#pragma mark 任务流
        //[self.messagesArray insertObject:@"任务流" atIndex:0];
        
        [self.tableView reloadData];
            [self showtipview];
        /*
        if (publicListVC) {
            [publicListVC reloadTabel];
        }
         */
    }
}

-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //    if (indexPath.row==0) {
    //        /*
    //        id value=[self.messagesArray objectAtIndex:0];
    //        if ([value isKindOfClass:[NSString class]]) {
    //            static NSString *CellIdentifier = @"NoNetworkCell";
    //            NoNetworkCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //            cell=[[[NSBundle mainBundle] loadNibNamed:@"NoNetworkCell" owner:self options:nil] lastObject];
    //
    //            return cell;
    //        }
    //*/
    //       // if ([value isEqualToString:@"任务流"]) {
    //        static NSString *CellIdentifier = @"TaskCell";
    //        TaskFlowCell *cell = [[TaskFlowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //        cell.iconImageView.image = [UIImage imageNamed:@"icon_task"];
    //        NSString *taskname;
    //        if (latestCreateTaskStatusDict)
    //        {
    //            taskname = [latestCreateTaskStatusDict objectForKey:@"task_name"];
    //        }
    //        NSString *statusContent;
    //        if (latestCreateTaskStatusDict)
    //        {
    //            if ([[latestCreateTaskStatusDict objectForKey:@"feature"] intValue] == 1)
    //            {
    //                statusContent = [latestCreateTaskStatusDict objectForKey:@"content"];
    //            }
    //            else if ([[latestCreateTaskStatusDict objectForKey:@"feature"] intValue] == 2)
    //            {
    //                statusContent = @"[图片]";
    //            }
    //            else if ([[latestCreateTaskStatusDict objectForKey:@"feature"] intValue] == 3)
    //            {
    //                statusContent = @"[语音]";
    //            }
    //
    //            cell.timeLabel.text = [TaskTools showTime:[latestCreateTaskStatusDict objectForKey:@"create_time"]];
    //        }
    //
    //        if (taskname && statusContent)
    //        {
    //            cell.lastContentLabel.text = [NSString stringWithFormat:@"%@:%@",taskname,statusContent];
    //        }
    //        if ([[[SqliteDataDao sharedInstanse] findSetWithKey:@"readed" andValue:@"0" andTableName:TASK_STATUS_TABLE] count] > 0)
    //        {
    //            cell.unreadNumLabel.hidden = NO;
    //            NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithKey:@"readed" andValue:@"0" andTableName:TASK_STATUS_TABLE];
    //            cell.unreadNumLabel.frame = CGRectMake(cell.iconImageView.frame.origin.x+cell.iconImageView.frame.size.width-10, cell.iconImageView.frame.origin.y+0, 20, 20);
    //            cell.unreadNumLabel.backgroundColor = [UIColor redColor];
    //            cell.unreadNumLabel.text = [NSString stringWithFormat:@"%d",[unReadArray count]];
    //            cell.unreadNumLabel.layer.cornerRadius = 10;
    //            cell.unreadNumLabel.clipsToBounds = YES;
    //        }
    //        else
    //        {
    //            cell.unreadNumLabel.hidden = YES;
    //        }
    //        return cell;
    //       // }
    //    }
    
    
    NSString *CellIdentifier = @"Cell";
    
    ChatListModel * message = self.messagesArray[indexPath.row];
    NSString *str=[[SqliteDataDao sharedInstanse]queryTempstrWithtoUserId:message.toUserId];
    if(str.length>0){
        message.lastMessageType=5;
        message.lastMessage=str;
    }
    NSString *cellDict_key=[NSString stringWithFormat:@"message_chat_cell_%@",message.toUserId];
    if([cellDict_key isEqualToString:@"message_chat_cell_null"]){
        DDLogInfo(@"有误cell");
        MessageCell *cell=[[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setHidden:YES];
        return  cell;
    }
    MessageCell *cell=[cellDict objectForKey:cellDict_key];
    if (!cell) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.cell_row=indexPath.row;
        cell.message=message;
        cell.unRead=self.unRead;
        [cell addImageToHeadImage];
        
        [cellDict setObject:cell forKey:cellDict_key];
    }
    if(indexPath.row==self.messagesArray.count-1){
        [cell.lineview setFrame:CGRectMake(0, 66.5, 320, 0.5)];
    }else{
        [cell.lineview setFrame:CGRectMake(72, 66.5, 248, 0.5)];
    }
    return cell;
}

#pragma mark 标记已读消息的通知
-(void) markReaded:(NSNotification *)noticeDic{
    NSString * chatTaskId = [NSString stringWithFormat:@"%@",[[noticeDic userInfo] valueForKey:@"taskId"]];
    for (NotesData * msg in self.messagesArray) {
        
        if (![msg isKindOfClass:[NotesData class]]) {
            //如果不是这个类型,跳过
            continue;
        }
        
        if ([msg.taskId isEqualToString:chatTaskId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"markHasReadChatCount" object:[self.unRead valueForKey:msg.taskId] userInfo:nil];
            break;
        }
    }
}
-(void)haveSendMessage:(id)sender{
    [self loadBaseData];
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 67;
}

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideMenu];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];

    //#pragma mark 任务流
    //    if (indexPath.row == 0) {
    //        TaskViewController *taskVC = [[TaskViewController alloc] init];
    //        taskVC.taskViewDelegate = self;
    //        [self.navigationController pushViewController:taskVC animated:YES];
    //        return;
    //    }
    
    ChatListModel *clm=[self.messagesArray objectAtIndex:indexPath.row];
    
    if (clm.chatType==2){
        if (!publicListVC) {
            publicListVC=[[PublicAccountListViewController alloc] init];
            publicListVC.hidesBottomBarWhenPushed=YES;
            //            publicListVC.messagesArray=clm.publicModelArray;
            [self.navigationController pushViewController:publicListVC animated:YES];
            return;
        }
        
        
    }
    //更新已读状态
    [[SqliteDataDao sharedInstanse] updateReadStateWithToUserId:clm.toUserId];
    //   DDLogInfo(@"未读消息的总数：：：%d--%d",[ConstantObject app].unReadNum,clm.unReadCount);
    //    [self loadBaseData];
    [ConstantObject app].unReadNum=[ConstantObject app].unReadNum-clm.unReadCount;
    MessageChatViewController *detailViewController = [[MessageChatViewController alloc] init];
    detailViewController.hidesBottomBarWhenPushed=YES;
    detailViewController.chatType=clm.chatType;
    if (clm.chatType==1) {
        
        detailViewController.roomInfoModel=clm.roomInfoModel;
        
    }else if (clm.chatType==3){
        NSArray *tempArray=[clm.toUserId componentsSeparatedByString:@";"];
        NSMutableArray *emArray=[[NSMutableArray alloc] init];
        for (NSString *imacc in tempArray) {
            EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:imacc];
            if (em.imacct) {
                [emArray addObject:em];
            }
        }
        detailViewController.member_infoArray=emArray;
    }else if (clm.chatType==0){
        detailViewController.member_userInfo=clm.memberInfo;
    }
    
    [self.navigationController pushViewController:detailViewController animated:YES];
    return;
    NotesData * msg=nil;
    id value=[self.messagesArray objectAtIndex:indexPath.row];
    if ([value isKindOfClass:[NSString class]]){
        //提醒网络设置
        NoNetworkViewController *noNetVC=[[NoNetworkViewController alloc] init];
        noNetVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:noNetVC animated:YES];
        return;
    }else if ([value isKindOfClass:[NotesData class]]){
        msg = self.messagesArray[indexPath.row];
    }
    if (msg==nil) {
        return;
    }
    
    //菊花停止转圈
    
    detailViewController.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:detailViewController animated:YES];

}
-(void)loadBaseData{
    if (self.messagesArray) {
        [self.messagesArray removeAllObjects];
    }
    [self.messagesArray addObjectsFromArray:[[SqliteDataDao sharedInstanse] queryChatListDataWithToUserId]];
    [cellDict removeAllObjects];
    
    int all_unRead_count=0;
    //    NSMutableArray *tempArray=[[NSMutableArray alloc] init];
    
    int all_public_count=0;
    
    for (ChatListModel *clm in self.messagesArray) {
        all_unRead_count=all_unRead_count+clm.unReadCount;
        if (clm.chatType==2) {
            
            //            int for_i=0;
            for (ChatListModel *pubClm in clm.publicModelArray) {
                //                if (for_i==0) {
                //                    clm.unReadPublic=[NSString stringWithFormat:@"%d",clm.unReadCount];
                //                }else{
                //                    for_i++;
                //                }
                all_public_count+=pubClm.unReadCount;
                //                [tempArray addObject:pubClm];
            }
            clm.unReadCount=all_public_count==0?0:-1;
            
        }
    }
    
    all_unRead_count=all_unRead_count-all_public_count;
    if (all_unRead_count>0 && all_unRead_count==all_public_count) {
        all_unRead_count=-1;
    }
    
    
    
    
    MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
    if(ORG_ID)
    {
        NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
    //    maivc.tabbarButtTask.remindNum = [unReadArray count];
        if([unReadArray count] > 0)
        {
            maivc.tabbarButtTask.isRemind = YES;
        }
        else
        {
            maivc.tabbarButtTask.isRemind = NO;
        }
    }
    
    maivc.tabbarButt1.remindNum=all_unRead_count;
    [ConstantObject app].unReadNum=maivc.tabbarButtTask.remindNum + all_unRead_count;
    //#pragma mark 任务流
    //[self.messagesArray insertObject:@"任务流" atIndex:0];
    
    
    [self.tableView reloadData];
    
    if (publicListVC) {
        [publicListVC reloadTabel];
    }
    [self showtipview];
}
#pragma mark - alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //关闭推送及推送计数
    [[QFXmppManager shareInstance]closeMessageCount];
    [[QFXmppManager shareInstance]CancelPushNotification];
    
    [[QFXmppManager shareInstance] goOffline];
    //                   更新一次可见性表
    //                ContactsViewController * updateSee=[[ContactsViewController alloc]init];
    
    [SqlAddressData deleteLeadertable];
    [SqlAddressData deleteVisilityContact];
    //                [updateSee  requestAdressBookVisible];
    
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:keyWindow];
    [keyWindow addSubview:HUD];
    HUD.labelText = @"正在退出登录...";
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        [[ConstantObject sharedConstant] releaseAllValue];
        [[AFClient sharedClient] releaseAFClient];
        [[SqliteDataDao sharedInstanse] releaseData];
        [SqlAddressData releaseDataQueue];
        [[QFXmppManager shareInstance] releaseXmppManager];
        
        
        
        //       删除登录标识
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[LOGIN_FLAG filePathOfCaches] error:nil];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:myPassWord];
        //[[NSUserDefaults standardUserDefaults]removeObjectForKey:JSSIONID];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MyUserInfo];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:MOBILEPHONE];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:myGID];
        //                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:isSeeView];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //                  退出登录把通知栏的未读消息数置为0
        [ConstantObject app].unReadNum=0;
        
    } completionBlock:^{
        AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
        [app login];
    }];
}

#pragma -mark 来电

- (void)callIncoming:(NSNotification *)notification
{
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if(appDele.callState == CALLSTATE_COMMING || appDele.callState == CALLSTATE_CALLING)
    {
        if(dwCallId != appDele.callid_voip)
        {
            Mtc_CallTerm(dwCallId, EN_MTC_CALL_TERM_STATUS_NORMAL, ZNULL);
        }
        return;
    }
    appDele.callState = CALLSTATE_COMMING;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    appDele.callid_voip = dwCallId;
    BOOL isVideo = Mtc_CallPeerOfferVideo(dwCallId);
    DDLogInfo(@"来电了——ID：%d",dwCallId);
    ZCONST ZCHAR *pcPhone = Mtc_CallGetPeerName(dwCallId);
    NSString *imacct = [NSString stringWithUTF8String:pcPhone];
    EmployeeModel *emodel = [SqlAddressData queryMemberInfoWithImacct:imacct];
    NSString *callName = emodel.name;
    NSString *msg = isVideo?@"视频":@"语音";
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = [NSString stringWithFormat:
                                NSLocalizedString(@"%@发来%@请求", nil),callName,msg];
        localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
        localNotif.soundName = @"ringtone.mp3";
        localNotif.applicationIconBadgeNumber = 0;
        localNotif.userInfo = notification.userInfo;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
    
}

#pragma mark -终断

- (void)callTermed:(NSNotification *)notification
{
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];

    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDele.termedCallid = dwCallId;
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateActive)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MyCallTermedNotification" object:notification];
        return;
    }
    if(appDele.callState == CALLSTATE_CALLING)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MyCallTermedNotification" object:notification];
        return;
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    appDele.callState = CALLSTATE_TERMED_BG;
    DDLogInfo(@"来电了——ID：%d",dwCallId);
    BOOL isVideo = Mtc_CallPeerOfferVideo(dwCallId);
    ZCONST ZCHAR *pcPhone = Mtc_CallGetPeerName(dwCallId);
    NSString *imacct = [NSString stringWithUTF8String:pcPhone];
    EmployeeModel *emodel = [SqlAddressData queryMemberInfoWithImacct:imacct];
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    NSString* messageId=cfuuidString;
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    long long int dateTime=(long long int) nowTime;
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString=[dateFormatter stringFromDate:time];
    appDele.msg_voip.msg = isVideo?[NSString stringWithFormat:@"视频通话未接通"]:[NSString stringWithFormat:@"语音通话未接通"];
    appDele.msg_voip.messageID=messageId;
    //收到的消息,to和from都是from
    appDele.msg_voip.fileType = isVideo?9:10;    //视频通话类型为9，音频通话为10
    appDele.msg_voip.to = emodel.imacct;
    appDele.msg_voip.from  = emodel.imacct;
    appDele.msg_voip.thread=@"";
    appDele.msg_voip.chatType = 0;
    appDele.msg_voip.receivedTime = destDateString;
    [[SqliteDataDao sharedInstanse] insertDataToMessageData:appDele.msg_voip];
    [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:appDele.msg_voip.messageID];

    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.alertBody = [NSString stringWithFormat:
                                NSLocalizedString(@"未接来电", nil)];
        localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
        localNotif.applicationIconBadgeNumber = 0;
        localNotif.userInfo = notification.userInfo;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
    
}

- (void)networkStatusChanged:(NSNotification *)notification
{
    
    ZINT networkStatus = [[notification.userInfo objectForKey:@MtcCallNetworkStatusKey] intValue];
    if (networkStatus == EN_MTC_NET_STATUS_DISCONNECTED) {
        [self callTermed:notification];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideMenu];
}
@end
