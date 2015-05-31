//
//  TaskListCell.m
//  e企
//
//  Created by huangxiao on 15/1/20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskListCell.h"


@implementation TaskListCell

- (void)awakeFromNib {
    // Initialization code
    self.contentLabel = [[MLEmojiLabel alloc] init];
    self.contentLabel.disableThreeCommon = YES;
    self.contentLabel.frame = CGRectMake(30, 40, 280, 18);
    self.contentLabel.textColor=[UIColor grayColor];
    self.contentLabel.font = [UIFont systemFontOfSize:12];
//    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:self.contentLabel];
    
    self.unreadLabel = [[UILabel alloc] init];
    self.unreadLabel.textAlignment = NSTextAlignmentCenter;
    self.unreadLabel.textColor = [UIColor whiteColor];
    self.unreadLabel.font = [UIFont systemFontOfSize:12];
    self.unreadLabel.backgroundColor = TaskRedColor;
    [self.contentView addSubview:self.unreadLabel];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.lineView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

