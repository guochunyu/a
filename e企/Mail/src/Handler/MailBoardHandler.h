//
//  MailBoardHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MailBoardRouter;
@class MailBoardController;
@class Email;
#import "MailLogic.h"

@interface MailBoardHandler : NSObject

@property (nonatomic) MailBoardRouter *router;
@property (nonatomic) MailBoardController *controller;

@property (nonatomic) NSDictionary *userInfo;



- (void)initData;
- (void)loadAccounts;
- (NSArray *)loadCacheMails:(EmailArchiveType)type;
- (void)loadRemoteMails;
- (void)loadMore;
- (void)hasDisappear:(BOOL)disappear;
- (void)syncMails;
- (void)deleteEmail:(Email *)email;
- (void)showMailDetail:(Email *)email;
- (void)editMail:(Email *)email;
-(void)EditMail:(EmployeeModel*)model;
- (void)changeBoxType:(EmailArchiveType)type;
- (void)changeAccount:(EmailAccount *)account;
- (void)stopLoading;
- (NSMutableArray *)doSearch:(NSString *)search;
- (void)addMailAccount;

@end
