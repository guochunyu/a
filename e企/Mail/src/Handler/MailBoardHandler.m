//
//  MailBoardHandler.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailBoardHandler.h"
#import "EmailAccount.h"
#import "MailLogic.h"
#import <MailCore/MailCore.h>
#import "Email.h"
#import "MailBoardController.h"
#import "LogicHelper.h"
#import "MailBoardRouter.h"
#import "CoreDataManager.h"
#import "EmailAccount.h"

@interface MailBoardHandler ()

@property (nonatomic) EmailAccount *account;
@property (nonatomic) NSMutableArray *emails;
@property (nonatomic) NSMutableDictionary *emailInfosDict;
@property (nonatomic) EmailArchiveType type;
@property (nonatomic) NSUInteger index;
@property (nonatomic) NSUInteger size;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL hasDisappear;

@end


@implementation MailBoardHandler

- (void)initData
{
    _loading = true;
    _size = 10;
    _type = EmailArchiveTypeInbox;
    _account = _userInfo[@"account"];
    _index = 0;
    _emailInfosDict = [NSMutableDictionary new];
    NSArray *accounts = [EmailAccount listAccounts];
    [_controller setValue:accounts forKey:@"accounts"];
    [_controller setValue:_account forKey:@"account"];
    [_controller setValue:@[@"收件箱",@"星标箱",@"发件箱", @"草稿箱"] forKey:@"boxTitles"];
    [_controller setValue:@(EmailArchiveTypeInbox) forKey:@"type"];

  
}

- (void)hasDisappear:(BOOL)disappear
{
    _hasDisappear = disappear;
}

- (void)loadAccounts
{
    NSArray *accounts = [EmailAccount listAccounts];
    if (_account == nil || _account.username == nil) {
        if ([accounts count] > 0) {
            _account = accounts[0];
        }
    }
    [_controller setValue:_account forKey:@"account"];
    [_controller setValue:accounts forKey:@"accounts"];
    DDLogInfo(@"account user name=%@",_account.username);
}

- (NSArray *)loadCacheMails:(EmailArchiveType)type
{
    NSArray *mails = [Email listEmails:_account.username archiveType:type includeDeleted:NO searchStr:nil];
    if (type==EmailArchiveTypeInbox&&mails.count>10&&_controller.isFirstLoading) {
        _emails = [NSMutableArray arrayWithArray:[mails subarrayWithRange:NSMakeRange(0,10)]];
    }else{
     _emails = [NSMutableArray arrayWithArray:mails];
    }
    _index = _emails.count;
    return _emails;
}

- (void)syncMails
{
    BOOL static isSync;
    if (isSync) {
        return;
    }
    isSync = YES;
    [MailLogic checkAccount:_account completion:^(NSError *error) {
        isSync = NO;
        if (error != nil) {
            //[_controller refreshMails];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统提示" message:@"邮箱服务器认证失败，请检查用户名密码是否正确，并尝试重新登录" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            //[_controller autherFailed:_account];
            return;
        }
        
        
        
        NSArray *mails = [Email listEmails:_account.username archiveType:EmailArchiveTypeInbox includeDeleted:YES searchStr:nil];
        NetworkIndicatorVisible(YES);
        [MailLogic loadMessageInfos:_account completion:^(NSError *error, NSArray *messageInfos) {
            NetworkIndicatorVisible(NO);
            [_controller refreshMails];
            if (error != nil) {
                return;
            }
            DDLogInfo(@"syncMails邮件总数:%lu",(unsigned long)[messageInfos count]);
                       NSString *infoSortKey = @"index";
            _emailInfosDict[_account.username] = messageInfos;
            NSSortDescriptor *infoSort = [NSSortDescriptor sortDescriptorWithKey:infoSortKey ascending:NO];
            messageInfos = [messageInfos sortedArrayUsingDescriptors:@[infoSort]];
            int existIndex =  [_emails count];
            for (NSUInteger i = 0; i < [messageInfos count]; i++) {
                MCOPOPMessageInfo *info = messageInfos[i];
                Email *email = [Email findByUid:_account.username uid:info.uid];
                if (email != nil) {
                    existIndex = i;
                    break;
                }
            }
            for (NSUInteger i = 0; i < existIndex && i < messageInfos.count ; i++) {
                if ([EmailAccount findByAccount:_account.username] == nil) {
                    NetworkIndicatorVisible(NO);
                    break;
                }
                MCOPOPMessageInfo *info = messageInfos[i];
                NetworkIndicatorVisible(YES);
                [MailLogic loadMessageHeader:_account index:info.index completion:^(NSError *error, MCOMessageHeader *header) {
                    NetworkIndicatorVisible(NO);
                    if (error != nil) {
                        DDLogInfo(@"同步邮件Header失败:%@",[error localizedDescription]);
                        return;
                    }
                    NSString *infoSortKey = @"index";
                    NSSortDescriptor *infoSort = [NSSortDescriptor sortDescriptorWithKey:infoSortKey ascending:NO];
                    NSMutableArray *_emailInfos = [self getEmailInfos:_account.username];
                    _emailInfos = [NSMutableArray arrayWithArray:[_emailInfos sortedArrayUsingDescriptors:@[infoSort]]];
                    _emailInfosDict[_account.username] = _emailInfos;
                    _index ++;
                    
                    //                        if (![EmailAccount findByAccount:_account.username]) {
                    //                            return;
                    //                        }
                    Email *email = [Email create:_account];
                    email.uid = info.uid;
                    email.index = @(info.index);
                    email.archiveType = @(EmailArchiveTypeInbox);
                    [email convertFromMCOIMAPMessageHeader:header];
                    if (_type != EmailArchiveTypeInbox) {
                        return;
                    }
                    if (![email.account.username isEqualToString:_account.username]) {
                        return;
                    }
                    [_emails addObject:email];
                    NSString *sortKey = @"date";
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO];
                    NSArray *temp = [_emails sortedArrayUsingDescriptors:@[sort]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_controller setValue:[NSMutableArray arrayWithArray:temp] forKey:@"emails"];
                        [_controller refreshMails];
                    });
                    DDLogInfo(@"%@",email.date);
                    [self getEmailBody:info.index email:email header:header];
                    [[CoreDataManager sharedInstance] save];
                }];
            }
        }];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.account decreate];
    [_controller viewWillAppear:YES];
}

