//
//  MailBoardCell.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailLogic.h"
@import UIKit;
@class Email;

@interface MailBoardCell : UITableViewCell

@property (nonatomic) Email *email;

- (void)configureWithEmail:(Email *)email batch:(BOOL)btach andType:(EmailArchiveType)type;
- (void)batchTag:(BOOL)tag;

- (void)configureWithEmailContent:(NSString *)content;

@end
