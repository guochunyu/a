//
//  CreateEnterPriseViewController.h
//  e企
//
//  Created by zw on 15/4/20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateEnterPriseSuccess <NSObject>

-(void)createEnterPriseSuccess;

@end

@interface CreateEnterPriseViewController : UIViewController <MBProgressHUDDelegate>
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, assign) id<CreateEnterPriseSuccess> createSuccessDel;
@end
