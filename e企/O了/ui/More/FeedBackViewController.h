//
//  FeedBackViewController.h
//  e企
//
//  Created by xuxue on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface FeedBackViewController : UIViewController<UITextViewDelegate>

@property (nonatomic, weak)IBOutlet UIView *textView;
@property (nonatomic, strong) UILabel *label_num;
@property (nonatomic, strong) UIPlaceHolderTextView *text_feedBack;
@property (nonatomic, weak)IBOutlet UIButton *btn_Submit;

- (IBAction)submitFB:(id)sender;

@end
