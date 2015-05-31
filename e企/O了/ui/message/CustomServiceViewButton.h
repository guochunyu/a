//
//  CustomServiceViewButton.h
//  O了
//
//  Created by roya-7 on 14-9-18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CustomServiceViewButtonTypeFirst,///<第一个button,图片在中间
    CustomServiceViewButtonTypeOther///<其他的button,图片在右边
}CustomServiceViewButtonType;

typedef void(^ButtonFrameChange)(CGRect rect);

@interface CustomServiceViewButton : UIButton{
    UIView *bgView;///<第一个butt的字体背景view
}

@property(nonatomic,assign)CustomServiceViewButtonType customServiceViewButtonType;///<按钮类型
@property(nonatomic,copy)ButtonFrameChange buttonFrameChange;///<butt的fram改变,只有图片修改后才会改变
@end
