//
//  MailDetailRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MailDetailHandler;
@class MailDetailController;

@class MailEditRouter;

@interface MailDetailRouter : NSObject

@property (nonatomic) MailDetailHandler *handler;
@property (nonatomic) MailDetailController *controller;

@property (nonatomic) MailEditRouter *mailEditRouter;

- (void)pushMailDetailControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;
- (void)pushMailEditRouter:(NSDictionary *)userInfo;
- (void)popController;


@end
