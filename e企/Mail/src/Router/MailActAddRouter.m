//
//  MailActAddRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActAddRouter.h"
#import "MailActAddHandler.h"
#import "MailActAddController.h"
#import "MailActSettingRouter.h"

static NSString * const kStoryboardName = @"Mail";
static NSString * const kMailActAddControllerIdentifier = @"MailActAddController";


@interface MailActAddRouter ()

@end


@implementation MailActAddRouter

- (void)pushMailActAddControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailActAddController *ctl = [sb instantiateViewControllerWithIdentifier:kMailActAddControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _controller = ctl;
    [viewController.navigationController pushViewController:ctl animated:YES];
}

- (void)pushMailActSettingController:(NSDictionary *)userInfo
{
    [_mailActSettingRouter pushMailActSettingControllerFromViewController:_controller userInfo:userInfo];
}

- (void)popController
{
    [_controller.navigationController popViewControllerAnimated:YES];
}

- (void)recvDataOnSettingCompleted:(NSDictionary *)userInfo
{
    _handler.userInfo = userInfo;
}

@end
