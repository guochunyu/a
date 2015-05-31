//
//  AddContentCell.m
//  O了
//
//  Created by 卢鹏达 on 14-1-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define CELL_MARGIN_LEFT 10 //左边距
#define CELL_ICON_SIZE 43 //头像大小
#define CELL_ACCESSORYVIEW_SIZE 14 //选中标记大小

#import "AddContentCell.h"

@interface AddContentCell ()

@end

@implementation AddContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //accessoryView设置
        self.accessoryView=[[UIImageView alloc]init];
        //字体设置
        self.textLabel.font=[UIFont systemFontOfSize:17];
        self.detailTextLabel.font=[UIFont systemFontOfSize:14];
        //分割线
        if (IS_IOS_7) {
            self.separatorInset=UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint center=CGPointZero;
    //设置accessoryView的center
    self.accessoryView.bounds=CGRectMake(0, 0, CELL_ACCESSORYVIEW_SIZE, CELL_ACCESSORYVIEW_SIZE);
    center.x=CELL_MARGIN_LEFT+CELL_ACCESSORYVIEW_SIZE/2;
    center.y=self.frame.size.height/2;
    self.accessoryView.center=center;
    //设置imageView的center
    self.imageView.bounds=CGRectMake(0, 0, CELL_ICON_SIZE, CELL_ICON_SIZE);
    center.x+=CELL_ACCESSORYVIEW_SIZE/2+15+CELL_ICON_SIZE/2;
    self.imageView.center=center;
//    self.imageView.layer.cornerRadius=CELL_ICON_SIZE*0.5;
    self.imageView.layer.cornerRadius=5;
    //设置textLabel的center
    CGFloat detailX=center.x;
    center.x=center.x+CELL_ICON_SIZE/2+10+self.textLabel.frame.size.width/2;
    center.y=self.frame.size.height/2-2-self.textLabel.frame.size.height/2;
    self.textLabel.center=center;
    //设置detailTextLabel的frame
    center.x=detailX+CELL_ICON_SIZE/2+10+self.detailTextLabel.frame.size.width/2;
    center.y=self.frame.size.height/2+3+self.detailTextLabel.frame.size.height/2;
    self.detailTextLabel.center=center;
}
@end
