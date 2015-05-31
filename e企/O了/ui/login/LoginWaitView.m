//
//  LoginWaitView.m
//  e企
//
//  Created by HC_hmc on 15/1/23.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "LoginWaitView.h"

@implementation LoginWaitView{
    UIView *loadingview;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        DDLogInfo(@"初始化");
        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"7_bg.png"]]];
        loadingview=[[UIView alloc]initWithFrame:CGRectMake(130, 200, 54, 54)];
        [loadingview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"loadingwait.png"]]];
        [loadingview.layer  addAnimation:[self rotation:1 degree:3.1314927 direction:1 repeatCount:10000] forKey:nil];
        [self addSubview:loadingview];
    }
    return self;
}
-(void)restart{
    DDLogCInfo(@"等待动画重新加载");
    [loadingview.layer  addAnimation:[self rotation:1 degree:3.1314927 direction:1 repeatCount:10000] forKey:nil];

}

-( CABasicAnimation *)rotation:( float )dur degree:( float )degree direction:( int )direction repeatCount:( int )repeatCount{
    CATransform3D rotationTransform = CATransform3DMakeRotation (degree, 0 , 0 , direction);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath : @"transform" ];
    animation. toValue = [ NSValue valueWithCATransform3D :rotationTransform];
    animation. duration   =  dur;
    animation. autoreverses = NO ;
    animation. cumulative = NO ;
    animation. fillMode = kCAFillModeForwards ;
    animation. repeatCount = repeatCount;
    animation. delegate = self ;
    return animation;
}


@end
