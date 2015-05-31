//
//  UIScrollViewTouchesDelegate.m
//  O了
//
//  Created by 化召鹏 on 14-2-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIScrollViewTouches.h"

@implementation UIScrollViewTouches

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
    
    if (!self.dragging) {
        //run at ios5 ,no effect;
        [self.nextResponder touchesEnded: touches withEvent:event];
        if (_touchesdelegate!=nil) {
            
            [_touchesdelegate scrollViewTouchesEnded:touches withEvent:event whichView:self];
        }
        
    }
    [super touchesEnded: touches withEvent: event];
    
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
