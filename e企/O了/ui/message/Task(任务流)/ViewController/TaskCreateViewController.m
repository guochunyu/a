//
//  TaskCreateViewController.m
//  e企
//
//  Created by huangxiao on 15/1/26.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskCreateViewController.h"
#import "DatePickerView.h"
#import "NavigationVC_AddID.h"
#import "UIButton+WebCache.h"
#import "UIViewExt.h"
#import "TaskTools.h"
#import "TaskClient.h"
#import "TaskStatusViewController.h"
#import "UserDetailViewController.h"
#import "PersonInfoViewController.h"

@interface TaskCreateViewController ()<UITextViewDelegate, DatePickerDelegate, navigation_addIDDelegaet,ReloadTaskDelegate> {
    UIButton *_rightButton;
    UITextField *_titleTextField;
    UILabel *_memLabel;
    UIView *_memberView;
    
    UIView *_taskNameView;
    UILabel *_nameLabel;
    UITextView *_nameTextView;
    UILabel *_namePlaceHolderView;
    UIImageView *_editeImgView;
    UIView *_lineView1;
    
    UIView *_taskDetailView;
    UILabel *_detailPlaceHolderView;
    UITextView *_detailTextView;
    UIView *_lineView2;
    
    UIView *_timeSetView;
    DatePickerView *_datePickerView;
    UIButton *_timeButton;
    UILabel *_timeLabel;
    UIView *_lineView3;
    long long dateTime;
    
    UIButton *_backBtn;
    
    NSMutableArray *_taskMemberArr;
    NSString *_tempStr;
    UIView *_lineView4;
    
    UITableView *_tableView;
    BOOL _delete;
}

@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong)NSString *org_id;
@property (nonatomic, strong)NSString *uid;

@end

