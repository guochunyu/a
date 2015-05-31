//
//  TaskStatusViewController.m
//  e企
//
//  Created by Capricorns on 15/3/17.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskStatusViewController.h"
#import "TaskClient.h"
#import "UIImageView+WebCache.h"
#import "MemberCell.h"
#import "UIButton+WebCache.h"
#import "UIMyTextView.h"
#import "ButtonAudioRecorder.h"
#import "FaceButton.h"
#import "AppDelegate.h"
#import "TaskDetailCell.h"
#import "NavigationVC_AddID.h"
#import "EmployeeModel.h"
#import "ActivituViewBg.h"
#import "UIViewExt.h"
#import "TaskTools.h"
#import "TouchTable.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "MBProgressHUD+Add.h"
#import "UIImage+ImageEffects.h"
#import "DatePickerView.h"
#import "SelectTaskDateButton.h"
#import "SqliteDataDao.h"
#import "QFXMPPManager.h"
#import "TaskViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "PersonInfoViewController.h"
#import "UserDetailViewController.h"

#define Count  20
#define DatePickerHeight  330

#define TaskNameTextViewTag  727598
#define TaskDescriptionTextViewTag 980507
#define InputTextViewTag    234233

@interface TaskStatusViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, ButtonAudioRecorderDelegate, FaceButtonDelegate,navigation_addIDDelegaet,UIImagePickerControllerDelegate, UINavigationControllerDelegate, TouchTableDelegate, UIAlertViewDelegate,DatePickerDelegate,SelectTaskDateButtonDelegate,RYAssetsPickerDelegate,UIActionSheetDelegate> {
    
    int keyboadHeight;
    UIView *_editTaskView;
    UITextField *_titleTextField;
    UIButton *_titleButton;
    UIImageView *sanjiao;
    
    //成员列表
    UIView *_memberView;
    UIView *_memberLine;
    
    //任务名
    UIView *_taskNameView;
    UILabel *_namePlaceHolderView;
    UIImageView *_editeImgView;
    UITextView *_nameTextView;
    UIView *_nameLine;
    
    //任务描述
    UILabel *_detailPlaceHolderView;
    UITextView *_detailTextView;
    
    CGPoint _contentOffset;
    UIButton *_rightButton;
    UIView *_optionsView; //放发送动态按钮列表的view
    BOOL _delete;
    BOOL _enAble;
    NSArray *_imgArr;
    NSArray *_imgSelectArr;
    NSArray *_titleArr;
    UIView *_toolBar; //输入框背景视图
    UIView *_inputView; //输入框
    ButtonAudioRecorder *_audioButton;
    AppDelegate *myApp;
    
    DatePickerView *datePickerView;
    SelectTaskDateButton *selectDateButton;
    
    UIView *_bottomView;
    UIMyTextView *inputTextView;
    
    UIButton *_backBtn;
    
    QFXmppManager *xmppManager;
    
    NSMutableArray *imageUrlArray;//存放所有的图片url
    
    NSString *_oldTitle;
    NSString *_oldDescription;
    NSMutableArray *_changeMemberArr;
    
    NSMutableArray *timesArray;
    long long currentSec;
    
    //重新发送动态的临时保存数组
    NSDictionary *tmpFailedStatusDict;
    
    //标记任务归档的packetid
    NSString *completePacketid;
}
@property (nonatomic, strong)TouchTable *tableView;
@property (nonatomic, strong)NSString *org_id;
@property (nonatomic, strong)NSString *uid;
@property (nonatomic, strong)NSMutableArray *memberArr;
@property (nonatomic, strong)NSMutableArray *taskDetailArr;
@property (nonatomic, assign)int count;
@property (nonatomic, strong)NSString *since_id;
@property (nonatomic, assign)__block BOOL isPull;


@property (nonatomic, strong) MBProgressHUD *HUD;

@end

static NSString *identify = @"collectionCell";

@implementation TaskStatusViewController

// Do any additional setup after loading the view.

- (BOOL)navigationShouldPopOnBackButton {
    NSArray *array = self.navigationController.viewControllers;
    if ([array count] > 3) {
        UIViewController *vc = [array objectAtIndex:[array count]-2];
        [self.navigationController popToViewController:vc animated:NO];
    }else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    xmppManager.receiveTaskPushInTaskCreate = nil;
    [_titleButton removeFromSuperview];
    [sanjiao removeFromSuperview];
    _rightButton.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationEnterBackground object:nil];
    return YES;
}

-(NSString *)getLocalTime
{
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.0f",timeInterval * 10000000];
}

- (void)isCreateAction {
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    completePacketid = nil;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(60, 0, 0.5, KScreenHeight-64)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView];
    
    self.count = Count;
    self.since_id = @"0";
    currentSec = 0;
    timesArray = [[NSMutableArray alloc] initWithCapacity:0];
    

    if (self.taskDict && [[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"task_id":[self.taskDict objectForKey:@"task_id"],@"readed":@"0",@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE orderBy:nil] count] > 0)
    {
        //更新数据库中的状态为已读
        if(![[SqliteDataDao sharedInstanse] updeteKey:@"readed" toValue:@"1" withParaDict:@{@"task_id":[self.taskDict objectForKey:@"task_id"],@"user_id":USER_ID,@"org_id":ORG_ID} andTableName:TASK_STATUS_TABLE])
        {
            DDLogInfo(@"task status readed update failed!");
        }
        else
        {
            if ([self.reloadTaskDelegate respondsToSelector:@selector(reloadTaskList)])
            {
                [self.reloadTaskDelegate reloadTaskList];
            }
        }
    }
    
    _tableView = [[TouchTable alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.touchDelegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    int numIos7=0;
    if (IS_IOS_7) {
        numIos7=64;
    }else{
        numIos7=44;
    }
    
    //添加下拉加载历史记录
    __weak TaskStatusViewController *weakSelf = self;
    [_tableView addPullToRefreshWithActionHandler:^{
        weakSelf.isPull = YES;
        if ([weakSelf.taskDetailArr count] > 0)
        {
            NSDictionary *firstStatusDict = [weakSelf.taskDetailArr firstObject];
            NSString *statusForMessage = [firstStatusDict objectForKey:@"status_id"];
            if ([statusForMessage isKindOfClass:[NSNull class]] || statusForMessage == NULL) {
                statusForMessage = @"0";
            }
            [weakSelf loadTaskDetailFromServerWithSinceId:statusForMessage count:-Count];
        }
        else if([weakSelf.taskDetailArr count] == 0)
        {
            [weakSelf loadTaskDetailFromServerWithSinceId:0 count:-Count];
        }
    } position:SVPullToRefreshPositionTop];
    
    DDLogInfo(@"home:%@",NSHomeDirectory());
    
    self.org_id = [[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    self.uid = [[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    self.memberArr = [[NSMutableArray alloc] init];
    
    self.taskDetailArr = [[NSMutableArray alloc] init];
    _taskMemberArr = [[NSMutableArray alloc] init];
    _contentOffset = CGPointMake(0, 0);
    
    _changeMemberArr = [[NSMutableArray alloc] init];
    
    _imgArr = @[@"task_icon_text_nor",
                @"task_icon_microphone_nor",
                @"task_icon_photo_nor",
                @"task_icon_camera_nor",
                @"task_icon_check_nor"];
    _imgSelectArr = @[@"task_icon_text_pre",
                      @"task_icon_microphone_pre",
                      @"task_icon_photo_pre",
                      @"task_icon_camera_pre",
                      @"task_icon_check_pre"];
    
    //导航item设置
    [self initNavigaItem];
    
    
    [self getDataFromDB];
    
    [self initBottomView];
    if (self.tableView.contentSize.height < KScreenHeight-64-160) {
        [self.view addSubview:_bottomView];
    }else {
        _bottomView.frame = CGRectMake(0, 0, KScreenWidth, 160);
        self.tableView.tableFooterView = _bottomView;
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height+160-KScreenHeight-100)];
    }
    
    //任务编辑
    [self initTopView];
    
    //输入框，录音键父视图
    [self initToolBar];
    
    //UIMenuController消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name: UITextViewTextDidChangeNotification object:_nameTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name: UITextViewTextDidChangeNotification object:_detailTextView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextChanged:) name: UITextViewTextDidChangeNotification object:inputTextView];
    
    //键盘上去下去的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHid:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVoiceToListened:) name:UpdateVoiceToListened object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callIncoming:) name:@MtcCallIncomingNotification object:nil];

}

-(void)updateVoiceToListened:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if ([[userInfo objectForKey:@"listened"] intValue] == 0)
    {
        for(int i=0;i<[self.taskDetailArr count];i++)
        {
            NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
            if ([[statusDict objectForKey:@"status_id"] longLongValue] == [[userInfo objectForKey:@"status_id"] longLongValue])
            {
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                [tmpDict setObject:@"1" forKey:@"listened"];
                [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpDict];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    __weak TaskStatusViewController *weakSelf = self;
    xmppManager = [QFXmppManager shareInstance];
    xmppManager.receiveTaskPushInTaskCreate = ^(NSDictionary *taskStatusDict){
        [weakSelf receivedNewTaskStatusPush:taskStatusDict];
        if ([weakSelf.reloadTaskDelegate respondsToSelector:@selector(reloadTaskSuccess)])
        {
            [weakSelf.reloadTaskDelegate reloadTaskSuccess];
        }
    };
    _backBtn.hidden = NO;
    _titleButton.hidden = NO;
    sanjiao.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.delegate stopPlay];
    _backBtn.hidden = YES;
    _titleButton.hidden = YES;
    sanjiao.hidden = YES;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ReceiveNewTaskPush object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UpdateVoiceToListened object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_nameTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_detailTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:inputTextView];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@MtcCallIncomingNotification object:nil];

}

- (void)endEditing {
    [self.view endEditing:YES];
}

-(void)findTimes
{
    [timesArray removeAllObjects];
    currentSec = 0.0f;
    for(int i = 0;i < [self.taskDetailArr count]; i++)
    {
        NSDictionary *taskDeict = [self.taskDetailArr objectAtIndex:i];
        if ((ABS(([[taskDeict objectForKey:@"create_time"] longLongValue]/1000 - currentSec)) >= 60*5) || i==0)
        {
            if ([[taskDeict objectForKey:@"create_time"] integerValue] == 0)
            {
                continue;
            }
            currentSec = [[taskDeict objectForKey:@"create_time"] longLongValue]/1000;
            [timesArray addObject:taskDeict];
        }
    }
}
#pragma mark - TouchTableDelegate
- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    if (_optionsView.frame.size.width == KScreenWidth-80) {
        [UIView animateWithDuration:0.25 animations:^{
            _optionsView.frame = _optionsView.frame = CGRectMake(70, 33, 0, 35);
            _optionsView.alpha = 0;
        }];
    }
    if (_toolBar.frame.origin.y != KScreenHeight-64) {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
        }];
    }
    if (datePickerView.top == KScreenHeight-DatePickerHeight) {
        [UIView animateWithDuration:0.25 animations:^{
            datePickerView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 0);
            datePickerView.hidden = YES;
        }];
    }
}

#pragma mark NotificationCenter

-(void)menuHide:(NSNotification *)notification{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:nil];
    [menu setMenuVisible:NO animated:NO];
}

-(void)keyboardShow:(NSNotification *)notification{
    if (_inputView) {
        //获取键盘的高度,随输入法的切换而改变
        NSDictionary *userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        
        keyboadHeight=keyboardRect.size.height;
        
        CGFloat duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        CGSize size =inputTextView.contentSize;
        CGRect fram=CGRectMake(10, 6, KScreenWidth-65, size.height);
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            //键盘隐藏,响应的view改变位置
            self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-keyboadHeight);
            if (size.height<=33) {
                inputTextView.frame = CGRectMake(10, 6, KScreenWidth-65, 32);
                _toolBar.frame=CGRectMake(0, KScreenHeight-64-44-keyboadHeight, KScreenWidth, 44);
                _inputView.frame = _toolBar.bounds;
            }else{
                if (size.height<=100.0) {
                    
                    _toolBar.frame=CGRectMake(0, KScreenHeight-64-11-size.height-keyboadHeight, KScreenWidth, 11+size.height);
                    _inputView.frame = _toolBar.bounds;
                    inputTextView.frame=fram;
                }else{
                    _toolBar.frame=CGRectMake(0, KScreenHeight-64-(100+11)-keyboadHeight, KScreenWidth, 100+11);
                    _inputView.frame = _toolBar.bounds;
                    inputTextView.frame=CGRectMake(10, 6, KScreenWidth-65, 100);
                }
            }
            if (keyboadHeight>240) {
                if ([self.taskDetailArr count]>0) {
                    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-keyboadHeight-64-_toolBar.frame.size.height);
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.taskDetailArr count]-1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
        }completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            if ([_taskMemberArr count] > 6)
            {
                _editTaskView.transform=CGAffineTransformMakeTranslation(0, -_memberView.bottom);
            }
        }];
    }
}
-(void)keyboardHid:(NSNotification *)notification{
    if (_inputView) {
        CGSize size = inputTextView.contentSize;
        CGRect fram=CGRectMake(10, 7, KScreenWidth-100, size.height);
        
        CGFloat duration=[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
        
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            //键盘隐藏,响应的view改变位置
            self.tableView.frame=CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
            if (size.height<100.0) {
                if (size.height<=33) {
                    _toolBar.frame=CGRectMake(0, KScreenHeight-64-44, KScreenWidth, 44);
                    _inputView.frame = _toolBar.bounds;
                    inputTextView.frame=CGRectMake(10, 6,KScreenWidth-65, 32);
                }else {
                    inputTextView.frame = fram;
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64-9-size.height, KScreenWidth, 9+size.height);
                    _inputView.frame = _toolBar.bounds;
                }
            }else{
                inputTextView.frame=CGRectMake(10, 6,KScreenWidth-65, size.height);
                _toolBar.frame=CGRectMake(0, KScreenHeight-64-(100+11), KScreenWidth, 100+11);
                _inputView.frame = _toolBar.bounds;
            }
        }completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            _editTaskView.transform=CGAffineTransformIdentity;
        }];
    }
}

