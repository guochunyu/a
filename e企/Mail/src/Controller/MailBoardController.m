//
//  MailBoardController.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailBoardController.h"
#import "MailBoardHandler.h"
#import "MailBoardCell.h"
#import "Email.h"
#import "LogicHelper.h"
#import "AccountPopup.h"
#import "AccountAddCell.h"
#import "MailActAddController.h"
#import "MainNavigationCT.h"
#import "AccountAddCell.h"

NSString*const notificationEmail=@"Unread";



@interface MailBoardController () <UIGestureRecognizerDelegate, AccountPopupDelegate,UISearchBarDelegate,UISearchDisplayDelegate, AccountAddCellDelegate, UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>{
    UIBarButtonItem *tempiAccountButton;
    UIBarButtonItem *tempiEditButton;
}


@property (nonatomic) EmailAccount *account;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *iFetchProgress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *iEditButton;
@property (strong, nonatomic) IBOutlet UIView *iBoxView; //收信箱，发信箱。。。视图
@property (weak, nonatomic) IBOutlet UITableView *iAccountTable;  //邮箱列表
@property (weak, nonatomic) IBOutlet UILabel *iProgressLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapp;

@property (nonatomic) NSMutableArray *emails;
@property (nonatomic) NSArray *boxTitles;
@property (nonatomic) UIButton *titleButton;
@property (nonatomic) EmailArchiveType type;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *iAccountButton;
@property (strong, nonatomic) IBOutlet UIView *iAccountAddView;

@property (nonatomic) AccountPopup *accountPopup;

//@property (weak, nonatomic) IBOutlet UISearchBar *iSearchBar;
@property (nonatomic) UISearchBar *iSearchBar;
@property (weak, nonatomic) IBOutlet UIButton *iAccountAddButton;
@property (nonatomic) UIRefreshControl *rc;
@property (weak, nonatomic) IBOutlet UIButton *iLoadMoreButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *iLoadMoreProgress;
@property (weak, nonatomic) IBOutlet UIView *iHeaderView;
@property (weak, nonatomic) IBOutlet UIView *iFooterView;

@property (nonatomic) BOOL batchEdit;
@property (weak, nonatomic) IBOutlet UIView *batchView;
@property (nonatomic) NSMutableArray *batchEmails;

@property (weak, nonatomic) IBOutlet UIButton *iReadButton;
@property (weak, nonatomic) IBOutlet UIButton *iUnreadButton;
@property (weak, nonatomic) IBOutlet UIButton *iTagButton;
@property (weak, nonatomic) IBOutlet UIButton *iUntagButton;
@property (weak, nonatomic) IBOutlet UIButton *iDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *iCancelButton;
@property (nonatomic) EmailAccount *authAccount;
@property (nonatomic) UIAlertView *deleteAccountAlert;
@property (nonatomic) BOOL hasDisappear;
@property(nonatomic,strong)UIButton*back;
@property (nonatomic) UIView *titleView;
@property(nonatomic,strong)UIButton *blackButton;
@property(nonatomic,assign) BOOL islogining;//是否正在登陆验证中
//@property (nonatomic) BOOL isFirstLoading;//是否是第一次加载，当时第一次加载最多加载10条
//@property (nonatomic,strong) NSMutableArray *emails10;

@property (nonatomic, strong)UIImageView *imagev;
@property (nonatomic, strong)UILabel *label;


@end

@implementation MailBoardController

-(void)checkAccountFailed
{
    
}

#pragma mark -
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvBox) name:@"recvBox" object:nil];

    [_handler initData];
    _hasDisappear = NO;
    _isFirstLoading=YES;
    _iSearchBar = [UISearchBar new];
    _iSearchBar.hidden = YES;
    _tapp.delegate = self;
    [self.view addGestureRecognizer:_tapp];
    [self initUI];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    _batchEdit = false;
    _batchEmails = [NSMutableArray new];
    _islogining=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logining) name:@"登陆中" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logined) name:@"登陆后" object:nil];
    
    _back = [[UIButton alloc]init];
    _back.frame = CGRectMake(0, 19, 80, 45);
    //[_back setBackgroundImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    //_back.backgroundColor = [UIColor lightGrayColor];
    [_back addTarget:self action:@selector(backff) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:_back];
    
    _imagev = [[UIImageView alloc]init];
    _imagev.frame = CGRectMake(3, 30, 25, 25);
    [_imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:_imagev];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(25, 32, 70, 20);
    _label.text = @"邮箱";
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:_label];
    
}

