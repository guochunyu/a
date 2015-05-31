//
//  MoreButton.m
//  O了
//
//  Created by royasoft on 14-2-19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MoreButton.h"

@implementation MoreButton{
    BOOL group;
    NSArray *ttary;
}


- (id)initWithFrame:(CGRect)frame isgroup:(BOOL)isgroup titleary:(NSArray *)ary{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        group=isgroup;
        ttary=[[NSArray alloc]initWithArray:ary];
    }
    return self;
}

-(MoreView *)inputView{
    
    if (!_inputView) {
        _inputView=[[MoreView alloc] initWithFrame:CGRectMake(0, 0, 320, 100) isgroup:group titlearr:ttary];
        _inputView.inputTextView=self.inputTextView;
        return _inputView;
    }
    
    return _inputView;
}
- (BOOL)canBecomeFirstResponder {
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
