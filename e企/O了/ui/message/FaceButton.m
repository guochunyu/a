//
//  FaceButton.m
//  O了
//
//  Created by 化召鹏 on 14-1-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "FaceButton.h"

@implementation FaceButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(FaceView *)inputView{
    
    if (!_inputView) {
        _inputView=[[FaceView alloc] initWithFrame:CGRectMake(0, 0, 320, 195)];
        _inputView.inputTextView=self.inputTextView;
        _inputView.delegate=self;
        __block typeof(self) mySelf=self;
        _inputView.faceClick=^(id sender){
            if (mySelf.faceClick) {
                mySelf.faceClick(sender);
            }
        };
        return _inputView;
    }
    return _inputView;
}

-(void)sendFaceButtClick:(UITextView *)textView{
    [self.delegate sendFace:textView];
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
