//
//  CustomButtonNewsDetail.h
//  O了
//
//  Created by 卢鹏达 on 14-4-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define PADDING 6    //外边距

#define HEIGHT_TITLE 20
#define HEIGHT_IMAGE 170
#define COUNT_DETAIL 4

#define SN_CACHE_IMAGE_PATH @"ServiceNumber/cacheImage/"    //服务号图片缓存路径

#import <UIKit/UIKit.h>
#import "NotesData.h"

typedef enum {
    CustomButtonTypeNomal,//默认,居中显示
    CustomButtonTypeTransmit,///<转发消息
    
}CustomButtonType;

@interface CustomButtonNewsDetail : UIButton

@property(nonatomic,assign)CustomButtonType customButtonType;
@property(nonatomic,copy) NSString *date;
@property(nonatomic,copy) NSString *detail;

@property(nonatomic,strong)NotesData *nd;
/**
 *  设置Button的图片，来自网络资源
 *
 *  @param urlName              图片链接地址
 *  @param placeholderImageName 占位图片
 */
- (void)setImageWithName:(NSString *)urlName placeholderImageName:(NSString *)placeholderImageName;


@end
