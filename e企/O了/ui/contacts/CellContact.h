//
//  CellContact.h
//  O了
//
//  Created by macmini on 14-01-10.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CellContactDelegate <NSObject>
@optional
-(void)menssegeIDCell:(NSIndexPath *)row type:(BOOL)isSearchTB;
@end

@interface CellContact : UITableViewCell

@property (nonatomic, strong)UILabel *label_name;
@property (nonatomic, strong)UILabel *label_position;



@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, strong)UIButton *messageBtn;
@property (nonatomic, strong)UIButton *calliphoneBtn;
@property (nonatomic, strong)UIView *lineView;
//#warning 化召鹏
@property (nonatomic, strong)NSIndexPath *menssegeID;

@property (nonatomic, assign)BOOL isSearchTB;

@property (weak, nonatomic)id<CellContactDelegate> delegate;
@end