- (void)loadMore
{
    NSArray *mails = [Email listEmails:_account.username archiveType:EmailArchiveTypeInbox includeDeleted:NO searchStr:nil];
    if (mails.count>_index) {
        [_controller setValue:[NSMutableArray arrayWithArray:mails] forKey:@"emails"];
        _emails=[NSMutableArray arrayWithArray:mails];
        _index=mails.count;
        [_controller refreshMails];
        [_controller loadNoData];
        [_controller hiddenLoadMore:NO];
        return;
    }
    
    [MailLogic sendNoop:_account completion:^(NSError *error) {
        NSMutableArray *_emailInfos = [self getEmailInfos:_account.username];
        if (_emailInfos == nil || [_emailInfos count] == 0) {
            [MailLogic loadMessageInfos:_account completion:^(NSError *error, NSArray *messageInfos) {
                NetworkIndicatorVisible(NO);
                if (error != nil) {
                    return;
                }
                NSMutableArray *emailInfos = [NSMutableArray arrayWithArray:messageInfos];
                _emailInfosDict[_account.username] = emailInfos;
                [_controller loadNoData];
                [_controller hiddenLoadMore:NO];
                [self getMailWithCount:_size];
            }];
        }else{
            [_controller loadNoData];
            [_controller hiddenLoadMore:NO];
            [self getMailWithCount:_size];
        }
    }];
}

- (void)loadRemoteMails
{
    [MailLogic sendNoop:_account completion:^(NSError *error) {
        _emails = [NSMutableArray new];
        NetworkIndicatorVisible(YES);
        [MailLogic loadMessageInfos:_account completion:^(NSError *error, NSArray *messageInfos) {
            NetworkIndicatorVisible(NO);
            if (error != nil) {
                DDLogInfo(@"获取邮件失败:%@",[error localizedDescription]);
                [_controller setValue:[NSMutableArray arrayWithArray:@[]] forKey:@"emails"];
                [_controller refreshMails];
                return;
            }
            DDLogInfo(@"loadRemoteMails邮件总数:%lu",(unsigned long)[messageInfos count]);
            NSMutableArray *_emailInfos = [self getEmailInfos:_account.username];
            _emailInfos = [NSMutableArray arrayWithArray:messageInfos];
            
            NSString *sortKey = @"index";
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES];
            _emailInfos = [NSMutableArray arrayWithArray:[_emailInfos sortedArrayUsingDescriptors:@[sort]]];
            _emailInfosDict[_account.username] = _emailInfos;
            NSUInteger count = _size;
            if ([_emailInfos count] < _size) {
                count = [_emailInfos count];
            }
            [self getMailWithCount:count];
        }];

    }];
}

