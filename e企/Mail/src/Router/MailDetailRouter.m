//
//  MailDetailRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailDetailRouter.h"
#import "MailDetailHandler.h"
#import "MailDetailController.h"
#import "MailEditRouter.h"

static NSString * const kStoryboardName = @"Mail";
static NSString * const kMailBoardControllerIdentifier = @"MailDetailController";

@implementation MailDetailRouter

- (void)pushMailDetailControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailDetailController *ctl = [sb instantiateViewControllerWithIdentifier:kMailBoardControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _handler.userInfo = userInfo;
    _controller = ctl;
    [viewController.navigationController pushViewController:ctl animated:YES];
}

- (void)pushMailEditRouter:(NSDictionary *)userInfo
{
    [_mailEditRouter pushMailEditControllerFromViewController:_controller userInfo:userInfo];
}

- (void)popController
{
    [_controller.navigationController popViewControllerAnimated:YES];
}

@end
