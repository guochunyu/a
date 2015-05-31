//
//  TaskViewController.h
//  mobok
//
//  Created by huangxiao on 15/1/20.
//  Copyright (c) 2015年 shanpow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskViewDelegate <NSObject>

-(void)reloadTaskStatusInMessageView;

@end

@interface TaskViewController : UIViewController
@property (nonatomic, assign) id<TaskViewDelegate> taskViewDelegate;
@property (nonatomic, strong)  UIButton *rightButton;
@end
