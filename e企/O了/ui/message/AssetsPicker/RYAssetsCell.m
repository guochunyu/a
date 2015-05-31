//
//  AssetsCell.m
//  O了
//
//  Created by 卢鹏达 on 14-1-17.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "RYAssetsCell.h"
#import "RYAsset.h"

@implementation RYAssetsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle=UITableViewCellSelectionStyleNone;
        //buttom的Frame
        CGFloat width=(IPHONE_WIDTH-IMAGE_SPACE_DISTANCE*(ROW_COLUMN+1))/ROW_COLUMN;
        
        //添加Button
        for (int i=0; i<ROW_COLUMN; i++) {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            //去除点击Button高亮
            button.adjustsImageWhenHighlighted=YES;
            button.highlighted=NO;
            //frame设置
            button.frame=CGRectMake(IMAGE_SPACE_DISTANCE+(width+IMAGE_SPACE_DISTANCE)*i, IMAGE_SPACE_DISTANCE, width, width);
            button.tag=TAG_START+i;
            //button事件
            [button addTarget:self action:@selector(manageAsstes:event:) forControlEvents:UIControlEventTouchUpInside];
            //给Button添加长按事件
            UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(browerPicture:)];
            longPressGesture.minimumPressDuration=0.3;
            [button addGestureRecognizer:longPressGesture];
            
            [self.contentView addSubview:button];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //    [super setSelected:selected animated:animated];
}
#pragma mark 长按事件，浏览图片
- (void)browerPicture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state==UIGestureRecognizerStateBegan) {
        if (self.blockPreview) {
            int index=sender.view.tag-TAG_START;
            self.blockPreview(self.arrayRowAssets[index]);
        }
    }
}
#pragma mark Button事件，选择数据
- (void)manageAsstes:(UIButton *)sender event:(UIEvent *)event
{
    int tag=sender.tag-TAG_START;
    //选中状态修改
    RYAsset *asset=self.arrayRowAssets[tag];
    BOOL original=asset.selected;
    asset.selected=!asset.selected;
    //获取Button子视图，等于nil时没有选择该资源，添加该资源选中
    UIImageView *checkView = (UIImageView *)[sender viewWithTag:ASSETS_CHECK_TAG];
    if (original==NO&&asset.selected==YES) {
        checkView.image = [UIImage imageNamed:@"file_choice.png"];
    }else{
        checkView.image  = [UIImage imageNamed:@"file_not-choice"];
    }
}
#pragma mark 重写setArrayRowAssets，设置UITableViewCell的显示数据
- (void)setArrayRowAssets:(NSArray *)arrayRowAssets
{
    for (int i=0; i<ROW_COLUMN; i++) {
        int tag=i+TAG_START;
        UIButton *button=(UIButton *)[self.contentView viewWithTag:tag];
        if(i>arrayRowAssets.count-1){
            button.hidden=YES;
        }else{
            RYAsset *asset=(RYAsset *)arrayRowAssets[i];
            [button setImage:[UIImage imageWithCGImage:[asset.asset thumbnail]] forState:UIControlStateNormal];
            button.hidden=NO;
            //重新构造勾选图片
            UIView *checkView=[button viewWithTag:ASSETS_CHECK_TAG];
            [checkView removeFromSuperview];
            UIImageView *imageView=[[UIImageView alloc]init];
            imageView.tag=ASSETS_CHECK_TAG;
            CGFloat x= button.bounds.size.width-IMAGE_CHECK_SIZE;
            CGFloat y= 0;
            imageView.frame=CGRectMake(x, y, IMAGE_CHECK_SIZE, IMAGE_CHECK_SIZE);
            [button addSubview:imageView];
            
            if (asset.selected) {
                imageView.image = [UIImage imageNamed:@"file_choice.png"];
            }
            else imageView.image = [UIImage imageNamed:@"file_not-choice"];
        }
    }
    _arrayRowAssets=arrayRowAssets;
}

@end
