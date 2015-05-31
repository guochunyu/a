//
//  HuiyiTableViewCell.h
//  e企
//
//  Created by a on 15/5/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HuiyiData;
@interface HuiyiTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentlabel;
@property (weak, nonatomic) IBOutlet UILabel *querenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redImageview;
@property(nonatomic,strong) HuiyiData *huiyidata;
-(void)initCellByHuiyidata:(HuiyiData*)huiyiData;
+(NSString*)getTimeStringFromTimeNumberstring:(NSString*)numberString;
@end