- (void)getMailWithCount:(NSUInteger)count
{
    NSMutableArray *_emailInfos = [self getEmailInfos:_account.username];
    NSInteger count1=_emailInfos.count - _emails.count<count?_emailInfos.count - _emails.count:count;
    NSInteger start = _emailInfos.count - _emails.count-1;
    _index += count1;
    if (_index >= _emailInfos.count) {
        [_controller hiddenLoadMore:YES];
    }
    for (NSInteger i = start; i > start - count1 && i >=0; i--) {
        // 检查account是否已登出
        if ([EmailAccount findByAccount:_account.username] == nil) {
            NetworkIndicatorVisible(NO);
            break;
        }
        
        
        MCOPOPMessageInfo *info = _emailInfos[i];
        Email *email = [Email findByUid:_account.username uid:info.uid];
        if (email != nil) {
            if (email.plainText == nil) {
                [self getEmailBody:info.index email:email header:nil];
            }
            continue;
        }
        [MailLogic loadMessageHeader:_account index:info.index completion:^(NSError *error, MCOMessageHeader *header) {
            if (error != nil) {
                DDLogInfo(@"获取邮件Header失败:%@",[error localizedDescription]);
                [_controller refreshMails];
                return;
            }
            DDLogInfo(@"index:%d",info.index);
            DDLogInfo(@"id:%@",header.messageID);
            DDLogInfo(@"标题:%@",header.subject);
            DDLogInfo(@"发件人名称:%@",header.from.displayName);
            DDLogInfo(@"发件人邮箱:%@",header.from.mailbox);
            if (header.to != nil && header.to.count > 0) {
                MCOAddress *adr = header.to[0];
                DDLogInfo(@"收件人邮箱:%@",adr.mailbox);
            }
            if (header.cc != nil && header.cc.count > 0) {
                MCOAddress *adr = header.cc[0];
                DDLogInfo(@"cc邮箱:%@",adr.mailbox);
            }
            DDLogInfo(@"发件人名称:%@",header);
            DDLogInfo(@"发件人邮箱:%@",header.from.mailbox);
            DDLogInfo(@"时间:%@",header.receivedDate);
//            if (![EmailAccount findByAccount:_account.username]) {
//                return;
//            }
            Email *email = [Email create:_account];
            email.uid = info.uid;
            email.index = @(info.index);
            email.archiveType = @(EmailArchiveTypeInbox);
            [email convertFromMCOIMAPMessageHeader:header];
            if (_type != EmailArchiveTypeInbox) {
                return;
            }
            if (![email.account.username isEqualToString:_account.username]) {
                return;
            }
            [_emails addObject:email];
            NSString *sortKey = @"date";
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO];
            NSArray *temp = [_emails sortedArrayUsingDescriptors:@[sort]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_controller setValue:[NSMutableArray arrayWithArray:temp] forKey:@"emails"];
                [_controller refreshMails];
            });
            [[CoreDataManager sharedInstance] save];
            [self getEmailBody:info.index email:email header:header];
        }];
    }
}

- (void)getEmailBody:(NSUInteger)index email:(Email *)email header:(MCOMessageHeader *)header
{
    NetworkIndicatorVisible(YES);
    [MailLogic loadMessageBody:_account index:index completion:^(NSError *error, MCOMessageParser *message) {
        NetworkIndicatorVisible(NO);
        if (error != nil) {
            DDLogInfo(@"获取邮件Body失败:%@",[error localizedDescription]);
            return;
        }
        [email convertFromMCOIMAPMessage:message];
        if (_type != EmailArchiveTypeInbox) {
            return;
        }
        if (![email.account.username isEqualToString:_account.username]) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [_controller refreshMailContent:email.uid content:email.plainText];
        });
        [[CoreDataManager sharedInstance] save];
    }];
}


- (void)deleteEmail:(Email *)email
{
    email.hasDeleted = @(YES);
    if ([email.archiveType integerValue]  == EmailArchiveTypeInbox) {
        return;
    }
    NetworkIndicatorVisible(YES);
    [MailLogic deleteMessage:_account messageIndex:[email.index unsignedIntegerValue] completion:^(NSError *error) {
        NetworkIndicatorVisible(NO);
    }];
}

- (void)showMailDetail:(Email *)email
{
    email.isRead = @(YES);
    [_router pushMailDetailController:@{@"email" : email, @"account" : _account}];
}

- (void)editMail:(Email *)email
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"account" : _account, @"type" :@(EmailSendTypeNew)}];
    if (email != nil) {
        dict[@"email"] = email;
    }
    [_router pushMailEditController:dict];
}

-(void)EditMail:(EmployeeModel*)model
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{@"account" : _account, @"type" :@(EmailSendTypeNew),@"model":model}];
   
    [_router pushMailEditController:dict];
}

- (void)changeBoxType:(EmailArchiveType)type
{
    _type = type;
}

- (void)changeAccount:(EmailAccount *)account
{
    _account = account;
}

- (void)resetIndex
{
    _index = 0;
}

- (NSMutableArray *)doSearch:(NSString *)search
{
    NSArray *mails = [Email listEmails:_account.username archiveType:_type includeDeleted:NO searchStr:search];
    _emails = [NSMutableArray arrayWithArray:mails];
    return _emails;
}

- (void)addMailAccount
{
    [_router pushMailActAddController:@{}];
}

- (NSMutableArray *)getEmailInfos:(NSString *)act
{
    NSMutableArray *infos = _emailInfosDict[act];
    if (infos == nil) {
        infos = [NSMutableArray new];
        _emailInfosDict[act] = infos;
    }
    return infos;
}

@end




















