//
//  MyImageView.m
//  O了
//
//  Created by 化召鹏 on 14-3-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MyImageView.h"
#import "NSString+FilePath.h"
#import "UIImageView+WebCache.h"

@interface MyImageView()

@property(nonatomic,assign)CGFloat radius;
@end

@implementation MyImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.radius=0;
        
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
- (void)setImageWithName:(NSString *)path placeholderImageName:(NSString *)placeholderImageName
{
//    NSString *imagePath=[path filePathOfCaches];
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if (![fileManager fileExistsAtPath:imagePath]) {
//        [self setImage:[UIImage imageNamed:placeholderImageName]];
//        UIImageView *imageView=[[UIImageView alloc]init];
//        NSString *urlStr=[NSString stringWithFormat:@"http://%@:%@%@",HTTP_IP,HTTP_PORT,path];
//        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
//        [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//            [self setImage:image];
//            //判断目录是否存在不存在则创建
//            NSString *pathDirectories = [imagePath stringByDeletingLastPathComponent];
//            if (![fileManager fileExistsAtPath:pathDirectories]) {
//                [fileManager createDirectoryAtPath:pathDirectories withIntermediateDirectories:YES attributes:nil error:nil];
//            }
//            [UIImageJPEGRepresentation(image, 1) writeToFile:[imagePath filePathOfCaches] atomically:YES];
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//            DDLogInfo(@"图片获取失败");
//        }];
//    }else{
//        [self setImage:[UIImage imageWithContentsOfFile:[imagePath filePathOfCaches]]];
//    }
}
- (void)setImage:(UIImage *)image{
    
    if (self.radius==0) {
        
        [super setImage:image];
        return;
    }
    
    float scale = [[UIScreen mainScreen]scale];//得到设备的分辨率
    
    CGSize newSize=CGSizeMake(self.frame.size.width*scale, self.frame.size.height*scale);
    
    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGFloat redio=self.radius;
    
    CGContextMoveToPoint(context,newSize.width-redio,0);
    CGContextAddArcToPoint(context, 0, 0, 0, newSize.height-redio, redio);
    CGContextAddArcToPoint(context, 0, newSize.height, newSize.width-redio, newSize.height, redio);
    CGContextAddArcToPoint(context, newSize.width, newSize.height, newSize.width, redio, redio);
    CGContextAddArcToPoint(context, newSize.width, 0, newSize.width-redio, 0, redio);
    
    CGContextClip(context);
    
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width*scale, self.frame.size.height*scale)];
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    [super setImage:newimg];
}
-(void)setImageWithImageName:(NSURL *)imageUrl placeholderImage:(UIImage *)placeholderImage radius:(CGFloat)radius{
    
    self.radius=radius;
    [self setImage:placeholderImage];
    __block typeof(self) mySelf=self;
    [self setImageWithURL:imageUrl placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            [mySelf setImage:image];
        }
    }];
}
-(void)setImageWithImage:(UIImage *)image radius:(CGFloat)radius{
    self.radius=radius;
    self.image=image;
}
@end
