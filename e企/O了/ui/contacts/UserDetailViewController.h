//
//  UserDetailViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-9.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NavigationVC_AddID.h"

typedef void(^ClearChatData)();

typedef void(^AddComman)(BOOL isAdd);

@class EmployeeModel;

@interface UserDetailViewController : UIViewController<navigation_addIDDelegaet,UIActionSheetDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong)NSString *UserPhoto;
@property (nonatomic, strong)NSString *myImacct;

@property (nonatomic,strong) NSArray * commanArray;

@property (nonatomic,strong) EmployeeModel *userInfo;
@property (nonatomic,strong) NSString      *organizationName;

@property(nonatomic,assign)BOOL isFromChat;///<是否从聊天进入
@property(nonatomic,strong)UIView * lineView;

@property(nonatomic,assign)NSInteger detailType;///<页面类型,0为默认,1为单聊回话详情

@property(nonatomic,copy)ClearChatData clearChatData;///<清空消息
@property(nonatomic,copy)AddComman addComman;///<添加了常用联系人

@property (nonatomic, strong)UISearchBar *searchBarContacts;
@property (nonatomic, strong)UITableView *tableViewSearch;
@property (nonatomic, strong)UIView *viewSearchBG;
@end
