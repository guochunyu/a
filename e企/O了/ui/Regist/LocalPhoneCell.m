//
//  LocalPhoneCell.m
//  e企
//
//  Created by zw on 4/20/15.
//  Copyright (c) 2015 QYB. All rights reserved.
//

#import "LocalPhoneCell.h"

@implementation LocalPhoneCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        self.nameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.nameLabel];
        
        self.nameIconLabel = [[UILabel alloc] init];
        self.nameIconLabel.font = [UIFont systemFontOfSize:15];
        self.nameIconLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.nameIconLabel];
        
        self.phoneLabel = [[UILabel alloc] init];
        self.phoneLabel.textColor = [UIColor lightGrayColor];
        self.phoneLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.phoneLabel];
        
        self.iconImageView = [[UIImageView alloc] init];
        self.iconImageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.iconImageView];
        
        self.topLineView = [[UIView alloc] init];
        self.topLineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.topLineView];
        
        self.bottomLineView = [[UIView alloc] init];
        self.bottomLineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.bottomLineView];
    }
    return self;
}
@end
