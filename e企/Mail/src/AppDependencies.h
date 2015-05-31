//
//  AppDependencies.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MailActRouter;

/**
 *  @class AppDependencies
 *  @brief 依赖注入
 */
@interface AppDependencies : NSObject

- (void)installRootView:(UIWindow *)window;

- (UIViewController *)createRootView;
- (MailActRouter *)actRouter;

@end
