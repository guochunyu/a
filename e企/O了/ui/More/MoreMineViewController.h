//
//  MoreMineViewController.h
//  e企
//
//  Created by royaMAC on 14-11-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, H5Type)
{
    AppRecommendationType,  // 应用推荐
    TrafficManagement,      // 流量管理
};

@interface MoreMineViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)  UITableView *table;
@property (strong, nonatomic) NSString *plistUrl;
@property (strong, nonatomic) NSString *UserPhoto;
@property (assign, nonatomic) H5Type currentH5Type;
@end
