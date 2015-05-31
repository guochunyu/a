//
//  PhotoAlbumsRouter.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class PhotoAlbumsHandler;
@class PhotoAlbumsController;
@class PhotoInPhoneRouter;


@interface PhotoAlbumsRouter : NSObject

@property (nonatomic) PhotoAlbumsHandler *handler;
@property (nonatomic) PhotoAlbumsController *controller;

@property (nonatomic) PhotoInPhoneRouter *photoInPhoneRouter;

- (void)presentPhotoAlbumsControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;
- (void)pushPhotoInPhoneController:(NSDictionary *)userInfo;

- (void)dismissController:(NSDictionary *)userInfo;

@end
