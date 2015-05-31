//
//  Asset.h
//  O了
//
//  Created by 卢鹏达 on 14-1-20.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ALAsset;
@class RYAsset;

@protocol RYAssetDelegate <NSObject>
/**
 *  确定该资源是否可以选择
 *
 *  @param asset 当前资源
 *
 *  @return YES:允许选择该资源，NO:当前资源数已达上限不允许选择
 */
- (BOOL)assetShouldSelect:(RYAsset *)asset;

@end

/**
 *  资源列表类
 */
@interface RYAsset : NSObject

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) id<RYAssetDelegate> parent;
/**
 *  初始化RYAsset
 *
 *  @param asset ALAsset资源
 *
 *  @return RYAsset
 */
- (id)initWithAsset:(ALAsset *)asset;

@end
