//
//  UIMyLabel.m
//  O了
//
//  Created by 化召鹏 on 14-8-26.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIMyLabel.h"

@implementation UIMyLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        self.textColor=[UIColor blackColor];
        self.font=[UIFont systemFontOfSize:14];
        self.textAlignment=NSTextAlignmentCenter;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
