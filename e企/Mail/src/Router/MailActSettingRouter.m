//
//  MailActSettingRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActSettingRouter.h"
#import "MailActSettingHandler.h"
#import "MailActSettingController.h"
#import "MailActAddRouter.h"


static NSString * const kStoryboardName = @"Mail";
static NSString * const kMailActSettingControllerIdentifier = @"MailActSettingController";


@implementation MailActSettingRouter

- (void)pushMailActSettingControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailActSettingController *ctl = [sb instantiateViewControllerWithIdentifier:kMailActSettingControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _handler.userInfo = userInfo;
    _controller = ctl;
    [viewController.navigationController pushViewController:ctl animated:YES];
}

- (void)popController:(NSDictionary *)userInfo
{
    [_mailActAddRouter recvDataOnSettingCompleted:userInfo];
    [_controller.navigationController popViewControllerAnimated:YES];
}

@end
