//
//  AssetsViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-17.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYAssetSelectionDelegate.h"
@class ALAssetsGroup;

@interface RYAssetsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,weak) id<RYAssetSelectionDelegate> parent;
@property(nonatomic,strong) ALAssetsGroup *assetsGroup;
@property(nonatomic,assign) NSInteger selectCount;              //选择数量
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *arrayAsset;         //选择发送的资源集合

@end
