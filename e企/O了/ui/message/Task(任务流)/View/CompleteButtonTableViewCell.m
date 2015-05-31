//
//  CompleteButtonTableViewCell.m
//  e企
//
//  Created by zw on 15/3/24.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "CompleteButtonTableViewCell.h"

@implementation CompleteButtonTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.completeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.completeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.completeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        self.completeButton.backgroundColor = [UIColor colorWithRed:64 green:138 blue:244 alpha:1];
        self.completeButton.frame = self.bounds;
        [self.contentView addSubview:self.completeButton];
        
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