-(void)textChanged:(NSNotification *)notification
{
    id object = notification.object;
    
    
    if (![object isKindOfClass:[UITextView class]])
    {
        return ;
    }
    
    UITextView *textView = (UITextView *)object;
    if (!(textView.tag == TaskNameTextViewTag || textView.tag == TaskDescriptionTextViewTag))
    {
        return ;
    }
    NSString *toBeString = textView.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    int maxLength = 0;
    NSString *errorMsg = @"";
    if (textView.tag == TaskNameTextViewTag)
    {
        maxLength = 30;
        errorMsg = @"任务名称不能超过30字";
    }
    else if(textView.tag == TaskDescriptionTextViewTag)
    {
        maxLength = 200;
        errorMsg = @"任务描述不能超过200字";
    }
    
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            {
                if (toBeString.length > maxLength) {
                    //[self showHudView: keyboardShow:NO];
                    [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:errorMsg isCue:0 delayTime:1 isKeyShow:NO];
                    textView.text = [toBeString substringToIndex:maxLength];
                }
            }
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > maxLength) {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"企业名称不能多于20个字符" isCue:0 delayTime:1 isKeyShow:NO];
            textView.text = [toBeString substringToIndex:maxLength];
        }
    }
    [self reloadView];
}

- (void)inputTextChanged:(NSNotification *)notification {
    
    id object = notification.object;
    if (![object isKindOfClass:[UITextView class]])
    {
        return ;
    }
    if (((UITextView *)object).tag != InputTextViewTag)
    {
        return ;
    }
    if(![inputTextView isKindOfClass:[UITextView class]])
    {
        return ;
    }
    CGSize size =inputTextView.contentSize;
    
    if (size.height<=33) {
        _toolBar.frame=CGRectMake(0, KScreenHeight-64-44-keyboadHeight, KScreenWidth, 44);
        _inputView.frame = _toolBar.bounds;
        inputTextView.frame=CGRectMake(10, 6,KScreenWidth-65, 32);
    }else{
        if (size.height<=100.0) {
            
            _toolBar.frame=CGRectMake(0, KScreenHeight-64-11-size.height-keyboadHeight, 320, 11+size.height);
            _inputView.frame = _toolBar.bounds;
            inputTextView.frame=CGRectMake(10, 6,KScreenWidth-65, size.height);
        }else{
            _toolBar.frame=CGRectMake(0, KScreenHeight-64-(100+11)-keyboadHeight, 320, 100+11);
            _inputView.frame = _toolBar.bounds;
            inputTextView.frame=CGRectMake(10, 6, KScreenWidth-65, 100);
        }
    }
    self.tableView.frame=CGRectMake(0, 0, 320, KScreenHeight-64-_toolBar.frame.size.height-keyboadHeight);
    if ([self.taskDetailArr count]>0) {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[self.taskDetailArr count]-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(void)deleteSelectedFile:(id)sender{
    if ([sender isMemberOfClass:[UILongPressGestureRecognizer class]]) {
        UILongPressGestureRecognizer * longGesture = (UILongPressGestureRecognizer *)sender;
        CGPoint p = [longGesture locationInView:_tableView];
        NSIndexPath * indexPath = [_tableView indexPathForRowAtPoint:p];
        UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            if ((p.y > (cell.frame.origin.y + cell.frame.size.height))) {
                return;
            }
        }
        if(longGesture.state == UIGestureRecognizerStateBegan){
            
        }
    }
}

#pragma mark - textfieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _toolBar.frame = CGRectMake(0, KScreenHeight-64-keyboadHeight, KScreenWidth, 0);
    if (_inputView) {
        [_inputView removeFromSuperview];
        _inputView = nil;
    }
    if (_audioButton) {
        [_audioButton removeFromSuperview];
        _audioButton = nil;
    }
//    _oldTitle = textField.text;
    UIImageView *editeImgView = (UIImageView *)[_editTaskView viewWithTag:img_edite_tag];
    editeImgView.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *str = [textField.text isEqualToString:@""]?@"未标题任务":textField.text;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, _titleTextField.frame.size.height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    UIImageView *editeImgView = (UIImageView *)[_editTaskView viewWithTag:img_edite_tag];
    editeImgView.frame = CGRectMake(20+size.width, 10, 22, 22);
    editeImgView.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_editTaskView.frame.origin.y == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            _editTaskView.frame = CGRectMake(0, -KScreenHeight, KScreenWidth, KScreenHeight);
            _rightButton.hidden = YES;
            [_titleTextField resignFirstResponder];
        }];
        _titleButton.selected = !_titleButton.selected;
    }
    return YES;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    //设置
    if (textView == inputTextView) {
        [self textChanged:nil];
        
        FaceButton *butt=(FaceButton *)[self.view viewWithTag:butt_face_tag];
        if (butt.selected) {
            butt.selected=!butt.selected;
        }
    }else if (textView == _nameTextView) {
        if (_inputView) {
            [_inputView removeFromSuperview];
        }
        _oldTitle = textView.text;
    }else {
        if (_inputView) {
            [_inputView removeFromSuperview];
        }
        _oldDescription = textView.text;
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if (textView == inputTextView) {
        NSString * toBeString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if (toBeString.length>900) {
            return NO;
        }
        if ([text isEqualToString:@"@"]) {
            
        }
        
        if (textView.text.length>0) {
            if ([text isEqualToString:@"\n"]) {
                [self sendMessage:inputTextView message:inputTextView.text packetId:nil];
                return NO;
            }
        }
        if ([text isEqualToString:@"\n"]) {
            return NO;
        }
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    if (textView == _nameTextView) {
        [self reloadView];
        if ([textView.text length] == 0) {
            _namePlaceHolderView.hidden = NO;
            NSString *string = _namePlaceHolderView.text;
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
            CGSize size1 = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _namePlaceHolderView.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            _editeImgView.frame = CGRectMake(size1.width+15, (_nameTextView.bottom-20)/2, 22, 22);
        }else{
            _namePlaceHolderView.hidden = YES;
            NSString *string = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
            CGSize size1 = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _namePlaceHolderView.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            if (size1.width < KScreenWidth-50) {
                if (size1.width > _nameTextView.width) {
                    _editeImgView.frame = CGRectMake(KScreenWidth-30, (_nameTextView.bottom-20)/2, 22, 22);
                }else {
                    _editeImgView.frame = CGRectMake(15+size1.width, (_nameTextView.bottom-20)/2, 22, 22);
                }
            }else {
                _editeImgView.frame = CGRectMake(KScreenWidth-30, (_nameTextView.bottom-20)/2, 22, 22);
            }
        }
    }else if(textView == _detailTextView) {
        [self reloadView];
        
        if ([textView.text length] == 0) {
            _detailPlaceHolderView.hidden = NO;
        }else {
            _detailPlaceHolderView.hidden = YES;
        }
    }
}
- (void)textViewDidChangeSelection:(UITextView *)textView{
    
    if (textView == inputTextView) {
        CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
        
        if ( overflow > 0 ) {
            
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            
            // Scroll caret to visible area
            
            CGPoint offset = textView.contentOffset;
            
            offset.y += overflow + 7; // leave 7 pixels margin
            
            // Cannot animate with setContentOffset:animated: or caret will not appear
            
            [UIView animateWithDuration:.2 animations:^{
                
                [textView setContentOffset:offset];
                
            }];
        }
    }
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.taskDetailArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCreateCell"];
    if (!cell) {
        cell = [[TaskDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"taskCreateCell" state:1];
    }
    cell.state = NO;
    
    if (indexPath.row > 0) {
        cell.state = [self tableViewHeight:indexPath];
    }
    if ([self.taskDetailArr[indexPath.row][@"feature"] intValue] == 7) {
        cell.state = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = self.taskDetailArr[indexPath.row];
    [cell setTaskDetail:dict];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDLogInfo(@"%ld+++%@",(long)indexPath.row,[self.taskDetailArr objectAtIndex:indexPath.row]);
    NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:indexPath.row];
    if (statusDict && [[statusDict objectForKey:@"successed"] isEqualToString:TaskStatusSendStatusFailed])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重新发送", nil];
        [actionSheet showInView:self.view];
        
        tmpFailedStatusDict = statusDict;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [TaskTools taskStatusHeightWithStatusDict:[self.taskDetailArr objectAtIndex:indexPath.row] andTimeHidden:[self tableViewHeight:indexPath]];
    if (indexPath.row == 0) {
        //46 = 头像 + 姓名的高度
        return (height<46?46:height)+25.00;
    }else {
        height = [self tableViewHeight:indexPath]?height:(height < 46 ? 46 : height);
        return [self tableViewHeight:indexPath]?(height):(height+25.00);
    }
}

- (BOOL)tableViewHeight:(NSIndexPath *)indexPath {
    if (indexPath.row > 0) {
        if (![[self.taskDetailArr[indexPath.row-1] objectForKey:@"from_user_id"] isEqualToString:[self.taskDetailArr[indexPath.row] objectForKey:@"from_user_id"]]) {
            return NO;
        };
    }
    NSDictionary *currentDeatil = self.taskDetailArr[indexPath.row];
    if (![timesArray containsObject:currentDeatil])
        return YES;
    else
        return NO;
}

#pragma mark - 导航栏试图设置
- (void)initNavigaItem {
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(KScreenWidth-48, 0, 44, 44);
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(changeTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_rightButton];
    
    _rightButton.hidden = YES;
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *str;
    str = (![self.taskDict[@"task_name"] isEqual:[NSNull null]] && [self.taskDict[@"task_name"] length] > 0)?self.taskDict[@"task_name"]:@"未标题任务";
    
    _titleButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [_titleButton addTarget:self action:@selector(titleAction:) forControlEvents:UIControlEventTouchUpInside];
    _titleButton.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar addSubview:_titleButton];
    
    sanjiao = [[UIImageView alloc] init];
    sanjiao.backgroundColor = [UIColor clearColor];
    [sanjiao setImage:[UIImage imageNamed:@"task_tabbar_title"]];
    [self.navigationController.navigationBar addSubview:sanjiao];
    
    [self setTitleButton:str];
}

#pragma mark - 设置导航栏title按钮
- (void)setTitleButton:(NSString *)str {
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    CGSize size = [str boundingRectWithSize:CGSizeMake(KScreenWidth-100, 40) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    [_titleButton setTitle:str forState:UIControlStateNormal];
    _titleButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (size.width > 170) {
        _titleButton.frame = CGRectMake(KScreenWidth/2-85, 0, 170, 40);
        sanjiao.frame = CGRectMake(_titleButton.right+5, _titleButton.bottom-19, 7, 7);
        
    }else {
        _titleButton.frame = CGRectMake(KScreenWidth/2-(size.width<22?22:size.width)/2, 0, size.width<22?22:size.width, 40);
        sanjiao.frame = CGRectMake(_titleButton.right+5, _titleButton.bottom-19, 7, 7);
    }
}

#pragma mark - titleButton 点击事件
- (void)titleAction:(UIButton *)button {
    
    //title设置view
    if (button.selected) {
        [UIView animateWithDuration:0.25 animations:^{
            _editTaskView.frame = CGRectMake(0, -KScreenHeight, KScreenWidth, KScreenHeight);
            _rightButton.hidden = YES;
            _editTaskView.backgroundColor = RGB(246, 246, 246, 0);
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            _editTaskView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
            _editTaskView.backgroundColor = RGB(246, 246, 246, 0.9f);
            if (![self.taskDict[@"complete_state"] intValue] == 1) {
                _rightButton.hidden = NO;
            }
        }];
        _oldTitle = [self.taskDict objectForKey:@"task_name"];
        _oldDescription = [self.taskDict objectForKey:@"description"];
    }
    [self.view bringSubviewToFront:_editTaskView];
    button.selected = !button.selected;
    [self.view endEditing:YES];
    if (_toolBar.frame.origin.y != KScreenHeight-64) {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
        }];
    }
    if (_inputView) {
        [_inputView removeFromSuperview];
        _inputView = nil;
    }
    if (_optionsView.frame.size.width != 0) {
        [UIView animateWithDuration:0.25 animations:^{
            _optionsView.frame = CGRectMake(70, 33, 0, 35);
            _optionsView.alpha = 0;
        }];
    }
}

