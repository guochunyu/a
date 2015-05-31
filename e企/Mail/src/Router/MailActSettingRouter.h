//
//  MailActSettingRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MailActSettingHandler;
@class MailActSettingController;

@class MailActAddRouter;

@interface MailActSettingRouter : NSObject

@property (nonatomic) MailActSettingHandler *handler;
@property (nonatomic) MailActSettingController *controller;

@property (nonatomic) MailActAddRouter *mailActAddRouter;



- (void)pushMailActSettingControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;

- (void)popController:(NSDictionary *)userInfo;

@end
