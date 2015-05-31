//
//  MenuButton.h
//  O了
//
//  Created by 化召鹏 on 14-3-7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesData.h"

@interface MenuButton : UIButton
@property(nonatomic,strong)NotesData *nd;

@property(nonatomic,weak)UIImageView *voiceImageView;

@property(nonatomic,strong)UIView *readStateView;
@end
