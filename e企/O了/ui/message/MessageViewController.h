//
//  MessageViewController.h
//  O了
//
//  Created by macmini on 14-01-08.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MessageChatViewController.h"
#import "MBProgressHUD.h"
#import "ServiceNumberWebViewController.h"

#import "NoNetworkCell.h"
#import "NoNetworkViewController.h"

#import "NavigationVC_AddID.h"

#import "ChatListModel.h"

#import "PublicAccountListViewController.h"
#import "ContactsCheck.h"

static NSString *const isAlreadyLoadMessageList=@"isAlreadyLoadMessageList";//是否已经加载过首页数据
static NSString *const haveSendMessage=@"haveSendMessage";

@interface MessageViewController : UITableViewController<ShowUnreadDelegate,MBProgressHUDDelegate,UIAlertViewDelegate,navigation_addIDDelegaet,ContactsCheckDelegate>{
    MBProgressHUD *_HUD;
    AFClient *client;
}

@property(strong,nonatomic)IBOutlet UILabel *label;
@end
