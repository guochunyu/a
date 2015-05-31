//
//  UIMyTextView.m
//  O了
//
//  Created by 化召鹏 on 14-8-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIMyTextView.h"

@implementation UIMyTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (NSString *)originalText{
    if (!_originalText) {
        _originalText=@"";
    }
    return _originalText;
}
@end
