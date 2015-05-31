//
//  MailActAddController.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/9.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
@class MailActAddHandler;
@class EmailAccount;

@interface MailActAddController : UITableViewController

@property (nonatomic) MailActAddHandler *handler;
@property (nonatomic) BOOL authFailed;
@property (nonatomic) EmailAccount *authAccount;

- (void)authSuccess;
- (void)alertMessage:(NSString *)msg;
- (void)enableUIForNetworking:(BOOL)enable;

@end
