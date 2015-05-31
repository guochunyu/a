//
//  AssetsCell.h
//  O了
//
//  Created by 卢鹏达 on 14-1-17.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#define ROW_COLUMN 3    //列数
#define ASSETS_CHECK_TAG 222    //选中资源标记的tag
#define TAG_START 100   //tag起始值
#define IMAGE_SPACE_DISTANCE 2  //图片间距
#define IMAGE_CHECK_SIZE 30 //选中标记图片大小
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
#import <UIKit/UIKit.h>
@class RYAsset;

@interface RYAssetsCell : UITableViewCell

@property(nonatomic,strong) NSArray *arrayRowAssets;

@property(nonatomic,copy) void (^blockPreview)(RYAsset *ryAsset);

@end
