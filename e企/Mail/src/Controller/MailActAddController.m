//
//  MailActAddController.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActAddController.h"
#import "MailActAddHandler.h"
#import "ACEAutocompleteBar.h"
#import "EmailAccount.h"
#import "LogicHelper.h"
#import "MailLogic.h"

@interface MailActAddController () <ACEAutocompleteDataSource, ACEAutocompleteDelegate>

@property (weak, nonatomic) IBOutlet UITextField *iAccountText;
@property (weak, nonatomic) IBOutlet UITextField *iPasswordText;
@property (weak, nonatomic) IBOutlet UIButton *iLoginButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *iHideKeyboardTapGesture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *iNetworkProgress;
@property (weak, nonatomic) IBOutlet UIButton *iSettingButton;
@property (nonatomic, strong) NSArray *sampleStrings;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;

@end

@implementation MailActAddController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    [_handler initData];
    [self.view addGestureRecognizer:_iHideKeyboardTapGesture];
    self.sampleStrings = @[@"@139.com",
                           @"@126.com",
                           @"@chinamobile.com",
                           @"@163.com",
                           @"@yeah.net",
                           @"@sina.cn",
                           @"@sina.com",
                           @"@hotmail.com",
                           @"@tom.com",
                           @"@outlook.com",
                           @"@qq.com",
                           @"@foxmail.com",
                           @"@yahoo.com",
                           @"@gmail.com",
                           @"@sohu.com"];
    [_iAccountText setAutocompleteWithDataSource:self
                                         delegate:self
                                        customize:^(ACEAutocompleteInputView *inputView) {
                                            
                                            // customize the view (optional)
                                            inputView.font = [UIFont systemFontOfSize:20];
                                            inputView.textColor = [UIColor whiteColor];
                                            inputView.backgroundColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.9 alpha:0.8];
                                            
                                        }];
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _iAccountText.leftView = paddingView;
    _iPasswordText.leftView = paddingView1;
    _iAccountText.leftViewMode = UITextFieldViewModeAlways;
    _iPasswordText.leftViewMode = UITextFieldViewModeAlways;

    _iAccountText.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.buttonAdd.layer setCornerRadius:4.f];
    
    //将添加邮箱返回按钮设置为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_authFailed) {
        _iAccountText.text = _authAccount.username;
        
    } else {
        [_iAccountText becomeFirstResponder];
        self.tableView.tableHeaderView = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (IBAction)textFieldEndOnExit:(UITextField *)sender
{
    if (sender == _iAccountText) {
        [_iPasswordText becomeFirstResponder];
    } else if (sender == _iPasswordText) {
        [self didLoginButtonClick:_iLoginButton];
    }
}

- (IBAction)didLoginButtonClick:(UIButton *)sender
{
    NSString *email = _iAccountText.text;
    NSString *password = _iPasswordText.text;
    if (_authFailed) {
        // 邮箱为空
        if ([LogicHelper isBlankOrNil:email]) {
            [self alertMessage:NSLocalizedString(@"MailActAdd.email.empty", nil)];
            return;
        }
        // 密码为空
        if ([LogicHelper isBlankOrNil:password]) {
            [self alertMessage:NSLocalizedString(@"MailActAdd.password.empty", nil)];
            return;
        }
        // 格式判断
        NSUInteger location = [email rangeOfString:@"@"].location;
        if (location == NSNotFound || location == email.length - 1 || location == 0) {
            [self alertMessage:NSLocalizedString(@"MailActAdd.email.format", nil)];
            return;
        }
        
        // 登录验证：
        [self enableUIForNetworking:NO];
        NetworkIndicatorVisible(YES);
        DDLogInfo(@"邮件账户登录:%@ 密码: host:%@ port:%ld",email,_authAccount.pop3Host ,(long)[_authAccount.pop3Port integerValue]);
        _authAccount.password = password;
        [MailLogic checkAccount:_authAccount completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NetworkIndicatorVisible(NO);
                [self enableUIForNetworking:YES];
                if (error == nil) {
                    DDLogInfo(@"邮件账户登录成功");
                    [self authSuccess];
                } else {
                    DDLogInfo(@"邮件账户登录失败:%@",error);
                    [self alertMessage:[error localizedDescription]];
                }
            });
        }];
    } else {
        [_handler mailLogin:email password:password];
    }
    
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (void)alertMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"app.confirm", nil) otherButtonTitles:nil, nil];
    [alert show];
}

- (void)enableUIForNetworking:(BOOL)enable
{
    _iAccountText.enabled = enable;
    _iPasswordText.enabled = enable;
    self.tableView.userInteractionEnabled = enable;
    _iLoginButton.hidden = !enable;
    if (enable) {
        [_iNetworkProgress stopAnimating];
    } else {
        [_iNetworkProgress startAnimating];
    }
}

- (IBAction)didSettingButtonClick:(id)sender
{
    // 高级设置
    [_handler mailSetting];
}

#pragma mark - Autocomplete Delegate

- (void)textField:(UITextField *)textField didSelectObject:(id)object inInputView:(ACEAutocompleteInputView *)inputView
{
    NSString *org = textField.text;
    NSString *append = (NSString *)object;
    append = [org stringByAppendingString:[append substringWithRange:NSMakeRange(1, append.length - 1)]];
    textField.text = append; // NSString
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//zw    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Autocomplete Data Source

- (NSUInteger)minimumCharactersToTrigger:(ACEAutocompleteInputView *)inputView
{
    return 1;
}

- (void)inputView:(ACEAutocompleteInputView *)inputView itemsFor:(NSString *)query result:(void (^)(NSArray *items))resultBlock;
{
    if (resultBlock != nil) {
        // execute the filter on a background thread to demo the asynchronous capability
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            // execute the filter
            
            NSMutableArray *array;
            
            if (_iAccountText.isFirstResponder) {
                array = [self.sampleStrings mutableCopy];
            }
            
            NSMutableArray *data = [NSMutableArray array];
            DDLogInfo(@"%@",query);
            NSString *at = [query substringWithRange:NSMakeRange(query.length - 1,1)];
            for (NSString *s in array) {
                if ([s hasPrefix:at]) {
                    [data addObject:s];
                }
            }
            
            // return the filtered array in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(data);
            });
        });
    }
}

- (void)authSuccess
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)authCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end