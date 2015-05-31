//
//  FindPasswordViewController.h
//  e企
//
//  Created by royaMAC on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWInsetsTextField.h"

@interface FindPasswordViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *MarkedWords;
@property (weak, nonatomic) IBOutlet MWInsetsTextField *textField;
@property (nonatomic,retain)NSString * userName;
- (IBAction)findPassword:(id)sender;

@end