#pragma mark - 点击编辑任务空白处
- (void)tapAction:(UITapGestureRecognizer *)tapGesture {
    [self titleAction:_titleButton];
}

- (void)sendTaskAction:(UIButton *)button {
    if (_optionsView.frame.size.width == 0) {
        [UIView animateWithDuration:0.25 animations:^{
            _optionsView.frame = CGRectMake(70, 33, KScreenWidth-80, 35);
            _optionsView.alpha = 1;
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            _optionsView.frame = CGRectMake(70, 33, 0, 35);
            _optionsView.alpha = 0;
        }];
    }
    if (_editTaskView.top != -_taskNameView.bottom) {
        [UIView animateWithDuration:0.25 animations:^{
            _editTaskView.frame = CGRectMake(0, -KScreenHeight, KScreenWidth, KScreenHeight);
            _titleButton.selected = !_titleButton.selected;
        }];
    }
    if (_toolBar.frame.origin.y != KScreenHeight-64) {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
        }];
    }
    [self.view endEditing:YES];
}


#pragma mark - 任务编辑视图
- (void)initTopView {
    
    _editTaskView = [[UIView alloc] init];
    _editTaskView.backgroundColor = RGB(246, 246, 246, 0.9);
    [self.view addSubview:_editTaskView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_editTaskView addGestureRecognizer:tapGesture];
    
    NSString *memstring = [self.taskDict objectForKey:@"task_member"];
    NSArray *tempMemberArr = [memstring componentsSeparatedByString:@","];
    
    [self loadMemberWithTaskMember:tempMemberArr];
    
    
    [self initTaskNameTextView];
     _editTaskView.frame = CGRectMake(0, -KScreenHeight, KScreenWidth, KScreenHeight);
}

- (void)loadMemberWithTaskMember:(NSArray *)taskMember {
    [_taskMemberArr removeAllObjects];
    [_taskMemberArr addObject:self.taskDict[@"creator_uid"]];
    for(int i = 0;i<[taskMember count]; i++)
    {
        NSString *memPhone = [taskMember objectAtIndex:i];
        if (![memPhone isEqualToString:self.taskDict[@"creator_uid"]] && ![memPhone isEqualToString:@""])
        {
            [_taskMemberArr addObject:memPhone];
        }
    }
    [_taskMemberArr addObject:@"add"];
    [_taskMemberArr addObject:@"delete"];
    [_memberView removeFromSuperview];
    [self initMemberView];
}

- (void)initMemberView {
    if ([_taskMemberArr count] == 3) {
        _delete = NO;
    }
    
    _memberView = [[UIView alloc] init];
    _memberView.backgroundColor = RGB(246, 246, 246, 1);
    [_editTaskView addSubview:_memberView];
    for (int i = 0; i<[_taskMemberArr count]-1; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14+43*(i%7), 13.5+(int)i/7*46, 33, 46)];
        [_memberView addSubview:view];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 33, 33);
        button.tag = i+100;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 33, 33, 13)];
        nameLabel.font = [UIFont systemFontOfSize:8];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        if (i<[_taskMemberArr count]-2) {
            EmployeeModel *memModel = [SqlAddressData queryMemberInfoWithPhone:[_taskMemberArr objectAtIndex:i]];
            if (memModel &&
                [memModel isKindOfClass:[EmployeeModel class]] &&
                memModel.avatarimgurl) {
                //通讯录里查到这个人
                [button setImageWithURL:[NSURL URLWithString:memModel.avatarimgurl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
                nameLabel.text = memModel.name;
            }else {
                //通讯录里查不到这个人
                [button setTitle:@"未知" forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:12];
                [button setBackgroundColor:RGB(149 ,203, 143, 1)];
                nameLabel.text = @"未知";
            }
        }
        button.hidden = NO;
        if (i == [_taskMemberArr count]-2) {
            [button setImage:[UIImage imageNamed:@"task_icon_plus"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addMemAction:) forControlEvents:UIControlEventTouchUpInside];
            if ([self.taskDict[@"complete_state"] intValue] == 1) {
                button.hidden = YES;
            }
            if (_enAble) {
                button.hidden = NO;
            }
        }else if (i == [_taskMemberArr count]-1) {
            [button setImage:[UIImage imageNamed:@"task_icon_substract"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteMemAction:) forControlEvents:UIControlEventTouchUpInside];
        }else {
            if (_delete)
            {
                if (i!=0)
                {
                    [button addTarget:self action:@selector(deleteMember:) forControlEvents:UIControlEventTouchUpInside];
                }
                
            }
            else
            {
                [button addTarget:self action:@selector(toPersonDetail:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        if ([_taskMemberArr count]<4) {
            if (i == [_taskMemberArr count]-1) {
                button.hidden = YES;
            }
        }
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 16.5;
        [view addSubview:button];
        [view addSubview:nameLabel];
        
        UIImageView *staImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, -2, 15, 15)];
        if (i == 0) {
            [staImgView setImage:[UIImage imageNamed:@"task_icon_user_admin"]];
            staImgView.hidden = NO;
            if (_delete)
            {
                button.enabled = NO;
            }
        }else if (i>0 && i<[_taskMemberArr count]-2) {
            [staImgView setImage:[UIImage imageNamed:@"task_icon_user_delete"]];
            if (_delete) {
                staImgView.hidden = NO;
            }else {
                staImgView.hidden = YES;
            }
            button.selected = _delete;
        }
        [view addSubview:staImgView];
    }
    _memberView.frame = CGRectMake(0, 0, KScreenWidth, 13.5+(([_taskMemberArr count]-2)/7+1)*46);
    
    _memberLine = [[UIView alloc] initWithFrame:CGRectMake(10, _memberView.height - 0.3, KScreenWidth-20, 0.3)];
    _memberLine.backgroundColor = [UIColor lightGrayColor];
    [_memberView addSubview:_memberLine];
    
}

- (void)initTaskNameTextView {
    _taskNameView = [[UIView alloc] init];
    _taskNameView.backgroundColor = RGB(246, 246, 246, 1);
    [_editTaskView addSubview:_taskNameView];
    
    _namePlaceHolderView = [[UILabel alloc] init];
    _namePlaceHolderView.text = @"未标题任务";
    _namePlaceHolderView.font = [UIFont systemFontOfSize:15];
    [_namePlaceHolderView sizeToFit];
    CGSize size = _namePlaceHolderView.frame.size;
    
    NSString *taskName = _taskDict[@"task_name"];
    if ((id)taskName == [NSNull null]) {
        taskName = @"";
    }
    _namePlaceHolderView.hidden = [taskName isEqualToString:@""]?NO:YES;
    _namePlaceHolderView.frame = CGRectMake(13, 10, size.width, size.height);
    _namePlaceHolderView.textColor = [UIColor lightGrayColor];
    [_taskNameView addSubview:_namePlaceHolderView];
    
    _nameTextView = [[UITextView alloc] init];
    _nameTextView.font = [UIFont systemFontOfSize:16];
    _nameTextView.backgroundColor = [UIColor clearColor];
    _nameTextView.text = taskName;
    _nameTextView.tag = TaskNameTextViewTag;
    _nameTextView.frame = CGRectMake(10, 2, KScreenWidth-34, 0);
    _nameTextView.scrollEnabled = NO;
    _nameTextView.delegate = self;
    [_nameTextView sizeToFit];
    [_taskNameView addSubview:_nameTextView];
    
    _nameTextView.frame = CGRectMake(10, 2, KScreenWidth-34,_nameTextView.frame.size.height);
    
    _editeImgView = [[UIImageView alloc] init];
    
    NSString *nameString = [taskName length] > 0 ?taskName:@"未标题任务";
    CGSize eSize = [TaskTools sizeWithString:nameString andWidth:KScreenWidth-34 andFoneSize:16];
    _editeImgView.frame = CGRectMake(eSize.width+15, (_nameTextView.bottom-20)/2, 22, 22);
    _editeImgView.image = [UIImage imageNamed:@"task_icon_edit"];
    [_taskNameView addSubview:_editeImgView];
    
    _detailTextView = [[UITextView alloc] init];
    _detailTextView.scrollEnabled = NO;
    _detailTextView.tag = TaskDescriptionTextViewTag;
    _detailTextView.backgroundColor = RGB(246, 246, 246, 1);
    _detailTextView.font = [UIFont systemFontOfSize:12];
    
    NSString *description = self.taskDict[@"description"];
    if ((id)description == [NSNull null]) {
        description = @"";
    }
    _detailTextView.text = description;
    _detailTextView.backgroundColor = [UIColor clearColor];
    _detailTextView.textColor = [UIColor lightGrayColor];
    _detailTextView.delegate = self;
    [_taskNameView addSubview:_detailTextView];
    NSString *detailStr = [description isEqualToString:@""]?@"点击输入任务描述...":description;
    NSDictionary *dAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize dtSize = [detailStr boundingRectWithSize:CGSizeMake(KScreenWidth-14, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:dAttribute context:nil].size;
    
    _detailTextView.frame = CGRectMake(10, _nameTextView.bottom-5, KScreenWidth-20, dtSize.height+20);
    
    _detailPlaceHolderView = [[UILabel alloc] init];
    _detailPlaceHolderView.text = @"点击输入任务描述...";
    _detailPlaceHolderView.font = [UIFont systemFontOfSize:12];
    [_detailPlaceHolderView sizeToFit];
    _detailPlaceHolderView.hidden = [description isEqualToString:@""]?NO:YES;
    CGSize dSize = _detailPlaceHolderView.frame.size;
    _detailPlaceHolderView.frame = CGRectMake(13, _detailTextView.top+7, dSize.width, dSize.height);
    _detailPlaceHolderView.textColor = [UIColor lightGrayColor];
    [_taskNameView addSubview:_detailPlaceHolderView];
    
    
    
    _taskNameView.frame = CGRectMake(0, _memberView.bottom, KScreenWidth, _detailTextView.bottom);
    
    _nameLine = [[UIView alloc] initWithFrame:CGRectMake(0, _taskNameView.height-0.3, KScreenWidth, 0.3)];
    _nameLine.backgroundColor = [UIColor lightGrayColor];
    //    [_taskNameView addSubview:_nameLine];
}



- (void)initBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight-160-64, KScreenWidth, 160)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(45, 35, 30, 30);
    button.tag = butt_add_tag;
    [button setImage:[UIImage imageNamed:@"task_content_icon_add"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendTaskAction:) forControlEvents:UIControlEventTouchUpInside];
    if ([self.taskDict[@"complete_state"] intValue] == 1) {
        button.hidden = YES;
    }
    [_bottomView addSubview:button];
    
    DDLogInfo(@"%f",KScreenWidth);
    _optionsView = [[UIView alloc] initWithFrame:CGRectMake(70, 33, 0, 35)];
    _optionsView.alpha = 0;
    [_bottomView addSubview:_optionsView];
    
    BOOL isCreator = [USER_ID isEqualToString:[self.taskDict objectForKey:@"creator_uid"]];
    for (int i=0; i < (isCreator?5:4); i++) {
        
        UIButton *imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        imgButton.frame = CGRectMake(10+45*i, 0, 35, 35);
        [imgButton setImage:[UIImage imageNamed:_imgArr[i]] forState:UIControlStateNormal];
        [imgButton setImage:[UIImage imageNamed:_imgSelectArr[i]] forState:UIControlStateHighlighted];
        imgButton.tag = 500+i;
        [imgButton addTarget:self action:@selector(typeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_optionsView addSubview:imgButton];
        
    }
    
    selectDateButton = [[SelectTaskDateButton alloc] initWithFrame:CGRectMake(56, 102, 200, 18)];
    selectDateButton.selectTaskDateButtonDelegate = self;
    [_bottomView addSubview:selectDateButton];
    
    [selectDateButton setComplete_state:[self.taskDict objectForKey:@"complete_state"] andComplete_time:[self.taskDict objectForKey:@"dead_line"]];
}

- (void)initToolBar {
    _toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight-64, KScreenWidth, 44)];
    _toolBar.backgroundColor = [UIColor whiteColor];
    _toolBar.layer.borderWidth = 0.5;
    _toolBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:_toolBar];
}



#pragma mark - 到个人详情

-(void)toPersonDetail:(UIButton *)button
{
    NSString *phoneNum = [_taskMemberArr objectAtIndex:button.tag-100];
    
    if([phoneNum isEqualToString:USER_ID])
    {
        PersonInfoViewController *pVC = [[PersonInfoViewController alloc] initWithNibName:@"PersonInfoViewController" bundle:nil];
        pVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pVC animated:YES];
        return;
    }
    EmployeeModel *eml = [SqlAddressData queryMemberInfoWithPhone:phoneNum];
    if (!eml)
    {
        return ;
    }
    UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] init];
    userDetailVC.userInfo = eml;
    userDetailVC.organizationName = eml.comman_orgName;
    userDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userDetailVC animated:YES];
}

