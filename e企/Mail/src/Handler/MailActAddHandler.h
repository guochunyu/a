//
//  MailActAddHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MailActAddRouter;
@class MailActAddController;


@interface MailActAddHandler : NSObject

@property (nonatomic) MailActAddRouter *router;
@property (nonatomic) MailActAddController *controller;

@property (nonatomic) NSDictionary *userInfo;

- (void)initData;
- (void)mailLogin:(NSString *)email password:(NSString *)password;
- (void)mailVerify:(NSString *)email password:(NSString *)password;
- (void)mailSetting;

@end
