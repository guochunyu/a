//
//  SelectTaskDateButton.m
//  e企
//
//  Created by zw on 15/3/5.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "SelectTaskDateButton.h"
#import "TaskDetailCell.h"
#import "UIViewExt.h"

@implementation SelectTaskDateButton


-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        timeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 9, 13)];
        timeImgView.image = [UIImage imageNamed:@"task_content_ending"];
        timeImgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:timeImgView];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.font = [UIFont systemFontOfSize:11];
        timeLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:timeLabel];
        
        timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        timeButton.titleLabel.font = [UIFont systemFontOfSize:11];
        timeButton.titleLabel.textColor = [UIColor lightGrayColor];
        [timeButton addTarget:self action:@selector(setTimeActionClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:timeButton];
    }
    return self;
}

-(void)setTimeActionClicked
{
    if ([self.selectTaskDateButtonDelegate respondsToSelector:@selector(setTimeAction)])
    {
        [self.selectTaskDateButtonDelegate setTimeAction];
    }
}

-(void)setComplete_state:(NSString *)complete_state
        andComplete_time:(NSString *)complete_time
{
    
    self.complete_state = complete_state;
    self.complete_time = complete_time;
    NSString *str = @"";
    if ([complete_state intValue] == 1) {
        timeLabel.text = @"任务已归档";
        str = @"";
    }else {
        if ([complete_time intValue] == 0) {
            timeLabel.text = nil;
            str = @"设定任务截止时间";
        }else {
            timeLabel.text = @"任务截止于";
            long long int dateTime = 0;
            if ([complete_time length] > 10)
            {
                dateTime =[complete_time longLongValue]/1000;
            }
            else
            {
                dateTime = [complete_time longLongValue];
            }
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/ddhhmmss"];
            NSString *destDateString = [dateFormatter stringFromDate:time];
            str = [destDateString substringToIndex:10];
        }
    }
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:11]};
    CGSize size = [timeLabel.text boundingRectWithSize:CGSizeMake(KScreenWidth-100, 40) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    timeLabel.frame = CGRectMake(timeImgView.right+5, timeImgView.top, size.width, 18);
    NSMutableAttributedString *buttonTitle = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange strRange = {0,[buttonTitle length]};
    [buttonTitle addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [timeButton setAttributedTitle:buttonTitle forState:UIControlStateNormal];
    
    CGSize size2 = [str boundingRectWithSize:CGSizeMake(KScreenWidth-100, 40) options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    timeButton.frame = CGRectMake(timeLabel.right+5, timeImgView.top, size2.width, 18);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
