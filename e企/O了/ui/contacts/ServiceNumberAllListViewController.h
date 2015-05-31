//
//  ServiceNumberAllListViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-3-3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//
/**
 *  服务号列表
 */
typedef enum{
    ServiceNumberListTypeSubscrib,      ///<订阅服务号列表
    ServiceNumberListTypeUnsubscrib     ///<未订阅服务号列表
}ServiceNumberListType;

#import <UIKit/UIKit.h>
#import "ServiceNumberWebViewController.h"
#import "PublicaccountModel.h"

#import "PublicAccountClient.h"

#import "NoPublicNumberCell.h"

@interface ServiceNumberAllListViewController : UITableViewController

@property(nonatomic,assign) ServiceNumberListType serviceNumberListType;

@end
