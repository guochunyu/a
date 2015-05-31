//
//  MailDetailController.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
@class MailDetailHandler;

@interface MailDetailController : UIViewController

@property (nonatomic) MailDetailHandler *handler;
@property(nonatomic,strong)UILabel * jiezhi;
@property(nonatomic,strong)UIView * fujian;
@property(nonatomic,strong)UIImageView * imageV;
@property(nonatomic,strong)UIActionSheet *actionSheet;
@property(nonatomic,strong)UIAlertView *alert;
- (void)refreshViewFromEmailContent:(NSString *)content;

@end
