//
//  VoIPViewController.h
//  e企
//
//  Created by 许学 on 15/1/31.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <AVFoundation/AVFoundation.h>

#import "zmf.h"
#import "mtc_api.h"

@interface VoIPViewController : UIViewController<AVAudioPlayerDelegate>

@property (nonatomic, assign) ZUINT callId;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, assign) ZUINT callStatus;

@property (nonatomic, retain) UILabel *phoneNumberLabel;
@property (nonatomic, retain) UILabel *callingStateLabel;
@property (nonatomic, retain) UIButton *endButton;
@property (nonatomic, retain) UIButton *voiceSpeakerButton;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, strong) UIView *backgroudCoverView;
@property (nonatomic, retain) UIView *preview;
@property (nonatomic, retain) UIView *remote;

@property (nonatomic, retain) UIImageView *headimageview;
@property (nonatomic, retain) UIButton *muteButton;
@property (nonatomic, retain) UIButton *nocameraButton;
@property (nonatomic, retain) UIButton *precameraButton;

@property (nonatomic, retain) UILabel *endLabel;
@property (nonatomic, retain) UILabel *voiceSpeakerLabel;
@property (nonatomic, retain) UILabel *muteLabel;
@property (nonatomic, retain) UILabel *nocameraLabel;
@property (nonatomic, retain) UILabel *precameraLabel;
@property (nonatomic, retain) UILabel *answerLabel;

@property (nonatomic, strong) EmployeeModel *emodel;
@property (nonatomic, assign) BOOL isIncoming;
@property (nonatomic, assign) NSString *phoneNumber;
@property (nonatomic, strong) NSString *headImageUrl;
@property (nonatomic, retain) UIButton *answerButton;

@property (nonatomic, strong) NSDate *changeCamera;
//通话计时
@property (nonatomic, strong) NSTimer *timer;

@end
