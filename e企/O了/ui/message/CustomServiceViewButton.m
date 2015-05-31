//
//  CustomServiceViewButton.m
//  O了
//
//  Created by roya-7 on 14-9-18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CustomServiceViewButton.h"
//#import <QuartzCore/QuartzCore.h>
#import "UIMyLabel.h"



#define left_button_margin 6 ///<左右边距

#define max_button_image_size_height 60 ///<大图片的高度

@implementation CustomServiceViewButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self setBackgroundColor:[UIColor grayColor]];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    //设置默认类型
    if (_customServiceViewButtonType!=CustomServiceViewButtonTypeOther) {
        self.customServiceViewButtonType=CustomServiceViewButtonTypeFirst;
        
    }else{
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        lineView.backgroundColor=[UIColor grayColor];
        lineView.alpha=0.3;
        [self addSubview:lineView];
    }
    
    
}

- (void)setCustomServiceViewButtonType:(CustomServiceViewButtonType)customServiceViewButtonType{
    
    _customServiceViewButtonType=customServiceViewButtonType;
    
}
-(void)touchDown:(id)sender{
    [self setBackgroundColor:[UIColor grayColor]];
}
-(void)touchCancel:(id)sender{
    [self setBackgroundColor:[UIColor blackColor]];
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    
    if (_customServiceViewButtonType==CustomServiceViewButtonTypeOther) {
        [super setTitle:title forState:state];
        UIFont *font=[UIFont systemFontOfSize:14];
        CGSize titleSize=[title sizeWithFont:font constrainedToSize:CGSizeMake(self.frame.size.width-5-10-35, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        if (titleSize.height>30) {
            CGRect rect = self.frame;
            rect.size.height=titleSize.height+5*2;
            self.frame=rect;
        }
        
    }else{
        UIFont *font=[UIFont systemFontOfSize:16];
        CGSize titleSize=[title sizeWithFont:font constrainedToSize:CGSizeMake(self.frame.size.width-5-10-35, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        [self bigTitle:titleSize title:title];
    }
    
}
- (void)setImage:(UIImage *)image forState:(UIControlState)state{
    
    UIImage *newImage=[image stretchableImageWithLeftCapWidth:270 topCapHeight:100];
    
    [super setImage:newImage forState:state];
    if (image) {
        
        if (_customServiceViewButtonType==CustomServiceViewButtonTypeFirst) {
            DDLogInfo(@"--->%f,--->%f",image.size.width,image.size.height);
            float size_h=max_button_image_size_height;
            float scale=size_h/image.size.height;
            float size_w=image.size.width*scale;
            /*
            float size_w=self.frame.size.width-left_button_margin*2;
            float scale=size_w/image.size.width;
            float size_h=image.size.height*scale;
             */
            if (size_w>270) {
                //如果换算后大于最大的高度,设置为最大高度
                size_w=270;
            }
            
            
//            self.contentMode=UIViewContentModeScaleToFill;
            CGRect rect_s=self.frame;
            rect_s.size.height=max_button_image_size_height+left_button_margin*2;
//            rect_s.size.width=size_w;
            self.frame=rect_s;
            
            CGRect bgViewRect=bgView.frame;
            bgViewRect.origin.y=rect_s.size.height-left_button_margin-bgViewRect.size.height;
            bgView.frame=bgViewRect;
            
//            [self layoutSubviews];
        }
        
    }
}
#pragma mark - 重写title位置
- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect rect=contentRect;
    if (_customServiceViewButtonType==CustomServiceViewButtonTypeOther) {
        rect.origin.x=5;
        rect.origin.y=5;
        rect.size.width=self.frame.size.width-5-left_button_margin-35;
        rect.size.height=self.frame.size.height;
    }
    return rect;
}
-(void)bigTitle:(CGSize)size title:(NSString *)title{
    
    if (_customServiceViewButtonType==CustomServiceViewButtonTypeFirst) {
        if (!bgView) {
            bgView=[[UIView alloc] initWithFrame:CGRectMake(left_button_margin, self.frame.size.height-(size.height+5), self.frame.size.width-left_button_margin*2, size.height+5)];
            bgView.backgroundColor=[UIColor blackColor];
            bgView.alpha=0.9;
            [self addSubview:bgView];
        }
        
        UIMyLabel *customLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height)];
        customLabel.textColor=[UIColor whiteColor];
        customLabel.font=[UIFont systemFontOfSize:14];
        customLabel.textAlignment=NSTextAlignmentLeft;
        customLabel.text=title;
        [bgView addSubview:customLabel];
        
    }
    
    
}
#pragma mark - 重写图片位置
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect rect=contentRect;
    if (_customServiceViewButtonType==CustomServiceViewButtonTypeOther) {
        rect.origin.x=self.frame.size.width-left_button_margin-35;
        rect.origin.y=3;
        rect.size=CGSizeMake(35, 35);
    }else{
        rect.origin.x=left_button_margin;
        rect.origin.y=left_button_margin;
        rect.size.width=self.frame.size.width-left_button_margin*2;
        rect.size.height=self.frame.size.height-left_button_margin*2;
    }
    return rect;
}
@end
