//
//  DatePickerView.h
//  e企
//
//  Created by zw on 15/3/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerDelegate <NSObject>

-(void)dateCancel;
-(void)dateDone:(NSString *)selectDate;

@end

@interface DatePickerView : UIView
{
    UINavigationBar *buttonBar;
    UIButton *cancelButton;
    UIButton *doneButton;
}
@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, assign) id<DatePickerDelegate> datePickerDelegate;
@end
