//
//  TaskViewController.m
//  e企
//
//  Created by huangxiao on 15/1/18.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskCreateViewController.h"
#import "TaskStatusViewController.h"
#import "TaskClient.h"
#import "TaskListCell.h"
#import "SVPullToRefresh.h"
#import "TaskTools.h"
#import "base64.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "MainNavigationCT.h"
#import "QFXMPPManager.h"
#import "CompleteButtonTableViewCell.h"
#import "Reachability.h"

//创建企业
#import "CreateEnterPriseViewController.h"

@interface TaskViewController () <UITableViewDelegate, UITableViewDataSource,ReloadTaskDelegate,CreateTaskDelegate,UIAlertViewDelegate>
{
    BOOL showCompleteTask;
    NSArray *serverTasks;
    
    UILabel *tipLabel;
}

@property (strong, nonatomic)UITableView *tableView;

@property (nonatomic, strong)NSString *org_id;
@property (nonatomic, strong)NSString *userId;
@property (nonatomic, assign)int page;
@property (nonatomic, assign)int currentPage;
@property (nonatomic, assign)int count;
@property (nonatomic, strong)NSMutableArray *taskList;

@end

@implementation TaskViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"任务";

    showCompleteTask = NO;
        
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(KScreenWidth-48, 0, 44, 44);
    [_rightButton setImage:[UIImage imageNamed:@"nav-bar_add.png"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(addTask:) forControlEvents:UIControlEventTouchUpInside];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-50-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
//    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView setSeparatorColor:[UIColor clearColor]];//cell中间消除白线
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:self.tableView];
    
    
    NSString *tipString = @"高效管理工作进展\n点击“+”发起任务";
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:tipString];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:10];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [tipString length])];
    
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(50, 148, ScreenWidth-100, 50);
    tipLabel.numberOfLines = 2;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textColor = cor3;
    tipLabel.hidden = YES;
    tipLabel.attributedText = attributedString;
    [self.view addSubview:tipLabel];
    
    NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
    MainNavigationCT *mainNavCT = (MainNavigationCT *)self.navigationController;
    MainViewController *mainVC = (MainViewController *)mainNavCT.mainVC;
    if ([unReadArray count] > 0)
    {
        mainVC.tabbarButtTask.isRemind = YES;
    }
    else
    {
        mainVC.tabbarButtTask.isRemind = NO;
    }
    [ConstantObject app].unReadNum = mainVC.tabbarButt1.remindNum + [unReadArray count];
    
    //添加下拉加载历史记录
    __weak TaskViewController *weakSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        
        [weakSelf loadTaskListFromServer];
        
    } position:SVPullToRefreshPositionTop];
    
    QFXmppManager *xmppManager = [QFXmppManager shareInstance];
    xmppManager.receiveTaskPushInTaskView = ^(NSDictionary *taskStatusDict){
        [self receivedNewTaskStatusPush:taskStatusDict];
        [self reloadTaskList];
    };
    
    self.org_id = [[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    self.userId = [[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    self.page = 1;
    self.currentPage = 1;
    self.count = 0;;
    
    [self timeLabel:nil];
    _taskList = [[NSMutableArray alloc] init];
    [self initTask];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_rightButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWTABBAR object:nil userInfo:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];

    if (_rightButton) {
        [_rightButton removeFromSuperview];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReceiveNewTaskPush object:nil];
}

-(void)deleteStatus
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *tasksInStatusTable = [[SqliteDataDao sharedInstanse] findTasksFromTaskStatusTable];
        
        if (serverTasks)
        {
            for(NSDictionary *taskIdDict in tasksInStatusTable)
            {
                if (![self haveThisTaskOnServer:[taskIdDict objectForKey:@"task_id"]])
                {
                    if (![[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"task_id":[taskIdDict objectForKey:@"task_id"],@"user_id":USER_ID} andTableName:TASK_STATUS_TABLE])
                    {
                        DDLogError(@"delete status failed!");
                    }
                }
            }
        }
       dispatch_async(dispatch_get_main_queue(), ^{
           NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
           MainNavigationCT *mainNavCT = (MainNavigationCT *)self.navigationController;
           MainViewController *mainVC = (MainViewController *)mainNavCT.mainVC;
           //    mainVC.tabbarButtTask.remindNum = [unReadArray count];
           if ([unReadArray count] > 0)
           {
               mainVC.tabbarButtTask.isRemind = YES;
           }
           else
           {
               mainVC.tabbarButtTask.isRemind = NO;
           }
           [ConstantObject app].unReadNum = mainVC.tabbarButt1.remindNum + [unReadArray count];
       });
    });
}

