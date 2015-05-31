//
//  PhotoInPhoneRouter.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoInPhoneRouter.h"
#import "PhotoInPhoneController.h"
#import "PhotoInPhoneHandler.h"
#import "PhotoAlbumsRouter.h"

static NSString * const kStoryboardName = @"Common";
static NSString * const kPhotoInPhoneControllerIdentifier = @"PhotoInPhoneController";

@interface PhotoInPhoneRouter ()

@end

@implementation PhotoInPhoneRouter

- (void)pushPhotoInPhoneControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    PhotoInPhoneController *ctl = [[UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]]instantiateViewControllerWithIdentifier:kPhotoInPhoneControllerIdentifier];
    ctl.handler = _handler;
    _handler.userInterface = ctl;
    _handler.userInfo = userInfo;
    _controller = ctl;
    [viewController.navigationController pushViewController:ctl animated:YES];
}

- (void)dismissViewController:(NSDictionary *)userInfo
{
    [_photoAlbumsRouter dismissController:userInfo];
}

@end
