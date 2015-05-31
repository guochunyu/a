//
//  MainTabRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MainTabHandler;
@class MainTabController;

@class MailBoardRouter;

@interface MainTabRouter : NSObject

@property (nonatomic) MainTabHandler *handler;
@property (nonatomic) MainTabController *controller;

@property (nonatomic) MailBoardRouter *mailBoardRouter;

- (void)setupRootView:(UIWindow *)window;

@end