- (void)reloadView {

    if (_memberView) {
        [_memberView removeFromSuperview];
    }
    
    [self initMemberView];
    [self updateTaskNameAndDescriptionView];
}

-(void)updateTaskNameAndDescriptionView
{
    NSDictionary *nAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    NSString *nameStr = [_nameTextView.text isEqualToString:@""]?@"未标题任务":_nameTextView.text;
    CGSize nSize = [nameStr boundingRectWithSize:CGSizeMake(KScreenWidth-50, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:nAttribute context:nil].size;
    _nameTextView.frame = CGRectMake(10, 2, KScreenWidth-40,nSize.height+17);
    
    NSString *detailStr = [_detailTextView.text isEqualToString:@""]?@"点击输入任务描述...":_detailTextView.text;
    NSDictionary *dAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize dtSize = [detailStr boundingRectWithSize:CGSizeMake(KScreenWidth-30, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dAttribute context:nil].size;
    _detailTextView.frame = CGRectMake(10, _nameTextView.bottom-5, KScreenWidth-20, dtSize.height+20);
    _taskNameView.frame = CGRectMake(0, _memberView.bottom, KScreenWidth, _detailTextView.bottom);
    _nameLine.frame = CGRectMake(0, _taskNameView.bottom-0.3, KScreenWidth, 0.3);
    
    CGSize dSize = _detailPlaceHolderView.frame.size;
    _detailPlaceHolderView.frame = CGRectMake(13, _detailTextView.top+7, dSize.width, dSize.height);
}

#pragma mark - 任务动态data

-(void)getDataFromDB
{
    NSArray *array = [[SqliteDataDao sharedInstanse]  findStatusArrayWithoutTipsWihtTaskId:[self.taskDict objectForKey:@"task_id"] from:0 count:Count];
    if ([array count] > 0)
    {
        for (int i = 0; i < [array count]; i++)
        {
            NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:[array objectAtIndex:i]];
            if ([[tmpStatusDict objectForKey:@"successed"] isEqualToString:TaskStatusSendStatusSending])
            {
                if(![[SqliteDataDao sharedInstanse] updeteKey:@"successed" toValue:TaskStatusSendStatusFailed withParaDict:@{@"status_id":[tmpStatusDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE])
                {
                    DDLogError(@"update successed from sending to failed failed!");
                }
                [tmpStatusDict setObject:TaskStatusSendStatusFailed forKey:@"successed"];
                //            [self reSendStatus:statusDict];
            }
            [self.taskDetailArr insertObject:tmpStatusDict atIndex:0];
        }
    }
    [self reloadStatusListView:NO];
    
    [self initTaskDetailData];
}

- (void)initTaskDetailData {
    NSDictionary *lastStatusDict = [[[SqliteDataDao sharedInstanse] findStatusArrayWithoutTipsWihtTaskId:[self.taskDict objectForKey:@"task_id"] success:TaskStatusSendStatusSuccessed] firstObject];
    if (lastStatusDict)
    {
        //since_id != 0 && count == 0 获取本地最大status_id后的所有数据
        [self loadTaskDetailFromServerWithSinceId:[lastStatusDict objectForKey:@"status_id"] count:0];
    }
    else
    {
        [self loadTaskDetailFromServerWithSinceId:self.since_id count:-Count];
    }
}

- (void)loadTaskDetailFromServerWithSinceId:(NSString *)sinceId
                                      count:(int)count
{
    TaskClient *client = [TaskClient shareClient];
    
    [client getTimelineWithOrg_id:self.org_id Task_id:self.taskDict[@"task_id"]  withCount:count withSince_id:sinceId success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        
        if ([[responseDict objectForKey:@"result"] intValue] == -1)
        {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[responseDict objectForKey:@"error_msg"] isCue:1 delayTime:1 isKeyShow:NO];
            return ;
        }
        
        NSArray *statusArray = [[responseDict objectForKey:@"task"] objectForKey:@"status"];
        if([statusArray count] == 0)
        {
            if (count < 0)
            {
                [_tableView.pullToRefreshView stopAnimating];
            }
            return ;
        }
        if (count > 1)
        {
            [[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"user_id":self.uid,
                                                                   @"task_id":[self.taskDict objectForKey:@"task_id"],
                                                                   @"successed":TaskStatusSendStatusSuccessed} andTableName:TASK_STATUS_TABLE];
        }
        
        if([statusArray count] > 0 &&
           [sinceId integerValue] != 0 &&
           count == 0)
        {
            //用本地status_id count = 0 获取服务器比 status_id  大的所有数据，并且获取到了
        }
        else if([statusArray count] > 0 &&
                [sinceId integerValue] != 0 &&
                count == 0)
        {
            //用本地status_id count = 0 获取服务器比 status_id  大的所有数据，并且没获取到数据
            return ;
        }
        else if ([statusArray count] == 0 &&
                 [sinceId integerValue] != 0 &&
                 count < 0)
        {
            //下拉加载更多没有请求到数据
            //[self showHudView:@"这已经是全部动态了!" keyboardShow:NO];
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"这已经是全部动态了!" isCue:0 delayTime:1 isKeyShow:NO];
            [_tableView.pullToRefreshView stopAnimating];
            return ;
        }
        else if([statusArray count] > 0 &&
                [sinceId integerValue] !=0 &&
                count < 0)
        {
            //下拉加载更多请求到数据
            [_tableView.pullToRefreshView stopAnimating];
        }
        else if([statusArray count] == 0 &&
                [sinceId integerValue] == 0 &&
                count < 0)
        {
            //本地没有数据，下拉加载更多没有请求到数据
            //            [MBProgressHUD showError:@"还没有人发不过动态哦！" toView:self.view];
            [_tableView.pullToRefreshView stopAnimating];
            return ;
        }
        else if([statusArray count] > 0 &&
                [sinceId integerValue] == 0 &&
                count < 0)
        {
            //本地没有数据，下拉加载更多请求到数据  或者本地没有数据第一次进入详情请求道数据
            [_tableView.pullToRefreshView stopAnimating];
        }
        
        if (count < 0 && [sinceId intValue]!=0)
        {
            //如果count < 0,倒序遍历添加到数组第0个位置
            for(int i=[statusArray count] -1;i>=0;i--)
            {
                NSDictionary *statusDict = [statusArray objectAtIndex:i];
                NSDictionary *tmpDict = [self dealWithTaskStatus:statusDict];
                [self.taskDetailArr insertObject:tmpDict atIndex:0];
            }
            [_tableView.pullToRefreshView stopAnimating];
            [self reloadStatusListView:YES];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else
        {
            //如果count >= 0,正序add 到数组末尾位置
            for(int i = 0 ; i < [statusArray count] ; i++)
            {
                NSDictionary *statusDict = [statusArray objectAtIndex:i];
                NSDictionary *tmpDict = [self dealWithTaskStatus:statusDict];
                [self.taskDetailArr addObject:tmpDict];
            }
            [self reloadStatusListView:NO];
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.taskDetailArr count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogInfo(@"taskDetailError:%@",error);
    }];
}

-(NSDictionary *)dealWithTaskStatus:(NSDictionary *)statusDict
{
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:[TaskTools dealWithTaskStatusDict:statusDict sourceType:TaskStatusSourceTypeServer]];
    
    [tmpDict setObject:[self.taskDict objectForKey:@"task_id"] forKey:@"task_id"];
    
    [tmpDict setObject:[self.taskDict objectForKey:@"task_name"] forKey:@"task_name"];
    if([tmpDict objectForKey:@"packetid"])
    {
        //如果出现服务器出入成功，但是本地没有成功的情况，从服务器请求道这条数据后删除数据库和缓存数组里的相同packetid 的多余数据
        if (![[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"packetid":[tmpDict objectForKey:@"packetid"]} andTableName:TASK_STATUS_TABLE])
        {
            DDLogError(@"delete send failed status failed");
        }
        for (int j=0; j<[self.taskDetailArr count]; j++)
        {
            NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:j];
            if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] && [[statusDict objectForKey:@"packetid"] longLongValue]== [[tmpDict objectForKey:@"packetid"] longLongValue])
            {
                if([[tmpDict objectForKey:@"feature"] intValue] ==  TaskStatusTypeAudio)
                {
                    NSString *listened = [statusDict objectForKey:@"listened"];
                    if (listened!=nil && ![listened isKindOfClass:[NSNull class]]) {
                        [tmpDict setObject:[statusDict objectForKey:@"listened"] forKey:@"listened"];
                    }
                    
                }
                [self.taskDetailArr removeObjectAtIndex:j];
            }
        }
    }
    
    if ([[SqliteDataDao sharedInstanse]  findSetWithDictionary:@{@"status_id":[tmpDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE orderBy:nil] == 0)
    {
        if (![[SqliteDataDao sharedInstanse]  insertStatusRecord:tmpDict andTableName:TASK_STATUS_TABLE])
        {
            DDLogInfo(@"insert status fail");
        }
    }
    else
    {
        if ([[SqliteDataDao sharedInstanse]  deleteRecordWithDict:@{@"status_id":[tmpDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE])
        {
            if (![[SqliteDataDao sharedInstanse]  insertStatusRecord:tmpDict andTableName:TASK_STATUS_TABLE])
            {
                DDLogInfo(@"insert status fail");
            }
        }
    }
    return tmpDict;
}

-(void)reloadStatusListView:(BOOL)top
{
    [self findTimes];
    [self.tableView reloadData];
    
    if (self.tableView.contentSize.height < KScreenHeight-64-160)
    {
        self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-160);
        [self.view insertSubview:_bottomView belowSubview:_editTaskView];
    }
    else
    {
        _bottomView.frame = CGRectMake(0, 0, KScreenWidth, 160);
        self.tableView.tableFooterView = _bottomView;
        if (!top)
        {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height+160-KScreenHeight-100)];
        }
        self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
    }

    NSDictionary *lastDict = [self.taskDetailArr lastObject];
    if (lastDict && ![[SqliteDataDao sharedInstanse] updeteKey:@"update_time" toValue:[NSString stringWithFormat:@"%lld",[[lastDict objectForKey:@"create_time"] longLongValue]] withParaDict:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"task_id":[lastDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
    {
        DDLogCError(@"update task's updatetime failed!");
    }
    if ([self.reloadTaskDelegate respondsToSelector:@selector(reloadTaskList)])
    {
        [self.reloadTaskDelegate reloadTaskList];
    }
}

#pragma mark - 失败动态重发
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //重新发送
        
        if (tmpFailedStatusDict)
        {
            //更新缓存数组
            [self reSendStatus:tmpFailedStatusDict];
        }
    }
}

-(void)reSendStatus:(NSDictionary *)statusDict
{
    if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeContent)
    {
        [self sendMessage:nil message:[statusDict objectForKey:@"content"] packetId:[statusDict objectForKey:@"packetid"]];
    }
    else if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeImage)
    {
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[statusDict objectForKey:@"packetid"]];
        [self uploadImage:imageName imagePath:[statusDict objectForKey:@"local_file_url"] uuid:imageName packetid:[statusDict objectForKey:@"packetid"]];
    }
    else if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAudio)
    {
        [self uploadVoice:[statusDict objectForKey:@"audio_name"] path:[statusDict objectForKey:@"local_file_url"] lenth:[statusDict objectForKey:@"audio_duration"] avtivtyView:nil packetId:[statusDict objectForKey:@"packetid"]];
    }
    else if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeComplete)
    {
        completePacketid = [statusDict objectForKey:@"packetid"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"标记归档后，成员将无法编辑任务，是否确认标记？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

#pragma mark - 添加任务成员

//加号按钮action
- (void)addMemAction:(UIButton *)button {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    nav_add.addScrollType = AddScrollTypeTask;
    nav_add.delegate_addID = self;
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<_taskMemberArr.count-2; i++)
    {
        [tempArr addObject:_taskMemberArr[i]];
    }
    if (_delete) {
        _delete = !_delete;
    }
    nav_add.phoneArray = tempArr;
    [self.navigationController presentViewController:nav_add animated:YES completion:^{
    }];
}

#pragma mark - 多选通讯录

- (void)GetTaskArray:(NSArray *)memberArray {
    if ([memberArray count]>0) {
        
        //        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:_taskMemberArr.count-2];
        for (EmployeeModel *md in memberArray) {
            
            [_taskMemberArr insertObject:md.phone atIndex:_taskMemberArr.count-2];
        }
        
        [_changeMemberArr addObjectsFromArray:memberArray];
        if ([_taskMemberArr count]>22) {
            int count1 = [_changeMemberArr count];
            if (count1 <= ([_taskMemberArr count]-22)+2) {
                for (EmployeeModel *md in memberArray) {
                    [_changeMemberArr removeObject:md];
                }
            }else{
                for (int i =count1-([_taskMemberArr count]-22)-2; i<count1; i++) {
                    [_changeMemberArr removeObjectAtIndex:[_changeMemberArr count]-1];
                }
            }
        }
        if ([_taskMemberArr count]>22) {
            //[self showHudView:@"任务成员上限人数为20人" keyboardShow:NO];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务成员上限人数为20人" isCue:0 delayTime:1 isKeyShow:NO];
            int count2 = [_taskMemberArr count];
            for (int i=21; i<count2-1; i++) {
                [_taskMemberArr removeObjectAtIndex:21];
            }
        }
        [self reloadView];
    }
}

//减号按钮action
- (void)deleteMemAction:(UIButton *)button {
    _delete = !_delete;
    [self reloadView];
}

#pragma mark - 提交修改任务信息

- (void)changeTask:(UIButton *)button {
    [self.view endEditing:YES];
    if ([[self.taskDict objectForKey:@"task_name"] isEqualToString:_nameTextView.text] && [[self.taskDict objectForKey:@"description"] isEqualToString:_detailTextView.text] && [_changeMemberArr count] == 0)
    {
        [self showViewWithCustomView:nil WithText:@"没有任何变化额!" withCue:1];
        return;
    }else {
        TaskClient *client = [TaskClient shareClient];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        if (![_oldTitle isEqualToString:_nameTextView.text]) {
            parameters[@"task_name"] = _nameTextView.text;
        }
        if (![_oldDescription isEqualToString:_detailTextView.text]) {
            parameters[@"description"] = _detailTextView.text;
        }
        if ([_changeMemberArr count] > 0) {
            NSMutableArray *phoneArr = [NSMutableArray array];
            for (EmployeeModel *em in _changeMemberArr) {
                [phoneArr addObject:em.phone];
            }
            parameters[@"task_member"] = phoneArr;
        }
        NSString *update_param = [parameters JSONString];
        [client postUpdateWithOrg_id:self.org_id withUid:self.uid withTask_id:self.taskDict[@"task_id"] withUpdate_param:update_param success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
            if ([[responseDict objectForKey:@"result"]intValue] == 0)
            {
                [self titleAction:_titleButton];
            }else {
                [self showViewWithCustomView:nil WithText:responseDict[@"error_msg"]  withCue:1];
                return ;
            }
            [self.reloadTaskDelegate reloadTaskSuccess];
            NSMutableDictionary *tmpTaskDict = [[NSMutableDictionary alloc] initWithDictionary:self.taskDict];
            if (![[self.taskDict objectForKey:@"task_name"] isEqualToString:_nameTextView.text]) {
                NSString *string = [_nameTextView.text isEqualToString:@""]?@"未标题任务":_nameTextView.text;
                [self setTitleButton:string];
                [tmpTaskDict setObject:_nameTextView.text forKey:@"task_name"];
            }
            
            if (parameters[@"task_name"] && parameters[@"task_member"])
            {
                [self updateDatabaseWithFeature:TaskStatusTypeUpdateNameAndMember];
            }
            else if (parameters[@"task_name"])
            {
                [self updateDatabaseWithFeature:TaskStatusTypeUpdateName];
            }
            else if(parameters[@"task_member"])
            {
                [self updateDatabaseWithFeature:TaskStatusTypeUpdateMember];
            }
            if (parameters[@"description"])
            {
                [self updateDatabaseWithFeature:TaskStatusTypeUpdateDescription];
                
                [tmpTaskDict setObject:_detailTextView.text forKey:@"description"];
            }
            self.taskDict = tmpTaskDict;
            [self showViewWithCustomView:nil WithText:@"修改成功" withCue:0];
            [_changeMemberArr removeAllObjects];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DDLogError(@"%@",error);
        }];
    }
    
    
    
}

