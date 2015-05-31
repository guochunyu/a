//
//  MenuButton.m
//  O了
//
//  Created by 化召鹏 on 14-3-7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MenuButton.h"

@implementation MenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(BOOL)canBecomeFirstResponder{
    return YES;
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
