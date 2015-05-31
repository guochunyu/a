//
//  DatePickerView.m
//  e企
//
//  Created by zw on 15/3/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "DatePickerView.h"
#import "TaskTools.h"

@implementation DatePickerView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        self.backgroundColor = [UIColor redColor];
        buttonBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        buttonBar.backgroundColor = [UIColor greenColor];
        [self addSubview:buttonBar];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        cancelButton.frame = CGRectMake(10, 5, 50, 40);
        [buttonBar addSubview:cancelButton];
        
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        doneButton.frame = CGRectMake(frame.size.width-60, 5, 50, 40);
        [buttonBar addSubview:doneButton];
        
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 50, frame.size.width, frame.size.height-50)];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.backgroundColor = [UIColor whiteColor];
        [self addSubview:_datePicker];
    }
    return self;
}

-(void)done
{
    NSDate *selectDate = [_datePicker date];
    long long selectInterval = [selectDate timeIntervalSince1970];
    NSDate *nowDate = [NSDate date];
    NSTimeInterval nowInterval = [nowDate timeIntervalSince1970];
    if ((long long)selectInterval/SECPERDAY < (long long)nowInterval/SECPERDAY)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"任务截止时间早于当前时间" isCue:1 delayTime:1 isKeyShow:NO];
        return ;
    }
    long long selectTime = selectInterval-selectInterval%SECPERDAY-8*HOUR+SECPERDAY-1;
    
    if ([self.datePickerDelegate respondsToSelector:@selector(dateDone:)])
    {
        [self.datePickerDelegate dateDone:[NSString stringWithFormat:@"%lld",selectTime*1000]];
    }
}

-(void)cancel
{
    if ([self.datePickerDelegate respondsToSelector:@selector(dateCancel)])
    {
        [self.datePickerDelegate dateCancel];
    }

}

/*
 -(void)dateDone
 {
 [UIView animateWithDuration:0.2 animations:^{
 dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
 NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
 [formatter setDateFormat:@"YYYY年MM月dd日"];
 birth = [formatter stringFromDate:datePicker.date];
 [personInfoTableView reloadData];
 }];
 }
 -(void)dateCancel
 {
 [UIView animateWithDuration:0.2 animations:^{
 dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
 }];
 }
 */


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
