//
//  HuiyiTimeInputView.m
//  e企
//
//  Created by a on 15/4/29.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "HuiyiTimeInputView.h"

@implementation HuiyiTimeInputView

static float labelHeight=50;

-(id)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        //self.backgroundColor=[UIColor greenColor];
        _datepicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0, labelHeight, frame.size.width, 216)];
        _datepicker.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
        _datepicker.datePickerMode=UIDatePickerModeDateAndTime;
        //_datepicker.timeZone=[NSTimeZone timeZoneWithName:@"GMT"];
         _formatter=[[NSDateFormatter alloc]init];
        _formatter.dateFormat=@"yyyy-MM-dd HH:mm";
        [_datepicker addTarget:self action:@selector(timeChange:) forControlEvents:UIControlEventValueChanged];
        //_datepicker.calendar=[NSCalendar currentCalendar];
        [self addSubview:_datepicker];
        
        _timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, labelHeight)];
        _timeLabel.backgroundColor=[UIColor lightGrayColor];
        _timeLabel.text=[_formatter stringFromDate:_datepicker.date];
        [self addSubview:_timeLabel];
        UIButton *b1=[UIButton buttonWithType:UIButtonTypeSystem];
        //b1.backgroundColor=[UIColor yellowColor];
        b1.frame=CGRectMake(30, _datepicker.frame.origin.y+_datepicker.frame.size.height, 50, 30);
        [b1 setTitle:@"取消" forState:UIControlStateNormal];
        [b1 addTarget:self action:@selector(b1) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b1];
        UIButton *b2=[UIButton buttonWithType:UIButtonTypeSystem];
        //b2.backgroundColor=[UIColor yellowColor];
        b2.frame=CGRectMake(self.frame.size.width-80, _datepicker.frame.origin.y+_datepicker.frame.size.height, 50, 30);
        [b2 setTitle:@"确定" forState:UIControlStateNormal];
        [b2 addTarget:self action:@selector(b2) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b2];
        
    }
    return self;
}

-(void)b1{
    if(self.quxiao){
        self.quxiao(self);
    }
}
-(void)b2{
    if (self.queding) {
        self.queding(self);
    }
}
-(NSString *)timeString{
    return [_formatter stringFromDate:_datepicker.date];
}

-(void)timeChange:(UIDatePicker*)picker{
    NSLog(@"%@",self.timeString);
    _timeLabel.text=self.timeString;
}
-(long long)timeLong
{
    return self.datepicker.date.timeIntervalSince1970*1000;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
