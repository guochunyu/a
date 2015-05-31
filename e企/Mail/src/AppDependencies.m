//
//  AppDependencies.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AppDependencies.h"
#import "MainTabRouter.h"

#import "MainTabRouter.h"
#import "MainTabHandler.h"

#import "MailActRouter.h"
#import "MailActHandler.h"

#import "MailActAddRouter.h"
#import "MailActAddHandler.h"

#import "MailActSettingRouter.h"
#import "MailActSettingHandler.h"

#import "MailBoardRouter.h"
#import "MailBoardHandler.h"

#import "MailDetailRouter.h"
#import "MailDetailHandler.h"

#import "MailEditRouter.h"
#import "MailEditHandler.h"

#import "PhotoAlbumsRouter.h"
#import "PhotoAlbumsHandler.h"
#import "PhotoAlbumsInteractor.h"

#import "PhotoInPhoneRouter.h"
#import "PhotoInPhoneHandler.h"
#import "PhotoInPhoneInteractor.h"

@interface AppDependencies ()

@property (nonatomic) MainTabRouter *mainTabRouter;
@property (nonatomic) UIViewController *rootCtl;
@property (nonatomic) MailActRouter *mailActRouter;

@end

@implementation AppDependencies

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self configureDependencies];
    }
    return self;
}

- (void)installRootView:(UIWindow *)window
{
    [_mainTabRouter setupRootView:window];
}

- (UIViewController *)createRootView
{
    return _rootCtl;
}

/**
 *  IoC
 */
- (void)configureDependencies
{
    MainTabRouter *mainTabRouter = [MainTabRouter new];
    MainTabHandler *mainTabHandler = [MainTabHandler new];
    mainTabRouter.handler = mainTabHandler;
    mainTabHandler.router = mainTabRouter;
    
    MailActRouter *mailActRouter = [MailActRouter new];
    MailActHandler *mailActHandler = [MailActHandler new];
    mailActRouter.handler = mailActHandler;
    mailActHandler.router = mailActRouter;
    
    
    MailActAddRouter *mailActAddRouter = [MailActAddRouter new];
    MailActAddHandler *mailActAddHandler = [MailActAddHandler new];
    mailActAddRouter.handler = mailActAddHandler;
    mailActAddHandler.router = mailActAddRouter;
    mailActRouter.mailActAddRouter = mailActAddRouter;
    
    MailActSettingRouter *mailActSettingRouter = [MailActSettingRouter new];
    MailActSettingHandler *mailActSettingHandler = [MailActSettingHandler new];
    mailActSettingRouter.handler = mailActSettingHandler;
    mailActSettingHandler.router = mailActSettingRouter;
    mailActAddRouter.mailActSettingRouter = mailActSettingRouter;
    mailActSettingRouter.mailActAddRouter = mailActAddRouter;
    
    MailBoardRouter *mailBoardRouter = [MailBoardRouter new];
    MailBoardHandler *mailBoardHandler = [MailBoardHandler new];
    mailBoardRouter.handler = mailBoardHandler;
    mailBoardHandler.router = mailBoardRouter;
    mailActRouter.mailBoardRouter = mailBoardRouter;
    mainTabRouter.mailBoardRouter = mailBoardRouter;
    mailBoardRouter.mailActAddRouter = mailActAddRouter;
    
    MailDetailRouter *mailDetailRouter = [MailDetailRouter new];
    MailDetailHandler *mailDetailHandler = [MailDetailHandler new];
    mailDetailRouter.handler = mailDetailHandler;
    mailDetailHandler.router = mailDetailRouter;
    mailBoardRouter.mailDetailRouter = mailDetailRouter;
    
    MailEditRouter *mailEditRouter = [MailEditRouter new];
    MailEditHandler *mailEditHandler = [MailEditHandler new];
    mailEditRouter.handler = mailEditHandler;
    mailEditHandler.router = mailEditRouter;
    mailBoardRouter.mailEditRouter = mailEditRouter;
    mailDetailRouter.mailEditRouter = mailEditRouter;
    
    PhotoAlbumsRouter *photoAlbumsRouter = [PhotoAlbumsRouter new];
    PhotoAlbumsHandler *photoAlbumsHandler = [PhotoAlbumsHandler new];
    PhotoAlbumsInteractor *photoAlbumsInteractor = [PhotoAlbumsInteractor new];
    photoAlbumsRouter.handler = photoAlbumsHandler;
    photoAlbumsHandler.router = photoAlbumsRouter;
    photoAlbumsHandler.interactor = photoAlbumsInteractor;
    photoAlbumsInteractor.handler = photoAlbumsHandler;
    
    PhotoInPhoneRouter *photoInPhoneRouter = [PhotoInPhoneRouter new];
    PhotoInPhoneHandler *photoInPhoneHandler = [PhotoInPhoneHandler new];
    PhotoInPhoneInteractor *photoInPhoneInteractor = [PhotoInPhoneInteractor new];
    photoInPhoneRouter.handler = photoInPhoneHandler;
    photoInPhoneHandler.router = photoInPhoneRouter;
    photoInPhoneHandler.interactor = photoInPhoneInteractor;
    photoInPhoneInteractor.handler = photoInPhoneHandler;
    photoAlbumsRouter.photoInPhoneRouter = photoInPhoneRouter;
    photoInPhoneRouter.photoAlbumsRouter = photoAlbumsRouter;
    mailEditRouter.photoAlbumsRouter = photoAlbumsRouter;
    
    _mainTabRouter = mainTabRouter;
    _rootCtl = [mailBoardRouter createMailBoardController];
    _mailActRouter = mailActRouter;
}

- (MailActRouter *)actRouter
{
    return _mailActRouter;
}

@end