@implementation TaskCreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _taskMemberArr = [[NSMutableArray alloc] init];
    
    self.org_id = [[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    self.uid = [[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    
    [_taskMemberArr addObject:self.uid];
    
    if([self.array count] > 0)
    {
        for (int i=0; i<[self.array count]; i++)
        {
            id model = self.array[i];
            if ([model isKindOfClass:[EmployeeModel class]])
            {
                [_taskMemberArr addObject:((EmployeeModel *)model).phone];
            }
        }
    }
    [_taskMemberArr addObject:@"add"];
    [_taskMemberArr addObject:@"delete"];
    
    
    [self initNavigaItem];
    [self initMemberView];
    [self initTaskNameTextView];
    [self initNameDetailView];
    [self initTimeSetView];
    
    _datePickerView = [[DatePickerView alloc] initWithFrame:CGRectMake(0, KScreenHeight, KScreenWidth, 0)];
    _datePickerView.datePickerDelegate = self;
    [self.view addSubview:_datePickerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _backBtn.hidden = NO;
    _rightButton.hidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY=keyBoardRect.size.height;
    
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        if (_timeSetView.bottom >= KScreenHeight-deltaY)
        {
            self.view.transform=CGAffineTransformMakeTranslation(0, -_memberView.bottom);
        }
    }];
}
-(void)keyboardHide:(NSNotification *)note
{
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _backBtn.hidden = YES;
    _rightButton.hidden = YES;
}

- (void)reloadView {
    if (_memberView) {
        [_memberView removeFromSuperview];
    }
    
    [self initMemberView];
    
    
    _nameTextView.frame = CGRectMake(_nameLabel.right+8, 2, KScreenWidth-_nameLabel.right-40, 2+_nameTextView.contentSize.height);
    _taskNameView.frame = CGRectMake(0, _memberView.bottom, KScreenWidth, _nameTextView.bottom);
    _lineView2.frame = CGRectMake(10, _taskNameView.height-0.3, KScreenWidth-20, 0.3);
    
    _taskDetailView.frame = CGRectMake(0, _taskNameView.bottom, KScreenWidth, 110);
    _lineView3.frame = CGRectMake(10, _taskDetailView.height-0.3, KScreenWidth-20, 0.3);
    
    _timeSetView.frame = CGRectMake(0, _taskDetailView.bottom, KScreenWidth, _timeButton.bottom+10);
    _lineView4.frame = CGRectMake(10, _timeSetView.height-0.3, KScreenWidth-20, 0.3);
}

//导航栏item设置
- (void)initNavigaItem {
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(KScreenWidth-48, 0, 44, 44);
    [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(createTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:_rightButton];
    _rightButton.hidden = NO;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"创建任务";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    self.navigationItem.titleView = titleLabel;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:20]};
    CGSize size = [titleLabel.text boundingRectWithSize:CGSizeMake(KScreenWidth-100, 40) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    titleLabel.frame = CGRectMake(0, 0, size.width, 40);
}

- (void)initMemberView {
    _memberView = [[UIView alloc] init];
    [self.view addSubview:_memberView];
    [self.view insertSubview:_memberView belowSubview:_datePickerView];
    
    _memLabel = [[UILabel alloc] init];
    _memLabel.text = @"执行人:";
    _memLabel.font = [UIFont systemFontOfSize:14];
    [_memLabel sizeToFit];
    CGSize size = _memLabel.frame.size;
    _memLabel.frame = CGRectMake(10, 15, size.width, 15);
    _memLabel.textColor = [UIColor grayColor];
    [_memberView addSubview:_memLabel];
    
    for (int i = 0; i< [_taskMemberArr count]; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(_memLabel.right+10+39*(i%6), 5+(int)i/6*49, 34, 39)];
        [_memberView addSubview:view];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 5, 34, 34);
        button.tag = 100+i;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 34, 9)];
        nameLabel.font = [UIFont systemFontOfSize:8];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        
        if (i >= 0 && i <[_taskMemberArr count]-2) {
            NSString *phone = _taskMemberArr[i];
            EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:phone];
            if ([model isKindOfClass:[EmployeeModel class]]) {
                [button setImageWithURL:[NSURL URLWithString:model.avatarimgurl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
                 nameLabel.text = model.name;

            }else {
                [button setImageWithURL:[NSURL URLWithString:[ConstantObject sharedConstant].userInfo.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
                nameLabel.text = [ConstantObject sharedConstant].userInfo.name;
            }
        }
        button.hidden = NO;
        if (i == [_taskMemberArr count]-2) {
            [button setImage:[UIImage imageNamed:@"task_icon_plus"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addMemAction:) forControlEvents:UIControlEventTouchUpInside];
        }else if (i == [_taskMemberArr count]-1) {
            [button setImage:[UIImage imageNamed:@"task_icon_substract"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deleteMemAction:) forControlEvents:UIControlEventTouchUpInside];
        }else {
            if (_delete)
            {
                [button addTarget:self action:@selector(deleteMember:) forControlEvents:UIControlEventTouchUpInside];
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
        button.layer.cornerRadius = 17;
        [view addSubview:button];
        [view addSubview:nameLabel];
        
        UIImageView *staImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 1, 15, 15)];
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
    
    int count = [_taskMemberArr count];
    _memberView.frame = CGRectMake(0, 0, KScreenWidth, 5+((count-1)/6+1)*49);
    
    _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(10, _memberView.height-0.3, KScreenWidth-20, 0.3)];
    _lineView1.backgroundColor = [UIColor lightGrayColor];
    [_memberView addSubview:_lineView1];
}

- (void)initTaskNameTextView {
    _taskNameView = [[UIView alloc] init];
    [self.view addSubview:_taskNameView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.text = @"任务名称:";
    _nameLabel.font = [UIFont systemFontOfSize:14];
    [_nameLabel sizeToFit];
    CGSize size = _nameLabel.frame.size;
    _nameLabel.frame = CGRectMake(10, 10, size.width, 15);
    _nameLabel.textColor = [UIColor grayColor];
    [_taskNameView addSubview:_nameLabel];
    
    _namePlaceHolderView = [[UILabel alloc] init];
    _namePlaceHolderView.text = @"未标题任务";
    _namePlaceHolderView.font = [UIFont systemFontOfSize:14];
    [_namePlaceHolderView sizeToFit];
    CGSize plSize = _namePlaceHolderView.frame.size;
    _namePlaceHolderView.frame = CGRectMake(_nameLabel.right+13, 10, plSize.width, 15);
    _namePlaceHolderView.textColor = [UIColor lightGrayColor];
    [_taskNameView addSubview:_namePlaceHolderView];
    
    _editeImgView = [[UIImageView alloc] init];
    NSString *string = _namePlaceHolderView.text;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGSize size1 = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _namePlaceHolderView.frame.size.height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    _editeImgView.frame = CGRectMake(15+size1.width+_nameLabel.right, 7, 22, 22);
    _editeImgView.image = [UIImage imageNamed:@"task_icon_edit"];
    [_taskNameView addSubview:_editeImgView];
    
    _nameTextView = [[UITextView alloc] initWithFrame:CGRectMake(_nameLabel.right+8, 2, KScreenWidth-_nameLabel.right-40, 35)];
    _nameTextView.font = [UIFont systemFontOfSize:14];
    _nameTextView.backgroundColor = [UIColor clearColor];
    _nameTextView.delegate = self;
    [_taskNameView addSubview:_nameTextView];
    
    _taskNameView.frame = CGRectMake(0, _memberView.bottom, KScreenWidth, _nameTextView.bottom);
    
    _lineView2 = [[UIView alloc] initWithFrame:CGRectMake(10, _taskNameView.height-0.3, KScreenWidth-20, 0.3)];
    _lineView2.backgroundColor = [UIColor lightGrayColor];
    [_taskNameView addSubview:_lineView2];
    
}

- (void)initNameDetailView {
    _taskDetailView = [[UIView alloc] init];
    [self.view addSubview:_taskDetailView];
    
    _detailPlaceHolderView = [[UILabel alloc] init];
    _detailPlaceHolderView.text = @"点击输入任务描述...";
    [_detailPlaceHolderView sizeToFit];
    CGSize size = _detailPlaceHolderView.frame.size;
    _detailPlaceHolderView.frame = CGRectMake(13, 13, size.width, 15);
    _detailPlaceHolderView.textColor = [UIColor lightGrayColor];
    _detailPlaceHolderView.font = [UIFont systemFontOfSize:14];
    [_taskDetailView addSubview:_detailPlaceHolderView];
    
    _detailTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, 5, KScreenWidth-16, 100)];
    _detailTextView.font = [UIFont systemFontOfSize:14];
    if (self.detailText) {
        _detailPlaceHolderView.hidden = YES;
        _detailTextView.text = self.detailText;
    }
    _detailTextView.backgroundColor = [UIColor clearColor];
    _detailTextView.delegate = self;
    [_taskDetailView addSubview:_detailTextView];
    
    _taskDetailView.frame = CGRectMake(0, _taskNameView.bottom, KScreenWidth, 110);
    
    _lineView3 = [[UIView alloc] initWithFrame:CGRectMake(10, _taskDetailView.height-0.3, KScreenWidth-20, 0.3)];
    _lineView3.backgroundColor = [UIColor lightGrayColor];
    [_taskDetailView addSubview:_lineView3];
}

