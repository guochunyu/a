//
//  AddFromContact.h
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "addScrollView_messege.h"
#import "NavigationVC_AddID.h"
#import "AddgGroupCell.h"
#import "QunLiaoListViewController.h"
#import "ContactsCheck.h"

@interface AddFromContact : UIViewController<ContactsCheckDelegate,UITableViewDataSource,UITabBarDelegate>{
    UIButton *_btnSender;
    NSMutableDictionary *_dictionarySelectUser;   ///<要添加的群聊用户
    addScrollView_messege *_addscrollMess;
    MBProgressHUD *_HUD;
    BOOL select[100];///<通讯录区头是否点击
}

@property (nonatomic, strong)NSArray *firstThree;
@property (nonatomic, strong)NSMutableDictionary *contact_MutDic;
@property (nonatomic, strong)NSMutableDictionary *contact_shoucang;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray *search_array;
@property(nonatomic,strong) NSArray * sortarray4;
@property(nonatomic,strong)NSMutableArray * sortAllMembersArray;



@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
