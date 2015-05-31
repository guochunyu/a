//
//  MessageGroupChatSetNameViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-1-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define GROUPCHATNAME_SUCESS @200 //登录成功
#define TABLEVIEWCELL_ROW_HEIGHT 50 //tableView的row高度
#define HUD_TAG_SUCCESS 600     //修改成功后的HUD高度

#import "MBProgressHUD.h"

#import "GroupChatInfo.h"

#import "MessageGroupChatSetNameViewController.h"

#import "menber_info.h"
@interface MessageGroupChatSetNameViewController ()<UIGestureRecognizerDelegate,MBProgressHUDDelegate>{
    UITextField *_txtGroupChatName;
    MBProgressHUD *_progressHUD;
}
@end

@implementation MessageGroupChatSetNameViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"群聊名称";
    
    
    //leftBarButtonItem设置
    UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.titleLabel.font=[UIFont systemFontOfSize:15];
    leftButton.bounds=CGRectMake(0, 0, 50, 29);
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back_pre.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftBar;
    //rightBarButtonItem设置
    UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.titleLabel.font=[UIFont systemFontOfSize:15];
    rightButton.bounds=CGRectMake(0, 0, 50, 29);
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"chat_button_disable.png"] forState:UIControlStateDisabled];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"chat_button_enable.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"chat_button_highlighted.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(saveGroupChatName:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
    rightBar.enabled=NO;
    self.navigationItem.rightBarButtonItem=rightBar;
    //tableView的设置
    if (IS_IOS_7) {
        self.tableView.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
    }
    self.tableView.scrollEnabled=NO;
    //手势添加
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEditingTextFile:)];
    tapGesture.delegate=self;
    [self.view addGestureRecognizer:tapGesture];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - 自定义消息
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark navigation的保存按钮
- (void)saveGroupChatName:(UIBarButtonItem *)sender
{
    
    
    NSString *groupChatName=_txtGroupChatName.text;
    
    BOOL isKongGe;
    for (int i=0; i<groupChatName.length; i++) {
        NSString *tempStr=[groupChatName substringWithRange:NSMakeRange(i, 1)];
        if (![tempStr isEqualToString:@" "]) {
            isKongGe=NO;
            break;
            
        }
        isKongGe=YES;
    }
    if (isKongGe) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"群名称不能全部为空" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }else{
        
    }

}
#pragma mark request请求成功
- (void)requestSuccess:(id)JSON
{
    if ([JSON[@"result"] isEqualToNumber:GROUPCHATNAME_SUCESS]) {
        _progressHUD.labelText=@"修改成功";
        _progressHUD.tag=HUD_TAG_SUCCESS;
        self.groupChatInfo.name=_txtGroupChatName.text;
        [_progressHUD hide:YES afterDelay:0.2];
    }else{
        _progressHUD.labelText=@"修改失败";
        [_progressHUD hide:YES afterDelay:0.5];
    }
    
}
#pragma mark request请求失败
- (void)requestFailure:(id)JSON
{
    _progressHUD.labelText=@"修改失败";
    [_progressHUD hide:YES afterDelay:0.5];
}
#pragma mark 手势事件结束编辑
- (void)endEditingTextFile:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}
#pragma mark 事件传递
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //如果为ClearButton则继续传递事件
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark textField的edition Change事件
- (void)switchBarButtonState:(UITextField *)sender
{
    if ([sender.text isEqualToString:self.groupChatInfo.name]||[sender.text isEqualToString:@""]) {
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        //textField设置
        _txtGroupChatName=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, 280, 30)];
        [_txtGroupChatName addTarget:self action:@selector(switchBarButtonState:) forControlEvents:UIControlEventEditingChanged];
        _txtGroupChatName.clearButtonMode=UITextFieldViewModeAlways;
        _txtGroupChatName.autocorrectionType=UITextAutocorrectionTypeNo;
        CGFloat width=[UIScreen mainScreen].bounds.size.width;
        _txtGroupChatName.center=CGPointMake(width/2, TABLEVIEWCELL_ROW_HEIGHT/2);
        _txtGroupChatName.placeholder=@"请输入群名称";
        _txtGroupChatName.delegate=self;
        [cell.contentView addSubview:_txtGroupChatName];
        _txtGroupChatName.text=self.groupChatInfo.name;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEWCELL_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (toBeString.length>31) {
        return NO;
    }
    return YES;
}
#pragma mark - MBProgressHUD Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud.tag==HUD_TAG_SUCCESS) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
