//
//  addMydepartController.h
//  e企
//
//  Created by zxdDong on 15-4-12.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "addScrollView_messege.h"
#import "NavigationVC_AddID.h"
#import "AddgGroupCell.h"
#import "QunLiaoListViewController.h"
#import "ContactsCheck.h"


@interface addMydepartController : UIViewController<ContactsCheckDelegate,UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>{
    UIButton *_btnSender;
    NSMutableDictionary *_dictionarySelectUser;   ///<要添加的群聊用户
    addScrollView_messege *_addscrollMess;
    MBProgressHUD *_HUD;
    BOOL select[100];///<通讯录区头是否点击
}
@property (nonatomic, strong)UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong)NSMutableDictionary *contact_MutDic;
@property (nonatomic, strong)NSMutableDictionary *contact_shoucang;
@property (nonatomic, strong)NSArray  * dataArray;

@property (nonatomic, strong)NSMutableArray *search_array;

@end
