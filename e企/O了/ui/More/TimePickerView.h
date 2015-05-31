//
//  TimePickerView.h
//  e企
//
//  Created by HC_hmc on 14/12/31.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol timepickdelegate <NSObject>
-(void)reload;

@end

@interface TimePickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate>
@property (weak,nonatomic)id<timepickdelegate> delegate;
@property (strong,nonatomic)UIPickerView *timepicker;
@property int sourcetype;
-(void)show;
-(void)showdown;
- (id)initWithFrame:(CGRect)frame sourcetype:(int)type;
@end
