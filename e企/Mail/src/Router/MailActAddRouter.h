//
//  MailActAddRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MailActAddHandler;
@class MailActAddController;

@class MailActSettingRouter;

@interface MailActAddRouter : NSObject

@property (nonatomic) MailActAddHandler *handler;
@property (nonatomic) MailActAddController *controller;

@property (nonatomic) MailActSettingRouter *mailActSettingRouter;

- (void)pushMailActAddControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;

- (void)pushMailActSettingController:(NSDictionary *)userInfo;

- (void)popController;

- (void)recvDataOnSettingCompleted:(NSDictionary *)userInfo;

@end
