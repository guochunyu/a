//
//  MessageGroupmembersViewController.h
//  e企
//
//  Created by zxdDong on 15-5-14.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageGroupmembersViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSString * roomJid;
@property(nonatomic,strong)NSMutableArray * MembersArray;
@property(nonatomic,strong)NSString *UserPhoto;
@property(nonatomic,strong)NSString * imacct;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)EmployeeModel * roonInfoModel;
@property(nonatomic,strong) NSArray * sortarray4;
@property(nonatomic,strong)NSMutableArray * keyArray;
@property(nonatomic,strong)NSMutableArray * sortAllMembersArray;
@end
