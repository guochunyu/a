//
//  MailActAddHandler.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActAddHandler.h"
#import "MailActAddController.h"
#import "MailActAddRouter.h"
#import "LogicHelper.h"
#import "EmailAccount.h"
#import "MailLogic.h"

@interface MailActAddHandler ()

@property (nonatomic) NSString *serverHost;
@property (nonatomic) NSNumber *serverPort;

@end

@implementation MailActAddHandler

- (void)initData
{

}

- (void)mailLogin:(NSString *)email password:(NSString *)password
{
    // 邮箱为空
    if ([LogicHelper isBlankOrNil:email]) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.email.empty", nil)];
        return;
    }
    // 密码为空
    if ([LogicHelper isBlankOrNil:password]) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.password.empty", nil)];
        return;
    }
    // 已存在
    if ([EmailAccount findByAccount:email] != nil) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.email.exist", nil)];
        return;
    }
    // 格式判断
    NSUInteger location = [email rangeOfString:@"@"].location;
    if (location == NSNotFound || location == email.length - 1 || location == 0) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.email.format", nil)];
        return;
    }
    _serverHost = _userInfo[@"host"];
    
    NSString *sufix = [email substringWithRange:NSMakeRange(location + 1, email.length - location - 1)];
    NSString *smtpHost = [NSString stringWithFormat:kDefaultSMTPHostFormat,sufix];
    if (_serverHost == nil) {
        _serverHost = [NSString stringWithFormat:kDefaultPOPHostFormat,sufix];
    }
    _serverPort = _userInfo[@"port"];
    if (_serverPort == nil) {
        _serverPort = @(kDefaultPOPPort);
    }
    
    // 登录验证：
    [_controller enableUIForNetworking:NO];
    NetworkIndicatorVisible(YES);
    DDLogInfo(@"邮件账户登录:%@ 密码:%@ host:%@ port:%ld",email,password,_serverHost,(long)[_serverPort integerValue]);
    EmailAccount *account = [EmailAccount create];
    [account decreate];
    account.username = email;
    account.password = password;
    account.pop3Host = _serverHost;
    account.pop3Port = _serverPort;
    account.smtpPort = @(kDefaultSMTPPort);
    account.smtpHost = smtpHost;
     [[NSNotificationCenter defaultCenter]postNotificationName:@"登陆中" object:nil];
    [MailLogic checkAccount:account completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NetworkIndicatorVisible(NO);
            [_controller enableUIForNetworking:YES];
            if (error == nil) {
                DDLogInfo(@"邮件账户登录成功");
                EmailAccount *account = [EmailAccount create];
                account.username = email;
                account.password = password;
                account.pop3Host = _serverHost;
                account.pop3Port = _serverPort;
                account.smtpPort = @(kDefaultSMTPPort);
                account.smtpHost = smtpHost;
                [_router popController];
            } else {
                DDLogInfo(@"邮件账户登录失败:%@",error);
                //[account decreate];
                [_controller alertMessage:[error localizedDescription]];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:@"登陆后" object:nil];
        });
    }];
}

- (void)mailVerify:(NSString *)email password:(NSString *)password
{
    // 邮箱为空
    if ([LogicHelper isBlankOrNil:email]) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.email.empty", nil)];
        return;
    }
    // 密码为空
    if ([LogicHelper isBlankOrNil:password]) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.password.empty", nil)];
        return;
    }
    // 格式判断
    NSUInteger location = [email rangeOfString:@"@"].location;
    if (location == NSNotFound || location == email.length - 1 || location == 0) {
        [_controller alertMessage:NSLocalizedString(@"MailActAdd.email.format", nil)];
        return;
    }
    _serverHost = _userInfo[@"host"];
    
    NSString *sufix = [email substringWithRange:NSMakeRange(location + 1, email.length - location - 1)];
    NSString *smtpHost = [NSString stringWithFormat:kDefaultSMTPHostFormat,sufix];
    if (_serverHost == nil) {
        _serverHost = [NSString stringWithFormat:kDefaultPOPHostFormat,sufix];
    }
    _serverPort = _userInfo[@"port"];
    if (_serverPort == nil) {
        _serverPort = @(kDefaultPOPPort);
    }
    
    // 登录验证：
    [_controller enableUIForNetworking:NO];
    NetworkIndicatorVisible(YES);
    DDLogInfo(@"邮件账户登录:%@ 密码:%@ host:%@ port:%ld",email,password,_serverHost,(long)[_serverPort integerValue]);
    EmailAccount *account = [EmailAccount create];
    account.username = email;
    account.password = password;
    account.pop3Host = _serverHost;
    account.pop3Port = _serverPort;
    account.smtpPort = @(kDefaultSMTPPort);
    account.smtpHost = smtpHost;
    [MailLogic checkAccount:account completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NetworkIndicatorVisible(NO);
            [_controller enableUIForNetworking:YES];
            if (error == nil) {
                DDLogInfo(@"邮件账户登录成功");
                [_controller authSuccess];
            } else {
                DDLogInfo(@"邮件账户登录失败:%@",error);
                [account decreate];
                [_controller alertMessage:[error localizedDescription]];
            }
        });
    }];
}

- (void)mailSetting
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (_serverHost != nil) {
        dict[@"host"] = _serverHost;
    }
    if (_serverPort != nil) {
        dict[@"port"] = _serverPort;
    }
    [_router pushMailActSettingController:dict];
}

@end


























