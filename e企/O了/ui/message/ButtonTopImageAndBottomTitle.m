  //
//  ButtonGroupChatSetIcon.m
//  O了
//
//  Created by 卢鹏达 on 14-1-8.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#define TITLE_SIZE 14   //标题大小
#define TITLE_COLOR grayColor //标题颜色
#define TITLE_ALIGN NSTextAlignmentCenter //标题对齐方式
#define DISTANCE_IMAGE_TEXT 6   //图标文字距离

//#import "UIImageView+AFNetworking.h"
#import "UIButton+WebCache.h"

#import "ButtonTopImageAndBottomTitle.h"

@interface ButtonTopImageAndBottomTitle(){
    
}

@end

@implementation ButtonTopImageAndBottomTitle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //标题设置
        self.titleLabel.textAlignment=TITLE_ALIGN;
        self.titleLabel.font=[UIFont boldSystemFontOfSize:TITLE_SIZE];
        [self setTitleColor:[UIColor TITLE_COLOR] forState:UIControlStateNormal];
        //限制行数且在多余文字最后加省略号
        self.titleLabel.numberOfLines=1;
        self.titleLabel.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        //图标设置
        self.imageView.layer.cornerRadius=self.imageView.bounds.size.height*0.5;
    }
    return self;
}

#pragma mark 重写Title大小的方法
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY=contentRect.size.width+DISTANCE_IMAGE_TEXT;
    CGFloat titleHeight=contentRect.size.height-titleY;
    return CGRectMake(0, titleY, contentRect.size.width, titleHeight);
}
#pragma mark 重写Image大小的方法
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, 0, contentRect.size.width, contentRect.size.width);
}
- (CGRect)backgroundRectForBounds:(CGRect)bounds{
    return CGRectMake(0, 0, bounds.size.width, bounds.size.width);
}
#pragma mark 设置Button的图片，来自网络资源
- (void)setImageWithName:(NSString *)urlName placeholderImageName:(NSString *)placeholderImageName
{
    [self setImageWithURL:[NSURL URLWithString:urlName] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:placeholderImageName]];
//    [self setImage:[UIImage imageNamed:placeholderImageName] forState:UIControlStateNormal];
//    UIImageView *imageView=[[UIImageView alloc]init];
//    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlName]];
//    [imageView setImageWithURL:[NSURL URLWithString:urlName] placeholderImage:[UIImage imageNamed:placeholderImageName]];
//    [imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:placeholderImageName] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        [self setImage:image forState:UIControlStateNormal];
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
////        DDLogInfo(@"图片获取失败");
//    }];

    
}
@end
