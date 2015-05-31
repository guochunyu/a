//
//  RYAssetsMediaPlayerViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-2-12.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYAssetSelectionDelegate.h"

@class RYAsset;

@interface RYAssetsMediaPlayerViewController : UIViewController

@property(nonatomic,weak) id<RYAssetSelectionDelegate> parent;

@property(nonatomic,strong) RYAsset *ryAsset;        //浏览资源列表

@property(nonatomic,strong) NSString *titleButtonSure;  //确定按钮的标题

@end
