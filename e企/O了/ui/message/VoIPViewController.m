 //
//  VoIPViewController.m
//  e企
//
//  Created by 许学 on 15/1/31.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "VoIPViewController.h"

@interface VoIPViewController ()
{
    AVAudioPlayer *player;
    BOOL _isVoiceOn;
    float topf,bottomf;
    BOOL _ismute;
    BOOL _isvideono;
    BOOL _isprevideo;
    int hour;
    int minute;
    int second;
}

@end

@implementation VoIPViewController

@synthesize
    callId = _callId,
    isVideo = _isVideo,
    isIncoming = _isIncoming;

@synthesize
    phoneNumberLabel = _phoneNumberLabel,
    callingStateLabel = _callingStateLabel,
    endButton = _endButton,
    voiceSpeakerButton = _voiceSpeakerButton,
    backgroundView = _backgroundView,
    backgroudCoverView = _backgroudCoverView,
    preview = _preview,
    remote = _remote,
    headimageview=_headimageview;
@synthesize
    muteButton=_muteButton,
    endLabel=_endLabel,
    voiceSpeakerLabel=_voiceSpeakerLabel,
    muteLabel=_muteLabel,
    nocameraButton=_nocameraButton,
    precameraButton=_precameraButton,
    nocameraLabel=_nocameraLabel,
    precameraLabel=_precameraLabel,
    answerLabel=_answerLabel;


- (UILabel *)phoneNumberLabel
{
    if (!_phoneNumberLabel) {
        _phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 155-topf, 160, 30)];
        _phoneNumberLabel.textColor = [UIColor whiteColor];
        _phoneNumberLabel.textAlignment = NSTextAlignmentCenter;
        _phoneNumberLabel.font = [UIFont systemFontOfSize:20];
    }
    return _phoneNumberLabel;
}

- (UILabel *)callingStateLabel
{
    if (!_callingStateLabel) {
        _callingStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 197, 160, 30)];
        _callingStateLabel.textColor = [UIColor whiteColor];
        _callingStateLabel.textAlignment = NSTextAlignmentCenter;
        _callingStateLabel.font = [UIFont systemFontOfSize:18];
    }
    return _callingStateLabel;
}
-(UILabel *)endLabel{
    if(!_endLabel){
        _endLabel=[[UILabel alloc]initWithFrame:CGRectMake(_isIncoming ? 200 : 130, 430+66-bottomf, 60, 30)];
        _endLabel.textColor = [UIColor whiteColor];
        _endLabel.textAlignment = NSTextAlignmentCenter;
        _endLabel.font = [UIFont systemFontOfSize:15];
        _endLabel.alpha=0.6;
       // _endLabel.text=_isIncoming ? @"拒绝" : @"挂断";
    }
    return  _endLabel;
}
-(UILabel *)voiceSpeakerLabel{
    if(!_voiceSpeakerLabel){
        _voiceSpeakerLabel=[[UILabel alloc]initWithFrame:CGRectMake(187.5, 330-bottomf+66, 60, 30)];
        _voiceSpeakerLabel.textColor = [UIColor whiteColor];
        _voiceSpeakerLabel.textAlignment = NSTextAlignmentCenter;
        _voiceSpeakerLabel.font = [UIFont systemFontOfSize:15];
        _voiceSpeakerLabel.alpha=0.6;
       // _voiceSpeakerLabel.text=_isVideo?@"听筒":@"扬声器";
    }
    return  _voiceSpeakerLabel;
}
-(UILabel *)muteLabel{
    if(!_muteLabel){
        _muteLabel=[[UILabel alloc]initWithFrame:CGRectMake(75.5, 330-bottomf+66, 60, 30)];
        _muteLabel.textColor = [UIColor whiteColor];
        _muteLabel.textAlignment = NSTextAlignmentCenter;
        _muteLabel.font = [UIFont systemFontOfSize:15];
        _muteLabel.alpha=0.6;
        //_muteLabel.text=_ismute ? @"开启" : @"静音";
    }
    return  _muteLabel;
}
-(UILabel *)nocameraLabel{
    if(!_nocameraLabel){
        _nocameraLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 430+66-bottomf, 90, 30)];
        _nocameraLabel.textColor = [UIColor whiteColor];
        _nocameraLabel.textAlignment = NSTextAlignmentCenter;
        _nocameraLabel.font = [UIFont systemFontOfSize:14];
        _nocameraLabel.alpha=0.6;
        //_nocameraLabel.text=_isvideono ? @"打开摄像头" : @"禁止摄像头";
    }
    return  _nocameraLabel;
}
-(UILabel *)precameraLabel{
    if(!_precameraLabel){
        _precameraLabel=[[UILabel alloc]initWithFrame:CGRectMake(220, 430+66-bottomf, 90, 30)];
        _precameraLabel.textColor = [UIColor whiteColor];
        _precameraLabel.textAlignment = NSTextAlignmentCenter;
        _precameraLabel.font = [UIFont systemFontOfSize:15];
        _precameraLabel.alpha=0.6;
        //_precameraLabel.text=_isprevideo ? @"后置摄像头" : @"前置摄像头";
    }
    return  _precameraLabel;
}
-(UILabel *)answerLabel{
    if(!_answerLabel){
        _answerLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 430+66-bottomf, 60, 30)];
        _answerLabel.textColor = [UIColor whiteColor];
        _answerLabel.textAlignment = NSTextAlignmentCenter;
        _answerLabel.font = [UIFont systemFontOfSize:15];
        _answerLabel.alpha=0.6;
        //_answerLabel.text=@"接听";
    }
    return _answerLabel;
}

