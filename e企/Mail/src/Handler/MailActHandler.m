//
//  MailActHandler.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActHandler.h"
#import "MailActRouter.h"
#import "EmailAccount.h"
#import "Email.h"
#import "MailActController.h"
#import "CoreDataManager.h"

@implementation MailActHandler

- (void)initData
{
    //BOOL fromMore = [_userInfo[@"fromMore"] boolValue];
    //[_controller setValue:@(fromMore) forKey:_userInfo[@"fromMore"]];
}

- (NSArray *)findMailAccounts
{
    NSArray *acts = [EmailAccount listAccounts];
    return acts;
}

- (void)addMailAccount
{
    [_router pushMailActAddController:@{}];
}

- (void)showMailBoard:(EmailAccount *)account
{
    [_router pushMailBoardController:@{@"account" : account}];
}

- (void)deleteAccount:(EmailAccount *)account
{
    NSArray *emails = [Email listEmails:account.username];
    for (Email *e in emails) {
        [e decreate];
    }
    [account decreate];
    [[CoreDataManager sharedInstance] save];
}

@end
