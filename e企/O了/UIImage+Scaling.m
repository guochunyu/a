//
//  UIImage+Scaling.m
//  O了
//
//  Created by 化召鹏 on 14-6-23.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIImage+Scaling.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1

#define kCGImageAlphaPremultipliedFirst  (kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst)

#else

#define kCGImageAlphaPremultipliedFirst  kCGImageAlphaPremultipliedFirst

#endif


@implementation UIImage (Scaling)

//static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth,
//                                 float ovalHeight)
//{
//    float fw, fh;
//    
//    if (ovalWidth == 0 || ovalHeight == 0)
//    {
//        CGContextAddRect(context, rect);
//        return;
//    }
//    
//    CGContextSaveGState(context);
//    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
//    CGContextScaleCTM(context, ovalWidth, ovalHeight);
//    fw = CGRectGetWidth(rect) / ovalWidth;
//    fh = CGRectGetHeight(rect) / ovalHeight;
//    
//    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
//    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
//    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
//    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
//    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
//    
//    CGContextClosePath(context);
//    CGContextRestoreGState(context);
//}


- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor < heightFactor) {
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil)
        DDLogInfo(@"could not scale image");
    return newImage ;
}
//设置圆角
//-(UIImage *)createRoundedRectImageSize:(CGSize)size radius:(NSInteger)r
//{
//    // the size of CGContextRef
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, 1);
//    CGFloat redio=6;
//    
//    CGContextMoveToPoint(context,size.width-redio,0);
//    CGContextAddArcToPoint(context, 0, 0, 0, size.height-redio, redio);
//    CGContextAddArcToPoint(context, 0, size.height, size.width-redio, size.height, redio);
//    CGContextAddArcToPoint(context, size.width, size.height, size.width, redio, redio);
//    CGContextAddArcToPoint(context, size.width, 0, size.width-redio, 0, redio);
//    
//    CGContextClip(context);
//    
//    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    CGContextStrokePath(context);
//    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    [super setBackgroundImage:newimg forState:state];
//}

@end
