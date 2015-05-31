//
//  MessageUserDetailViewController.h
//  e企
//
//  Created by HC_hmc on 15/3/12.
//  Copyright (c) 2015年 QYB. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "NavigationVC_AddID.h"

typedef void(^ClearChatData)();

typedef void(^AddComman)(BOOL isAdd);

@class EmployeeModel;

@interface MessageUserDetailViewController : UITableViewController<navigation_addIDDelegaet>
@property (nonatomic, strong)NSString *UserPhoto;

@property (nonatomic,strong) NSArray * commanArray;

@property (nonatomic,strong) EmployeeModel *userInfo;
@property (nonatomic,strong) NSString      *organizationName;

@property(nonatomic,assign)BOOL isFromChat;///<是否从聊天进入

@property(nonatomic,assign)NSInteger detailType;///<页面类型,0为默认,1为单聊回话详情

@property(nonatomic,copy)ClearChatData clearChatData;///<清空消息
@property(nonatomic,copy)AddComman addComman;///<添加了常用联系人
@end
