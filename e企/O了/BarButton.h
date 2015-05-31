//
//  BarButton.h
//  O了
//
//  Created by 化召鹏 on 14-1-23.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarButton : UIButton{
    UILabel *tabbarLabel;
}

@property(strong,nonatomic)UIImageView *remindImage;
@property(assign,nonatomic) NSInteger remindNum;//提醒的数量
@property(assign,nonatomic) BOOL isRemind;//是否提醒
@property(strong,nonatomic)NSString *tabbarTitleLabel;//标题

-(void)setBarButtonTitleColor:(NSInteger)isSelect;
@end
