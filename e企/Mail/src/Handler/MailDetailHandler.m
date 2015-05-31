//
//  MailDetailHandler.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailDetailHandler.h"
#import "MailDetailController.h"
#import "Email.h"
#import "MailLogic.h"
#import "MailDetailRouter.h"
#import "LogicHelper.h"
#import "CoreDataManager.h"

@interface MailDetailHandler ()

@property (nonatomic) Email *email;
@property (nonatomic) EmailAccount *account;


@end

@implementation MailDetailHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailReplay) name:@"emailReply" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailTransmit) name:@"emailTransmit" object:nil];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"emailReplay"];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:@"emailTransmit"];
}

- (void)emailReplay
{
    if (_email) {
        if (_email.hasTransmit.boolValue) {
            _email.hasTransmit=@(NO);
        }
        _email.hasReply = @(YES);
    }
}

- (void)emailTransmit
{
    if (_email) {
        if (_email.hasReply.boolValue) {
            _email.hasReply=@(NO);
        }
        _email.hasTransmit = @(YES);
    }
}

- (void)initData
{
    _email = _userInfo[@"email"];
    _account = _userInfo[@"account"];
    [_controller setValue:_email forKey:@"email"];
    [_controller setValue:_account forKey:@"account"];
}

- (void)loadEmailHtmlText
{
    NetworkIndicatorVisible(YES);
    [MailLogic loadMessageBody:_account index:[_email.index unsignedIntegerValue] completion:^(NSError *error, MCOMessageParser *message) {
        NetworkIndicatorVisible(NO);
        if (error != nil) {
            DDLogInfo(@"获取邮件Body失败:%@",[error localizedDescription]);
            return;
        }
        [_email convertFromMCOIMAPMessage:message];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_controller refreshViewFromEmailContent:_email.htmlText];
        });
    }];
}

- (void)saveFavorite
{
    if ([_email.isFlag boolValue]) {
        _email.isFlag = @(NO);
    } else {
        _email.isFlag = @(YES);
    }
    [[CoreDataManager sharedInstance] save];
    [_controller setValue:_email forKey:@"email"];
}

- (void)deleteMail
{
    _email.hasDeleted = @(YES);
    NetworkIndicatorVisible(YES);
    [MailLogic deleteMessage:_account messageIndex:[_email.index unsignedIntegerValue] completion:^(NSError *error) {
        NetworkIndicatorVisible(NO);
    }];
    [_router popController];
}

- (void)reply
{
    _email.sendType = @(EmailSendTypeReply);
    [_router pushMailEditRouter:@{@"account" : _account, @"email" : _email,@"type" :@(EmailSendTypeReply)}];
}

- (void)replyAll
{
    _email.sendType = @(EmailSendTypeReplyAll);
    [_router pushMailEditRouter:@{@"account" : _account, @"email" : _email,@"type" :@(EmailSendTypeReplyAll)}];
    
}

- (void)transmit
{
    _email.sendType = @(EmailSendTypeTransmit);
    [_router pushMailEditRouter:@{@"account" : _account, @"email" : _email,@"type" :@(EmailSendTypeTransmit)}];

}

@end
