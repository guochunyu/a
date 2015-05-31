//
//  PersonInfoViewController.h
//  e企
//
//  Created by royaMAC on 14-11-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImagePickerController.h"
#import "ImageFilterProcessViewController.h"

typedef void (^Myblock)(UIImage * UserImage);
@interface PersonInfoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,CustomImagePickerControllerDelegate,ImageFitlerProcessDelegate>

@property (strong, nonatomic) UITableView *table;
@property (nonatomic, copy)Myblock myblock;
@property (strong, nonatomic)UIImage * image11;
@property(nonatomic,strong)UIButton*back;

-(void)useThePersoninfoImageChangeOther:(Myblock)myblock;

@property (strong, nonatomic) NSString *plistUrl;

@end
