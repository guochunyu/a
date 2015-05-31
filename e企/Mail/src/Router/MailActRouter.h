//
//  MailActRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MailActHandler;
@class MailActController;

@class MailActAddRouter;
@class MailBoardRouter;


@interface MailActRouter : NSObject

@property (nonatomic) MailActHandler *handler;
@property (nonatomic) MailActController *controller;

@property (nonatomic) MailActAddRouter *mailActAddRouter;
@property (nonatomic) MailBoardRouter *mailBoardRouter;

@property(nonatomic,strong)UINavigationController *nc;

- (UINavigationController *)presentMailActRootController;
- (void)push:(UIViewController *)c;
- (void)pushMailActAddController:(NSDictionary *)userInfo;
- (void)pushMailBoardController:(NSDictionary *)userInfo;


@end
