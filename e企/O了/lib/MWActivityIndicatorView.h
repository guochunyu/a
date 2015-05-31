//
//  MWActivityIndicatorView.h
//  MobileWallet
//
//  Created by louzhenhua on 14-8-29.
//  Copyright (c) 2014年 CMCC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWActivityIndicatorView : UIView

@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, readonly) BOOL isAnimating;

- (id)initWithFrame:(CGRect)frame;
- (void)startAnimation;
- (void)stopAnimation;
@end
