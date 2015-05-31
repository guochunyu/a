//
//  RYGroupChatSetViewController.h
//  OChat
//
//  Created by 卢鹏达 on 14-1-8.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "menber_info.h"
#import "NavigationVC_AddID.h"

typedef void(^ClearChatData)();
@interface MessageGroupChatSetViewController : UITableViewController<MBProgressHUDDelegate,UIAlertViewDelegate,navigation_addIDDelegaet,UITextFieldDelegate>{
    MBProgressHUD *_HUD;
}

@property(nonatomic,strong) NSString * imacc;
@property (nonatomic,strong) EmployeeModel *groupChatInfo;
@property(nonatomic,strong)RoomInfoModel *roomInfoModel;
@property(nonatomic,assign)NSInteger chatType;///<聊天类型
@property(nonatomic,copy)ClearChatData clearChatData;///<清空消息
@end
