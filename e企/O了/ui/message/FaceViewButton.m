//
//  FaceViewButton.m
//  O了
//
//  Created by 化召鹏 on 14-1-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "FaceViewButton.h"

@implementation FaceViewButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageview=[[UIImageView alloc]initWithFrame:CGRectMake(7, 7, 30, 30)];
        [self addSubview:_imageview];
//        [self.imageView setFrame:CGRectMake(7, 7, 30, 30)];
//        self.imageView.frame
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
