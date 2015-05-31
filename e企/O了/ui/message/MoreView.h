//
//  MoreView.h
//  O了
//
//  Created by royasoft on 14-2-19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    CameraTypePhoto = 1,//照片
    CameraTypeVideo = 2,//视频
    
} CameraType;//文件类型

typedef enum {
    MoreButtTypePhoto=1,///<图片
    MoreButtTypeCamera=0,///<拍照
    MoreButtTypeCall=2,
    MoreButtTypeVoice=3,
    MoreButtTypeVideo=4
}MoreButtType;///<按钮类型

typedef void(^MoreButtClick)(MoreButtType type);

typedef void (^VoiceEventButtClick)(id sender);
typedef void (^VoiceEventResult)(NSString *result,id sender);

@protocol MoreViewDelegate <NSObject>

-(void)selectCamera:(CameraType)type;

@end


@interface MoreView : UIView <UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate>   {
    NSMutableArray *_moreArray;
    UIScrollView *_view;
    UIPageControl *_morePageControl;
    
}
@property(nonatomic,assign)id<MoreViewDelegate> delegate;
@property (nonatomic, retain) UITextField *inputTextField;
@property (nonatomic, retain) UITextView *inputTextView;

@property(nonatomic,copy)NSString *inputViewTextStr;


@property(nonatomic,copy)MoreButtClick moreButtClick;//更多按钮的点击

@property(nonatomic,copy)VoiceEventButtClick voiceButtClick;
@property(nonatomic,copy)VoiceEventResult voiceResult;
- (id)initWithFrame:(CGRect)frame isgroup:(BOOL)isgroup titlearr:(NSArray *)ary;
@end