- (void)initTimeSetView {
    _timeSetView = [[UIView alloc] init];
    [self.view addSubview:_timeSetView];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.text = @"任务截止时间:";
    _timeLabel.font = [UIFont systemFontOfSize:14];
    [_timeLabel sizeToFit];
    CGSize size = _timeLabel.frame.size;
    _timeLabel.frame = CGRectMake(10, 10, size.width, 15);
    _timeLabel.textColor = [UIColor lightGrayColor];
    [_timeSetView addSubview:_timeLabel];
    
    _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _timeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self timeButtonSetTime:@"设定任务截止时间"];
    _timeButton.titleLabel.textColor = [UIColor lightGrayColor];
    [_timeButton addTarget:self action:@selector(setTimeAction:) forControlEvents:UIControlEventTouchUpInside];
    [_timeSetView addSubview:_timeButton];
    
    _timeSetView.frame = CGRectMake(00, _taskDetailView.bottom, KScreenWidth, _timeButton.bottom+10);
    
    _lineView4 = [[UIView alloc] initWithFrame:CGRectMake(10, _timeSetView.height-0.3, KScreenWidth-20, 0.3)];
    _lineView4.backgroundColor = [UIColor lightGrayColor];
    [_timeSetView addSubview:_lineView4];
}

- (void)timeButtonSetTime:(NSString *)str {
    NSString *string = str;
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc] initWithString:string];
    NSRange strRange = {0,[buttonTitle length]};
    [buttonTitle addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_timeButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    CGSize size = [str boundingRectWithSize:CGSizeMake(KScreenWidth-100, 40) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    _timeButton.frame = CGRectMake(_timeLabel.right+8, _timeLabel.top, size.width, 15);
}

#pragma mark --
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (_datePickerView.height != 0) {
        [UIView animateWithDuration:0.2 animations:^{
            _datePickerView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 0);
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == _nameTextView) {
        if (textView.text.length > 30)
        {
//            [self showHudView:@"任务名称不能超过30字" keyboardShow:YES];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务名称不能超过30字" isCue:0 delayTime:1 isKeyShow:NO];
            textView.text = [textView.text substringToIndex:30];
            return;
        }
        CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
        if ( overflow > 0 || overflow < -10.0 ) {
            
            [self reloadView];
        }
        if ([textView.text length] == 0) {
            _namePlaceHolderView.hidden = NO;
            NSString *string = _namePlaceHolderView.text;
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
            CGSize size1 = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _namePlaceHolderView.frame.size.height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
            _editeImgView.frame = CGRectMake(10+size1.width+_nameLabel.right, 7, 22, 22);
        }else{
            _namePlaceHolderView.hidden = YES;
            NSString *string = textView.text;
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
            CGSize size1 = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, _namePlaceHolderView.frame.size.height) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
            if (size1.width < KScreenWidth-_nameLabel.right-40) {
                if (size1.width > _nameTextView.width-20) {
                    _editeImgView.frame = CGRectMake(KScreenWidth-30, (_taskNameView.height-22)/2, 22, 22);
                }else{
                    _editeImgView.frame = CGRectMake(15+size1.width+_nameLabel.right, (_taskNameView.height-22)/2, 22, 22);
                }
            }else {
                _editeImgView.frame = CGRectMake(KScreenWidth-30, (_taskNameView.height-22)/2, 22, 22);
            }
        }
    }
    if (textView == _detailTextView) {
        if (textView.text.length > 200)
        {
//            [self showHudView:@"任务描述不能超过200字" keyboardShow:YES];
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务描述不能超过200字" isCue:0 delayTime:1 isKeyShow:NO];
            textView.text = [textView.text substringToIndex:200];
            return;
        }
        if ([textView.text length] == 0) {
            _detailPlaceHolderView.hidden = NO;
        }else {
            _detailPlaceHolderView.hidden = YES;
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView == _nameTextView) {
        if(range.location > 29){
//            [self showHudView:@"任务名称不能超过30字" keyboardShow:YES];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务名称不能超过30字" isCue:0 delayTime:1 isKeyShow:NO];
            return NO;
        }
        char c=[text UTF8String][0];
        if (c=='\000') {
            return YES;
        }
        
        if([[textView text] length]==30) {
            if(![text isEqualToString:@"\b"])
                return NO;
        }
        return YES;
    }else {
        if (range.location > 199) {
//            [self showHudView:@"任务描述不能超过200字" keyboardShow:YES];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务描述不能超过200字" isCue:0 delayTime:1 isKeyShow:NO];
            return NO;
        }
        char c = [text UTF8String][0];
        if (c == '\000') {
            return YES;
        }
        if ([[textView text] length] == 200) {
            if (![text isEqualToString:@"\b"]) {
                return NO;
            }
        }
        return YES;
    }
    return YES;
    
}

#pragma mark --
#pragma mark ButtonAction

//加号按钮action
- (void)addMemAction:(UIButton *)button {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    nav_add.addScrollType = AddScrollTypeTask;
    nav_add.delegate_addID = self;
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (int i=1; i<_taskMemberArr.count-2; i++) {
        EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:[_taskMemberArr objectAtIndex:i]];
        if (model.phone != nil) {
            [tempArr addObject:model.phone];
        }
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
        for (EmployeeModel *md in memberArray) {
            [_taskMemberArr insertObject:md.phone atIndex:_taskMemberArr.count-2];
        }
        if ([_taskMemberArr count]>22) {
//            [self showHudView:@"任务成员上限人数为20人" keyboardShow:NO];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务成员上限人数为20人" isCue:0 delayTime:1 isKeyShow:NO];
            int count2 = [_taskMemberArr count];
            for (int i=21; i<count2-1; i++) {
                [_taskMemberArr removeObjectAtIndex:21];
            }
        }
        [self reloadView];
    }
}

