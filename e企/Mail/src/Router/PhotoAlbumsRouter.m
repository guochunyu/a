//
//  PhotoAlbumsRouter.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoAlbumsRouter.h"
#import "PhotoAlbumsController.h"
#import "PhotoAlbumsHandler.h"
#import "PhotoInPhoneRouter.h"
#import "AppNotificationCenter.h"

static NSString * const kStoryboardName = @"Common";
static NSString * const kPhotoAlbumsControllerIdentifier = @"PhotoAlbumsController";
static NSString * const kPhotoAlbumsRootIdentifier = @"PhotoAlbumsRoot";

@interface PhotoAlbumsRouter () <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) id caller;

@end

@implementation PhotoAlbumsRouter

- (void)presentPhotoAlbumsControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    PhotoAlbumsController *ctl = [storyboard instantiateViewControllerWithIdentifier:kPhotoAlbumsControllerIdentifier];
    UINavigationController *rootNav = [storyboard instantiateViewControllerWithIdentifier:kPhotoAlbumsRootIdentifier];
    
//    rootNav.transitioningDelegate = self;
//    rootNav.navigationBar.barTintColor = [UIColor navigationBackgroundColor];
//    rootNav.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor navigationTitleColor] };
//    rootNav.navigationBar.tintColor = [UIColor navigationTitleColor];
    rootNav.viewControllers = @[ctl];
    
    ctl.handler = _handler;
    _handler.userInterface = ctl;
    _handler.userInfo = userInfo;
    _controller = ctl;
    [viewController presentViewController:rootNav animated:YES completion:nil];
    _caller = userInfo[@"caller"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    rootNav.navigationBar.titleTextAttributes = dict;
    
    rootNav.navigationBar.barTintColor = [UIColor colorWithRed:49.0/255 green:105.0/255 blue:245.0/255 alpha:1.0];
    
}

- (void)pushPhotoInPhoneController:(NSDictionary *)userInfo
{
    [_photoInPhoneRouter pushPhotoInPhoneControllerFromViewController:_controller userInfo:userInfo];
}

- (void)dismissController:(NSDictionary *)userInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    dic[@"caller"] = _caller;
    [AppNotificationCenter postNotification:AppNotificationTypePhotoAlbumSelectCompleted withUserInfo:dic];
    [_controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Transitioning Delegate
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    MNPresentDismissAnimation *animation = [MNPresentDismissAnimation new];
//    animation.animationType = MNControllerAnimationTypeSlideInFromBottom;
//    animation.duration = .2f;
//    return animation;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    MNPresentDismissAnimation *animation = [MNPresentDismissAnimation new];
//    animation.animationType = MNControllerAnimationTypeSlideOutToBottom;
//    animation.duration = .2f;
//    return animation;
//}

@end













