//
//  MainTabRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MainTabRouter.h"
#import "MainTabHandler.h"
#import "MainTabController.h"
#import "MailBoardRouter.h"

@implementation MainTabRouter

- (void)setupRootView:(UIWindow *)window
{
    MainTabController *ctl = (MainTabController *)[window rootViewController];
    
    
   
    UINavigationController *mailActRoot = [_mailBoardRouter presentMailBoardRootController];
    
    NSArray *tabControllers = @[mailActRoot];
    
    NSArray *tabTexts = @[NSLocalizedString(@"tabbar.mail.act", nil)];
    
    NSArray *tabIcons = @[@"ic_tab_mail"];
    NSArray *tabIconsSelected = @[@"ic_tab_mail_s"];
    
    UIImage *icon = [[UIImage imageNamed:tabIcons[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *iconSelected = [[UIImage imageNamed:tabIconsSelected[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:tabTexts[0] image:icon selectedImage:iconSelected];
    
    UINavigationController *navi = (UINavigationController *)tabControllers[0];
    navi.tabBarItem = tabBarItem;

    ctl.viewControllers = tabControllers;
    
    ctl.handler = _handler;
    _handler.controller = ctl;
    _controller = ctl;

}

@end
