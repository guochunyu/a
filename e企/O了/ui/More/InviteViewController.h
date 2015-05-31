//
//  InviteViewController.h
//  e企
//
//  Created by xuxue on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MWInsetsTextField.h"

@interface InviteViewController : UIViewController

@property (nonatomic, weak)IBOutlet MWInsetsTextField *text_phone;
@property (nonatomic, weak)IBOutlet UIButton *btn_Sure;

-(IBAction)inviteFriend:(id)sender;

@end
