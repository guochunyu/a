//
//  MailEditHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MailEditRouter;
@class MailEditController;
@class EmailAccount;

@interface MailEditHandler : NSObject

@property (nonatomic) MailEditRouter *router;
@property (nonatomic) MailEditController *controller;

@property (nonatomic) NSDictionary *userInfo;

- (void)initData;

- (void)cancel:(BOOL)recv;

- (void)sendWithSubject:(NSString *)subject body:(NSString *)body to:(NSArray *)to cc:(NSArray *)cc files:(NSArray *)files;

- (void)selectPhotos;
- (void)changeAccount:(EmailAccount *)account;

@end
