//
//  PhotoInPhoneRouter.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class PhotoInPhoneHandler;
@class PhotoInPhoneController;
@class PhotoAlbumsRouter;

@interface PhotoInPhoneRouter : NSObject

@property (nonatomic) PhotoInPhoneHandler *handler;
@property (nonatomic) PhotoInPhoneController *controller;

@property (nonatomic) PhotoAlbumsRouter *photoAlbumsRouter;


- (void)pushPhotoInPhoneControllerFromViewController:(UIViewController *)viewController userInfo:(NSDictionary *)userInfo;

- (void)dismissViewController:(NSDictionary *)userInfo;

@end
