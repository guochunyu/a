//
//  ServiceNumberAllListCell.m
//  O了
//
//  Created by 卢鹏达 on 14-3-3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define TAG_START 100   //tag起始值
#define CONTROL_SPACE_DISTANCE 25  //控件间距
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width

#import "ServiceNumberAllListCell.h"
#import "ButtonTopImageAndBottomTitle.h"
#import "ServiceNumberDetailViewController.h"

@interface ServiceNumberAllListCell()<UIAlertViewDelegate>

@end

@implementation ServiceNumberAllListCell
#pragma mark 初始化
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier useGesture:(BOOL)gesture
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        self.backgroundColor=[UIColor clearColor];
        //buttom的Frame
        CGFloat hight=(IPHONE_WIDTH-CONTROL_SPACE_DISTANCE*(ROW_COLUMN+1))/ROW_COLUMN;
        CGFloat width=hight-[@"测试" sizeWithFont:[UIFont systemFontOfSize:14]].height;
        //添加Button
        for (int i=0; i<ROW_COLUMN; i++) {
            ButtonTopImageAndBottomTitle *button=[[ButtonTopImageAndBottomTitle alloc]initWithFrame:CGRectMake(CONTROL_SPACE_DISTANCE+(hight-width)*0.5+(hight+CONTROL_SPACE_DISTANCE)*i, CONTROL_SPACE_DISTANCE+5, width, hight)];
            button.tag=TAG_START+i;
            //去除点击Button高亮
            button.adjustsImageWhenHighlighted=YES;
            button.highlighted=NO;
    
            //button事件
            [button addTarget:self action:@selector(toSNDetail:) forControlEvents:UIControlEventTouchUpInside];
            /*
            if (gesture) {
                //button长按事件
                UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(unsubscribeSN:)];
                longPress.minimumPressDuration=0.5;
                [button addGestureRecognizer:longPress];
            }
             */
            [self.contentView addSubview:button];
        }
    }
    return self;
}
#pragma mark 重写方法
- (void)setArraySub:(NSArray *)arraySub
{
    for (int i=0; i<ROW_COLUMN; i++) {
        int tag=i+TAG_START;
        ButtonTopImageAndBottomTitle *button=(ButtonTopImageAndBottomTitle *)[self.contentView viewWithTag:tag];
        if(i>arraySub.count-1){
            button.hidden=YES;
        }else{
            
            PublicaccountModel *pm=(PublicaccountModel *)arraySub[i];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            [button setTitle:pm.name forState:UIControlStateNormal];

            [button setImageWithName:pm.logo placeholderImageName:default_headImage];
            button.hidden=NO;
        }
    }
    _arraySub=arraySub;
}
#pragma mark 重写选中动画
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
#pragma mark button事件
#pragma mark 进入服务号详情
- (void)toSNDetail:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(serviceNumberAllListCell:clickServiceNumberInfo:)]) {
        [self.delegate serviceNumberAllListCell:self clickServiceNumberInfo:self.arraySub[sender.tag-TAG_START]];
    }
}
- (void)unsubscribeSN:(UILongPressGestureRecognizer *)sender
{
    
}
#pragma mark 委托事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [self.delegate serviceNumberAllListCell:self deleteServiceNumberInfo:self.arraySub[alertView.tag-TAG_START]];
    }
}
@end