-(void)backff{
    //邮箱客户端返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)logining{
    _islogining=YES;
}
-(void)logined{
    _islogining=NO;
    if ([_accounts count]){
    _type=EmailArchiveTypeInbox;
    [_handler changeBoxType:_type];
    _emails = [NSMutableArray arrayWithArray:[_handler loadCacheMails:_type]];
    [_titleButton setTitle:_boxTitles[_type] forState:UIControlStateNormal];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (_hasDisappear) {
//        [self.tableView reloadData];
//        _hasDisappear = NO;
//        return;
//    }
    //[self notificationReadCount];
    if (_islogining) {
        _hasDisappear=NO;
        return;
    }
    [_handler loadAccounts];
    _accountPopup.accounts = _accounts;
    if ([_accounts count]  == 0) {
        self.refreshControl = nil;
        _iLoadMoreButton.hidden = YES;
        _iSearchBar.hidden = YES;
        [self customTitleView:NO];
        [self.tableView reloadData];
        
        self.title = @"邮箱";
        _hasDisappear = NO;
    } else {
        //have mail account
        _iHeaderView.hidden = NO;
        _iFooterView.hidden = NO;
        self.refreshControl = _rc;
        [self addAccountPopup];
        _iAccountAddButton.hidden = YES;
        [self customTitleView:YES];
        _emails = [NSMutableArray arrayWithArray:[_handler loadCacheMails:_type]];
      /*  if (_isFirstLoading&&_emails.count>10) {
            _emails10=[NSMutableArray arrayWithArray:[_emails subarrayWithRange:NSMakeRange(0, 10)]];
        }
        */
        if ([_emails count] == 0 && _type == EmailArchiveTypeInbox) {
            [_iFetchProgress startAnimating];
            _iProgressLabel.hidden = NO;
            [_handler loadRemoteMails];
        } else {
            _iSearchBar.hidden = NO;
            _iProgressLabel.hidden = YES;
            [_iFetchProgress stopAnimating];
            [self.tableView reloadData];
        }
        if (_type == EmailArchiveTypeInbox) {
            _iLoadMoreButton.hidden = NO;
        } else {
            _iLoadMoreButton.hidden = YES;
        }
    }
    _back.hidden = NO;
    _imagev.hidden = NO;
    _label.hidden = NO;
    [self notificationReadCount];
}


-(void)notificationReadCount{
    MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
    MainViewController *maivc = (MainViewController *)mainct.mainVC;
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    if ([_accounts count]  == 0){
       [maivc.tabbarButt3 setRemindNum:0];
        [ud setObject:@(0) forKey:@"未读个数"];
        return;
    }
    if(_type ==EmailArchiveTypeInbox){
        NSArray *mails =_isFirstLoading?[Email listEmails:_account.username archiveType:EmailArchiveTypeInbox includeDeleted:NO searchStr:nil]:_emails;
        NSInteger count=0;
        for (int i=0;i<mails.count;i++) {
            Email *e=mails[i];
            if(!e.isRead.boolValue){
                count++;
            }
        }
        [ud setObject:@(count) forKey:@"未读个数"];
        [maivc.tabbarButt3 setRemindNum:count];
        
    }
    [ud synchronize];
    [_iAccountTable reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //[[[UIAlertView alloc] initWithTitle:@"系统警告" message:@"邮件大附件获取中，频繁操作可能导致出错。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWTABBAR object:nil userInfo:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_islogining) {
        _hasDisappear=YES;
        return;
    }
    _iBoxView.hidden = YES;
    _accountPopup.hidden = YES;
    self.navigationItem.titleView = nil;
    [self batchEdit:NO];
    _hasDisappear = YES;
    //[_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    //self.hidesBottomBarWhenPushed = NO;
    _back.hidden = YES;
    _imagev.hidden = YES;
    _label.hidden = YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_iBoxView removeObserver:self forKeyPath:@"hidden"];
}

- (void)recvBox
{
    _type = EmailArchiveTypeSendbox;
    _emails = [NSMutableArray arrayWithArray:[_handler loadCacheMails:_type]];
    [_handler changeBoxType:_type];
    [self.tableView reloadData];
    [_titleButton setTitle:_boxTitles[_type] forState:UIControlStateNormal];
    _iLoadMoreButton.hidden = YES;

}

- (void)customTitleView:(BOOL)show
{
    if (!show) {
        self.title = @"邮箱";
        tempiEditButton = _iEditButton;
        tempiAccountButton = _iAccountButton;
        self.navigationItem.titleView = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
//    if (self.navigationItem.titleView == nil) {
        self.title = @"";
    
        float x = (self.view.frame.size.width -200) /2;
    static UIView *view=nil;
    if (view==nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(x, 2, 200, 40)];
        _titleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _titleButton.font=[UIFont systemFontOfSize:19];
        _titleButton.font=[UIFont boldSystemFontOfSize:18];;
        _titleButton.frame = CGRectMake(45, 0, 200, 40);
        [_titleButton setTitle:_boxTitles[_type] forState:UIControlStateNormal];
        //[_titleButton sizeToFit];
        //[_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(didTitleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *imge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
        imge.frame = CGRectMake(175, 17, 12, 6);
        [view addSubview:_titleButton];
        [view addSubview:imge];
    }
    self.navigationItem.titleView = view;
        if(tempiEditButton){
            self.navigationItem.leftBarButtonItem = tempiAccountButton;
            self.navigationItem.rightBarButtonItem = tempiEditButton;
        }
}


- (void)initUI
{
//     _iAccountTable.hidden=NO;
    DDLogInfo(@"ffff");
    _rc = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, -20, ABDEVICE_SCREEN_WIDTH, 50)];
    [_rc addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _rc;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    self.blackButton =[UIButton buttonWithType:UIButtonTypeCustom];
    _blackButton.frame = CGRectMake(-99,-99,999,999);
    [_blackButton addTarget:self action:@selector(hideBlackButton:) forControlEvents:UIControlEventTouchUpInside];
    _blackButton.backgroundColor=[UIColor blackColor];
    _blackButton.alpha=0.3;
    _blackButton.hidden=YES;
    [window addSubview:_blackButton];
    [_iBoxView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
  
    _iBoxView.frame = CGRectMake(ABDEVICE_SCREEN_WIDTH / 4 , ABIOS7_STATUS_BAR_HEIGHT, ABDEVICE_SCREEN_WIDTH / 2, 44 * [_boxTitles count]);
    //_iAccountTable.frame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH / 2, 44 * [_boxTitles count]);
    _iAccountTable.frame = CGRectMake(-53, 0, ABDEVICE_SCREEN_WIDTH-55, 44 * [_boxTitles count]);
    _iAccountTable.backgroundColor=[UIColor whiteColor];

    [_iBoxView addSubview:_iAccountTable];
    _iBoxView.hidden=YES;
    [window addSubview:_iBoxView];

}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    _blackButton.hidden=[[change objectForKey:@"new"] boolValue];
   // NSLog(@"asdasd:%@",[change objectForKey:@"new"]);
}
- (void)addAccountPopup
{
    if (_accountPopup != nil) {
        [_accountPopup removeFromSuperview];
    }
    _accountPopup = [[AccountPopup alloc] initWithAccount:_accounts delegate:self];
    [_accountPopup createAccountsPopupLeft];
    _accountPopup.hidden = YES;
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:_accountPopup];
}

