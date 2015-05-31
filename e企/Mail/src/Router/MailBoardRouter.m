//
//  MailBoardRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailBoardRouter.h"
#import "MailBoardHandler.h"
#import "MailBoardController.h"
#import "MailDetailRouter.h"
#import "MailEditRouter.h"
#import "MailActAddRouter.h"

static NSString * const kStoryboardName = @"Mail";
static NSString * const kMailBoardControllerIdentifier = @"MailBoardController";
static NSString * const kMailActRootIdentifier = @"MailActRoot";

@implementation MailBoardRouter

- (UIViewController *)createMailBoardController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailBoardController *ctl = [sb instantiateViewControllerWithIdentifier:kMailBoardControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _controller = ctl;
    return ctl;
}

- (UINavigationController *)presentMailBoardRootController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailBoardController *ctl = [sb instantiateViewControllerWithIdentifier:kMailBoardControllerIdentifier];
    UINavigationController *rootNav = [sb instantiateViewControllerWithIdentifier:kMailActRootIdentifier];
    rootNav.viewControllers = @[ctl];
    
    ctl.handler = _handler;
    _handler.controller = ctl;
    _controller = ctl;
    return rootNav;
}

- (void)pushMailBoardControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailBoardController *ctl = [sb instantiateViewControllerWithIdentifier:kMailBoardControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _handler.userInfo = userInfo;
    _controller = ctl;
    [viewController.navigationController pushViewController:ctl animated:YES];
}

- (void)pushMailDetailController:(NSDictionary *)userInfo
{
    [_mailDetailRouter pushMailDetailControllerFromViewController:_controller userInfo:userInfo];
}

- (void)popController
{
    [_controller.navigationController popViewControllerAnimated:YES];
}

- (void)pushMailEditController:(NSDictionary *)userInfo
{
    [_mailEditRouter pushMailEditControllerFromViewController:_controller userInfo:userInfo];
}

- (void)pushMailActAddController:(NSDictionary *)userInfo
{
    [_mailActAddRouter pushMailActAddControllerFromViewController:_controller userInfo:userInfo];
}

@end
