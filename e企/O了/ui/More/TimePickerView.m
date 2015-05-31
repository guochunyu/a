//
//  TimePickerView.m
//  e企
//
//  Created by HC_hmc on 14/12/31.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "TimePickerView.h"

@implementation TimePickerView{
        UIView *_view;
}
@synthesize timepicker;
@synthesize sourcetype;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame sourcetype:(int)type;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       self.backgroundColor=[[UIColor alloc]initWithRed:0 green:0 blue:0 alpha:0.3];
        UIView *bcview=[[UIView alloc]initWithFrame:CGRectMake(10, frame.size.height/2-100, frame.size.width-20, 200)];
        bcview.backgroundColor=[UIColor whiteColor];
        [self addSubview:bcview];
        sourcetype=type;
        DDLogInfo(@"大小 %@  %@ %d",NSStringFromCGRect(frame),NSStringFromCGRect( [ UIScreen mainScreen ].bounds),sourcetype);
        UIButton *submitbtn=[[UIButton alloc]initWithFrame:CGRectMake(90, frame.size.height/2-100+150, 140, 44)];
        [submitbtn addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchDown];
        submitbtn.backgroundColor=[UIColor clearColor];
        [submitbtn setTitle:@"确认设定" forState:UIControlStateNormal];
        [submitbtn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        [self addSubview:submitbtn];
        //    submitbtn.backgroundColor=[UIColor redColor];
        int time;
        if(sourcetype==0){
            time=[[NSUserDefaults standardUserDefaults] integerForKey:NO_DISTURB_STARTTIME];
        }else{
            time=[[NSUserDefaults standardUserDefaults] integerForKey:NO_DISTURB_ENDTIME];
        }
        timepicker = [[UIPickerView alloc] initWithFrame:CGRectMake(80, frame.size.height/2-100, 160, 120)];
        timepicker.autoresizingMask = UIViewAutoresizingNone;
        timepicker.dataSource = self;
        timepicker.delegate = self;
        timepicker.showsSelectionIndicator = YES;
        [timepicker selectRow:(time/60) inComponent:0 animated:NO];
        [timepicker selectRow:(time%60) inComponent:1 animated:NO];
        [self addSubview:timepicker];
        
      
        UITapGestureRecognizer *panRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quxiao)];
        [self addGestureRecognizer:panRecognizer];
        panRecognizer.numberOfTapsRequired = 1;
        panRecognizer.delegate =self;

    }
    return self;
}
-(void)quxiao{
        [self removeFromSuperview];
}
-(void)showdown{
    [self removeFromSuperview];
    [_delegate reload];
}
-(void)show{
    [[[UIApplication sharedApplication].delegate window]addSubview:self];
}
-(void)submit:(id)sender{
    int  time;
    
    time=[timepicker selectedRowInComponent:0]*60+[timepicker selectedRowInComponent:1];
//    DDLogInfo(@"设定时间%d %d****%d",[timepicker selectedRowInComponent:0],[timepicker selectedRowInComponent:1],time);
    if(sourcetype==0){
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:time] forKey:NO_DISTURB_STARTTIME];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:time] forKey:NO_DISTURB_ENDTIME];
    }
    [self showdown];
}
#pragma mark -
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;     //这个picker里的组键数
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component==0)
        return 24;
    else
        return 60;
}

#pragma mark -
#pragma mark UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* lab = (UILabel*)view;
    if (!lab) {
        lab=[[UILabel alloc]init];
        lab.text=[NSString stringWithFormat:@"%d",row];
        lab.font=[UIFont systemFontOfSize:25];
        lab.textAlignment=NSTextAlignmentCenter;
    }
    return lab;
}- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    CGFloat componentWidth = 0.0;
    if (component == 0)
        componentWidth = 80.0; // 第一个组键的宽度
    else
        componentWidth = 80.0; // 第2个组键的宽度
    return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 30.0;
}


@end