- (void)refreshTableView
{
    if ([Reachability getCurrentNetWorkStatus]) {
        [_handler syncMails];
        [self notificationReadCount];
    }else{
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络断开了，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [a show];
    }
}

- (void)didTitleButtonClick:(UIButton *)sender
{
    DDLogInfo(@"点击收件箱时调用此方法");
    _accountPopup.hidden = YES;
   
    [_iSearchBar resignFirstResponder];
    
    _iBoxView.hidden = !_iBoxView.hidden;
    [_iAccountTable reloadData];
}
-(void)hideBlackButton:(UIButton * )button{
      _iBoxView.hidden = YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView==_iAccountTable){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _iAccountTable) {
        return section?[_boxTitles count]:1;
    }
    if (tableView == self.tableView) {
        if ([_accounts count]  == 0) {
            return 1;
        }
        //[self setUnReadMailCount];
        return _emails.count;
        //return _isFirstLoading&&_emails.count>10?_emails10.count:_emails.count;
    }
    return 1;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView==_iAccountTable) {
        if (section) {
            UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(20, 30, 30, 25)];
            label.backgroundColor=[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1];
            label.text=@"  文件夹";
            label.font=[UIFont systemFontOfSize:11];
            return label;
        }else{
            UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 25)];
            label1.backgroundColor=[UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1];
            label1.text=@"  当前邮箱";
            label1.font=[UIFont systemFontOfSize:11];
            return label1;
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView==_iAccountTable?30:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _iAccountTable) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailAccountCell" forIndexPath:indexPath];
        if (indexPath.section) {
            //收件箱
            if (indexPath.row==0) {
                NSNumber *n= [[NSUserDefaults standardUserDefaults] objectForKey:@"未读个数"] ;
                _Email_Unread = [NSString stringWithFormat:@"%@",n];
               // DDLogCInfo(@"_Email_Unread：%@",_Email_Unread);
                cell.textLabel.text=[NSString stringWithFormat:@"收件箱                                   %@",n];
                //[self Email_Unread_Notification_Methods];
            }else{
                cell.textLabel.text = _boxTitles[indexPath.row];
            }
        
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            if (_type==indexPath.row) {
                cell.textLabel.textColor = [UIColor colorWithRed:84.0/255.0 green:124.0/255.0 blue:213.0/255.0 alpha:1.0];
                cell.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0];
            }else{
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.backgroundColor = [UIColor whiteColor];
            }
        }else{
            //账户
            cell.textLabel.text=_account.username;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
//        cell.textLabel.textColor = [UIColor lightGrayColor];
//        cell.textLabel.font = [UIFont systemFontOfSize:16];
//        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        return cell;
    }
    
    if (tableView == self.tableView) {
        if ([_accounts count]  == 0) {
            _iHeaderView.hidden = YES;
            _iFooterView.hidden = YES;
            AccountAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountAddCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if([ConstantObject sharedConstant].userInfo.email)
            {
                cell.iAccountText.text = [ConstantObject sharedConstant].userInfo.email;
            }
            [cell configure:self];
            return cell;
        }
        MailBoardCell *cell = (MailBoardCell *)[tableView dequeueReusableCellWithIdentifier:@"MailBoardCell" forIndexPath:indexPath];
        if ([_emails count] >0) {
            Email *email=_emails[indexPath.row];
            //Email *email =_isFirstLoading&&_emails.count>10?_emails10[indexPath.row]:_emails[indexPath.row];
            [cell configureWithEmail:email batch:_batchEdit andType:_type];
            if (_batchEdit) {
                self.tableView.tableHeaderView = _iHeaderView;
                tableView.tableFooterView = _iFooterView;
            } else {
                UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongPress:)];
                [cell addGestureRecognizer:longPressGesture];
            }
            
            if ([_batchEmails containsObject:cell.email]) {
                [cell batchTag:YES];
            }else{
                [cell batchTag:NO];
            }
        }else{
            [self.tableView reloadData];
        }
        return cell;
    }
    return nil;
}


