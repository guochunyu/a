//
//  HuiyiTableViewCell.m
//  e企
//
//  Created by a on 15/5/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "HuiyiTableViewCell.h"
#import "HuiyiData.h"
#import "MacroDefines.h"
@implementation HuiyiTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)initCellByHuiyidata:(HuiyiData*)huiyiData
{
    //NSLog(@"%@",dataDict);
    self.huiyidata=huiyiData;
       _titleLabel.text=huiyiData.conf_name;
    _contentlabel.text=huiyiData.content;
    if (huiyiData.conf_time) {
        _timeLabel.text = [HuiyiTableViewCell getTimeStringFromTimeNumberstring:huiyiData.conf_time];
    }else{
        _timeLabel.text=@"无时间";
    }
    if (huiyiData.noconfirm_members.count) {
        _querenLabel.text=[NSString stringWithFormat:@"%d人未确认",huiyiData.noconfirm_members.count];
    }else{
        _querenLabel.text=@"已确认";
    }
    _redImageview.hidden=YES;
    if (![_huiyidata.creator_uid isEqualToString:USER_ID]) {
        for (NSString *uid in huiyiData.noconfirm_members) {
            if ([USER_ID isEqualToString:uid]) {
                _redImageview.hidden=NO;//如果自己还没有确认并且发起人不是自己才显示红点
                break;
            }
        }
    }
}

+(NSString*)getTimeStringFromTimeNumberstring:(NSString*)numberString
{
    if (numberString) {
        if ([numberString isEqualToString:@""]) {
            return @"";
        }
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        formatter.dateFormat=@"yyyy-MM-dd HH:mm";
        NSDate *date=[NSDate dateWithTimeIntervalSince1970:numberString.longLongValue/1000.0];
        return [formatter stringFromDate:date];
    }else{
        return nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
