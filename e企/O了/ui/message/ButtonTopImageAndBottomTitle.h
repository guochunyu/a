//
//  ButtonGroupChatSetIcon.h
//  O了
//
//  Created by 卢鹏达 on 14-1-8.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonTopImageAndBottomTitle : UIButton
/**
 *  设置Button的图片，来自网络资源
 *
 *  @param urlName              图片链接地址
 *  @param placeholderImageName 占位图片
 */
- (void)setImageWithName:(NSString *)urlName placeholderImageName:(NSString *)placeholderImageName;

@end
