//
//  AccountAddCell.h
//  e企
//
//  Created by 陆广庆 on 15/1/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountAddCellDelegate <NSObject>

- (void)refreshViewForAccount;

@end

@interface AccountAddCell : UITableViewCell<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *iAccountText;
@property (weak, nonatomic) IBOutlet UITextField *iPasswordText;
@property (weak, nonatomic) IBOutlet UIButton *iLoginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *iLoginProgress;
@property (nonatomic) id<AccountAddCellDelegate> delegate;
@property (nonatomic,strong)UITableView * ad;
@property(nonatomic,strong)NSMutableArray * emailMutableArray;
@property(nonatomic,strong)NSMutableArray * eArray;
@property(nonatomic,weak)UITableView * tableV;
@property(nonatomic,strong)NSArray * list;
@property(nonatomic,strong)NSArray * emaillala;
- (void)configure:(id<AccountAddCellDelegate>)delegate;

@end