//邮箱未读消息传值
/*
- (void)Email_Unread_Notification_Methods {
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    //创建发布内容
    NSDictionary*data=@{@"product":_Email_Unread};
    //创建频道                                      频道名称                        内容
    NSNotification*notification=[NSNotification notificationWithName:notificationEmail object:nil userInfo:data];
    //通知中心发送广播
    [center postNotification:notification];
}
*/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        if ([_accounts count]  > 0)
        {
            return YES;
        }
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            Email *email = _emails[indexPath.row];
            //if (_isFirstLoading&&_emails.count>10) {[_emails10 removeObjectAtIndex:indexPath.row];}
            [_emails removeObject:email];
            [_handler deleteEmail:email];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self notificationReadCount];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.tableView) {
        
        if (_accountPopup.hidden == NO)
        {
            _accountPopup.hidden = YES;
            return ;
        }
        if (_iBoxView.hidden == NO)
        {
            _iBoxView.hidden = YES;
            return;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
        Email *email = _emails[indexPath.row];
        if (_batchEdit) {
            MailBoardCell *cell = (MailBoardCell *)[tableView cellForRowAtIndexPath:indexPath];
            if ([_batchEmails containsObject:cell.email]) {
                //[cell batchTag:NO];
                [_batchEmails removeObject:cell.email];
            } else {
                //[cell batchTag:YES];
                [_batchEmails addObject:cell.email];
            }
            [self.tableView reloadData];
        } else {
            [self batchEdit:NO];
            if (_type == EmailArchiveTypeDraft) {
                [_handler editMail:email];
            } else {
                [_handler showMailDetail:email];
                email.isRead=@(YES);
                [self notificationReadCount];
            }
        }
    } else  if(tableView==_iAccountTable){
        if (indexPath.section==0) {
            return;
        }
        _iBoxView.hidden = YES;
        [self batchEdit:NO];
        _type=indexPath.row;
        
        _emails = [NSMutableArray arrayWithArray:[_handler loadCacheMails:_type]];
        [_handler changeBoxType:_type];
        [self.tableView reloadData];
        [_titleButton setTitle:_boxTitles[_type] forState:UIControlStateNormal];
        if (_type == EmailArchiveTypeInbox) {
            _iLoadMoreButton.hidden = NO;
        } else {
            _iLoadMoreButton.hidden = YES;
        }
        [_iAccountTable reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _iAccountTable) {
        return 34;
    }
    if ([_accounts count]  == 0) {
        return 400;
    }
    return 100;
}

- (void)didAccountChanged:(EmailAccount *)account
{
    _deleteAccountAlert = [[UIAlertView alloc] initWithTitle:@"系统提示" message:@"是否删除该账号？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",nil];
    [_deleteAccountAlert show];
    
//    [self batchEdit:NO];
//    _account = account;
//    _type = EmailArchiveTypeInbox;
//    [_handler changeBoxType:_type];
//    [_titleButton setTitle:_boxTitles[_type] forState:UIControlStateNormal];
//    _iLoadMoreButton.hidden = NO;
//    [_handler changeAccount:_account];
//    _emails = [NSMutableArray arrayWithArray:[_handler loadCacheMails:_type]];
//    [self.tableView reloadData];
//    if ([_emails count] == 0) {
//        [_handler loadRemoteMails];
//    }
//    [self hiddenLoadMore:NO];
}

- (void)refreshMails
{
    [self.refreshControl endRefreshing]; 
    [_iFetchProgress stopAnimating];
    _iSearchBar.hidden = NO;
    _iProgressLabel.hidden = YES;
    [_iFetchProgress stopAnimating];
    [self hiddenLoadMore:NO];
    [self notificationReadCount];
//    if (_isFirstLoading&&_emails.count>10) {
//        _emails10=[NSMutableArray arrayWithArray:[_emails subarrayWithRange:NSMakeRange(0, 10)]];
//    }
    [self.tableView reloadData];
}

- (void)refreshMailContent:(NSString *)uid content:(NSString *)content
{
    NSUInteger count = [_emails count];
    for (NSUInteger i = 0; i < count; i++) {
        Email *email = _emails[i];
        if ([email.uid isEqualToString:uid]) {
            email.plainText = content;
            MailBoardCell *updateCell = (MailBoardCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (updateCell) {
                [updateCell configureWithEmailContent:content];
            }
            [self.tableView reloadData];
        }
    }

}

- (IBAction)didEditButtonClick:(id)sender
{
    if ([_accounts count] == 0)
    {
        return;
    }
    [self batchEdit:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
    [_handler editMail:nil];
    
}
-(void)sendemail:(EmployeeModel*)model
{
    if ([_accounts count] == 0)
    {
        return;
    }
    [self batchEdit:NO];
    [_handler EditMail:model];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView && _iSearchBar.hidden == NO) {
        _iBoxView.hidden = YES;
        _accountPopup.hidden = YES;
        [self.view endEditing:YES];
        //[_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    }
    
    if (_iSearchBar.hidden == YES) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

- (void)enableTitleButton:(BOOL)enable
{
    if (enable) {
        _titleButton.enabled = YES;
        [_titleButton setTitle:_boxTitles[0] forState:UIControlStateNormal];
    } else {
        _titleButton.enabled = NO;
        [_titleButton setTitle:@"读取中" forState:UIControlStateNormal];
    }
}



- (IBAction)didAccountButtonClick:(id)sender
{
        if ([_accounts count] == 0) {
            return;
        }
        if (_accountPopup.superview == nil) {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:_accountPopup];
        }
        _iBoxView.hidden = YES;
        BOOL hidden = _accountPopup.hidden;
        _accountPopup.hidden = !hidden;
        [_iSearchBar resignFirstResponder];

}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    _accountPopup.hidden = YES;
    _iBoxView.hidden = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([LogicHelper isBlankOrNil:searchText]) {
        _emails = [_handler doSearch:nil];
    } else {
        _emails = [_handler doSearch:searchText];
    }
    [self.tableView reloadData];
}

- (IBAction)didAccountAddButtonClick:(id)sender
{
     [_handler addMailAccount];
}

- (IBAction)didLoadMoreButtonClick:(id)sender
{
    if (_isFirstLoading) {
        _isFirstLoading=NO;
    }
    if ([Reachability getCurrentNetWorkStatus]) {
        _iLoadMoreButton.hidden = YES;
        _iLoadMoreButton.enabled = NO;
        [_iLoadMoreProgress startAnimating];
        [_handler loadMore];
    }else{
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络断开了，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [a show];
    }
}

- (void)hiddenLoadMore:(BOOL)hidden
{
    
    if (hidden) {
        _iLoadMoreButton.hidden = NO;
        [_iLoadMoreButton setTitle:@"没有更多邮件" forState:UIControlStateNormal];
        _iLoadMoreButton.enabled = NO;
        [_iLoadMoreProgress stopAnimating];
    } else {
        _iLoadMoreButton.hidden = NO;
        [_iLoadMoreButton setTitle:@"点击加载更多..." forState:UIControlStateNormal];
        _iLoadMoreButton.enabled = YES;
    }
    
}

- (void)loadNoData
{
    _iLoadMoreButton.hidden = NO;
    [_iLoadMoreButton setTitle:@"没有更多邮件" forState:UIControlStateNormal];
    _iLoadMoreButton.enabled = NO;
    [_iLoadMoreProgress stopAnimating];
}

- (void)loadMoreData
{
    _iLoadMoreButton.hidden = NO;
    [_iLoadMoreButton setTitle:@"点击加载更多..." forState:UIControlStateNormal];
    _iLoadMoreButton.enabled = NO;
    [_iLoadMoreProgress stopAnimating];
}

- (IBAction)hidden:(id)sender {
    [self.view endEditing:YES];
    [self.view.window endEditing:YES];
}

- (void)refreshViewForAccount
{
    if (_hasDisappear) {
        [_handler loadAccounts];
        [_account decreate];
        [self.tableView reloadData];
        _hasDisappear = NO;
        return;
    }
       
    [_handler initData];
    [_handler loadAccounts];
    _accountPopup.accounts = _accounts;
    _emails = [NSMutableArray new];
    [self.tableView reloadData];
    _iHeaderView.hidden = NO;
    _iFooterView.hidden = NO;
    if ([_accounts count]  == 0) {
        self.refreshControl = nil;
        _iLoadMoreButton.hidden = YES;
        [self.tableView reloadData];
    } else {
        self.refreshControl = _rc;
        [self addAccountPopup];
        _iAccountAddButton.hidden = YES;
        [self customTitleView:YES];
        _emails = [NSMutableArray arrayWithArray:[_handler loadCacheMails:_type]];
        if ([_emails count] == 0 && _type == EmailArchiveTypeInbox) {
            [_iFetchProgress startAnimating];
            _iProgressLabel.hidden = NO;
            [_handler loadRemoteMails];
        } else {
            _iSearchBar.hidden = NO;
            _iProgressLabel.hidden = YES;
            [_iFetchProgress stopAnimating];
            [self.tableView reloadData];
        }
        if (_type == EmailArchiveTypeInbox) {
            _iLoadMoreButton.hidden = NO;
        } else {
            _iLoadMoreButton.hidden = YES;
        }
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
     DDLogInfo(@"点击其他的时候退出");
    [[NSNotificationCenter defaultCenter]postNotificationName:@"WWDC" object:nil];
    _iBoxView.hidden=YES;
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
 
    return  YES;
}


#pragma mark - 批量操作
- (void)cellLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    return;
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        if (!_batchEdit) {
            [self batchEdit:YES];
        }
    }
    
}

- (void)batchEdit:(BOOL)edit
{
    _batchEdit = edit;
    _batchView.hidden = !edit;
    _iFooterView.hidden = edit;
    [self.tableView reloadData];
    if (!edit) {
        _batchEmails = [NSMutableArray new];
    }
    if (_type == EmailArchiveTypeDraft) {
        _iReadButton.hidden = YES;
        _iUnreadButton.hidden = YES;
        _iTagButton.hidden = YES;
        _iUntagButton.hidden = YES;
    } else {
        _iReadButton.hidden = NO;
        _iUnreadButton.hidden = NO;
        _iTagButton.hidden = NO;
        _iUntagButton.hidden = NO;
    }
    
}

- (IBAction)batchAllread:(id)sender
{
    for (Email *email in _batchEmails) {
        email.isRead = @(YES);
    }
    [self batchEdit:NO];
}

- (IBAction)batchAllUnread:(id)sender
{
    for (Email *email in _batchEmails) {
        email.isRead = @(NO);
    }
    [self batchEdit:NO];
}

- (IBAction)batchTag:(id)sender
{
    for (Email *email in _batchEmails) {
        email.isFlag = @(YES);
    }
    [self batchEdit:NO];
}

- (IBAction)batchUntag:(id)sender
{
    for (Email *email in _batchEmails) {
        email.isFlag = @(NO);
    }
    [self batchEdit:NO];
}

- (IBAction)batchDelete:(id)sender
{
    for (Email *email in _batchEmails) {
        [_handler deleteEmail:email];
        [_emails removeObject:email];
    }
    [self batchEdit:NO];
}

- (IBAction)cancel:(id)sender
{
    [self batchEdit:NO];
}

- (void)autherFailed:(EmailAccount *)account
{
    _authAccount = account;
    [self performSegueWithIdentifier:@"AuthFailed" sender:self];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MailActAddController *ctl = segue.destinationViewController;
    ctl.authFailed = YES;
    ctl.authAccount = _authAccount;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == _deleteAccountAlert) {
        if (buttonIndex == 1) {
            self.navigationItem.titleView = nil;
            [_account decreate];
            _iSearchBar.hidden = YES;
            [self customTitleView:NO];
            [self refreshViewForAccount];
            [self notificationReadCount];
        }
    }
}
-(void)setUnReadMailCount{
//    MainNavigationCT *mainNavCT2 = (MainNavigationCT *)self.navigationController;
//    MainViewController *maivc = (MainViewController *)mainNavCT2.mainVC;
//    NSInteger all_unRead_count = 0;
//    for (Email *email in _emails) {
//        if ([email.isRead integerValue] == 0) {
//            all_unRead_count++;
//        }
//    }
//    maivc.tabbarButt3.remindNum=all_unRead_count;
}

@end