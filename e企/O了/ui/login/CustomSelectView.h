//
//  CustomSelectView.h
//  e企
//
//  Created by royaMAC on 14-11-3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomSelectViewDelegate;


@interface CustomSelectView : UIView<CustomSelectViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIView      *_contentView;
    id          _deledate;
    NSDictionary * dataDic;
}
@property (nonatomic,strong)UILabel * nameLabel;
@property (nonatomic,strong)UILabel * companyNameLabel;
@property (nonatomic,strong)UILabel * nameLabel1;
@property (nonatomic,strong)UILabel * companyNameLabel1;
@property (nonatomic,strong)NSString* title;
/****************************************************/
@property (nonatomic,strong)UITableView * scrollTableView;

@property (nonatomic,strong)NSDictionary * dataDic;
/****************************************************/

- (id)initWithTitle:(NSString *)title  delegate:(id<CustomSelectViewDelegate>)delegate data:(NSDictionary*)dic;

- (void)show;
@end
@protocol CustomSelectViewDelegate <NSObject>

@optional
- (void)myAlertView:(CustomSelectView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end