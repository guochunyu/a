//
//  HuiyiViewController.h
//  e企
//
//  Created by a on 15/4/28.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
//extern NSString*const noticecxd;

@interface HuiyiViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong)NSString *Meeting_Unread;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

//-(void)Transmission_Information;
@end
