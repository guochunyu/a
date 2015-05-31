//
//  ContactsViewController.h
//  e企
//
//  Created by zxdDong on 15-4-20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupAddress.h"
#import "CellContact.h"
#import "CellFirstThree.h"

#import "QunLiaoListViewController.h"

#import "MBProgressHUD.h"
#import "ContactsCheck.h"

@class MainViewController;
static NSString * const selectToGroupAddresss =@"selectToGroupAddresss";
static NSString * const selectToFuwuhao =@"selectToFuwuhao";

static NSString * const selectToPersonAdress =@"selectToPersonAdress";
static NSString * const selectToIms =@"selectToIms";



@interface ContactsViewController : UIViewController<UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,CellContactDelegate,MBProgressHUDDelegate,CellFirstThreeDelegate,ContactsCheckDelegate>{
    MBProgressHUD *_HUD;
}
@property (nonatomic, strong)NSString *UserPhoto;
@property (nonatomic, strong)NSArray        *sortArray;
@property (nonatomic, strong)NSArray        *firstThree;//存放的 单位 群 公共号
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray *search_array;
@property (nonatomic, strong)NSMutableArray *search_array1;
@property (nonatomic, strong)NSDictionary   *contact_MutDic;
@property (nonatomic, strong)NSArray        * dataArray;
@property(nonatomic,weak)NSString *showContentName;//bug4


-(void)initData;
@end
