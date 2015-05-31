//
//  CustomButtonNewsDetail.m
//  O了
//
//  Created by 卢鹏达 on 14-4-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CustomButtonNewsDetail.h"

#import "NSString+FilePath.h"
#import "UIButton+WebCache.h"
//#import "UIImageView+AFNetworking.h"

@interface CustomButtonNewsDetail(){
    UILabel *_lbDate;
    UILabel *_lbDetail;
}

@end

@implementation CustomButtonNewsDetail
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
    if (_lbDate==nil) {
        _lbDate=[[UILabel alloc]init];
        _lbDate.textAlignment=NSTextAlignmentLeft;
        _lbDate.font=[UIFont systemFontOfSize:13];
        _lbDate.textColor=[UIColor grayColor];
        _lbDate.frame=CGRectMake(PADDING, PADDING+HEIGHT_TITLE, self.bounds.size.width-PADDING*2, HEIGHT_TITLE);
        [self addSubview:_lbDate];
    }
    
    if (_lbDetail==nil) {
        _lbDetail=[[UILabel alloc]init];
        _lbDetail.textAlignment=NSTextAlignmentLeft;
        _lbDetail.font=[UIFont systemFontOfSize:13];
        _lbDetail.textColor=[UIColor grayColor];
        _lbDetail.numberOfLines=COUNT_DETAIL;
        _lbDetail.lineBreakMode=NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail;
        
        _lbDetail.frame=CGRectMake(PADDING, PADDING+HEIGHT_TITLE*2+HEIGHT_IMAGE, self.bounds.size.width-PADDING*2, HEIGHT_TITLE*COUNT_DETAIL);
//        _lbDetail.backgroundColor=[UIColor redColor];
        [self addSubview:_lbDetail];
    }
    //标题设置
    self.titleLabel.textAlignment=NSTextAlignmentLeft;
    self.titleLabel.font=[UIFont systemFontOfSize:15];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    self.titleLabel.backgroundColor=[[UIColor redColor] colorWithAlphaComponent:0.5];
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
//    self.layer.shouldRasterize=YES;
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)setDate:(NSString *)date
{
    _lbDate.text=date;
    _date=date;
}
- (void)setDetail:(NSString *)detail
{
    _lbDetail.text=detail;
    if (self.customButtonType==CustomButtonTypeTransmit) {
        _lbDetail.frame=CGRectMake(50+8, PADDING*2+HEIGHT_TITLE*2, 125, 50);
        _detail=detail;
        return;
    }
    
//    return plainText;
    
    
    
//    CGSize size=[detail sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(self.bounds.size.width-PADDING*2, 100) lineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary * attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:13]};
    CGSize size= [detail boundingRectWithSize:CGSizeMake(self.bounds.size.width-PADDING*2, 100) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    _lbDetail.frame=CGRectMake(PADDING, PADDING+HEIGHT_TITLE*2+HEIGHT_IMAGE+6, self.bounds.size.width-PADDING*2, size.height);
    
    _detail=detail;
    
    [self loadLastView];
}
-(void)loadLastView{
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(8, _lbDetail.frame.origin.y+_lbDetail.frame.size.height+10, self.frame.size.width-16, 1)];
    lineView.backgroundColor=[UIColor grayColor];
    lineView.alpha=0.1;
    [self addSubview:lineView];
    
    UILabel *lastLabel=[[UILabel alloc] initWithFrame:CGRectMake(8, lineView.frame.origin.y+lineView.frame.size.height+5, 100, 30)];
    lastLabel.textAlignment=NSTextAlignmentLeft;
    lastLabel.backgroundColor=[UIColor clearColor];
    lastLabel.text=@"阅读全文";
    lastLabel.textColor=[UIColor blackColor];
    [self addSubview:lastLabel];
    
    UIImageView *arrowImage=[[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-10-12, lastLabel.frame.origin.y+8, 12, 12)];
    arrowImage.image=[UIImage imageNamed:@"arrowd"];
    [self addSubview:arrowImage];
    
}
#pragma mark 高亮重写
- (void)setHighlighted:(BOOL)highlighted{};
#pragma mark 重写Title大小的方法
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX=PADDING;
    CGFloat titleY=PADDING;
    CGFloat titleHeight=HEIGHT_TITLE;
    CGFloat titleWidth=contentRect.size.width-PADDING*2;
    return CGRectMake(titleX, titleY, titleWidth, titleHeight);
}
#pragma mark 重写Image大小的方法
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (self.customButtonType==CustomButtonTypeTransmit) {
        //转发
        
//        CGFloat buttWidth=200;
//        CGFloat buttHight=150;
//        buttonFram=CGRectMake(2, 2, buttWidth-21-2, buttHight+10);
        
        CGFloat imageX=2;
        CGFloat imageY=PADDING*2+HEIGHT_TITLE*2;
        CGFloat imageWidth=50;
        CGFloat imageHeight=50;
        return CGRectMake(imageX, imageY, imageWidth, imageHeight);
        
    }
    
//    self.imageView.contentMode=UIViewContentModeScaleAspectFill;
    
    CGFloat imageX=PADDING;
    CGFloat imageY=PADDING*2+HEIGHT_TITLE*2;
    CGFloat imageWidth=contentRect.size.width-PADDING*2;
    CGFloat imageHeight=HEIGHT_IMAGE;
    return CGRectMake(imageX, imageY, imageWidth, imageHeight);
}
#pragma mark 设置Button的图片，来自网络资源
- (void)setImageWithName:(NSString *)urlName placeholderImageName:(NSString *)placeholderImageName
{
//    CGFloat imageX=PADDING;
//    CGFloat imageY=PADDING*2+HEIGHT_TITLE*2;
//    CGFloat imageWidth=self.frame.size.width-PADDING*2;
//    CGFloat imageHeight=HEIGHT_IMAGE;
//    CGRect rect = CGRectMake(imageX, imageY, imageWidth, imageHeight);
//    UIImageView *buttImg=[[UIImageView alloc] initWithFrame:rect];
//    buttImg.contentMode=UIViewContentModeScaleAspectFill;
//    [buttImg setImageWithURL:[NSURL URLWithString:urlName] placeholderImage:[UIImage imageNamed:placeholderImageName]];
//    [self addSubview:buttImg];
    
//    [self imageRectForContentRect:CGRectZero];
    [self setImageWithURL:[NSURL URLWithString:urlName] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:placeholderImageName]];
//    [self setImage:[UIImage imageNamed:placeholderImageName] forState:UIControlStateNormal];
//    NSString *imagePath=[NSString stringWithFormat:@"%@%@",SN_CACHE_IMAGE_PATH,[urlName lastPathComponent]];
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:[imagePath filePathOfCaches]]) {
//
//        [self setImage:[UIImage imageNamed:placeholderImageName] forState:UIControlStateNormal];
//        UIImageView *imageView=[[UIImageView alloc]init];
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
//            DDLogInfo(@"图片获取失败");
//        }];
//    }else{
//        [self setImage:[UIImage imageWithContentsOfFile:[imagePath filePathOfCaches]] forState:UIControlStateNormal];
//    }
}

@end
