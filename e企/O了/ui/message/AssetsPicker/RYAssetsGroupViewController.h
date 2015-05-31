//
//  AssetsGroupViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-17.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYAssetSelectionDelegate.h"
@class ALAssetsLibrary;

@interface RYAssetsGroupViewController : UITableViewController
@property(nonatomic,weak) id<RYAssetSelectionDelegate> parent;

@end
