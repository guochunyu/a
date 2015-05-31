//
//  ServiceNumberAllListCell.h
//  O了
//
//  Created by 卢鹏达 on 14-3-3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define ROW_COLUMN 3    //列数
#import <UIKit/UIKit.h>
@class ServiceNumberAllListCell;

@protocol ServiceNumberAllListCellDelegate <NSObject>
/**
 *  点击按钮后进入消息界面
 *
 *  @param cell     所在类
 *  @param snInfo   服务号信息
 */
- (void)serviceNumberAllListCell:(ServiceNumberAllListCell *)cell clickServiceNumberInfo:(PublicaccountModel *)snInfo;
/**
 *  长按取消订阅
 *
 *  @param cell     所在类
 *  @param snInfo   服务号信息
 */
- (void)serviceNumberAllListCell:(ServiceNumberAllListCell *)cell deleteServiceNumberInfo:(PublicaccountModel *)snInfo;
@end


@interface ServiceNumberAllListCell : UITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier useGesture:(BOOL)gesture;

@property(nonatomic,assign) id<ServiceNumberAllListCellDelegate> delegate;

@property(nonatomic,strong) NSArray *arraySub;

@end
