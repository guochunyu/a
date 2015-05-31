//
//  ImageChatData.h
//  e企
//
//  Created by roya-7 on 14/11/6.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageChatData : NSObject
@property(nonatomic,copy)NSString *middleLink;///<图片原图
@property(nonatomic,copy)NSString *originalLink;///<图片大图
@property(nonatomic,copy)NSString *smallLink;///<图片小图
@property(nonatomic,copy)NSString *imageName;///<图片名字
@property(nonatomic,copy)NSString *imagePath;///<图片路径
@property int imagewidth; ///缩放后图片宽
@property int imageheight;///缩放后图片高
@end