-(BOOL)haveThisTaskOnServer:(NSString *)taskId
{
        for(NSDictionary *taskDict in serverTasks)
        {
            NSString *task_id = [NSString stringWithFormat:@"%lld",[[taskDict objectForKey:@"task_id"] longLongValue]];
            if ([task_id isEqualToString:taskId])
            {
                return YES;
            }
        }
        return NO;
}

//add

-(void)loadDataFromDB
{
    @synchronized (_taskList) {
        [_taskList removeAllObjects];
    }
    
    NSMutableArray *uncompleteArray = [[NSMutableArray alloc] initWithArray:[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"complete_state":@"0"} andTableName:TASK_TABLE orderBy:@"update_time" orderFunc:1]];
    NSMutableArray *completeArray = [[NSMutableArray alloc] initWithArray:[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"complete_state":@"1"} andTableName:TASK_TABLE orderBy:@"update_time" orderFunc:1]];
    
    NSMutableArray *completeUnreadArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *dict in completeArray)
    {
        NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"task_id":[dict objectForKey:@"task_id"],@"readed":@"0"} andTableName:TASK_STATUS_TABLE orderBy:nil];
        if ([unReadArray count] > 0)
        {
            [completeUnreadArray addObject:dict];
        }
    }
    for (NSDictionary *dict in completeUnreadArray)
    {
        [completeArray removeObject:dict];
    }
    [uncompleteArray addObjectsFromArray:completeUnreadArray];
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"update_time" ascending:NO]];
    [uncompleteArray sortUsingDescriptors:sortDescriptors];
    
    [_taskList addObjectsFromArray:uncompleteArray];
    [_taskList addObjectsFromArray:completeArray];
}

- (void)initTask {
//    [self loadDataFromDB];
    [_tableView triggerPullToRefresh];
}

-(void)reloadTaskSuccess
{
    [self loadTaskListFromServer];
}

- (void)createTaskSuccess {
    [self loadTaskListFromServer];
}

