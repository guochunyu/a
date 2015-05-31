//
//  MailEditRouter.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailEditRouter.h"
#import "MailEditController.h"
#import "MailEditHandler.h"
#import "PhotoAlbumsRouter.h"

static NSString * const kStoryboardName = @"Mail";
static NSString * const kMailEditControllerIdentifier = @"MailEditController";

@interface MailEditRouter ()

@end

@implementation MailEditRouter

- (void)pushMailEditControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    MailEditController *ctl = [sb instantiateViewControllerWithIdentifier:kMailEditControllerIdentifier];
    ctl.handler = _handler;
    _handler.controller = ctl;
    _handler.userInfo = userInfo;
    _controller = ctl;
    [viewController.navigationController pushViewController:ctl animated:YES];
    if ([userInfo objectForKey:@"model"]) {//从通信录发送邮件
        EmployeeModel *model=[userInfo objectForKey:@"model"];
        [ctl contactSelected:AddScrollTypeRecv member:@[model]];
        NSLog(@"%@",model.email);
    }
    
}

- (void)presentPhotoAlbumsController:(NSDictionary *)userInfo
{
    [_photoAlbumsRouter presentPhotoAlbumsControllerFromViewController:_controller userInfo:userInfo];
}

- (void)dismissController
{
    [_controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)popViewController
{
    
    [_controller.navigationController popViewControllerAnimated:YES];
}



@end
