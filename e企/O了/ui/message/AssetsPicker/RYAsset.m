//
//  Asset.m
//  O了
//
//  Created by 卢鹏达 on 14-1-20.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import "RYAsset.h"

@implementation RYAsset

- (id)initWithAsset:(ALAsset *)asset
{
    self=[super init];
    if (self) {
        self.asset=asset;
        self.selected=NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
   if (![self.parent assetShouldSelect:self]) {
       return;
   }
    _selected=selected;
}
@end
