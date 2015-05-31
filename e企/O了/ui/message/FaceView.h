//
//  FaceView.h
//  O了
//
//  Created by 化召鹏 on 14-1-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIMyTextView.h"

typedef void(^FaceViewButtClick)(id sender);

@protocol FaceViewDelegate <NSObject>

-(void)sendFaceButtClick:(UITextView *)textView;

@end

@interface FaceView : UIView<UIScrollViewDelegate>{

    UIPageControl *_facePageControl;
}
@property (nonatomic, retain) UITextField *inputTextField;
@property (nonatomic, retain) UIMyTextView *inputTextView;
@property(nonatomic,assign)id<FaceViewDelegate> delegate;
@property (nonatomic,retain)    UIScrollView *faceView;

@property(nonatomic,copy)FaceViewButtClick faceClick;

@end
