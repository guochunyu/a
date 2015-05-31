//
//  AppDetailViewController.h
//  e企
//
//  Created by shawn on 14/11/12.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "PagePhotosDataSource.h"
//#import "PagePhotosView.h"

@interface AppDetailViewController : UIViewController

@property (nonatomic,strong) id plugin;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *installBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *descpics;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *appContentView;

- (IBAction)installApp:(id)sender;

@end
