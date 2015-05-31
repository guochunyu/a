//
//  UserDetailCell.m
//  O了
//
//  Created by 卢鹏达 on 14-1-10.
//  Copyright (c) 2014年 roya. All rights reserved.
//
#define IMAGE_SIZE 40   //图片大小
#import "UserDetailCell.h"

@interface UserDetailCell()<UIAlertViewDelegate>

@end

@implementation UserDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialFont];
    }
    return self;
}

#pragma mark 初始化字体
- (void)initialFont
{
    UIFont *font=[UIFont systemFontOfSize:13];
    //textlabel字体设置
    self.textLabel.font=font;
    //detailTextLabel字体设置
    self.detailTextLabel.font=font;
    self.detailTextLabel.textColor=[UIColor blackColor];
    self.detailTextLabel.textAlignment=NSTextAlignmentLeft;
    [self.detailTextLabel setNumberOfLines:INT_MAX];
 
}
#pragma mark 重写UITableViewCell布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    //textLabel的Y坐标
    CGFloat textLabelY=(self.frame.size.height-self.textLabel.frame.size.height)/2;
    //设置textLabel的frame
    CGRect rect=CGRectMake(CELL_MARGIN_LEFT, textLabelY, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.textLabel.frame=rect;
    //设置imageView的frame
    CGFloat imageViewY=(self.frame.size.height-IMAGE_SIZE)/2;
    self.imageView.frame=CGRectMake(rect.origin.x+rect.size.width,imageViewY,IMAGE_SIZE,IMAGE_SIZE);
    self.imageView.layer.masksToBounds = YES;

//    self.imageView.layer.cornerRadius=IMAGE_SIZE*0.5;
    self.imageView.layer.cornerRadius=5;

    //设置detailTextLabel的frame
    self.detailTextLabel.frame=CGRectMake(rect.origin.x+rect.size.width,self.detailTextLabel.frame.origin.y,self.detailTextLabel.frame.size.width,self.detailTextLabel.frame.size.height);
}
#pragma mark 手势 detailLabel
- (void)dtTapGesture:(UITapGestureRecognizer *)sender
{
    if ([self isMobileNumber:self.detailTextLabel.text]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"电话" message:@"是否拨打电话？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
        [alert show];
    }
}
#pragma mark 手机号验证
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 委托事件 alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.detailTextLabel.text]]];
    }
}

@end
