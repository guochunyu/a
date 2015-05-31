//
//  ContextDetilControllerViewController.h
//  e企
//
//  Created by HC_hmc on 15/3/30.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BulletinModel.h"
@interface ContextDetilControllerViewController : UIViewController<UIScrollViewAccessibilityDelegate>
@property (nonatomic,strong) UIScrollView *bgview;
@property (nonatomic,strong) BulletinModel *context;
@property (nonatomic,strong) NSString *bulletinID;
@end
