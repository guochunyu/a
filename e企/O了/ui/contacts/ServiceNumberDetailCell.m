//
//  ServiceNumberDetailCell.m
//  O了
//
//  Created by 卢鹏达 on 14-3-6.
//  Copyright (c) 2014年 QYB. All rights reserved.
//
#define IMAGE_MAGRIN_UP 10   //图片Y坐标
#import "ServiceNumberDetailCell.h"

@implementation ServiceNumberDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialFont];
    }
    return self;
}

#pragma mark 初始化字体
- (void)initialFont
{
    return;
    UIFont *font=[UIFont systemFontOfSize:17];
    //textlabel字体设置
    self.textLabel.font=font;
    //detailTextLabel字体设置
    self.detailTextLabel.font=font;
    self.detailTextLabel.textColor=[UIColor blackColor];
    self.detailTextLabel.textAlignment=NSTextAlignmentLeft;
    [self.detailTextLabel setNumberOfLines:INT_MAX];
}
#pragma mark 重写UITableViewCell布局
- (void)toLayoutSubviews
{
    [super layoutSubviews];
    CGFloat detailX=self.textLabel.frame.origin.x+self.textLabel.frame.size.width;
    if (!CGRectEqualToRect(self.imageView.frame, CGRectZero)) {
        //设置imageView的frame
        CGFloat imageViewSize=self.frame.size.height-IMAGE_MAGRIN_UP*2;
        self.imageView.frame=CGRectMake(self.imageView.frame.origin.x,IMAGE_MAGRIN_UP,imageViewSize,imageViewSize);
        self.imageView.layer.cornerRadius=5;
        detailX=self.imageView.frame.origin.x+imageViewSize+5;
    }
    //设置detailTextLabel的frame
    self.detailTextLabel.frame=CGRectMake(detailX,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
    self.textLabel.frame=CGRectMake(detailX,self.textLabel.frame.origin.y,self.textLabel.frame.size.width,self.textLabel.frame.size.height);
}

@end

