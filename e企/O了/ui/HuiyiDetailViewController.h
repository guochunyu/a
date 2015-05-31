//
//  HuiyiDetailViewController.h
//  e企
//
//  Created by a on 15/5/6.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>


@class HuiyiData;
@interface HuiyiDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *didianlabel;
@property (weak, nonatomic) IBOutlet UILabel *contentlabel;
@property (weak, nonatomic) IBOutlet UILabel *faqiLabel;
@property(nonatomic,strong) HuiyiData *huiyidata;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIView *faqiView;

@end
