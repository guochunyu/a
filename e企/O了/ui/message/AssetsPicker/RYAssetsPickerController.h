//
//  AssetsPickerController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-17.
//  Copyright (c) 2014年 roya. All rights reserved.
//

static NSString *const AssetsPickerMediaName=@"mediaName";                 ///<媒体名称 String

static NSString *const AssetsPickerImageThumbnail=@"thumnail";         ///<缩略图   Data
static NSString *const AssetsPickerImageFullScreen=@"fullScreen";      ///<全屏图   Data
static NSString *const AssetsPickerImageOriginal=@"original";          ///<原图     Data
static NSString *const AssetsPickerImageIsOriginl=@"isOriginl";                         ///是否是原图


static NSString *const AssetsPickerVedioCompress=@"compress";           ///<视频压缩 Url

/**
 *  选择器类型
 */
typedef enum {
	RYAssetsPickerAssetPhoto=1,   ///<图片
    RYAssetsPickerAssetVideo=2    ///<视频
} RYAssetsPickerAssetType;

#import <UIKit/UIKit.h>
@class ALAssetsLibrary;
@class RYAssetsPickerController;

@protocol RYAssetsPickerDelegate <UINavigationControllerDelegate>
/**
 *  图片选择结束后调用该委托，获取选择的图片
 *
 *  @param assetsPicker RYAssetsPickerController
 *  @param info         图片信息
 */
- (void)assetsPicker:(RYAssetsPickerController *)assetsPicker didFinishPickingMediaWithInfo:(NSArray *)info;
@end

@interface RYAssetsPickerController : UINavigationController

@property(nonatomic,weak) id<RYAssetsPickerDelegate> delegate;
@property(nonatomic,assign) NSInteger maxSelectCount;   ///<最大选择资源数,默认为9
@property(nonatomic,assign,readonly) RYAssetsPickerAssetType AssetType; //资源类型
@property(nonatomic,strong) NSString *titleButtonSure;  //确定按钮的标题
/**
 *  init图片选择器
 *
 *  @return 当前类
 */
- (id)initPhotosPicker;
/**
 *  init视频选择器
 *
 *  @return 当前类
 */
- (id)initVideosPicker;

@end