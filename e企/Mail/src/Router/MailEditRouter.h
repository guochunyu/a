//
//  MailEditRouter.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class MailEditHandler;
@class MailEditController;
@class PhotoAlbumsRouter;

@interface MailEditRouter : NSObject

@property (nonatomic) MailEditHandler *handler;
@property (nonatomic) MailEditController *controller;


@property (nonatomic) PhotoAlbumsRouter *photoAlbumsRouter;


- (void)pushMailEditControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;
- (void)presentPhotoAlbumsController:(NSDictionary *)userInfo;
- (void)dismissController;
- (void)popViewController;

@end