#pragma mark - 删除成员
- (void)deleteMember:(UIButton *)button {
    [self.taskMemberArr removeObjectAtIndex:button.tag-100];
    [self reloadView];
}

#pragma mark - 设置时间
- (void)setTimeAction
{
    [UIView animateWithDuration:0.2 animations:^{
        if (!datePickerView) {
            datePickerView = [[DatePickerView alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 0)];
            datePickerView.datePickerDelegate = self;
            if (![self.taskDict[@"dead_line"] intValue] == 0) {
                long long int dateTime = 0;
                if ([self.taskDict[@"dead_line"] length] > 10)
                {
                    dateTime =[self.taskDict[@"dead_line"] longLongValue]/1000;
                }
                else
                {
                    dateTime = [self.taskDict[@"dead_line"] longLongValue];
                }
                NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
                datePickerView.datePicker.date = time;
            }
            datePickerView.hidden = YES;
            [self.view addSubview:datePickerView];
        }
        
        
        datePickerView.frame = CGRectMake(0, KScreenHeight-DatePickerHeight, KScreenWidth, DatePickerHeight);
        [self.view bringSubviewToFront:datePickerView];
    } completion:^(BOOL finished) {
        datePickerView.hidden = NO;
    }];
}

-(void)dateDone:(NSString *)selectDate
{
    DDLogInfo(@"complete time %@",selectDateButton.complete_time);
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:self.taskDict];
    [tempDict setObject:selectDate forKey:@"dead_line"];
    self.taskDict = [NSDictionary dictionaryWithDictionary:tempDict];
    tempDict = nil;
    
    TaskClient *client = [TaskClient shareClient];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"dead_line"] = selectDate;
    
    NSString *update_param = [parameters JSONString];
    [client postUpdateWithOrg_id:self.org_id withUid:self.uid withTask_id:self.taskDict[@"task_id"] withUpdate_param:update_param success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        if ([[responseDict objectForKey:@"result"]intValue] == 0)
        {
            [self showViewWithCustomView:nil WithText:@"时间修改成功" withCue:0];
            [selectDateButton setComplete_state:[self.taskDict objectForKey:@"complete_state"] andComplete_time:selectDate];
            
            [self updateDatabaseWithFeature:TaskStatusTypeUpdateDeadLine];
            if ([[SqliteDataDao sharedInstanse] updeteKey:@"dead_line" toValue:selectDate withParaDict:@{@"task_id":[self.taskDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
            {
                if([self.reloadTaskDelegate respondsToSelector:@selector(reloadTaskList)])
                {
                    [self.reloadTaskDelegate reloadTaskList];
                }
            }
        }
        else
        {
            [self showViewWithCustomView:nil WithText:responseDict[@"error_msg"] withCue:1];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self showViewWithCustomView:nil WithText:@"修改失败，请重试！" withCue:0];
    }];
    [self dateCancel];
}

-(void)dateCancel
{
    [UIView animateWithDuration:0.2 animations:^{
        datePickerView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 0);
    } completion:^(BOOL finished) {
        datePickerView.hidden = YES;
        
        [datePickerView removeFromSuperview];
        datePickerView = nil;
    }];
}

#pragma mark - 底部按钮列表

- (void)typeAction:(UIButton *)button {
    NSInteger tag = button.tag-500;
    if (_optionsView.frame.size.width == KScreenWidth-80) {
        [UIView animateWithDuration:0.25 animations:^{
            _optionsView.frame = _optionsView.frame = CGRectMake(70, 33, 0, 35);
            _optionsView.alpha = 0;
        }];
    }
    switch (tag) {
        case 0:
        {
            if (_toolBar.frame.origin.y == KScreenHeight-44-64 && _audioButton) {
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64-44, KScreenWidth, 44);
                }];
            }else if (_toolBar.frame.origin.y == KScreenHeight-64){
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64-44, KScreenWidth, 44);
                }];
            }else {
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
                }];
            }
            [_audioButton removeFromSuperview];
            _audioButton = nil;
            [_inputView removeFromSuperview];
            _inputView = nil;
            
            _inputView = [[UIView alloc] initWithFrame:_toolBar.bounds];
            [_toolBar addSubview:_inputView];
            inputTextView = [[UIMyTextView alloc] initWithFrame:CGRectMake(10, 6, KScreenWidth-65, 32)];
            inputTextView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1];
            inputTextView.layer.cornerRadius = 4;
            inputTextView.tag = InputTextViewTag;
            inputTextView.returnKeyType = UIReturnKeySend;
            inputTextView.font = [UIFont systemFontOfSize:14];
            inputTextView.delegate = self;
           
            [_inputView addSubview:inputTextView];
            
            FaceButton *biaoqingBtn = [FaceButton buttonWithType:UIButtonTypeCustom];
            biaoqingBtn.frame = CGRectMake(KScreenWidth-82, 7, 30, 30);
            biaoqingBtn.delegate = self;
            biaoqingBtn.hidden = YES;
            biaoqingBtn.tag = butt_face_tag;
            [biaoqingBtn addTarget:self action:@selector(biaoqingAction:) forControlEvents:UIControlEventTouchUpInside];
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chat_smile"] forState:UIControlStateNormal];
            [biaoqingBtn setBackgroundImage:[UIImage imageNamed:@"chat_keybord"] forState:UIControlStateSelected];
            [_inputView addSubview:biaoqingBtn];
            __block typeof(self) mySelf = self;
            biaoqingBtn.faceClick = ^(id sender) {
                [mySelf textChanged:nil];
                [mySelf textViewDidChange:inputTextView];
            };
            
            UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
            sendButton.frame = CGRectMake(KScreenWidth-45, 6, 40, 32);
            [sendButton setTitle:@"发送" forState:UIControlStateNormal];
            sendButton.backgroundColor = [UIColor colorWithRed:52.0/255.0 green:109.0/255.0 blue:241.0/255.0 alpha:1];
            sendButton.layer.cornerRadius = 3;
            sendButton.titleLabel.textColor = [UIColor whiteColor];
            sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [sendButton addTarget:self action:@selector(sendMsg:) forControlEvents:UIControlEventTouchUpInside];
            [_inputView addSubview:sendButton];
            
            [self.view bringSubviewToFront:_toolBar];
            
            break;
        }
        case 1:
        {
            if (_toolBar.frame.origin.y == KScreenHeight-44-64 && _inputView) {
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64-44, KScreenWidth, 44);
                }];
            }else if (_toolBar.frame.origin.y == KScreenHeight-64){
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64-44, KScreenWidth, 44);
                }];
            }else {
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
                }];
            }
            
            [_audioButton removeFromSuperview];
            _audioButton = nil;
            [_inputView removeFromSuperview];
            _inputView = nil;
            
            _audioButton = [ButtonAudioRecorder buttonWithType:UIButtonTypeCustom];
            _audioButton.recorderDuration = 60;
            [_audioButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            _audioButton.frame = CGRectMake(10, 6, KScreenWidth-20, 32);
            [_audioButton setTitle:@"按住说话" forState:UIControlStateNormal];
            _audioButton.titleLabel.font = [UIFont systemFontOfSize:14];
            [_audioButton setChangeTitle:@"松开发送"];
            [_audioButton setUpChangeTitle:@"松开取消"];
            _audioButton.delegate = self;
            [_audioButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_audioButton setBackgroundImage:[UIImage imageNamed:@"task_btn_toolbar_talk_nor"] forState:UIControlStateNormal];
            [_audioButton setChangeBackgroundImage:[UIImage imageNamed:@"task_btn_toolbar_talk_pre"]];
            [_toolBar addSubview:_audioButton];
            
            [self.view bringSubviewToFront:_toolBar];
            
            break;
        }
        case 2:
        {
            if (_toolBar.top == KScreenHeight-44-64) {
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
                }];
            }
//            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//                picker.delegate = self;
//                picker.allowsEditing = YES;
//                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//                [self presentViewController:picker animated:YES completion:nil];
//            }
            RYAssetsPickerController * rpc ;
            rpc = [[RYAssetsPickerController alloc]initPhotosPicker];
            rpc.delegate = self;
            rpc.maxSelectCount = 1;
            [self presentViewController:rpc animated:YES completion:nil];
            break;
        }
        case 3:
        {
            if (_toolBar.top == KScreenHeight-44-64) {
                [UIView animateWithDuration:0.25 animations:^{
                    _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
                }];
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = YES;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"照相机不可用" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
                [alertView show];
            }
            break;
        }
        case 4:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"标记归档后，成员将无法编辑任务，是否确认标记？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        default:
            break;
    }
    
}

