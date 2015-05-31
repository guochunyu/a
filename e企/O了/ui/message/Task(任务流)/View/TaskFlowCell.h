//
//  TaskFlowCell.h
//  e企
//
//  Created by zw on 15/2/11.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskFlowCell : UITableViewCell
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *unreadNumLabel;
@property (strong, nonatomic) UILabel *titleTextLabel;
@property (strong, nonatomic) UILabel *lastContentLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@end
