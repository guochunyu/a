//
//  MessageGroupChatSetNameViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupChatInfo;

@interface MessageGroupChatSetNameViewController : UITableViewController<UITextFieldDelegate>

@property(nonatomic,strong) GroupChatInfo *groupChatInfo;

@end
