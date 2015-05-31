//
//  TaskCreateViewController.h
//  e企
//
//  Created by huangxiao on 15/1/26.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskTools.h"

#define DatePickerHeight        330

@protocol CreateTaskDelegate <NSObject>

@optional

-(void)createTaskSuccess;

@end

@interface TaskCreateViewController : UIViewController

@property (nonatomic, strong)NSMutableArray *array;

@property (nonatomic, copy)NSString *detailText;

@property (nonatomic, assign) BOOL isFromMessage;

@property (nonatomic, assign) BOOL isFromContact;

@property (nonatomic, weak) id<CreateTaskDelegate> createTaskDelegate;

@end
