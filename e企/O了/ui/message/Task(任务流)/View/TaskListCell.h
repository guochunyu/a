//
//  TaskListCell.h
//  e企
//
//  Created by huangxiao on 15/1/20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"
#import "TaskTools.h"

@interface TaskListCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *statusImgView;
@property (strong, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *completeImgView;
@property (strong, nonatomic) MLEmojiLabel *contentLabel;
@property (strong, nonatomic) UILabel *unreadLabel;
@property (strong, nonatomic) UIView *lineView;
@end
