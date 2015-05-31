//
//  OrganizationViewController.h
//  e企
//
//  Created by royaMAC on 14-11-7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrganizationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)  UITableView *tableView;
@property (nonatomic, strong)NSArray             *dataArray;
@property (nonatomic, strong)NSMutableArray *search_array;
@property (nonatomic, strong)NSMutableArray *search_array1;

@end