#pragma mark - 向数据库里插入任务更新动态
-(void)updateDatabaseWithFeature:(int)feature
{
    long long create_time = [[self getLocalTime] longLongValue];;
    NSDictionary *latestStatusDict = [[SqliteDataDao sharedInstanse] findLatestStatusWithTaskId:[self.taskDict objectForKey:@"task_id"]];;
    if (latestStatusDict)
    {
        create_time = [[latestStatusDict objectForKey:@"create_time"] longLongValue]+1;
    }
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
    [tmpDict setObject:USER_ID forKey:@"user_id"];
    [tmpDict setObject:[NSString stringWithFormat:@"%lld",create_time] forKey:@"create_time"];
    [tmpDict setObject:[self.taskDict objectForKey:@"task_id"] forKey:@"task_id"];
    [tmpDict setObject:[NSString stringWithFormat:@"%d",feature] forKey:@"feature"];
    [tmpDict setObject:@"1" forKey:@"readed"];
    [tmpDict setObject:@"1" forKey:@"successed"];
    [tmpDict setObject:ORG_ID forKey:@"org_id"];
    [tmpDict setObject:USER_ID forKey:@"from_user_id"];
    
    NSString *name = @"您";
    if (feature == TaskStatusTypeUpdateDeadLine)
    {
        [tmpDict setObject:[NSString stringWithFormat:@"%@修改了任务截止时间",name] forKey:@"content"];
    }
    else if(feature == TaskStatusTypeUpdateDescription)
    {
        [tmpDict setObject:[NSString stringWithFormat:@"%@修改了任务描述",name] forKey:@"content"];
    }
    else if(feature == TaskStatusTypeUpdateName)
    {
        [tmpDict setObject:[NSString stringWithFormat:@"%@修改了任务名称",name] forKey:@"content"];
    }
    else if(feature == TaskStatusTypeUpdateMember)
    {
        [tmpDict setObject:[NSString stringWithFormat:@"%@添加了任务成员",name] forKey:@"content"];
    }
    else if(feature == TaskStatusTypeUpdateNameAndMember)
    {
        [tmpDict setObject:[NSString stringWithFormat:@"%@修改了任务名称并且添加了成员",name] forKey:@"content"];
    }
    if (![[SqliteDataDao sharedInstanse] insertStatusRecord:tmpDict andTableName:TASK_STATUS_TABLE])
    {
        DDLogError(@"insert record of self update failed!");
    }
}

#pragma mark - 向数据库中插入单条动态数据

-(void)insertTmpDictToDB:(NSDictionary *)tmpDict
{
    if (![[SqliteDataDao sharedInstanse] insertStatusRecord:tmpDict andTableName:TASK_STATUS_TABLE])
    {
        DDLogError(@"insert tmpdict failed!");
    }
}


#pragma mark - 处理发送动态结果
-(void)sendStatusSuccessWithResultDict:(NSDictionary *)resultDict
                                 andId:(NSString *)packetid
                            andFeature:(NSString *)feature
{
    if([[resultDict objectForKey:@"result"] intValue] == 0)
    {
        _isPull = NO;
        if ([feature intValue] == TaskStatusTypeContent ||
            [feature intValue] == TaskStatusTypeComplete)
        {
            //更新缓存数组
            for (int i=0; i<[self.taskDetailArr count]; i++)
            {
                NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
                if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] && [[statusDict objectForKey:@"packetid"] longLongValue]== [packetid longLongValue])
                {
                    NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                    [tmpStatusDict setObject:[resultDict objectForKey:@"status_id"] forKey:@"status_id"];
                    [tmpStatusDict setObject:[resultDict objectForKey:@"create_time"] forKey:@"create_time"];
                    [tmpStatusDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
                    [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
                }
            }
            //更新数据库
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"create_time" toValue:[resultDict objectForKey:@"create_time"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update create time failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"successed" toValue:TaskStatusSendStatusSuccessed withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status successed failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"status_id" toValue:[resultDict objectForKey:@"status_id"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status_id failed!");
            }
            if (![[SqliteDataDao sharedInstanse] updeteKey:@"update_time" toValue:[resultDict objectForKey:@"create_time"] withParaDict:@{@"task_id":self.taskDict[@"task_id"]} andTableName:TASK_TABLE])
            {
                DDLogError(@"update task update_time failed!");
            }
        }
        else if([feature intValue] == TaskStatusTypeAudio)
        {
            //更新缓存数组
            for (int i=0; i<[self.taskDetailArr count]; i++)
            {
                NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
                if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] && [[statusDict objectForKey:@"packetid"] longLongValue]== [packetid longLongValue])
                {
                    NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                    [tmpStatusDict setObject:[resultDict objectForKey:@"status_id"] forKey:@"status_id"];
                    [tmpStatusDict setObject:[resultDict objectForKey:@"create_time"] forKey:@"create_time"];
                    [tmpStatusDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
                    if ([resultDict objectForKey:@"audio_url"])
                    {
                        [tmpStatusDict setObject:[resultDict objectForKey:@"audio_url"] forKey:@"audio_url"];
                    }
                    [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
                }
            }
            //更新数据库
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"create_time" toValue:[resultDict objectForKey:@"create_time"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update create time failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"audio_url" toValue:[resultDict objectForKey:@"audio_url"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status_id failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"successed" toValue:TaskStatusSendStatusSuccessed withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status successed failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"status_id" toValue:[resultDict objectForKey:@"status_id"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status_id failed!");
            }
            if (![[SqliteDataDao sharedInstanse] updeteKey:@"update_time" toValue:[resultDict objectForKey:@"create_time"] withParaDict:@{@"task_id":self.taskDict[@"task_id"]} andTableName:TASK_TABLE])
            {
                DDLogError(@"update task update_time failed!");
            }
        }
        else if ([feature intValue] == TaskStatusTypeImage)
        {
            for (int i=0; i<[self.taskDetailArr count]; i++)
            {
                NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
                if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] && [[statusDict objectForKey:@"packetid"] longLongValue]== [packetid longLongValue])
                {
                    NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                    [tmpStatusDict setObject:[resultDict objectForKey:@"status_id"] forKey:@"status_id"];
                    [tmpStatusDict setObject:[resultDict objectForKey:@"create_time"] forKey:@"create_time"];
                    [tmpStatusDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
                    if([resultDict objectForKey:@"thumbnail_pic"])
                    {
                        [tmpStatusDict setObject:[resultDict objectForKey:@"thumbnail_pic"] forKey:@"thumbnail_pic"];
                        [tmpStatusDict setObject:[resultDict objectForKey:@"original_pic"] forKey:@"original_pic"];
                        [tmpStatusDict setObject:[resultDict objectForKey:@"pic_width_height"] forKey:@"pic_width_height"];
                    }
                    [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
                }
            }
            //更新数据库
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"create_time" toValue:[resultDict objectForKey:@"create_time"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update create time failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"thumbnail_pic" toValue:[resultDict objectForKey:@"thumbnail_pic"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update thumbnail_pic failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"original_pic" toValue:[resultDict objectForKey:@"original_pic"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update original_pic failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"pic_width_height" toValue:[resultDict objectForKey:@"pic_width_height"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update pic_width_height failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"successed" toValue:TaskStatusSendStatusSuccessed withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status successed failed!");
            }
            if(![[SqliteDataDao sharedInstanse] updeteKey:@"status_id" toValue:[resultDict objectForKey:@"status_id"] withParaDict:@{@"packetid":packetid} andTableName:TASK_STATUS_TABLE])
            {
                DDLogError(@"update status_id failed!");
            }
            if (![[SqliteDataDao sharedInstanse] updeteKey:@"update_time" toValue:[resultDict objectForKey:@"create_time"] withParaDict:@{@"task_id":self.taskDict[@"task_id"]} andTableName:TASK_TABLE])
            {
                DDLogError(@"update task update_time failed!");
            }
        }
        [self reloadStatusListView:NO];
    }
    else
    {
        //发送状态有错误时
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[resultDict objectForKey:@"error_msg"] isCue:1 delayTime:1 isKeyShow:NO];
        [self sendTaskStatusFailed:packetid];
    }
}

-(void)sendTaskStatusFailed:(NSString *)tmpStatusId
{
    for (int i=0; i<[self.taskDetailArr count]; i++)
    {
        NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
        if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] &&  [[statusDict objectForKey:@"packetid"] longLongValue]== [tmpStatusId longLongValue])
        {
            NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
            [tmpStatusDict setObject:TaskStatusSendStatusFailed forKey:@"successed"];
            [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
        }
    }
    if(![[SqliteDataDao sharedInstanse] updeteKey:@"successed" toValue:TaskStatusSendStatusFailed withParaDict:@{@"packetid":tmpStatusId} andTableName:TASK_STATUS_TABLE])
    {
        DDLogError(@"update status successed failed!");
    }
    [self reloadStatusListView:NO];
}

#pragma mark - 标记任务归档

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (![[self.taskDict objectForKey:@"creator_uid"] isEqualToString:self.uid]) {
            [self showViewWithCustomView:nil WithText:@"非创建人员无法标记任务为归档" withCue:1];
        }else {
            
            if (![TaskTools checkNetWork])
            {
                return;
            }
            
            TaskClient *client = [TaskClient shareClient];
            
            if (!completePacketid &&[[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"task_id":[self.taskDict objectForKey:@"task_id"],@"feature":@"7"} andTableName:TASK_STATUS_TABLE orderBy:nil] count] > 0)
            {
                NSDictionary *completeDict = [[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"task_id":[self.taskDict objectForKey:@"task_id"],@"feature":@"7"} andTableName:TASK_STATUS_TABLE orderBy:nil] firstObject];
                completePacketid = [completeDict objectForKey:@"packetid"];
            }
            
            if(!completePacketid)
            {
                completePacketid = [self getLocalTime];
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
                [tmpDict setObject:USER_ID forKey:@"user_id"];
                [tmpDict setObject:@"1" forKey:@"readed"];
                [tmpDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
                [tmpDict setObject:ORG_ID forKey:@"org_id"];
                [tmpDict setObject:[NSString stringWithFormat:@"%d",TaskStatusTypeComplete] forKey:@"feature"];
                [tmpDict setObject:USER_ID  forKey:@"from_user_id"];
                [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[self.taskDict objectForKey:@"task_id"] longLongValue]] forKey:@"task_id"];
                [tmpDict setObject:[self.taskDict objectForKey:@"task_name"] forKey:@"task_name"];
                [tmpDict setObject:completePacketid forKey:@"packetid"];
                long long create_time = [[self getLocalTime] longLongValue];
                NSDictionary *latestStatusDict = [[SqliteDataDao sharedInstanse] findLatestStatusWithTaskId:[self.taskDict objectForKey:@"task_id"]];;
                if (latestStatusDict)
                {
                    create_time = [[latestStatusDict objectForKey:@"create_time"] longLongValue]+1;
                }
                [tmpDict setObject:[NSString stringWithFormat:@"%lld",create_time] forKey:@"create_time"];
                [self.taskDetailArr addObject:tmpDict];
                [self reloadStatusListView:NO];
                
                [self insertTmpDictToDB:tmpDict];
            }
            else
            {
                for (int i=0; i<[self.taskDetailArr count]; i++)
                {
                    NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
                    if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] && [[statusDict objectForKey:@"packetid"] longLongValue]== [completePacketid longLongValue])
                    {
                        NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                        [tmpStatusDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
                        [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
                    }
                }
                
                [self reloadStatusListView:NO];
            }
            
            ((UIView *)[self.view viewWithTag:505]).userInteractionEnabled = NO;
            
            [client postCompleteWithOrg_id:self.org_id withUid:self.uid withTask_id:self.taskDict[@"task_id"] packetId:completePacketid success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
                [self sendStatusSuccessWithResultDict:responseDict
                                                andId:completePacketid andFeature:[NSString stringWithFormat:@"%d",TaskStatusTypeComplete]];
                if ([responseDict[@"result"] intValue] == 0) {
                    if ([self.reloadTaskDelegate respondsToSelector:@selector(reloadTaskSuccess)])
                    {
                        //[self showHudView: keyboardShow:NO];
                        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"已将任务标记为归档" isCue:0 delayTime:1 isKeyShow:NO];
                        if ([[SqliteDataDao sharedInstanse] updeteKey:@"" toValue:@"" withParaDict:@{@"task_id":self.taskDict[@"task_id"],@"user_id":USER_ID} andTableName:TASK_TABLE])
                        {
                            DDLogError(@"update task complete failed!");
                        }
                        [self updateTaskToComplete];
                    }
                }else {
                    [self showViewWithCustomView:nil WithText:responseDict[@"error_msg"] withCue:1];
                    [self sendTaskStatusFailed:completePacketid];
                    ((UIView *)[self.view viewWithTag:505]).userInteractionEnabled = YES;
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DDLogInfo(@"SendMessageError:%@",error);
                ((UIView *)[self.view viewWithTag:505]).userInteractionEnabled = YES;
                [self showViewWithCustomView:nil WithText:@"发送失败，请重试" withCue:1];
                [self sendTaskStatusFailed:completePacketid];
            }];
        }
    }
}

-(void)updateTaskToComplete
{
    [self.reloadTaskDelegate reloadTaskSuccess];
    UIButton *button = (UIButton *)[_bottomView viewWithTag:butt_add_tag];
    button.hidden = YES;
    [selectDateButton setComplete_state:@"1" andComplete_time:nil];
}

#pragma mark - 发送文本动态

