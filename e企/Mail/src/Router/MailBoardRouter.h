//
//  MailBoardRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MailBoardHandler;
@class MailBoardController;

@class MailDetailRouter;
@class MailEditRouter;
@class MailActAddRouter;

@interface MailBoardRouter : NSObject

@property (nonatomic) MailBoardHandler *handler;
@property (nonatomic) MailBoardController *controller;

@property (nonatomic) MailDetailRouter *mailDetailRouter;
@property (nonatomic) MailEditRouter *mailEditRouter;
@property (nonatomic) MailActAddRouter *mailActAddRouter;

- (UIViewController *)createMailBoardController;
- (UINavigationController *)presentMailBoardRootController;
- (void)pushMailBoardControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;

- (void)pushMailDetailController:(NSDictionary *)userInfo;
- (void)pushMailEditController:(NSDictionary *)userInfo;
- (void)pushMailActAddController:(NSDictionary *)userInfo;
- (void)popController;

@end