-(void)toPersonDetail:(UIButton *)button
{
    NSString *phone = [_taskMemberArr objectAtIndex:button.tag-100];
    
    if([phone isEqualToString:USER_ID])
    {
        PersonInfoViewController *pVC = [[PersonInfoViewController alloc] initWithNibName:@"PersonInfoViewController" bundle:nil];
        pVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:pVC animated:YES];
        return;
    }
    if (!phone)
    {
        return ;
    }
    EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:phone];
    UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] init];
    userDetailVC.userInfo = model;
    userDetailVC.organizationName = model.comman_orgName;
    userDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userDetailVC animated:YES];
}


//减号按钮action
- (void)deleteMemAction:(UIButton *)button {
    _delete = !_delete;
    [self reloadView];
}

- (void)deleteMember:(UIButton *)button {
    
    [_taskMemberArr removeObjectAtIndex:button.tag-100];
    
    [self reloadView];
}

- (void)createTask:(UIButton *)button {
    if ([self.view endEditing:NO]) {
        [self.view endEditing:YES];
    }
    [self addHUD:@"创建任务"];
    NSMutableArray *taskArr = [[NSMutableArray alloc] initWithArray:_taskMemberArr];
    [taskArr removeObject:@"add"];
    [taskArr removeObject:@"delete"];
    [taskArr removeObjectAtIndex:0];
    NSMutableArray *task_member = [[NSMutableArray alloc] init];
    for (NSString *phone in taskArr) {
        [task_member addObject:phone];
    }
    NSString *time = nil;
    if (![_timeButton.titleLabel.text isEqualToString:@"设定任务截止时间"]) {
        time = [NSString stringWithFormat:@"%lld",dateTime*1000];
    }else {
        time = @"0";
    }
    NSString *dead_line = time;
    
    NSString *description = _detailTextView.text?_detailTextView.text:nil;
    int task_type = 0;
    if (self.isFromMessage) {
        task_type = 2;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    __block NSMutableString *member = [[NSMutableString alloc] initWithString:@""];
    if ([task_member count] > 0)
    {
        [member insertString:@"[" atIndex:[member length]];
        for (NSString *user in task_member)
        {
            [member insertString:[NSString stringWithFormat:@"%@,",user] atIndex:[member length]];
        }
        [member insertString:@"]" atIndex:[member length]-1];
    }
    if ([member length] == 0)
    {
        [member insertString:@"[]" atIndex:0];
    }
    else
    {
        [member deleteCharactersInRange:NSMakeRange([member length]-1, 1)];
    }
    
    NSString *task_name = _nameTextView.text;
    parameters[@"org_id"] = self.org_id?self.org_id:@"";
    parameters[@"uid"] = self.uid?self.uid:@"";
    parameters[@"task_name"] = task_name?task_name:@"未标题任务";
    parameters[@"dead_line"] = dead_line?dead_line:@"0";
    parameters[@"task_member"] = member?member:@"";
    parameters[@"description"] = description?description:@"";
    parameters[@"task_type"] = @(task_type);
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,CreateTask];
    _rightButton.enabled = NO;
    [[TaskClient shareClient] POST:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        _rightButton.hidden = YES;
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        [self hudWasHidden];
        if ([responseDict[@"result"] intValue] == -1) {
            [self showViewWithCustomView:nil WithText:responseDict[@"error_msg"] withCue:1];
        }else {
            if ([[responseDict objectForKey:@"result"] intValue] == 0)
            {
                if (self.isFromMessage || self.isFromContact) {
                    QFXmppManager *manager = [QFXmppManager shareInstance];
                    if (manager.receiveTaskPushInTaskView)
                    {
                        manager.receiveTaskPushInTaskView(nil);
                    }else {
                        [self requestTaskList];
                    }
                }
                if ([self.createTaskDelegate respondsToSelector:@selector(createTaskSuccess)])
                {
                    [self.createTaskDelegate createTaskSuccess];
                }
                [self showViewWithCustomView:nil WithText:@"创建成功" withCue:0];
                
                NSMutableDictionary *taskDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [taskDict setObject:@"0" forKey:@"complete_state"];
                [taskDict setObject:@"0" forKey:@"complete_time"];
                [taskDict setObject:[responseDict objectForKey:@"create_time"] forKey:@"create_time"];
                [taskDict setObject:USER_ID forKey:@"creator_uid"];
                [taskDict setObject:[parameters objectForKey:@"dead_line"] forKey:@"dead_line"];
                [taskDict setObject:description forKey:@"description"];
                [taskDict setObject:@"" forKey:@"dispatched_uid"];
                [taskDict setObject:@"" forKey:@"mail_id"];
                [taskDict setObject:ORG_ID forKey:@"org_id"];
                [taskDict setObject:@"0" forKey:@"origin_type"];
                [taskDict setObject:[NSString stringWithFormat:@"%lld",[[responseDict objectForKey:@"task_id"] longLongValue]] forKey:@"task_id"];
                [taskDict setObject:@"default_task_logo.jpg" forKey:@"task_logo"];
                [member deleteCharactersInRange:NSMakeRange(0, 1)];
                [member deleteCharactersInRange:NSMakeRange([member length] - 1, 1)];
                [taskDict setObject:member forKey:@"task_member"];
                [taskDict setObject:task_name forKey:@"task_name"];
                
                if (self.isFromMessage)
                {
                    [taskDict setObject:@"2" forKey:@"task_type"];
                }
                else
                {
                    [taskDict setObject:@"0" forKey:@"task_type"];
                }
                [taskDict setObject:[responseDict objectForKey:@"create_time"] forKey:@"update_time"];
                
                TaskStatusViewController *taskStatusVC = [[TaskStatusViewController alloc] init];
                taskStatusVC.taskDict = taskDict;
                taskStatusVC.reloadTaskDelegate = self;
                taskStatusVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:taskStatusVC animated:YES];
                //                [self performSelector:@selector(pushAction) withObject:nil afterDelay:0.5];
            }
            else
            {
                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[responseDict objectForKey:@"error_msg"] isCue:1 delayTime:1 isKeyShow:NO];
            }
        }

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogInfo(@"CreateTask:%@",error);
        _rightButton.hidden = YES;
        [self hudWasHidden];
        [self showViewWithCustomView:nil WithText:@"创建失败，请重试" withCue:1];
    }];
}

