//
//  MailActSettingHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MailActSettingRouter;
@class MailActSettingController;

@interface MailActSettingHandler : NSObject

@property (nonatomic) MailActSettingRouter *router;
@property (nonatomic) MailActSettingController *controller;

@property (nonatomic) NSDictionary *userInfo;

- (void)initData;

- (void)settingCompleted:(NSString *)serverHost port:(NSString *)serverPort;

@end
