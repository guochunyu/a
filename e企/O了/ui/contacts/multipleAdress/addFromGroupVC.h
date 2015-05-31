//
//  addFromGroupVC1.h
//  e企
//
//  Created by zxdDong on 15-4-14.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "addScrollView_messege.h"
#import "AddGroupScrollButt.h"
#import "NavigationVC_AddID.h"

@interface addFromGroupVC : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UIButton *_btnSender;
    NSMutableDictionary *_dictionarySelectUser;   ///<要添加的群聊用户
    addScrollView_messege *_addscrollMess;
}


@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic)NSInteger grou_ID;
@property(nonatomic,copy)NSString *rootName;///<根节点名字
@property (strong, nonatomic)NSArray *arr_enterprise;
@property (strong, nonatomic)NSArray *arr_menber;
@property (nonatomic, strong)UITableView * tableView;
@property (nonatomic, strong)NSMutableArray *search_array_grou;
@property (nonatomic, strong)NSMutableArray *search_array_menber;

@end