- (void)requestTaskList {
    TaskClient *client = [TaskClient shareClient];
    [client getTaskListWithOrg_id:ORG_ID withUid:USER_ID withPage:1 WithCount:1 success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        NSArray *tasks = [responseDict objectForKey:@"tasks"];
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [tmpDict setObject:USER_ID forKey:@"user_id"];
        NSDictionary *taskDict = [tasks firstObject];
        for(NSString *key in taskDict)
        {
            NSString *valueType = NSStringFromClass([[[tasks firstObject] objectForKey:key] class]);
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

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DDLogCError(@"%@",error);
    }];
}

- (void)pushAction {
    NSArray *unReadArray = [[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"complete_state":@"0"} andTableName:TASK_TABLE orderBy:@"update_time" orderFunc:1];
    NSDictionary *taskDict = [unReadArray firstObject];
    TaskStatusViewController *taskStatusVC = [[TaskStatusViewController alloc] init];
    taskStatusVC.taskDict = taskDict;
    taskStatusVC.reloadTaskDelegate = self;
    taskStatusVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taskStatusVC animated:YES];
}

-(void)reloadTaskSuccess
{
    if ([self.createTaskDelegate respondsToSelector:@selector(createTaskSuccess)])
    {
        [self.createTaskDelegate createTaskSuccess];
    }
}

