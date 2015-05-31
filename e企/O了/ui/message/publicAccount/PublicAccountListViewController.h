//
//  PublicAccountListViewController.h
//  e企
//
//  Created by roya-7 on 14/11/27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIMyViewController.h"
#import "MessageChatViewController.h"

@interface PublicAccountListViewController : UIMyViewController
@property (strong,nonatomic) NSArray * messagesArray;

-(void)reloadTabel;
@end
