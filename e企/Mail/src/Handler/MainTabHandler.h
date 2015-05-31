//
//  MainTabHandler.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class MainTabRouter;
@class MainTabController;

@interface MainTabHandler : NSObject

@property (nonatomic) MainTabRouter *router;
@property (nonatomic) MainTabController *controller;

@property (nonatomic) NSDictionary *userInfo;

@end
