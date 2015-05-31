//
//  MyImageView.h
//  O了
//
//  Created by 化召鹏 on 14-3-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesData.h"

@interface MyImageView : UIImageView
- (void)setImageWithName:(NSString *)path placeholderImageName:(NSString *)placeholderImageName;

//加载网络图片
-(void)setImageWithImageName:(NSURL *)imageUrl placeholderImage:(UIImage *)placeholderImage radius:(CGFloat)radius;
//加载本地图片
-(void)setImageWithImage:(UIImage *)image radius:(CGFloat)radius;

@property(nonatomic,strong)NotesData *nd;
@end
