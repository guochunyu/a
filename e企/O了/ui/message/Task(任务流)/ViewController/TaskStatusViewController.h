//
//  TaskStatusViewController.h
//  e企
//
//  Created by huangxiao on 15/1/26.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define text_input_tag 124//输入框
#define butt_face_tag 122//表情
#define img_edite_tag 125//
#define butt_add_tag 126
@protocol TaskStatusStopPlayDelegate <NSObject>

@optional

- (void)stopPlay;

@end

@protocol ReloadTaskDelegate <NSObject>

@optional

-(void)reloadTaskSuccess;

-(void)reloadTaskList;

@end

@interface TaskStatusViewController: UIViewController

@property (nonatomic, strong)NSMutableArray *taskMemberArr;
@property (nonatomic, strong) NSDictionary *taskDict;
@property (nonatomic, weak) id<ReloadTaskDelegate> reloadTaskDelegate;
@property (nonatomic, weak) id<TaskStatusStopPlayDelegate> delegate;

- (void)endEditing;

@end
