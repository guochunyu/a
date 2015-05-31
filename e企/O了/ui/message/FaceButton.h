//
//  FaceButton.h
//  O了
//
//  Created by 化召鹏 on 14-1-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceView.h"


typedef void (^FaceButtonClick)(id sender);

@class FaceButton;
@protocol FaceButtonDelegate <NSObject>

-(void)sendFace:(UITextView *)textView;

@end

@interface FaceButton : UIButton<FaceViewDelegate>{
    
}
@property(strong,nonatomic)UIMyTextView *inputTextView;
@property(strong,nonatomic,readwrite) FaceView *inputView;
@property(nonatomic,copy)FaceButtonClick faceClick;
@property(nonatomic,assign)id<FaceButtonDelegate> delegate;
@end