- (UIButton *)endButton
{
    if (!_endButton) {
        _endButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _endButton.frame = CGRectMake(_isIncoming ? 200 : 130, 430-bottomf, 60, 60);
        [_endButton setBackgroundImage:[UIImage imageNamed:@"btn_hang-up_press.png"] forState:UIControlStateHighlighted];
        [_endButton setBackgroundImage:[UIImage imageNamed:@"btn_hang-up_nm.png"] forState:UIControlStateNormal];
        
        [_endButton addTarget:self action:@selector(endAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _endButton;
}
- (UIButton *)answerButton
{
    if (!_answerButton) {
        _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _answerButton.frame = CGRectMake(60, 430-bottomf, 60, 60);
        [_answerButton setImage:_isVideo?[UIImage imageNamed:@"btn_answer_video_nm.png"]:[UIImage imageNamed:@"btn_answer_phone_nm.png"] forState:UIControlStateNormal];
        [_answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerButton;
}

- (UIButton *)voiceSpeakerButton
{
    if (!_voiceSpeakerButton) {
        _voiceSpeakerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceSpeakerButton.frame = CGRectMake(187.5, 330-bottomf, 60, 60);
        [_voiceSpeakerButton setImage:_isVideo?[UIImage imageNamed:@"btn_loudspeake_press.png"]:[UIImage imageNamed:@"btn_loudspeake_nm.png"] forState:UIControlStateNormal];
        [_voiceSpeakerButton addTarget:self action:@selector(voiceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceSpeakerButton;
}

-(UIButton *)muteButton{
    if(!_muteButton){
        _muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _muteButton.frame = CGRectMake(75.5, 330-bottomf, 60, 60);
        [_muteButton setImage:_ismute?[UIImage imageNamed:@"btn_mute_press.png"]:[UIImage imageNamed:@"btn_mute_nm.png"] forState:UIControlStateNormal];
        [_muteButton addTarget:self action:@selector(muteButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _muteButton;
}
- (UIButton *)nocameraButton
{
    if (!_nocameraButton) {
        _nocameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nocameraButton.frame = CGRectMake(25, 430-bottomf, 60, 60);
        [_nocameraButton setImage:_isvideono?[UIImage imageNamed:@"btn_no-photo_press.png"]:[UIImage imageNamed:@"btn_no-photo_nm.png"] forState:UIControlStateNormal];
        [_nocameraButton addTarget:self action:@selector(nocameraClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nocameraButton;
}
- (UIButton *)precameraButton
{
    if (!_precameraButton) {
        _precameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _precameraButton.frame = CGRectMake(235, 430-bottomf, 60, 60);
        [_precameraButton setImage:_isprevideo?[UIImage imageNamed:@"btn_camera-switch_press.png"]:[UIImage imageNamed:@"btn_camera-switch_nm.png"] forState:UIControlStateNormal];
        [_precameraButton addTarget:self action:@selector(precameraClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _precameraButton;
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_backgroundView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"phone_bg.png"]]];
    }
    return _backgroundView;
}

- (UIView *)backgroudCoverView
{
    if (!_backgroudCoverView) {
        _backgroudCoverView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_backgroudCoverView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"vedio_shadow_cover-layer.png"]]];
    }
    return _backgroudCoverView;
}

- (UIView *)preview
{
    if (!_preview) {
        _preview = [[ZmfView alloc] initWithFrame:CGRectMake(0, 25, 100, 140)];
        [self.backgroundView addSubview:_preview];
        Zmf_VideoRenderStart((__bridge void *)(_preview), ZmfRenderViewFx);
    }
    return _preview;
}

- (UIView *)remote
{
    if (!_remote) {
        _remote = [[ZmfView alloc] initWithFrame:self.backgroundView.bounds];
        _remote.backgroundColor = [UIColor clearColor];
        [self.backgroundView insertSubview:_remote belowSubview:_preview];
        Zmf_VideoRenderStart((__bridge void *)(_remote), ZmfRenderViewFx);
    }
    return _remote;
}

- (void)setPhoneNumber:(NSString *)phoneNumber
{
    self.phoneNumberLabel.text = _emodel.name;
}

#pragma mark -挂断

- (void)endAction
{
    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDele.callState = CALLSTATE_TERMED;

    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    if([player isPlaying])
    {
        [player stop];
    }
    Mtc_CallTerm(_callId, EN_MTC_CALL_TERM_STATUS_NORMAL, ZNULL);
    Mtc_RingStop(ZMAXUINT);
    [self audioStop];
    if (_isVideo) {
        [self stopVideo:_callId];
    }
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    MessageModel *mm=[[MessageModel alloc] init];
    NSString* messageId=cfuuidString;
    
    NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
    long long int dateTime=(long long int) nowTime;
    NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *destDateString=[dateFormatter stringFromDate:time];
    if(_callStatus == 1101)
    {
        mm.msg = @"对方不在线";
    }else if (_callStatus == 1001)
    {
        mm.msg = @"对方正忙";
    }else
    {
        if(hour ==0 && minute == 0 && second ==0)
        {
            _callingStateLabel.text = @"未接通";
        }
        mm.msg = _isVideo?[NSString stringWithFormat:@"视频通话%@",_callingStateLabel.text]:[NSString stringWithFormat:@"语音通话%@",_callingStateLabel.text];
    }
    mm.messageID=messageId;
    //收到的消息,to和from都是from
    mm.fileType = _isVideo?9:10;    //视频通话类型为9，音频通话为10
    if(_isIncoming)
    {
        mm.to = _emodel.imacct;
        mm.from  = _emodel.imacct;
    }else
    {
        mm.from = [ConstantObject sharedConstant].userInfo.imacct;
        mm.to  = _emodel.imacct;
    }
    mm.thread=@"";
    mm.chatType = 0;
    mm.receivedTime = destDateString;
    [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
    [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
    [[ConstantObject app]getDelegate:mm];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -answer

- (void)answerAction
{
    [self audioStart];
    [self.view insertSubview:self.voiceSpeakerButton aboveSubview:self.backgroundView];
    
    if (_isVideo) {
        const char *pcCapture = ZmfVideoCaptureFront;
        [self videoCaptureStart];
        Zmf_VideoRenderAdd((__bridge void *)self.preview, pcCapture, 0, ZmfRenderFullScreen);
        Mtc_CallCameraAttach(_callId, pcCapture);
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(UInt32), &audioRouteOverride);
        _isVoiceOn = YES;
    } else {
        _isVoiceOn = NO;
    }
    
    Mtc_CallAnswer(_callId, 0, ZTRUE, _isVideo);
}

#pragma mark -听筒模式or扬声器模式

- (void)voiceButtonClick
{
    if (_isVoiceOn) {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(UInt32), &audioRouteOverride);
    } else {
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(UInt32), &audioRouteOverride);
    }
    _isVoiceOn = !_isVoiceOn;
    //_voiceSpeakerLabel.text=_isVoiceOn ?@"听筒":@"扬声器";
    [_voiceSpeakerButton setImage:_isVoiceOn?[UIImage imageNamed:@"btn_loudspeake_press.png"]:[UIImage imageNamed:@"btn_loudspeake_nm.png"] forState:UIControlStateNormal];
}

#pragma mark -静音开关

-(void)muteButtonClick{
    _ismute=!_ismute;
    //_muteLabel.text=_ismute?@"打开":@"静音";
    [_muteButton setImage:_ismute?[UIImage imageNamed:@"btn_mute_press.png"]:[UIImage imageNamed:@"btn_mute_nm.png"] forState:UIControlStateNormal];
    ZBOOL zbool = _ismute ? ZTRUE:ZFALSE;
     Mtc_CallSetMicMute(_callId,zbool);
    DDLogInfo(@"静音按钮点击");
}

#pragma mark -禁止摄像头

-(void)nocameraClick{
    DDLogInfo(@"点击禁止摄像头");
    _isvideono=!_isvideono;
    [_nocameraButton setImage:_isvideono?[UIImage imageNamed:@"btn_no-photo_press.png"]:[UIImage imageNamed:@"btn_no-photo_nm.png"] forState:UIControlStateNormal];
   // _nocameraLabel.text=_isvideono ? @"打开摄像头" : @"禁止摄像头";
    
    if(_isvideono)
    {
        Zmf_VideoCaptureStopAll();
        Mtc_CallCameraDetach(_callId);

        if (_preview) {
            Zmf_VideoRenderRemoveAll((__bridge void *)_preview);
            Zmf_VideoRenderStop((__bridge void *)_preview);
            [_preview removeFromSuperview];
            _preview = nil;
        }
 
    }else
    {
        const char *pcCapture =_isprevideo ? ZmfVideoCaptureFront: ZmfVideoCaptureBack;
        Zmf_VideoRenderAdd((__bridge void *)self.preview, pcCapture, 0, ZmfRenderFullScreen);
        Mtc_CallCameraAttach(_callId, pcCapture);
        [self videoCaptureStart];
    }
}

#pragma mark -前置or后置摄像头

-(void)precameraClick{
    DDLogInfo(@"点击前置摄像头");
    if(_isvideono)
    {
        [_nocameraButton setImage:[UIImage imageNamed:@"btn_no-photo_nm.png"] forState:UIControlStateNormal];
        _isvideono = NO;
    }

    if(self.changeCamera){
        float aaa=[[NSDate date] timeIntervalSinceDate:self.changeCamera];
        if(aaa<5){
            return ;
        }
    }
    self.changeCamera = [NSDate date];

    _isprevideo=!_isprevideo;
    [_precameraButton setImage:_isprevideo?[UIImage imageNamed:@"btn_camera-switch_press.png"]:[UIImage imageNamed:@"btn_camera-switch_nm.png"] forState:UIControlStateNormal];
    //_precameraLabel.text=_isprevideo ? @"后置摄像头" : @"前置摄像头";
    Zmf_VideoCaptureStopAll();
    Mtc_CallCameraDetach(_callId);
    
    if (_preview) {
        Zmf_VideoRenderRemoveAll((__bridge void *)_preview);
        Zmf_VideoRenderStop((__bridge void *)_preview);
        [_preview removeFromSuperview];
        _preview = nil;
    }
    
    const char *pcCapture =_isprevideo ? ZmfVideoCaptureFront: ZmfVideoCaptureBack;
    Zmf_VideoRenderAdd((__bridge void *)self.preview, pcCapture, 0, ZmfRenderFullScreen);
    Mtc_CallCameraAttach(_callId, pcCapture);
    [self videoCaptureStart];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self audioStart];
    self.changeCamera = nil;
    NSString *path = [[NSString alloc]init];
    DDLogInfo(@"当前屏幕大小￥￥￥%@", NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    if([[UIScreen mainScreen] bounds].size.height>480){
        topf=0;
        bottomf=0;
    }else{
        DDLogInfo(@"需要修正");
        topf=20;
        bottomf=50;
    }
    _ismute=NO;
    _isvideono=NO;
    _isprevideo=YES;
    hour = 0;
    minute = 0;
    second = 0;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"vedio_shadow_cover-layer.png"]];
    [self.view addSubview:self.backgroundView];
    [self.view insertSubview:self.phoneNumberLabel aboveSubview:self.backgroundView];
    [self.view insertSubview:self.callingStateLabel aboveSubview:self.backgroundView];
    if (_isIncoming) {
        path = [[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"mp3"];
        [self.view insertSubview:self.answerButton aboveSubview:self.backgroundView];
        [self.view insertSubview:self.answerLabel aboveSubview:self.backgroundView];
    } else {
        path = [[NSBundle mainBundle] pathForResource:@"RingBack" ofType:@"mp3"];
        [self.view insertSubview:self.voiceSpeakerButton aboveSubview:self.backgroundView];
        [self.view insertSubview:self.voiceSpeakerLabel aboveSubview:self.backgroundView];
        [self.view insertSubview:self.muteButton aboveSubview:self.backgroundView];
        [self.view insertSubview:self.muteLabel aboveSubview:self.backgroundView];
        if(_isVideo){
            [self.view insertSubview:self.nocameraButton aboveSubview:self.backgroundView];
            [self.view insertSubview:self.precameraButton aboveSubview:self.backgroundView];
            [self.view insertSubview:self.nocameraLabel aboveSubview:self.backgroundView];
            [self.view insertSubview:self.precameraLabel aboveSubview:self.backgroundView];
            
        }
    }
    [self.view insertSubview:self.endButton aboveSubview:self.backgroundView];
    [self.view insertSubview:self.endLabel aboveSubview:self.backgroundView];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self selector:@selector(callError:) name:@MtcCallErrorNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(callOutgoing:) name:@MtcCallOutgoingNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(callAlerted:) name:@MtcCallAlertedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(callConnecting:) name:@MtcCallConnectingNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(callTalking:) name:@MtcCallTalkingNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(myCallTermed:) name:@"MyCallTermedNotification" object:nil];
    //头像视图
    if(!_isVideo || _isIncoming){
        _headimageview=[[UIImageView alloc]initWithFrame:CGRectMake(115, 50-topf, 90, 90)];
        _headimageview.layer.masksToBounds = YES;
        _headimageview.layer.cornerRadius = 45.0;
        [_headimageview setImageWithURL:[NSURL URLWithString:_headImageUrl] placeholderImage:[UIImage imageNamed:@"address_icon_person"]];

        [self.view insertSubview:_headimageview aboveSubview:self.backgroundView];
    }
    
    [self playVoice:path];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    
}

#pragma mark - Notification callbacks
#pragma mark -拨号错误
- (void)callError:(NSNotification *)notification
{
    DDLogInfo(@"%@",notification.description);
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    DDLogInfo(@"callerror===>>%d",dwCallId);

}
#pragma mark -正在拨号中
- (void)callOutgoing:(NSNotification *)notification
{
    DDLogInfo(@"%@",notification.description);

    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    DDLogInfo(@"callOutgoing===>>%d",dwCallId);
    
    _callingStateLabel.text = @"正在拨通中...";
    
    Mtc_RingPlay(EN_MTC_RING_RING_BACK, MTC_RING_FOREVER);
    
    //[self audioStart];
    
    if (_isVideo) {
        const char *pcCapture = ZmfVideoCaptureFront;
        [self videoCaptureStart];
        Zmf_VideoRenderAdd((__bridge void *)self.preview, pcCapture, 0, ZmfRenderFullScreen);
        Mtc_CallCameraAttach(_callId, pcCapture);
        
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(UInt32), &audioRouteOverride);
        _isVoiceOn = YES;
    } else {
        [UIDevice currentDevice].proximityMonitoringEnabled = YES;
        _isVoiceOn = NO;
    }
}

#pragma mark -响铃

- (void)callAlerted:(NSNotification *)notification
{
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    ZUINT dwAlertType = [[notification.userInfo objectForKey:@MtcCallAlertTypeKey] unsignedIntValue];
    DDLogInfo(@"callAlerted===>>%d,%d",dwCallId,dwAlertType);
    
    _callingStateLabel.text = @"等待接听...";
}

#pragma mark -正在连接中

- (void)callConnecting:(NSNotification *)notification
{
    [player stop];
    [self audioStart];
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    
    _callingStateLabel.text = @"连接中...";
    
    BOOL isVideo = Mtc_CallHasVideo(dwCallId);
    if (isVideo) {
        Zmf_VideoRenderAdd((__bridge void *)self.remote, Mtc_CallGetName(dwCallId), 0, ZmfRenderAuto);
    }
    if (_isIncoming) {
        _answerButton.hidden = YES;
        _answerLabel.hidden=YES;
        
        [self.view insertSubview:self.voiceSpeakerButton aboveSubview:self.backgroundView];
        [self.view insertSubview:self.voiceSpeakerLabel aboveSubview:self.backgroundView];
        [self.view insertSubview:self.muteButton aboveSubview:self.backgroundView];
        [self.view insertSubview:self.muteLabel aboveSubview:self.backgroundView];
        if(_isVideo){
            [self.view insertSubview:self.nocameraButton aboveSubview:self.backgroundView];
            [self.view insertSubview:self.precameraButton aboveSubview:self.backgroundView];
            [self.view insertSubview:self.nocameraLabel aboveSubview:self.backgroundView];
            [self.view insertSubview:self.precameraLabel aboveSubview:self.backgroundView];
        }
        [_endButton setFrame:CGRectMake(130, 430-bottomf, 60, 60)];
        [_endLabel setFrame:CGRectMake( 130, 430-bottomf+66, 60, 30)];
        _endLabel.text=@"挂断";
        
    }
}

#pragma mark -通话中

- (void)callTalking:(NSNotification *)notification
{
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
    DDLogInfo(@"callTalking===>>%d",dwCallId);
    if(_isVideo){
        [_headimageview removeFromSuperview];
        [_phoneNumberLabel setFrame:CGRectMake(self.view.frame.size.width / 2, topf + 25, 160, 30)];
        [_callingStateLabel setFrame:CGRectMake(self.view.frame.size.width / 2, CGRectGetMaxY(_phoneNumberLabel.frame) + 20, 160, 30)];
    }

    
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    //_callingStateLabel.text = @"通话中...";
}

#pragma mark -终断

- (void)myCallTermed:(NSNotification *)notification
{
    AppDelegate *appDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDele.callState = CALLSTATE_TERMED;

    DDLogInfo(@"%@",notification.description);
    ZUINT dwCallId = [[notification.userInfo objectForKey:@MtcCallIdKey] unsignedIntValue];
//    if(dwCallId != _callId)
//        return;
    
    _callStatus = [[notification.userInfo objectForKey:@MtcCallStatusCodeKey] unsignedIntValue];
    if(_callStatus == 1101)
    {
        _callingStateLabel.text = @"对方不在线";
    }else if (_callStatus == 1001)
    {
        _callingStateLabel.text = @"对方正忙";
    }
    DDLogInfo(@"callTermed===>>%d,%d", dwCallId, _callStatus);
    [self performSelector:@selector(endAction) withObject:nil afterDelay:1.0f];
    //[self endAction];
   // _callingStateLabel.text = @"call ended...";
    
}

#pragma mark - ZMF Audio

#pragma mark -开始音频
- (void)audioStart
{
    ZBOOL bAec = Mtc_MdmGetOsAec();
    const char *pcId = bAec ? ZmfAudioDeviceVoice : ZmfAudioDeviceRemote;
    ZBOOL bAgc = Mtc_MdmGetOsAgc();
    int ret = Zmf_AudioInputStart(pcId, 0, 0, bAec ? ZmfAecOn : ZmfAecOff, bAgc ? ZmfAgcOn : ZmfAgcOff);
    if (ret == 0) {
        ret = Zmf_AudioOutputStart(pcId, 0, 0);
    }
}

#pragma mark -停止音频
- (void)audioStop
{
    Zmf_AudioInputStopAll();
    Zmf_AudioOutputStopAll();
}

#pragma mark - ZMF Video

#pragma mark -开始视频采集
- (void)videoCaptureStart
{
    
    const char *pcCapture =_isprevideo ? ZmfVideoCaptureFront: ZmfVideoCaptureBack;
    unsigned int iVideoCaptureWidth;
    unsigned int iVideoCaptureHeight;
    unsigned int iVideoCaptureFrameRate;
    Mtc_MdmGetCaptureParms(&iVideoCaptureWidth, &iVideoCaptureHeight, &iVideoCaptureFrameRate);
    Zmf_VideoCaptureStart(pcCapture, iVideoCaptureWidth, iVideoCaptureHeight, iVideoCaptureFrameRate);
}

#pragma mark -停止视频
- (void)stopVideo:(ZUINT)dwCallId
{
    Zmf_VideoCaptureStopAll();
    Mtc_CallCameraDetach(dwCallId);
    
    if (_preview) {
        Zmf_VideoRenderRemoveAll((__bridge void *)_preview);
        Zmf_VideoRenderStop((__bridge void *)_preview);
        [_preview removeFromSuperview];
        _preview = nil;
    }
    
    if (_remote) {
        Zmf_VideoRenderRemoveAll((__bridge void *)_remote);
        Zmf_VideoRenderStop((__bridge void *)_remote);
        [_remote removeFromSuperview];
        _remote = nil;
    }
}

-(void)playVoice:(NSString *)path{
    
    //    从path路径中 加载播放器
    //得到AVAudioSession单例对象
    //AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置类别,此处只支持支持播放
    //[audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //[audioSession setActive:YES error:nil];
    //NSError *error_1=nil;
    //NSData *dataAudio = [NSData dataWithContentsOfFile:path options:0 error:&error_1];
    //NSError *error=nil;
    NSURL *url = [NSURL fileURLWithPath:path];//本地路径应该这样写
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //触发play事件的时候会将mp3文件加载到内存中，然后再播放，所以开始的时候可能按按钮的时候会卡，所以需要prepare
    player.delegate = self;
    [player prepareToPlay];
    
    //设置播放循环次数，如果numberOfLoops为负数 音频文件就会一直循环播放下去
    player.numberOfLoops = -1;
    
    //设置音频音量 volume的取值范围在 0.0为最小 0.1为最大 可以根据自己的情况而设置
    player.volume = 1.0f;
    
    [player play];
    
}

#pragma -mark 计时器显示

- (void)onTimer
{
    second ++;
    if(second == 60)
    {
        minute ++;
        second = 0;
    }
    
    if(minute == 60)
    {
        hour ++;
        minute = 0;
    }
    _callingStateLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute,second];

}

#pragma mark - AVAudioPlayDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[AVAudioSession sharedInstance] setActive:NO withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
