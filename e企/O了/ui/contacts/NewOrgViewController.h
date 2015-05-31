//
//  NewOrgViewController.h
//  e企
//
//  Created by royaMAC on 14-11-11.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewOrgViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)   UITableView *table;
@property (nonatomic,strong)  EmployeeModel *userInfo;
@property (nonatomic,strong)  NSString      *organizationName;
@property (nonatomic,strong)  NSString      *orgId;
@property (nonatomic,strong)  NSArray       *dataArray;
@end
