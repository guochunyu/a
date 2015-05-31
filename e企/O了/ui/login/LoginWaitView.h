//
//  LoginWaitView.h
//  e企
//
//  Created by HC_hmc on 15/1/23.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginWaitView : UIView

@property(nonatomic,strong)UIActivityIndicatorView *activityView;///<菊花
- (id)initWithFrame:(CGRect)frame;

-(void)restart;
@end
