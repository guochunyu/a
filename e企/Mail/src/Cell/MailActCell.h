//
//  MailActCell.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import UIKit;
@class EmailAccount;

@interface MailActCell : UITableViewCell

- (void)configureWithEmailAccount:(EmailAccount *)account;

@end
