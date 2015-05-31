//
//  ActivituViewBg.m
//  e企
//
//  Created by roya-7 on 14/11/7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ActivituViewBg.h"
#import "MenuButton.h"

@implementation ActivituViewBg{
    BOOL timerisruing;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(id)initWithGetActivityView:(NotesData *)nd{
    self=[super init];
    if (self) {
        _activityView=[[UIActivityIndicatorView alloc] init];
        _activityView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        _activityView.hidesWhenStopped=YES;
        _activityView.frame=CGRectMake(0, 0, 15, 15);
        [_activityView startAnimating];
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_activityView];
        self.nd=nd;
        _mytimer=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
        timerisruing=YES;
        DDLogInfo(@"生成菊花圈%@--%@",_nd.contentsUuid,self);
    }
    return self;
}
-(void)addFailView:(NotesData *)notesData{
    MenuButton *sendFailedButt=[MenuButton buttonWithType:UIButtonTypeCustom];
    sendFailedButt.frame=CGRectMake(0, 0, 15, 15);
    //                [sendFailedButt setTitle:@"失败" forState:UIControlStateNormal];
    [sendFailedButt setImage:[UIImage imageNamed:@"icon_tip"] forState:UIControlStateNormal];
    [sendFailedButt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
    //                    sendFailedButt.tag=chatNotesDataArrayIndex+sendFailedButt_tag;
    sendFailedButt.nd=notesData;
    [self addSubview:sendFailedButt];
    [_activityView stopAnimating];
    //    [_activityView hide:YES];
    [_activityView removeFromSuperview];
}
-(void)timeout{
    DDLogInfo(@"发送超时%@--%@",_nd.contentsUuid,self);
    [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:_nd.contentsUuid state:@"2"];
    [_activityView stopAnimating];
    [self addFailView:_nd];
    timerisruing=NO;
    
}
-(void)sendsucceed{
    DDLogInfo(@"发送成功，菊花圈停止%@--%@",_nd.contentsUuid,self);
    if(timerisruing){
        [_mytimer invalidate];
        [_activityView stopAnimating];
    }
}
-(void)sendMessageAgain:(MenuButton *)sender{
    if (self.sendMessageAgain) {
        self.sendMessageAgain(sender.nd);
    }
}
@end