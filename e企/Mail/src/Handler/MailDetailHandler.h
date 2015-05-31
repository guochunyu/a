//
//  MailDetailHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MailDetailRouter;
@class MailDetailController;


@interface MailDetailHandler : NSObject

@property (nonatomic) MailDetailRouter *router;
@property (nonatomic) MailDetailController *controller;

@property (nonatomic) NSDictionary *userInfo;

- (void)initData;

- (void)loadEmailHtmlText;

- (void)saveFavorite;

- (void)deleteMail;

- (void)reply;

- (void)replyAll;

- (void)transmit;

@end
