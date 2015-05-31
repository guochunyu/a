//
//  MailActHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MailActRouter;
@class MailActController;
@class EmailAccount;

@interface MailActHandler : NSObject

@property (nonatomic) MailActRouter *router;
@property (nonatomic) MailActController *controller;

@property (nonatomic) NSDictionary *userInfo;

- (void)initData;
- (NSArray *)findMailAccounts;
- (void)addMailAccount;

- (void)showMailBoard:(EmailAccount *)account;
- (void)deleteAccount:(EmailAccount *)account;

@end
