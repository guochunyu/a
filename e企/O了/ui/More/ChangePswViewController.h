//
//  ChangePswViewController.h
//  e企
//
//  Created by xuxue on 14/11/18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWInsetsTextField.h"

@interface ChangePswViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic, weak)IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak)IBOutlet MWInsetsTextField *text_oldPsw;
@property (nonatomic, weak)IBOutlet MWInsetsTextField *text_newPsw;
@property (nonatomic, weak)IBOutlet MWInsetsTextField *text_reNewPsw;
//@property (nonatomic, weak)IBOutlet UIButton *btn_sure;

- (void)changePsw:(id)sender;

@end
