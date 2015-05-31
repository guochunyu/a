//
//  WriteMeetingViewController.h
//  e企
//
//  Created by a on 15/4/28.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WriteMeetingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *timeTf1;
@property (weak, nonatomic) IBOutlet UITextField *titleTf;
@property (weak, nonatomic) IBOutlet UITextField *addressTf;
@property (weak, nonatomic) IBOutlet UIButton *wangLuo;
@property (weak, nonatomic) IBOutlet UIButton *duanXin;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (weak, nonatomic) IBOutlet UILabel *membersLabel;
@property (weak, nonatomic) IBOutlet UIView *meetDetailCentent;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollBackGround;
@property (strong,nonatomic)NSMutableArray * imageMutableArray;
@property (nonatomic,strong)UIView * imageHeadView;
@property (nonatomic,strong)UIImageView * imageFrame;




@end
