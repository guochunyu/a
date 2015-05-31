//
//  UserInfoView.m
//  e企
//
//  Created by zxdDong on 15-1-17.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "UserInfoView.h"

@implementation UserInfoView

-(id)initWithFrame:(CGRect)frame{
   self = [super initWithFrame:frame];
    self.imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height - 20);
    self.label.textAlignment = NSTextAlignmentCenter;
   // self.label.font = [UIFont fontWithName:<#(NSString *)#> size:<#(CGFloat)#>]
    return self;
}

@end
