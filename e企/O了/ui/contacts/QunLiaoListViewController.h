//
//  QunLiaoListViewController.h
//  O了
//
//  Created by 化召鹏 on 14-3-20.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationVC_AddID.h"
#import "AFClient.h"
#import "MBProgressHUD.h"
#import "RoomInfoModel.h"
#import "QunliaoListCell.h"


@interface QunLiaoListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,navigation_addIDDelegaet,MBProgressHUDDelegate,UIAlertViewDelegate>{
//    UITableView *_qunliao_list_table;
    MBProgressHUD *_HUD;
    BOOL isCreat;
}
@property(nonatomic,strong)UITableView *qunliao_list_table;

@property(nonatomic,assign)BOOL isSelect;//是否是选择

@property(nonatomic,assign)BOOL isFromMultiple;///<是否是从多选中进来

@property(nonatomic,copy)void (^isTransmit)(RoomInfoModel * transmitInfo);
@end