- (void)sendMessage:(UITextView *)textView message:(NSString *)content
           packetId:(NSString *)packetId
{
    textView.text = nil;
    
    
    //收起发动态按钮列表的view
    if (_optionsView.frame.size.width == KScreenWidth-80) {
        [UIView animateWithDuration:0.25 animations:^{
            _optionsView.frame = _optionsView.frame = CGRectMake(70, 33, 0, 35);
            _optionsView.alpha = 0;
        }];
    }
    [textView resignFirstResponder];
//    FaceButton *faceBtn = (FaceButton *)[_inputView viewWithTag:butt_face_tag];
//    if ([faceBtn becomeFirstResponder]) {
//        [faceBtn resignFirstResponder];
//    }
    
    //收起输入框背景视图
    if (_toolBar.frame.origin.y != KScreenHeight-64) {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
        }];
    }
    
    BOOL isKongGe;
    for (int i=0; i<content.length; i++) {
        NSString *tempStr=[content substringWithRange:NSMakeRange(i, 1)];
        if (![tempStr isEqualToString:@" "]) {
            isKongGe=NO;
            break;
            
        }
        isKongGe=YES;
    }
    if (isKongGe) {
        //[self showHudView: keyboardShow:NO];
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"不能发送空的进展" isCue:0 delayTime:1 isKeyShow:NO];
        return;
    }
    NSString *cfuuidString = [self getLocalTime];
    if (packetId)
    {
        cfuuidString = packetId;
    }
    if (!packetId)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [tmpDict setObject:USER_ID forKey:@"user_id"];
        [tmpDict setObject:@"1" forKey:@"readed"];
        [tmpDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
        [tmpDict setObject:ORG_ID forKey:@"org_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%d",TaskStatusTypeContent] forKey:@"feature"];
        [tmpDict setObject:USER_ID  forKey:@"from_user_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[self.taskDict objectForKey:@"task_id"] longLongValue]] forKey:@"task_id"];
        [tmpDict setObject:[self.taskDict objectForKey:@"task_name"] forKey:@"task_name"];
        [tmpDict setObject:content forKey:@"content"];
    //    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    //    NSString *cfuuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        
        
        [tmpDict setObject:cfuuidString forKey:@"packetid"];
    //    [tmpDict setObject:cfuuidString forKey:@"status_id"];
        long long create_time = [[self getLocalTime] longLongValue];
        NSDictionary *latestStatusDict = [[SqliteDataDao sharedInstanse] findLatestStatusWithTaskId:[self.taskDict objectForKey:@"task_id"]];;
        if (latestStatusDict)
        {
            create_time = [[latestStatusDict objectForKey:@"create_time"] longLongValue]+1;
        }
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",create_time] forKey:@"create_time"];
        [self.taskDetailArr addObject:tmpDict];
        [self reloadStatusListView:NO];
        
        [self insertTmpDictToDB:tmpDict];
    }
    else
    {
        for (int i=0; i<[self.taskDetailArr count]; i++)
        {
            NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
            if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] &&  [[statusDict objectForKey:@"packetid"] longLongValue]== [cfuuidString longLongValue])
            {
                NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                [tmpStatusDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
                [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
            }
        }
        
        [self reloadStatusListView:NO];
    }

    if (![TaskTools checkNetWork])
    {
        return;
    }
    
    TaskClient *client = [TaskClient shareClient];
    [client postStatusCreateWithOrg_id:self.org_id
                               withUid:self.uid
                              packetID:cfuuidString
                           withTask_id:self.taskDict[@"task_id"] withContent:content success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        [self sendStatusSuccessWithResultDict:responseDict andId:cfuuidString andFeature:[NSString stringWithFormat:@"%d",TaskStatusTypeContent]];
        [self.reloadTaskDelegate reloadTaskSuccess];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogInfo(@"SendMessageError:%@",error);
        [self showViewWithCustomView:nil WithText:@"发送失败，请重试" withCue:1];
        [self sendTaskStatusFailed:cfuuidString];
    }];
}