- (void)setTimeAction:(UIButton *)button {
    [UIView animateWithDuration:0.2 animations:^{
        [_nameTextView resignFirstResponder];
        [_detailTextView resignFirstResponder];
        _datePickerView.frame = CGRectMake(0, KScreenHeight-DatePickerHeight, KScreenWidth, DatePickerHeight);
        
    } completion:^(BOOL finished) {
    }];
    
}

- (void)dateDone:(NSString *)selectDate {
    DDLogInfo(@"complete time %@",selectDate);
    NSString *str = @"";
    dateTime = 0;
    if ([selectDate length] > 10)
    {
        dateTime =[selectDate longLongValue]/1000;
    }
    else
    {
        dateTime = [selectDate longLongValue];
    }
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd"];
    NSString *destDateString = [dateFormatter stringFromDate:time];
    str = destDateString;
    [self timeButtonSetTime:str];
    [self dateCancel];
}

- (void)dateCancel {
    [UIView animateWithDuration:0.2 animations:^{
        _datePickerView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 0);
    } completion:^(BOOL finished) {
    }];
}

- (void)hudWasHidden{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}

-(void)addHUD:(NSString *)labelStr{
    
    
    _HUD=[[MBProgressHUD alloc] initWithView:self.view.window];
    _HUD.frame = CGRectMake((ScreenWidth-_HUD.frame.size.width)/2, (ScreenHeight-_HUD.frame.size.height)/2-70, _HUD.frame.size.width, _HUD.frame.size.height);
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

//- (void)showHudView:(NSString *)failMessage keyboardShow:(BOOL)keyboardShow
//{
//    if (!_HUD) {
//        _HUD=[MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
//    }
//    _HUD.frame = CGRectMake((ScreenWidth-_HUD.frame.size.width)/2, (ScreenHeight-_HUD.frame.size.height)/2, _HUD.frame.size.width, _HUD.frame.size.height);    _HUD.detailsLabelText=failMessage;
//    _HUD.mode=MBProgressHUDModeText;
//    _HUD.userInteractionEnabled=NO;
//    [_HUD hide:YES afterDelay:1];
//    _HUD=nil;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    if (_datePickerView.height != 0) {
        [UIView animateWithDuration:0.2 animations:^{
            _datePickerView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 0);
        }];
    }
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
