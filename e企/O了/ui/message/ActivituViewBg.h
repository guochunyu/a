//
//  ActivituViewBg.h
//  e企
//
//  Created by roya-7 on 14/11/7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SendMessageAgain)(NotesData *nd);

@interface ActivituViewBg : UIView
-(id)initWithGetActivityView:(NotesData *)nd;
-(void)addFailView:(NotesData *)notesData;
-(void)sendsucceed;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;///<菊花view
@property(nonatomic,strong)NSTimer *mytimer;
@property(nonatomic,copy)SendMessageAgain sendMessageAgain;///<再次发送按钮
@property(nonatomic,strong)NotesData *nd;
@end