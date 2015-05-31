//
//  RYAssetsBrowerViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-22.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RYAssetSelectionDelegate.h"

@interface RYAssetsBrowerViewController : UIViewController

@property(nonatomic,weak) id<RYAssetSelectionDelegate> parent;

@property(nonatomic,strong) NSArray *arrayAsset;        //浏览资源列表
@property(nonatomic,assign) NSInteger intSelectIndex;   //选择索引

@property(nonatomic,assign) NSInteger selectCount;      //资源数量

@property(nonatomic,strong) NSString *titleButtonSure;  //确定按钮的标题

@end
