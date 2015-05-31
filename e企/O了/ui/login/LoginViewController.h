//
//  UILoginViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-1-7.
//  Copyright (c) 2014年 royasoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWInsetsTextField.h"
#import "LoginWaitView.h"
@interface LoginViewController : UIViewController
@property (nonatomic,copy) void (^blockEnterMain)();

@property (weak, nonatomic) IBOutlet MWInsetsTextField *txtPhone;
@property (weak, nonatomic) IBOutlet MWInsetsTextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton    *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton    *btnGetPassword;
@property (weak, nonatomic) IBOutlet UIImageView *toobarIMG;
@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@property (weak, nonatomic) IBOutlet UILabel *toobarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *centerLG;
@property (weak, nonatomic) IBOutlet UIImageView *centerLogo;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImg;
@property (weak, nonatomic) IBOutlet UIImageView *pswImg;
@property (weak, nonatomic) IBOutlet UILabel *ZYlabel;

- (IBAction)Login:(id)sender;
- (IBAction)getPassword:(UIButton *)sender;
-(void)restart;
-(void)stop;
@end
