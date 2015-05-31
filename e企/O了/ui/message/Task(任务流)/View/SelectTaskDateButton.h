//
//  SelectTaskDateButton.h
//  e企
//
//  Created by zw on 15/3/5.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectTaskDateButtonDelegate <NSObject>

-(void)setTimeAction;

@end

@interface SelectTaskDateButton : UIView
{
    UIButton *timeButton;
    UILabel *timeLabel;
    UIImageView *timeImgView;
}
@property (nonatomic, strong) NSString *complete_state;
@property (nonatomic, strong) NSString *complete_time;
@property (nonatomic, assign) id<SelectTaskDateButtonDelegate> selectTaskDateButtonDelegate;

-(void)setComplete_state:(NSString *)complete_state
        andComplete_time:(NSString *)complete_time;
@end
