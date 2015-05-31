//
//  MailActRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActRouter.h"
#import "MailActController.h"
#import "MailActHandler.h"
#import "MailActAddRouter.h"
#import "MailBoardRouter.h"


static NSString * const kStoryboardName = @"Mail";
static NSString * const kMailActControllerIdentifier = @"MailActController";
static NSString * const kMailActRootIdentifier = @"MailActRoot";

@interface MailActRouter ()

@end

@implementation MailActRouter

- (UINavigationController *)presentMailActRootController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailActController *ctl = [sb instantiateViewControllerWithIdentifier:kMailActControllerIdentifier];
    UINavigationController *rootNav = [sb instantiateViewControllerWithIdentifier:kMailActRootIdentifier];
    rootNav.viewControllers = @[ctl];
    
    ctl.handler = _handler;
    _handler.controller = ctl;
    _controller = ctl;
    return rootNav;
}

- (void)push:(UIViewController *)c
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailActController *ctl = [sb instantiateViewControllerWithIdentifier:kMailActControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _controller = ctl;
    //[c.navigationController pushViewController:ctl animated:YES];
    
    
    _nc=[[UINavigationController alloc]initWithRootViewController:ctl];
    //更多选项中邮箱设置去除动画效果
    [c presentViewController:_nc animated:NO completion:nil];
    //导航控制器背景颜色
    _nc.navigationBar.barTintColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
    //字体颜色
    _nc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
}



- (void)pushMailBoardController:(NSDictionary *)userInfo
{
    [_mailBoardRouter pushMailBoardControllerFromViewController:_controller userInfo:userInfo];
}

- (void)pushMailActAddController:(NSDictionary *)userInfo
{
    [_mailActAddRouter pushMailActAddControllerFromViewController:_controller userInfo:userInfo];
}



@end
