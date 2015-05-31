//
//  ButtonAboveTitleAndBelowImage.h
//  O了
//
//  Created by 卢鹏达 on 14-3-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define SN_CACHE_IMAGE_PATH @"ServiceNumber/cacheImage/"    //服务号图片缓存路径

#import <UIKit/UIKit.h>

@interface ButtonAboveTitleAndBelowImage : UIButton
/**
 *  设置Button的图片，来自网络资源
 *
 *  @param urlName              图片链接地址
 *  @param placeholderImageName 占位图片
 */
- (void)setImageWithName:(NSString *)urlName placeholderImageName:(NSString *)placeholderImageName;

@end
