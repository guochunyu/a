//
//  MailActCell.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActCell.h"
#import "EmailAccount.h"

@interface MailActCell ()

@property (weak, nonatomic) IBOutlet UILabel *iActLabel;

@end


@implementation MailActCell

- (void)configureWithEmailAccount:(EmailAccount *)account
{
    _iActLabel.text = account.username;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