-(void)receivedNewTaskStatusPush:(NSDictionary *)taskStatusDict
{
    if (!taskStatusDict)
    {
        [self loadTaskListFromServer];
        return ;
    }
    if ([[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAddSelfToTask ||
        [[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeCreateTask)
    {
        [self loadTaskListFromServer];
        return ;
    }
    if([[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeTaskDeleted)
    {
        if ([[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"task_id":[taskStatusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
        {
            DDLogCError(@"delete task failed!");
        }
        if ([[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"task_id":[taskStatusDict objectForKey:@"task_id"]} andTableName:TASK_STATUS_TABLE])
        {
            DDLogCError(@"delete task status failed!");
        }
    }
    
    @synchronized (_taskList) {
        [_taskList removeAllObjects];
    }
    
    [self reloadTaskList];
}


-(void)reloadTaskList
{
    [self loadDataFromDB];
    [self.tableView reloadData];
    
    if([self.taskList count] > 0)
    {
        self.tableView.hidden = NO;
        tipLabel.hidden = YES;
    }
    else
    {
        self.tableView.hidden = YES;
        tipLabel.hidden = NO;
    }
    
    NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil];
    MainNavigationCT *mainNavCT = (MainNavigationCT *)self.navigationController;
    MainViewController *mainVC = (MainViewController *)mainNavCT.mainVC;
//    mainVC.tabbarButtTask.remindNum = [unReadArray count];
    if ([unReadArray count] > 0)
    {
        mainVC.tabbarButtTask.isRemind = YES;
    }
    else
    {
        mainVC.tabbarButtTask.isRemind = NO;
    }
    [ConstantObject app].unReadNum = mainVC.tabbarButt1.remindNum + [unReadArray count];
}

- (void)loadTaskListFromServer{
    NSString *newPath = [NSString stringWithFormat:@"%@%@",@"task_group/service/",@"task/user_timeline.json"];
    [[AFClient sharedClient] getPath:newPath parameters:@{@"org_id":ORG_ID,@"uid":USER_ID,@"count":[NSString stringWithFormat:@"%d",self.count],@"page":[NSString stringWithFormat:@"%d",self.page]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @synchronized (_taskList) {
            [_taskList removeAllObjects];
        }
        serverTasks = [responseObject objectForKey:@"tasks"];
        
        [[SqliteDataDao sharedInstanse]  deleteTableDataFromTable:TASK_TABLE key:nil value:nil];
        
        
        
        for(NSDictionary *taskDict in serverTasks)
        {
            
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            [tmpDict setObject:USER_ID forKey:@"user_id"];
            for(NSString *key in taskDict)
            {
                NSString *valueType = NSStringFromClass([[[serverTasks firstObject] objectForKey:key] class]);
                if ([valueType isEqualToString:@"__NSCFNumber"])
                {
                    [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[taskDict objectForKey:key] longLongValue]] forKey:key];
                }
                else
                {
                    if ([key isEqualToString:@"task_name"] &&[TaskTools decodingString:[taskDict objectForKey:key]] && [[TaskTools decodingString:[taskDict objectForKey:key]] length] > 0
                        )
                    {
                        [tmpDict setObject:[TaskTools decodingString:[taskDict objectForKey:key]] forKey:key];
                    }
                    else if([key isEqualToString:@"task_member"])
                    {
                        NSArray *memberArray = [taskDict objectForKey:@"task_member"];
                        NSMutableString *memberString = [[NSMutableString alloc] initWithCapacity:0];
                        for(NSString *tmpStr in memberArray)
                        {
                            [memberString appendFormat:@"%@,",tmpStr];
                        }
                        [tmpDict setObject:[memberArray count] > 1?[memberString substringToIndex:[memberString length]-1]:memberString forKey:key];
                    }else if ([key isEqualToString:@"description"] &&[TaskTools decodingString:[taskDict objectForKey:key]] && [[TaskTools decodingString:[taskDict objectForKey:key]] length] > 0
                              )
                    {
                        [tmpDict setObject:[TaskTools decodingString:[taskDict objectForKey:key]] forKey:key];
                    }
                    else if (![taskDict objectForKey:@"description"])
                    {
                        [tmpDict setObject:@"" forKey:@"description"];
                    }
                    else
                    {
                        if ([taskDict objectForKey:key])
                        {
                            [tmpDict setObject:[NSString stringWithFormat:@"%@",[taskDict objectForKey:key]] forKey:key];
                        }
                        else
                        {
                            [tmpDict setObject:@"" forKey:key];
                        }
                    }
                    
                    
                }
            }
            
            if ([[[SqliteDataDao sharedInstanse]  findSetWithDictionary:@{@"task_id":[tmpDict objectForKey:@"task_id"]} andTableName:TASK_TABLE orderBy:nil] count] == 0)
            {
                if (![[SqliteDataDao sharedInstanse]  insertTaskRecord:tmpDict andTableName:TASK_TABLE])
                {
                    DDLogInfo(@"insert task fail");
                }
            }
            else
            {
                if ([[SqliteDataDao sharedInstanse]  deleteRecordWithDict:@{@"task_id":[tmpDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                {
                    if (![[SqliteDataDao sharedInstanse] insertTaskRecord:tmpDict andTableName:TASK_TABLE])
                    {
                        DDLogInfo(@"insert task fail");
                    }
                }
            }
        }
        [self reloadTaskList];
        [self deleteStatus];
        [self.tableView.pullToRefreshView stopAnimating];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView.pullToRefreshView stopAnimating];
        [self reloadTaskList];
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1 delayTime:1 isKeyShow:NO];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_taskList count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [_taskList count])
    {
        NSDictionary *task = (_taskList)[indexPath.row];
        TaskListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TaskListCell" owner:self options:nil] lastObject];
        }
        if([[task objectForKey:@"complete_state"] intValue] == 1 && !showCompleteTask && [[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"task_id":[task objectForKey:@"task_id"],@"org_id":ORG_ID,@"user_id":USER_ID,@"readed":@"0"} andTableName:TASK_STATUS_TABLE orderBy:nil] count] == 0)
        {
            for(UIView *view in cell.contentView.subviews)
            {
                view.hidden = YES;
            }
        }
        else
        {
            for(UIView *view in cell.contentView.subviews)
            {       
                view.hidden = NO;
            }
        }
        NSString *taskName  = [task objectForKey:@"task_name"];
        NSString *taskID    = [task objectForKey:@"task_id"];
        NSString *deadLine  = task[@"dead_line"];
        if ((id)taskName == [NSNull null]) {
            taskName = @"";
        }
        if ((id)taskID == [NSNull null]) {
            taskID = @"";
        }
        if ((id)deadLine == [NSNull null]) {
            deadLine = @"";
        }
        cell.taskNameLabel.text = [taskName isEqualToString:@""]?@"未标题任务":taskName;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
        if ([[task objectForKey:@"complete_state"] intValue] == 1 && showCompleteTask) {
            cell.completeImgView.hidden = YES;
            cell.statusImgView.hidden = NO;
            cell.statusImgView.image = [UIImage imageNamed:@"icon_achieve"];
            cell.timeLabel.text = @"已归档";
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            cell.taskNameLabel.textColor = [UIColor lightGrayColor];
        }
        else {
            cell.completeImgView.hidden = NO;
            cell.statusImgView.hidden = YES;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            if ([deadLine isEqualToString:@"0"]) {
                cell.timeLabel.text = @"未设置";
            }else {
                if ([self timeLabel:deadLine] > 0) {
                    long long date = (long long)[self timeLabel:deadLine];
                    cell.timeLabel.text = [NSString stringWithFormat:@"%lld天后",date];
                }
                else if([self timeLabel:deadLine] < 0)
                {
                    cell.timeLabel.text = [NSString stringWithFormat:@"已逾期"];
                    cell.statusImgView.hidden = NO;
                    cell.statusImgView.image = [UIImage imageNamed:@"icon_out-of-date"];
                }
                else if ([self timeLabel:deadLine] == 0)
                {
                    NSDate *localDate = [NSDate date];
                    NSTimeInterval localTimeInterVal = [localDate timeIntervalSince1970];
                    CGFloat hours = ((long long)localTimeInterVal - [deadLine longLongValue]/1000)/HOUR;
                    cell.timeLabel.text = [NSString stringWithFormat:/*@"%.0f小时后逾期"*/@"%.0f小时后",hours<0?(-hours):(hours<1?1:hours)];
                }
            }
            cell.taskNameLabel.textColor = [taskName isEqualToString:@""]?[UIColor grayColor]:[UIColor blackColor];
        }
       
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *latestStatusDict = [[SqliteDataDao sharedInstanse] findLatestStatusWithTaskId:taskID];
            NSLog(@"latest dict %@",latestStatusDict);
            NSString *userPhone = [latestStatusDict objectForKey:@"from_user_id"];
            EmployeeModel *userModel = [SqlAddressData queryMemberInfoWithPhone:userPhone];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (latestStatusDict && userModel)
                {
                    NSString *statusContent;
                    if ([[latestStatusDict objectForKey:@"feature"] intValue] == 1)
                    {
                        if ([[latestStatusDict objectForKey:@"content"] length]>18) {
                            statusContent = [NSString stringWithFormat:@"%@:%@...",userModel.name,[[latestStatusDict objectForKey:@"content"] substringToIndex:18]];
                        }else {
                            statusContent = [NSString stringWithFormat:@"%@:%@",userModel.name,[latestStatusDict objectForKey:@"content"]];
                        }
                    }
                    else if ([[latestStatusDict objectForKey:@"feature"] intValue] == 2)
                    {
                        statusContent = [NSString stringWithFormat:@"%@:%@",userModel.name,@"[图片]"];
                    }
                    else if ([[latestStatusDict objectForKey:@"feature"] intValue] == 3)
                    {
                        statusContent = [NSString stringWithFormat:@"%@:%@",userModel.name,@"[语音]"];
                    }
                    else if([[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDeadLine ||
                            [[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateMember ||
                            [[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateName ||
                            [[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateNameAndMember ||
                            [[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeCreateTask ||
                            [[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDescription)
                    {
                        statusContent = [latestStatusDict objectForKey:@"content"];
                    }
                    else if([[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAddSelfToTask)
                    {
                        EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:[latestStatusDict objectForKey:@"from_user_id"]];
                        statusContent = [NSString stringWithFormat:@"%@：邀请你加入任务",model.name];
                    }
                    else if([[latestStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeComplete)
                    {
                        EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:[latestStatusDict objectForKey:@"from_user_id"]];
                        statusContent = [NSString stringWithFormat:@"%@：标记任务已归档",model.name];
                    }
                    
                    cell.contentLabel.text = statusContent;
                }
                else
                {
                    NSString *creator_uid = [task objectForKey:@"creator_uid"];
                    if ((id)creator_uid == [NSNull null]) {
                        creator_uid = @"";
                    }
                    EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                    NSString *creater_name = model.name ? model.name:@"未知";
                    if ([[task objectForKey:@"complete_state"] intValue] ==1)
                    {
                        cell.contentLabel.text = [NSString stringWithFormat:@"%@：编标记任务已归档",creater_name];
                    }
                    else
                    {
                        cell.contentLabel.text = [NSString stringWithFormat:@"%@：创建了任务",creater_name];
                    }
                }
            });
        });
        NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":[[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE],@"task_id":taskID,@"readed":@"0"} andTableName:TASK_STATUS_TABLE orderBy:nil];
        cell.unreadLabel.frame = CGRectMake(7, cell.taskNameLabel.frame.origin.y+3, 16, 12);
        cell.unreadLabel.text = [NSString stringWithFormat:@"%d",[unReadArray count]];
        cell.unreadLabel.font = [UIFont systemFontOfSize:8];
        cell.unreadLabel.backgroundColor = TaskRedColor;
        cell.unreadLabel.layer.cornerRadius = 6;
        cell.unreadLabel.clipsToBounds = YES;
        if ([unReadArray count] > 0)
        {
            if ([[task objectForKey:@"complete_state"] intValue] != 1) {
                cell.unreadLabel.hidden = NO;
            }
        }
        else
        {
            cell.unreadLabel.hidden = YES;
        }
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTask:)];
        cell.contentView.tag = indexPath.row;
        [cell.contentView addGestureRecognizer:longPress];
        cell.contentView.userInteractionEnabled = YES;
        
        if([[task objectForKey:@"complete_state"] intValue] == 1 && !showCompleteTask)
        {
            cell.completeImgView.hidden = YES;
            cell.statusImgView.hidden = YES;
            if ([unReadArray count] == 0)
            {
                cell.unreadLabel.hidden = YES;
            }
            else
            {
                cell.unreadLabel.hidden = NO;
//                cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
                cell.taskNameLabel.textColor = [UIColor lightGrayColor];
                cell.timeLabel.text = @"已归档";
            }
        }
        else if ([[task objectForKey:@"complete_state"] intValue] == 1 && showCompleteTask)
        {
            cell.completeImgView.hidden = YES;
//            cell.statusImgView.hidden = YES;
            if ([unReadArray count] == 0)
            {
                cell.unreadLabel.hidden = YES;
                cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
            }
            else
            {
                cell.unreadLabel.hidden = NO;
                cell.contentView.backgroundColor = [UIColor whiteColor];
                cell.taskNameLabel.textColor = [UIColor lightGrayColor];
                cell.timeLabel.text = @"已归档";
            }
        }
        
        if (indexPath.row == [tableView numberOfRowsInSection:0]-1)
        {
            cell.lineView.frame = CGRectMake(0, 67.5, KScreenWidth, 0.5);
        }
        else
        {
            cell.lineView.frame = CGRectMake(30, 67.5, KScreenWidth-30, 0.5);
        }
        
        return cell;
    }
    else
    {
        static NSString *completeCellIder = @"completeCellIder";
        CompleteButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:completeCellIder];
        if (cell == nil)
        {
            cell = [[CompleteButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:completeCellIder];
        }
        
        if (showCompleteTask)
        {
            [cell.completeButton setTitle:@"隐藏已归档任务" forState:UIControlStateNormal];
        }
        else
        {
            [cell.completeButton setTitle:@"显示已归档任务" forState:UIControlStateNormal];
        }
        [cell.completeButton addTarget:self action:@selector(completeButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if ([[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"complete_state":@"1"} andTableName:TASK_TABLE orderBy:@"update_time" orderFunc:1] count] > 0)
        {
            cell.completeButton.hidden = NO;
        }
        else
        {
            cell.completeButton.hidden = YES;
        }
        
        return cell;
    }
    return nil;
}

-(void)completeButtonClick
{
    showCompleteTask = !showCompleteTask;
    [self.tableView reloadData];
    if ([_taskList count]>0) {
        NSInteger row = [_taskList count];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)deleteTask:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"是否删除该任务？"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        al.delegate = self;
        al.tag = longPress.view.tag;
        [al show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //
        NSDictionary *taskDict = [_taskList objectAtIndex:alertView.tag];
        if (![[taskDict objectForKey:@"creator_uid"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]])
        {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"只有任务创建者才能删除任务！" isCue:1 delayTime:1 isKeyShow:NO];
            return ;
        }
        
        if (![Reachability isNetWorkReachable])
        {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请检查网络设置！" isCue:1 delayTime:1 isKeyShow:NO];
            return ;
        }
        
        NSDictionary *parameters = @{@"org_id":self.org_id,
                                     @"uid":USER_ID,
                                     @"task_id":[taskDict objectForKey:@"task_id"]};
        [[TaskClient shareClient] postDeleteTaskWithParameters:parameters andPath:@"task/delete.json" success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
                if ([[responseDict objectForKey:@"result"]intValue] == 0)
                {
                    [_taskList removeObjectAtIndex:alertView.tag];
                    [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"删除成功" isCue:0 delayTime:1 isKeyShow:NO];
                    if (![[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"user_id":USER_ID,@"task_id":[taskDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                    {
                        DDLogCError(@"任务从数据库中删除失败");
                    }
                    if(![[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"task_id":[taskDict objectForKey:@"task_id"],@"user_id":USER_ID} andTableName:TASK_STATUS_TABLE])
                    {
                        DDLogCError(@"任务状态从数据库中删除失败");
                    }
                    [self reloadTaskList];
                }
                else
                {
                    DDLogCError(@"%@",[responseDict objectForKey:@"msg_error"]);
                }

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
}


- (long long)timeLabel:(NSString *)dateTime {
    if ([dateTime length] > 10)
    {
        dateTime = [dateTime substringToIndex:10];
    }
    NSDate *date = [NSDate date];
    //时区
    NSTimeZone* destinationTimeZone     = [NSTimeZone localTimeZone];
    //时区时间偏移量
    NSInteger sourceGMTOffset           = [destinationTimeZone secondsFromGMTForDate:date];
    NSDate *localDate                   = [date  dateByAddingTimeInterval:sourceGMTOffset];
    NSTimeInterval localTimeInterVal    = [localDate timeIntervalSince1970];
    
    NSString *localtimeStr  = [NSString stringWithFormat:@"%.0lf",localTimeInterVal];
    NSString *timeStr       = [NSString stringWithFormat:@"%@",dateTime];
    long long resultTime    = ([timeStr longLongValue]-[timeStr longLongValue]%SECPERDAY) - ([localtimeStr longLongValue]-[localtimeStr longLongValue]%SECPERDAY);
    
    return (long long)(resultTime/SECPERDAY);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row >= self.taskList.count)
    {
        return ;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
    NSDictionary *taskDict = _taskList[indexPath.row];
    TaskStatusViewController *taskStatusVC = [[TaskStatusViewController alloc] init];
    taskStatusVC.taskDict = taskDict;
    taskStatusVC.hidesBottomBarWhenPushed = YES;
    taskStatusVC.reloadTaskDelegate = self;
    [self.navigationController pushViewController:taskStatusVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < [_taskList count])
    {
        NSDictionary *task = [_taskList objectAtIndex:indexPath.row];
        if([[task objectForKey:@"complete_state"] intValue] == 1 && !showCompleteTask && [[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"task_id":[task objectForKey:@"task_id"],@"org_id":ORG_ID,@"user_id":USER_ID,@"readed":@"0"} andTableName:TASK_STATUS_TABLE orderBy:nil] count] == 0)
        {
            return 0;
        }
        else
        {
            return 68;
        }
    }
    if ([[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"complete_state":@"1"} andTableName:TASK_TABLE orderBy:@"update_time" orderFunc:1] count] > 0)
    {
        return 40;
    }
    return 0;
}

- (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)addTask:(UIButton *)button {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
    
    TaskCreateViewController *taskCreateVC = [[TaskCreateViewController alloc] init];
    taskCreateVC.hidesBottomBarWhenPushed = YES;
    taskCreateVC.createTaskDelegate = self;
    taskCreateVC.isFromMessage = NO;
    [self.navigationController pushViewController:taskCreateVC animated:YES];
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

