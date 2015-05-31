//
//  H5ViewController.h
//  e企
//
//  Created by 独孤剑道(张洋) on 15/3/31.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, H5Types)
{
    AppRecommendationTypes,  // 应用推荐
    TrafficManagements,      // 流量管理
};

@interface H5ViewController : UIViewController

@property (assign, nonatomic) H5Types currentH5Types;
//@property (nonatomic, copy) NSString *phone;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withRequest:(NSURLRequest *)request;

@end
