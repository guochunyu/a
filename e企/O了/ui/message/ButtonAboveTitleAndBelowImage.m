//
//  ButtonAboveTitleAndBelowImage.m
//  O了
//
//  Created by 卢鹏达 on 14-3-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define PADDING 6    //外边距

#import "ButtonAboveTitleAndBelowImage.h"

#import "NSString+FilePath.h"
//#import "UIImageView+AFNetworking.h"

@implementation ButtonAboveTitleAndBelowImage
#pragma mark init初始化调用
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}
#pragma mark 在nib文件中创建该控件
- (void)awakeFromNib
{
    [self initial];
}
#pragma mark 初始化
- (void)initial
{
    //标题设置
    self.titleLabel.textAlignment=NSTextAlignmentLeft;
    self.titleLabel.font=[UIFont systemFontOfSize:15];
    self.titleLabel.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.5];
    //限制行数且在多余文字最后加省略号
    self.titleLabel.numberOfLines=1;
    self.titleLabel.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
    //图标设置
    self.imageView.contentMode=UIViewContentModeScaleAspectFill;
    //默认背景色设置
    self.backgroundColor=[UIColor whiteColor];
    //Button设置
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:3];
    self.layer.shouldRasterize=YES;
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark 高亮重写
- (void)setHighlighted:(BOOL)highlighted{};
#pragma mark 重写Title大小的方法
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX=PADDING;
    CGFloat titleHeight=contentRect.size.height*0.2;
    CGFloat titleY=contentRect.size.height-titleHeight-PADDING;
    CGFloat titleWidth=contentRect.size.width-PADDING*2;
    
    return CGRectMake(titleX, titleY, titleWidth, titleHeight);
}
#pragma mark 重写Image大小的方法
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX=PADDING;
    CGFloat imageY=PADDING;
    CGFloat imageWidth=contentRect.size.width-PADDING*2;
    CGFloat imageHeight=contentRect.size.height-PADDING*2;
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}
#pragma mark 设置Button的图片，来自网络资源
- (void)setImageWithName:(NSString *)urlName placeholderImageName:(NSString *)placeholderImageName
{
    NSString *imagePath=[NSString stringWithFormat:@"%@%@",SN_CACHE_IMAGE_PATH,[urlName lastPathComponent]];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[imagePath filePathOfCaches]]) {
        [self setImage:[UIImage imageNamed:placeholderImageName] forState:UIControlStateNormal];
        UIImageView *imageView=[[UIImageView alloc]init];
        [imageView setImageWithURL:[NSURL URLWithString:urlName] placeholderImage:[UIImage imageNamed:placeholderImageName]];
//        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlName]];
//        [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            [self setImage:image forState:UIControlStateNormal];
//            //判断目录是否存在不存在则创建
//            NSString *pathDirectories = [[imagePath filePathOfCaches] stringByDeletingLastPathComponent];
//            if (![fileManager fileExistsAtPath:pathDirectories]) {
//                [fileManager createDirectoryAtPath:pathDirectories withIntermediateDirectories:YES attributes:nil error:nil];
//            }
//            [UIImageJPEGRepresentation(image, 1) writeToFile:[imagePath filePathOfCaches] atomically:YES];
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
////            DDLogInfo(@"图片获取失败");
//        }];
    }else{
        [self setImage:[UIImage imageWithContentsOfFile:[imagePath filePathOfCaches]] forState:UIControlStateNormal];
    }
}
@end
