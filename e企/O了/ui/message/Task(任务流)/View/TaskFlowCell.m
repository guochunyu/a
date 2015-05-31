//
//  TaskFlowCell.m
//  e企
//
//  Created by zw on 15/2/11.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskFlowCell.h"

@implementation TaskFlowCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.iconImageView = [[UIImageView alloc] init];
        self.iconImageView.backgroundColor = [UIColor brownColor];
        [self.contentView addSubview:self.iconImageView];
        
        self.unreadNumLabel = [[UILabel alloc] init];
        self.unreadNumLabel.backgroundColor = [UIColor clearColor];
        self.unreadNumLabel.textAlignment = NSTextAlignmentCenter;
        self.unreadNumLabel.textColor = [UIColor whiteColor];
        self.unreadNumLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.unreadNumLabel];
        
        self.titleTextLabel = [[UILabel alloc] init];
        self.titleTextLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.titleTextLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment=NSTextAlignmentRight;
        self.timeLabel.font=[UIFont systemFontOfSize:12];
        self.timeLabel.textColor=[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1];
        [self.contentView addSubview:self.timeLabel];
        
        self.lastContentLabel = [[UILabel alloc] init];
        self.lastContentLabel.backgroundColor = [UIColor clearColor];
        self.lastContentLabel.textColor=[UIColor grayColor];
        self.lastContentLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.lastContentLabel];
        
        [self.iconImageView setImage:[UIImage imageNamed:@""]];
        self.titleTextLabel.frame = CGRectMake(68, 10, 150, 25);
        self.titleTextLabel.font = [UIFont systemFontOfSize:15];
        self.lastContentLabel.frame = CGRectMake(67, 35, 250, 18);
        self.iconImageView.frame = CGRectMake(8,10,50,50);
        self.timeLabel.frame = CGRectMake(210, 10, 100, 25);
        
        self.timeLabel.textColor=[UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1];
        self.iconImageView.layer.cornerRadius = 25;
        self.iconImageView.clipsToBounds = YES;
        self.titleTextLabel.text = @"任务流";
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
