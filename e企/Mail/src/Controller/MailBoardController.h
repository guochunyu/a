//
//  MailBoardController.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

extern NSString*const notificationName;
extern NSString*const notificationEmail;
@import UIKit;

@class MailBoardHandler;
@class Email;
@class EmailAccount;

@interface MailBoardController : UITableViewController

@property (nonatomic) MailBoardHandler *handler;
@property (nonatomic) NSArray *accounts;
@property (nonatomic) BOOL isFirstLoading;//是否是第一次加载，当时第一次加载最多加载10条

@property (nonatomic ,strong)NSString *Email_Unread;
//- (void)Email_Unread_Notification_Methods;


- (void)refreshMails;

- (void)autherFailed:(EmailAccount *)account;

-(void)sendemail:(EmployeeModel*)model;
- (void)refreshMailContent:(NSString *)uid content:(NSString *)content;

- (void)hiddenLoadMore:(BOOL)hidden;
- (void)loadNoData;
- (void)checkAccountFailed;
- (void)loadMoreData;

- (void)enableTitleButton:(BOOL)enable;



@end