-(void)sendMessage:(UITextView *)textView messageType:(NSString *)messageType message:(NSString *)content withNotesData:(NotesData *)nd {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *contentsStr = content;
    BOOL isKongGe;
    for (int i=0; i<contentsStr.length; i++) {
        NSString *tempStr = [contentsStr substringWithRange:NSMakeRange(i, 1)];
        if (![tempStr isEqualToString:@" "]) {
            isKongGe = NO;
            break;
        }
        isKongGe = YES;
    }
    if (![messageType isEqualToString:@"0"]) {
        isKongGe = NO;
    }
    if (isKongGe) {
        [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"发送的内容全部为空格，内容为:%@",contentsStr]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"不能发soon空白信息" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    if (contentsStr.length > 6000) {
        [myApp showWithCustomView:nil detailText:@"内容太长了！" isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }
    NotesData *notesData = [[NotesData alloc] init];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    long long int dateTime = (long long int)nowTime;
    
//    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
//    NSString *cfuuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    NSString *cfuuidString = [self getLocalTime];
    notesData.contentsUuid = cfuuidString;
    notesData.sendContents = contentsStr;
    notesData.fromUserName = [ConstantObject sharedConstant].userInfo.name;
    notesData.fromUserId = [ConstantObject sharedConstant].userInfo.imacct;
    notesData.typeMessage = messageType;
    
    NSDictionary *msgDict;
    int message_type = 0;
    if ([messageType isEqualToString:@"1"]) {
        message_type = 1;
        msgDict = @{key_messageImage_image_name:nd.imageCHatData.imageName,
                    key_messageImage_middle_link:nd.imageCHatData.middleLink,
                    key_messageImage_original_link:nd.imageCHatData.originalLink,
                    key_messageImage_small_link:nd.imageCHatData.smallLink,
                    key_messageImage_image_width:[NSString stringWithFormat:@"%d",nd.imageCHatData.imagewidth],key_messageImage_image_height:[NSString stringWithFormat:@"%d",nd.imageCHatData.imageheight]};
        notesData.imageCHatData = nd.imageCHatData;
        [imageUrlArray addObject:notesData];
    }else if ([messageType isEqualToString:@"2"]) {
        NSString *voicename = nd.chatVoiceData.voiceName;
        message_type = 2;
        if (voicename.length <= 0) {
            voicename = [nd.chatVoiceData.voicePath lastPathComponent];
            voicename = [NSString stringWithFormat:@"%@_%@.%@",[voicename stringByDeletingPathExtension],nd.chatVoiceData.voiceLenth,[voicename pathExtension]];
        }
        msgDict = @{key_messageVoice_name:voicename,
                    key_messageVoice_url:nd.chatVoiceData.voiceUrl,
                    key_messageVoice_length:nd.chatVoiceData.voiceLenth};
        notesData.chatVoiceData = nd.chatVoiceData;
    }else if ([messageType isEqualToString:@"0"]) {
        msgDict = @{key_messageText:contentsStr};
    }
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString = [dateFormatter stringFromDate:time];
    notesData.serverTime = destDateString;
    
}

#pragma mark - 表情

- (void)biaoqingAction:(UIButton *)button {
    FaceButton *faceBtn = (FaceButton *)button;
    faceBtn.selected = !faceBtn.selected;
    if (faceBtn.selected) {
        faceBtn.inputTextView = inputTextView;
        //        [faceBtn becomeFirstResponder];
    }else {
        [inputTextView becomeFirstResponder];
    }
}

- (void)sendMsg:(UIButton *)button {
    if (inputTextView.text.length>0) {
        [self sendMessage:inputTextView message:inputTextView.text packetId:nil];
    }
}

-(void)sendFace:(UITextView *)textView{
    if (textView.text.length>0) {
        [self sendMessage:textView message:textView.text packetId:nil];
    }
}

#pragma mark - 发送图片动态

-(void)uploadImage:(NSString *)imageName imagePath:(NSString *)path uuid:(NSString *)cfuuidString packetid:(NSString *)packetId{
    
    NSData *imageData=[NSData dataWithContentsOfFile:[path filePathOfCaches]];
    
    UIImage *testImage = [UIImage imageWithData: imageData];
    float iwidth=100;
    float iheight=120;
    if(testImage.size.width>testImage.size.height){
        //宽图
        iwidth=100;
        iheight=iwidth/testImage.size.width*testImage.size.height;
        if (iheight<20) {
            iheight=20;
        }
    }else{
        //长图
        iheight=120;
        iwidth=iheight/testImage.size.height*testImage.size.width;
        if(iwidth<20)
            iwidth=20;
    }
    
    NSString *tmpStatusId = [self getLocalTime];
    if(packetId)
    {
        tmpStatusId = packetId;
    }
    if (!packetId)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [tmpDict setObject:USER_ID forKey:@"user_id"];
        [tmpDict setObject:@"1" forKey:@"readed"];
        [tmpDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
        [tmpDict setObject:ORG_ID forKey:@"org_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%d",TaskStatusTypeImage] forKey:@"feature"];
        [tmpDict setObject:USER_ID  forKey:@"from_user_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[self.taskDict objectForKey:@"task_id"] longLongValue]] forKey:@"task_id"];
        [tmpDict setObject:[self.taskDict objectForKey:@"task_name"] forKey:@"task_name"];
        [tmpDict setObject:path forKey:@"local_file_url"];
        //    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        //    NSString *tmpStatusId = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        [tmpDict setObject:tmpStatusId forKey:@"packetid"];
        //    [tmpDict setObject:tmpStatusId forKey:@"status_id"];
        long long create_time = [[self getLocalTime] longLongValue];
        NSDictionary *latestStatusDict = [[SqliteDataDao sharedInstanse] findLatestStatusWithTaskId:[self.taskDict objectForKey:@"task_id"]];;
        if (latestStatusDict)
        {
            create_time = [[latestStatusDict objectForKey:@"create_time"] longLongValue]+1;
        }
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",create_time] forKey:@"create_time"];
        [tmpDict setObject:[NSString stringWithFormat:@"%.2f/%.2f",iwidth,iheight] forKey:@"original_pic_width_height"];
        [self.taskDetailArr addObject:tmpDict];
        [self reloadStatusListView:NO];
        
        [self insertTmpDictToDB:tmpDict];
    }
    else
    {
        for (int i=0; i<[self.taskDetailArr count]; i++)
        {
            NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
            if (![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] &&[[statusDict objectForKey:@"packetid"] longLongValue]== [cfuuidString longLongValue])
            {
                NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                [tmpStatusDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
                [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
            }
        }
        [self reloadStatusListView:NO];
    }
    
    TaskClient *client = [TaskClient shareClient];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = self.org_id;
    parameters[@"uid"] = self.uid;
    parameters[@"packetid"] = tmpStatusId;
    parameters[@"task_id"] = self.taskDict[@"task_id"];
    parameters[@"feature"] = @"2";
    parameters[@"pic_width_height"] = [NSString stringWithFormat:@"%f/%f",iwidth,iheight];
    parameters[@"pic_name"] = imageName;
    
    [client postPic_mediaWithParameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"pic" fileName:imageName mimeType:@"application/binary"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        [self sendStatusSuccessWithResultDict:responseDict andId:tmpStatusId andFeature:[NSString stringWithFormat:@"%d",TaskStatusTypeImage]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogInfo(@"图片上传Error:%@",error);
        [self showViewWithCustomView:nil WithText:@"发送失败，请重试" withCue:1];
        [self sendTaskStatusFailed:tmpStatusId];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize image_size = image.size;
    //屏幕尺寸
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    //分辨率
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    
    float scaling = (width*scale_screen)/image_size.width;
    UIImage *newImage = [image imageByScalingToSize:CGSizeMake(width*scale_screen, scaling*image_size.height)];
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    float iwidth = 100;
    float iheight = 120;
    if (image.size.width > image.size.height) {
        //宽图
        iwidth = 100;
        iheight = iwidth/image.size.width*image.size.height;
        if (iheight < 20) {
            iheight = 20;
        }
    }else {
        //长图
        iheight = 120;
        iwidth = iheight/image.size.height*image.size.width;
        if (iwidth < 20) {
            iwidth = 20;
        }
    }
    
    //文件保存的URL
//    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
//    NSString *cfuuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    NSString *cfuuidString = [self getLocalTime];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",cfuuidString];
    NSString *imagePath = [NSString stringWithFormat:@"%@%@",image_path,imageName];
    NSString *newFilePath = [imagePath filePathOfCaches];
    //判断目录是否存在，不存在则创建目录
    NSString *fileDictionary = [newFilePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileDictionary]) {
        [fileManager createDirectoryAtPath:fileDictionary withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5);
    if ([imageData writeToFile:newFilePath atomically:YES]) {
        imageData = nil;
        [self uploadImage:imageName imagePath:imagePath uuid:cfuuidString packetid:nil];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"写入文件失败\n请重新尝试操作" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)assetsPicker:(RYAssetsPickerController *)assetsPicker didFinishPickingMediaWithInfo:(NSArray *)info {
    NSString *isOriginal;
    //如果是图片资源
    
    if(assetsPicker.AssetType == RYAssetsPickerAssetPhoto){
        
        //        NSMutableArray *tempArray=[[NSMutableArray alloc] initWithCapacity:0];
        for (int i = 0;i<[info count];i++) {
            
            NSDictionary *dic=[info objectAtIndex:i];
            
            //指定文件保存路径
            
            //判断目录是否存在，不存在则创建目录
//            CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
//            NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
            NSString *cfuuidString = [self getLocalTime];
            //文件保存的URL
            
            NSString *dataName=[NSString stringWithFormat:@"%@.jpg",cfuuidString];
            
            NSString *imagePath=[NSString stringWithFormat:@"%@%@",image_path,dataName];
            NSString *newFilePath=[imagePath filePathOfCaches];
            
            NSString *fileDictionary = [newFilePath stringByDeletingLastPathComponent];
            NSFileManager *fileManager=[NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:fileDictionary]) {
                [fileManager createDirectoryAtPath:fileDictionary withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //判断是否是原图
            isOriginal = dic[AssetsPickerImageIsOriginl];
            
            NSData *imageData;
            
            if ([isOriginal isEqualToString:@"1"]) {
                imageData=UIImageJPEGRepresentation(dic[AssetsPickerImageOriginal], 1);
            }else if ([isOriginal isEqualToString:@"0"]){
                imageData=UIImageJPEGRepresentation(dic[AssetsPickerImageFullScreen], 1);
            }
            
            if ([imageData writeToFile:newFilePath atomically:YES]) {
                UIImage *testImage = [UIImage imageWithData: imageData];
                float iwidth=100;
                float iheight=120;
                if(testImage.size.width>testImage.size.height){
                    //宽图
                    iwidth=100;
                    iheight=iwidth/testImage.size.width*testImage.size.height;
                    if (iheight<20) {
                        iheight=20;
                    }
                }else{
                    //长图
                    iheight=120;
                    iwidth=iheight/testImage.size.height*testImage.size.width;
                    if(iwidth<20)
                        iwidth=20;
                }
                imageData = nil;
                [self uploadImage:dataName imagePath:imagePath uuid:cfuuidString packetid:nil];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"写入文件失败\n请重新尝试操作!" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                
                [alert show];
            }
        }
    }
}

#pragma mark - 发送音频动态

- (void)uploadVoice:(NSString *)voiceName path:(NSString *)path lenth:(NSString *)lenth avtivtyView:(ActivituViewBg *)activityBg packetId:(NSString *)packetId{
    
    if (_toolBar.frame.origin.y != KScreenHeight-64) {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
        }];
    }
    NSData *voiceData = [NSData dataWithContentsOfFile:[path filePathOfCaches]];
    TaskClient *client = [TaskClient shareClient];
    NSString *cfuuidString = [self getLocalTime];
    if (packetId)
    {
        cfuuidString = packetId;
    }
    if(!packetId)
    {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
        [tmpDict setObject:USER_ID forKey:@"user_id"];
        [tmpDict setObject:@"1" forKey:@"readed"];
        [tmpDict setObject:@"1" forKey:@"listened"];
        [tmpDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
        [tmpDict setObject:ORG_ID forKey:@"org_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%d",TaskStatusTypeAudio] forKey:@"feature"];
        [tmpDict setObject:USER_ID  forKey:@"from_user_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[self.taskDict objectForKey:@"task_id"] longLongValue]] forKey:@"task_id"];
        [tmpDict setObject:[self.taskDict objectForKey:@"task_name"] forKey:@"task_name"];
        [tmpDict setObject:path forKey:@"local_file_url"];
        //    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        //    NSString *cfuuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        [tmpDict setObject:cfuuidString forKey:@"packetid"];
        //    [tmpDict setObject:cfuuidString forKey:@"status_id"];
        long long create_time = [[self getLocalTime] longLongValue];
        NSDictionary *latestStatusDict = [[SqliteDataDao sharedInstanse] findLatestStatusWithTaskId:[self.taskDict objectForKey:@"task_id"]];;
        if (latestStatusDict)
        {
            create_time = [[latestStatusDict objectForKey:@"create_time"] longLongValue]+1;
        }
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",create_time] forKey:@"create_time"];
        [tmpDict setObject:voiceName forKey:@"audio_name"];
        [tmpDict setObject:lenth forKey:@"audio_duration"];
        [self.taskDetailArr addObject:tmpDict];
        [self reloadStatusListView:NO];
        
        [self insertTmpDictToDB:tmpDict];
    }
    else
    {
        for (int i=0; i<[self.taskDetailArr count]; i++)
        {
            NSDictionary *statusDict = [self.taskDetailArr objectAtIndex:i];
            if ( ![[statusDict objectForKey:@"packetid"] isEqual:[NSNull null]] && [[statusDict objectForKey:@"packetid"] longLongValue]== [cfuuidString longLongValue])
            {
                NSMutableDictionary *tmpStatusDict = [[NSMutableDictionary alloc] initWithDictionary:statusDict];
                [tmpStatusDict setObject:TaskStatusSendStatusSending forKey:@"successed"];
                [self.taskDetailArr replaceObjectAtIndex:i withObject:tmpStatusDict];
            }
        }
        
        [self reloadStatusListView:NO];
    }
    
    if (![TaskTools checkNetWork])
    {
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = self.org_id;
    parameters[@"uid"] = self.uid;
    parameters[@"task_id"] = self.taskDict[@"task_id"];
    parameters[@"feature"] = @"3";
    parameters[@"packetid"] = cfuuidString;
    parameters[@"audio_name"] = voiceName;
    parameters[@"audio_duration"] = lenth;
    [client postPic_mediaWithParameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:voiceData name:@"audio" fileName:voiceName mimeType:@"application/binary"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        [self sendStatusSuccessWithResultDict:responseDict andId:cfuuidString andFeature:[NSString stringWithFormat:@"%d",TaskStatusTypeAudio]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogInfo(@"SendMessageError:%@",error);
        [self showViewWithCustomView:nil WithText:@"发送失败，请重试" withCue:1];
        [self sendTaskStatusFailed:cfuuidString];
    }];
}

//由ButtonAudioRecorder录制完语音后回调，进行语音的上传及发送
- (void)buttonAudioRecorder:(ButtonAudioRecorder *)audioRecorder didFinishRcordWithAudioInfo:(NSDictionary *)audioInfo sendFlag:(BOOL)flag{
    [[LogRecord sharedWriteLog] writeLog:@"录制声音"];
    if (flag) {
        NSString *fileName=audioInfo[AudioRecorderName];
        NSString *filePath=audioInfo[AudioRecorderPath];
        NSString *voiceLenth=audioInfo[AudioRecorderDuration];
        [self uploadVoice:fileName path:filePath lenth:voiceLenth avtivtyView:nil packetId:nil];
    }else{
        DDLogInfo(@"取消");
    }
    
}
- (void)buttonAudioRecorder:(ButtonAudioRecorder *)audioRecorder begintouch:(BOOL)flag {
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width, self.view.frame.size.height));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    //    CGRect rect = CGRectMake(166, 211, 426, 320);//这里可以设置想要截图的区域
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height);//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    audioRecorder.image=[sendImage applyLightEffect];

}

- (void)changeToolBar {
    if (_toolBar.frame.origin.y != KScreenHeight-64) {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64, KScreenWidth, 44);
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            _toolBar.frame = CGRectMake(0, KScreenHeight-64-44, KScreenWidth, 44);
        }];
    }
}

#pragma mark - 收到任务动态推送
-(void)receivedNewTaskStatusPush:(NSDictionary *)statusDict
{
    if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeTaskDeleted)
    {
        if (![[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"task_id":[self.taskDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
        {
            DDLogCError(@"delete task failed!");
        }
        if (![[SqliteDataDao sharedInstanse] deleteRecordWithDict:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"task_id":[self.taskDict objectForKey:@"task_id"]} andTableName:TASK_STATUS_TABLE])
        {
            DDLogCError(@"delete task status failed!");
        }
        if ([self.reloadTaskDelegate respondsToSelector:@selector(reloadTaskList)])
        {
            [self.reloadTaskDelegate reloadTaskList];
        }
        return;
    }
    if([[NSString stringWithFormat:@"%lld",[[statusDict objectForKey:@"task_id"] longLongValue]]  isEqualToString:[self.taskDict objectForKey:@"task_id"]])
    {
        if ([statusDict objectForKey:@"status_id"] && ![[SqliteDataDao sharedInstanse] updeteKey:@"readed" toValue:@"1" withParaDict:@{@"status_id":[statusDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE])
        {
            //更新消息为已读
            DDLogError(@"update readed failed in task create");
        }
        if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeContent ||
            [[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeImage ||
            [[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAudio ||
            [[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeComplete )
        {
            [self.taskDetailArr addObject:statusDict];
        }
        
        if ([statusDict objectForKey:@"status_id"])
        {
            //把这条消息置成已读
            if (![[SqliteDataDao sharedInstanse] updeteKey:@"readed" toValue:@"1" withParaDict:@{@"status_id":[statusDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE])
            {
                DDLogInfo(@"update readed failed");
            }
        }
        else
        {
            if (![[SqliteDataDao sharedInstanse] updeteKey:@"readed" toValue:@"1" withParaDict:@{@"content":[statusDict objectForKey:@"content"]} andTableName:TASK_STATUS_TABLE])
            {
                DDLogInfo(@"update readed failed");
            }
        }
        
        self.taskDict = [[[SqliteDataDao sharedInstanse] findSetWithKey:@"task_id" andValue:[statusDict objectForKey:@"task_id"] andTableName:TASK_TABLE] firstObject];
        
        if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeComplete)
        {
            
        }
        else if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDescription)
        {
            self.taskDict = [[[SqliteDataDao sharedInstanse] findSetWithKey:@"task_id" andValue:[statusDict objectForKey:@"task_id"] andTableName:TASK_TABLE] firstObject];
            if ([[self.taskDict objectForKey:@"description"] length] == 0)
            {
                _detailPlaceHolderView.hidden = NO;
            }
            else
            {
                _detailPlaceHolderView.hidden = YES;
            }
            _detailTextView.text = [self.taskDict objectForKey:@"description"];
        }
        else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDeadLine)
        {
            [selectDateButton setComplete_state:[self.taskDict objectForKey:@"complete_state"] andComplete_time:[self.taskDict objectForKey:@"dead_line"]];
            
        }
        else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateMember)
        {
            NSString *memstring = [self.taskDict objectForKey:@"task_member"];
            NSArray *tempMemberArr = [memstring componentsSeparatedByString:@","];
            [self loadMemberWithTaskMember:tempMemberArr];
        }
        else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateNameAndMember)
        {
            [self setTitleButton:[self.taskDict objectForKey:@"task_name"]];
            NSString *memstring = [self.taskDict objectForKey:@"task_member"];
            NSArray *tempMemberArr = [memstring componentsSeparatedByString:@","];
            [self loadMemberWithTaskMember:tempMemberArr];
        }
        else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateName)
        {
            [self setTitleButton:[self.taskDict objectForKey:@"task_name"]];
            _namePlaceHolderView.hidden = [self.taskDict[@"task_name"] isEqualToString:@""]?NO:YES;
//            NSDictionary *nAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
//            NSString *nameStr = [self.taskDict[@"task_name"] isEqualToString:@""]?@"未标题任务":self.taskDict[@"task_name"];
//            CGSize nSize = [nameStr boundingRectWithSize:CGSizeMake(KScreenWidth-40, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:nAttribute context:nil].size;
            _nameTextView.text = self.taskDict[@"task_name"];
            [self textViewDidChange:_nameTextView];
//            _nameTextView.frame = CGRectMake(10, 2, KScreenWidth-34,nSize.height+15);
            
//            NSString *string = [self.taskDict[@"task_name"] isEqualToString:@""]?@"未标题任务":self.taskDict[@"task_name"];
//            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16]};
//            CGSize eSize = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _namePlaceHolderView.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
//            _editeImgView.frame = CGRectMake(20+eSize.width, (_nameTextView.bottom-20)/2, 22, 22);
        }
        
        [self reloadStatusListView:NO];
        if ([self.reloadTaskDelegate respondsToSelector:@selector(reloadTaskSuccess)])
        {
            [self.reloadTaskDelegate reloadTaskSuccess];
        }
    }
}

#pragma mark - hud
- (void)hudWasHidden{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}

-(void)addHUD:(NSString *)labelStr{
    
    
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    _HUD=[[MBProgressHUD alloc] initWithView:keyWindow];
    _HUD.dimBackground = YES;
    _HUD.labelText = labelStr;
    _HUD.userInteractionEnabled=YES;
    _HUD.removeFromSuperViewOnHide=YES;
    [self.view addSubview:_HUD];
    [_HUD show:YES];
}

- (void)showViewWithCustomView:(NSString *)customText WithText:(NSString *)text withCue:(int)cue {
    [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:customText detailText:text isCue:cue delayTime:1 isKeyShow:NO];
}


- (void)showHudView:(NSString *)failMessage keyboardShow:(BOOL)keyboardShow
{
    if (!_HUD) {
        _HUD=[MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    }
    _HUD.frame = CGRectMake((ScreenWidth-_HUD.frame.size.width)/2, (ScreenHeight-_HUD.frame.size.height)/2, _HUD.frame.size.width, _HUD.frame.size.height);
    _HUD.detailsLabelText=failMessage;
    _HUD.mode=MBProgressHUDModeText;
    _HUD.userInteractionEnabled=NO;
    [_HUD hide:YES afterDelay:1];
    _HUD=nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callIncoming:(NSNotification *)notification
{
    [_audioButton cancelsend];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end