//
//  MailActSettingController.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActSettingController.h"
#import "MailActSettingHandler.h"

@interface MailActSettingController ()

@property (weak, nonatomic) IBOutlet UITextField *iHostName;
@property (weak, nonatomic) IBOutlet UITextField *iServerPortText;
@property (weak, nonatomic) IBOutlet UITextField *iServerHostText;
@property (weak, nonatomic) IBOutlet UIButton *iSaveButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *iHideKeyboardTap;

@property (nonatomic) NSString *serverHost;
@property (nonatomic) NSString *serverPort;

@end


@implementation MailActSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    [_handler initData];
    [self.view addGestureRecognizer:_iHideKeyboardTap];
    _iServerPortText.text = _serverPort;
    _iServerHostText.text = _serverHost;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_iServerHostText becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (IBAction)didSaveButtonClick:(id)sender
{
    NSString *host = _iServerHostText.text;
    NSString *port = _iServerPortText.text;
    [_handler settingCompleted:host port:port];
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)didTextEndOnExit:(UITextField *)sender
{
    if (sender == _iServerHostText) {
        [_iServerPortText becomeFirstResponder];
    }
}


@end