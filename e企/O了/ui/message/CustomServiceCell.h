//
//  CustomServiceCell.h
//  O了
//
//  Created by roya-7 on 14-9-19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomServiceFirstCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UIView *titleBgView;
@property (weak, nonatomic) IBOutlet UILabel *bitTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bigTitleBgImageView;

@property(nonatomic,copy)NSString *titleText;///<标题

@end

@interface CustomServiceOtherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *detailImage;

@end
