//
//  CellAddMenb.h
//  O了
//
//  Created by macmini on 14-01-24.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellAddMenb : UITableViewCell

@property (strong, nonatomic)UIImageView *imageView;
@property (strong, nonatomic)UIView * lineView;
@property (nonatomic, strong)UILabel *label_name;
//@property (nonatomic, strong)UIButton *addMenberBtn;

@property (strong, nonatomic)UILabel *label_phonenumber;
//bug4增加label显示
@property(strong,nonatomic)UILabel * layer_hhh;
@property(strong,nonatomic)UILabel*layer_ttt;
@property(strong,nonatomic)UILabel*layer_mmm;
@end
