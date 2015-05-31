//
//  CellFirstThree.h
//  O了
//
//  Created by macmini on 14-01-10.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellFirstThreeDelegate <NSObject>
@optional
-(void)cellFirstThreeCell:(NSIndexPath *)row;
@end

@interface CellFirstThree : UITableViewCell

@property (nonatomic, strong)UILabel *label;
@property (nonatomic, strong)UIImageView *imageView;
@property (retain, nonatomic) UIView *lineView;
@property (nonatomic,strong)UIButton *unitBtn;

@property (nonatomic, strong)UILabel *label1;
@property (nonatomic, strong)UIImageView *imageView1;
@property (retain, nonatomic) UIView *lineView1;
@property (nonatomic,strong)UIButton *qunBtn;

@property (nonatomic, strong)UILabel *label2;
@property (nonatomic, strong)UIImageView *imageView2;
@property (retain, nonatomic) UIView *lineView2;
@property (nonatomic,strong)UIButton *publicBtn;

@property (nonatomic,strong)UIButton *messageBtn;

@property (weak, nonatomic)id<CellFirstThreeDelegate> delegate;

@property (nonatomic, strong)NSIndexPath *menssegeID;
-(void)addChatImage;
@end
