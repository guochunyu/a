//
//  HuiyiTimeInputView.h
//  e企
//
//  Created by a on 15/4/29.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HuiyiTimeInputView : UIView
@property(nonatomic,strong) UIDatePicker *datepicker;
@property(nonatomic,strong) UILabel *timeLabel;
@property(nonatomic,strong) NSDateFormatter *formatter;
@property(nonatomic,copy,readonly) NSString *timeString;
@property(nonatomic,assign,readonly) long long timeLong;
@property(nonatomic,copy) void(^quxiao)(HuiyiTimeInputView*);//点击取消block回调方法
@property(nonatomic,copy) void(^queding)(HuiyiTimeInputView*);//点击确定block回调方法
@end
