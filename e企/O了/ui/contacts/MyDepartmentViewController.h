//
//  MyDepartmentViewController.h
//  e企
//
//  Created by zxdDong on 15-4-12.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDepartmentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic)  UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)NSMutableArray *search_array;
@property (nonatomic, strong)NSMutableArray *search_array1;


@end
