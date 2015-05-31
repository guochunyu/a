//
//  ButtonRecord.m
//  O了
//
//  Created by 卢鹏达 on 14-1-14.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#define HUD_IMG_TAG 600             //指示器imageview的tag
#define HUD_LABEL_TAG 800           //指示器label的tag
#define HUD_CUSTOMVIEW_WIDTH 130    //指示器自定义视图宽
#define HUD_CUSTOMVIEW_HEIGHT 120   //指示器自定义视图高
#define HUD_IMG_WIDTH 81            //指示器imageview的宽
#define HUD_IMG_HEIGHT 90           //指示器imageview的高
#define HUD_LABEL_FONT_SIZE 12      //指示器字体大小
#define RECORDER_DURATION 180        //默认录音最大时长

#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "ButtonAudioRecorder.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"
@interface ButtonAudioRecorder()<AVAudioRecorderDelegate>{
    MBProgressHUD *_progressHUD;        ///<指示器
    NSTimer *_timer;                    ///<定时器
    AVAudioRecorder *_recorder;         ///<录音 AVAudioRecorder
    BOOL _sendFlag;                     ///<YES发送，NO没有发送
    
    NSString *_originTitle;             ///<原始titile
    NSString *_changeTitle;             ///<改动title
    NSString *_upChangeTitle;           ///<上滑改动title
    
    UIImage *_originImage;              ///<原始Image
    UIImage *_changeImage;              ///<改动Image
    UIImage *_upChangeImage;            ///<上滑改动Image
    
    UIImage *_originBackgroundImage;    ///<原始groundImage
    UIImage *_changeBackgroundImage;    ///<改动groundImage
    UIImage *_upChangeBackgroundImage;  ///<上滑改动groundImage
    
    BOOL _volumeAnimation;              ///<音量变化
    BOOL islongtouch;                   ///是否长按
    UIView *showview;                   ///语音输入界面
    UIImageView *voiceimage;            ///语音
    UIImageView *cancelbutton;          ///取消区域
    UIImageView *pointview;             ///手指指示视图
    BOOL istosend;                      ///是否要发送
    BOOL isneedsend;   ///是否需要发送
    UILabel *label3;
    float subheight;
}

@end

@implementation ButtonAudioRecorder
#pragma mark - 生命周期
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化
        [self initial];
    }
    return self;
}
- (void)awakeFromNib
{
    //初始化
    [self initial];
}
#pragma mark 初始化
- (void)initial
{
    self.recorderDuration=RECORDER_DURATION;
    _originImage=self.imageView.image;
    _originTitle=self.titleLabel.text;
    _originBackgroundImage=self.currentBackgroundImage;
    self.adjustsImageWhenHighlighted=NO;
    islongtouch=NO;
    subheight=[UIScreen mainScreen].bounds.size.height>480? 0:60; //4S修正
    //    //按下
    //    [self addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    //    //内部松开
    //    [self addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    //    //外部松开
    //    [self addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    //    //进入内部
    //    [self addTarget:self action:@selector(touchDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    //    //进入外部
    //    [self addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit];
    //触摸取消事件
    [self addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchCancel];
}
#pragma mark - 重写Button方法
#pragma 重写高亮的方法
- (void)setHighlighted:(BOOL)highlighted{}
#pragma mark title方法重写
- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    if (state==UIControlStateNormal) {
        if (_originTitle==nil) {
            _originTitle=title;
        }
        if (_changeTitle==nil) {
            _changeTitle=title;
        }
        if (_upChangeTitle==nil) {
            _upChangeTitle=title;
        }
    }
}
#pragma mark image方法重写
- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    if (state==UIControlStateNormal) {
        if(_originImage==nil){
            _originImage=image;
        }
        if (_changeImage==nil) {
            _changeImage=image;
        }
        if (_upChangeImage==nil) {
            _upChangeImage=image;
        }
    }
}
#pragma mark backgroundImage方法重写
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
    [super setBackgroundImage:image forState:state];
    if (state==UIControlStateNormal) {
        if(_originBackgroundImage==nil){
            _originBackgroundImage=image;
        }
        if (_changeBackgroundImage==nil) {
            _changeBackgroundImage=image;
        }
        if (_upChangeBackgroundImage==nil) {
            _upChangeBackgroundImage=image;
        }
    }
}
#pragma mark - 类公有方法
#pragma mark 设置改动标题
- (void)setChangeTitle:(NSString *)title
{
    _changeTitle=title;
    if ([_upChangeTitle isEqualToString:_originTitle]) {
        _upChangeTitle=_changeTitle;
    }
}
#pragma mark 设置上滑改动标题
- (void)setUpChangeTitle:(NSString *)title
{
    _upChangeTitle=title;
}
#pragma mark 设置改动图片
- (void)setChangeImage:(UIImage *)image
{
    _changeImage=image;
    if ([_upChangeImage isEqual:_originImage]) {
        _upChangeImage=_changeImage;
    }
}
#pragma mark 设置上滑改动图片
- (void)setUpChangeImage:(UIImage *)image
{
    _upChangeImage=image;
}
#pragma mark 设置改动背景图片
- (void)setChangeBackgroundImage:(UIImage *)backgroundImage
{
    _changeBackgroundImage=backgroundImage;
    if ([_upChangeBackgroundImage isEqual:_originBackgroundImage]) {
        _upChangeBackgroundImage=_changeBackgroundImage;
    }
}
#pragma mark 设置上滑改动背景图片
- (void)setUpChangeBackgroundImage:(UIImage *)backgroundImage
{
    _upChangeBackgroundImage=backgroundImage;
}
#pragma mark - 自定义Target方法
#pragma mark 按下不动，开始录音
- (void)touchDown:(UIButton *)button
{
    //    BOOL RESULT = [ConstantObject sharedConstant].avdioGranted;
    //    if (RESULT) {
    //
    //    }else{
    //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"麦克风被禁用" message:@"请在iPhone的\"设置-隐私-麦克风\"中允许O了访问你的麦克风." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    //        [alert show];
    //    }
    [self allocButtAudio:button];
}

#pragma mark 进入内部
- (void)touchDragEnter:(UIButton *)button
{
    [button setTitle:_changeTitle forState:UIControlStateNormal];
    [button setImage:_changeImage forState:UIControlStateNormal];
    [button setBackgroundImage:_changeBackgroundImage forState:UIControlStateNormal];
    [self progressHUDLabel:@"手指上滑，取消发送" warning:NO];
    [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_1.png"]];
}
#pragma mark 进入外部
- (void)touchDragExit:(UIButton *)button
{
    [button setTitle:_upChangeTitle forState:UIControlStateNormal];
    [button setImage:_upChangeImage forState:UIControlStateNormal];
    [button setBackgroundImage:_upChangeBackgroundImage forState:UIControlStateNormal];
    [self progressHUDLabel:@"松开手指，取消发送" warning:YES];
    [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_1.png"]];
}
#pragma mark 内部松开，发送语音
- (void)touchUpInside:(UIButton *)button
{
    if (!_sendFlag) {
        //发送语音
        islongtouch=NO;
        [self sendAudioMessageWithSendFlag:YES timeout:NO];
    }
}
#pragma mark 外部松开,取消发送语音
- (void)touchUpOutside:(UIButton *)button
{
    if (!_sendFlag) {
        //取消发送语音
        islongtouch=NO;
        [self sendAudioMessageWithSendFlag:NO timeout:NO];
    }
}
#pragma mark 触摸取消事件
- (void)touchCancel:(UIButton *)sender
{
    DDLogInfo(@"触摸取消%d",_sendFlag);
    if (!_sendFlag) {
        islongtouch=NO;
        [self sendAudioMessageWithSendFlag:NO timeout:NO];
    }
}
#pragma mark 程序进入后台
- (void)applicationWillResignActive:(NSNotification *)notification
{
    DDLogInfo(@"程序进入后台%d",_sendFlag);
    if (!_sendFlag) {
        islongtouch=NO;
        [self sendAudioMessageWithSendFlag:NO timeout:NO];
    }
    return;
    
    if (!_sendFlag) {
        islongtouch=NO;
        [self sendAudioMessageWithSendFlag:YES timeout:NO];
    }
}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}
#pragma mark-----程序终止
- (void)applicationWillTerminate:(NSNotification *)notification
{
//  保存已经录制的声音
    if (!_sendFlag) {
        [self sendAudioMessageWithSendFlag:NO timeout:NO];
    }
}
#pragma mark----程序激活
//- (void)applicationWillResignActive:(NSNotification*)notification
//{
//
//}
#pragma mark - AVAudioRecorderDelegate委托事件
#pragma mark 录音结束
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
//    DDLogInfo(@"录音结束%d",flag);
    if(!flag){
        [self sendAudioMessageWithSendFlag:NO timeout:NO];
        isneedsend=NO;
        return ;
    }
    if (!_sendFlag) {
        islongtouch=NO;
        [self sendAudioMessageWithSendFlag:YES timeout:YES];
        isneedsend=NO;
    }
}
#pragma mark - 类私有方法
#pragma mark AVAudioRecorder设置
- (void)initialRecord
{
    //录音权限设置，IOS7必须设置，得到AVAudioSession单例对象
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置类别,此处只支持支持录音
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    //启动音频会话管理,此时会阻断后台音乐的播放
    [audioSession setActive:YES error:nil];
    //录音参数设置设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    //    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //录音文件保存的URL
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
    NSString *catchPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    //AAC大写的话，android收到播放不出来，问题暂且不清楚
    //    NSString *audioRecordFilePath=[catchPath stringByAppendingPathComponent:[NSString stringWithFormat:@"andron_voice/%@.AAC", cfuuidString]];
    
    NSString *audioRecordFilePath=[catchPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/file/voice/temp/%@.caf", cfuuidString]];
    //判断目录是否存在不存在则创建
    NSString *audioRecordDirectories = [audioRecordFilePath stringByDeletingLastPathComponent];
    DDLogInfo(@"%@",audioRecordDirectories);
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:audioRecordDirectories]) {
        [fileManager createDirectoryAtPath:audioRecordDirectories withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURL *url = [NSURL fileURLWithPath:audioRecordFilePath];
    NSError *error=nil;
    //初始化AVAudioRecorder
    _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&error];
    if (error != nil) {
        //DDLogInfo(@"初始化录音Error: %@",error);
    }else{
        if ([_recorder prepareToRecord]) {
            //录音最长时间
            [_recorder recordForDuration:self.recorderDuration-1];
            _recorder.delegate=self;
            [_recorder record];
            
            //开启音量检测
            _recorder.meteringEnabled = YES;
            //开启定时器，音量监测
            _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(volumeMeters:) userInfo:nil repeats:YES];
        }
    }
}
#pragma mark 实时监测音量变化
- (void)volumeMeters:(NSTimer *)timer
{
    if (_volumeAnimation) {
        //刷新音量数据
        [_recorder updateMeters];
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
//                DDLogInfo(@"tttt%f",lowPassResults);
        if (lowPassResults<=0.36) {
            [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_1.png"]];
        }else if (0.36<lowPassResults<=0.6) {
            [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_2.png"]];
        }else if (0.6<lowPassResults<=0.78) {
            [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_3.png"]];
        }else if (0.78<lowPassResults<=0.85) {
            [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_4.png"]];
        }else if (0.85<lowPassResults<=0.9) {
            [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_5.png"]];
        }else if (0.9<lowPassResults) {
            [voiceimage setImage:[UIImage imageNamed:@"icon_voice_playing_6.png"]];
        }
    }
    label3.text=[NSString stringWithFormat:@"%d\"",(int)_recorder.currentTime];
//    DDLogInfo(@"当前录音时间%f",_recorder.currentTime);
}
#pragma mark 指示器设置
- (void)initialProgressHUD
{
    CGFloat marginImgLb=10.f;
    CGFloat marginLb=5.f;
    NSString *stringAlert=@"手指上滑，取消发送";
    UIFont *fontLabel=[UIFont systemFontOfSize:HUD_LABEL_FONT_SIZE];
    CGFloat labelHeight=[stringAlert sizeWithFont:fontLabel].height+2*marginLb;
    _progressHUD=[MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    
    //隐藏时从父视图中移除
    _progressHUD.removeFromSuperViewOnHide=YES;
    //允许显示自定义视图
    _progressHUD.mode=MBProgressHUDModeCustomView;
    _progressHUD.opacity=0.6;
    //外框架view
    UIView *customView=[[UIView alloc]init];
    customView.bounds=CGRectMake(0, 0, HUD_CUSTOMVIEW_WIDTH, HUD_CUSTOMVIEW_HEIGHT);
    //imageview
    UIImageView *imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ButtonAudioRecorder.bundle/record_animate_1.png"]];
    imageView.tag=HUD_IMG_TAG;
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    imageView.bounds=CGRectMake(0, 0, HUD_IMG_WIDTH, HUD_IMG_HEIGHT);
    imageView.center=CGPointMake(HUD_CUSTOMVIEW_WIDTH*0.5, HUD_IMG_HEIGHT*0.5);
    //label
    UILabel *label=[[UILabel alloc]init];
    label.tag=HUD_LABEL_TAG;
    label.font=fontLabel;
    label.textAlignment=NSTextAlignmentCenter;
    label.text=stringAlert;
    //圆角
    label.layer.cornerRadius=3;
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor whiteColor];
    label.frame=CGRectMake(0, HUD_IMG_HEIGHT+marginImgLb, HUD_CUSTOMVIEW_WIDTH, labelHeight);
    //添加到view中
    [customView addSubview:imageView];
    [customView addSubview:label];
    _progressHUD.customView=customView;
}
#pragma mark 设置指示器的label
- (void)progressHUDLabel:(NSString *)text warning:(BOOL)warning
{
    UIView *customView=_progressHUD.customView;
    UILabel *label=(UILabel *)[customView viewWithTag:HUD_LABEL_TAG];
    if (warning) {
        label.backgroundColor=[UIColor colorWithRed:1 green:0.08 blue:0.02 alpha:0.6];
    }else{
        label.backgroundColor=[UIColor clearColor];
    }
    label.text=text;
}
#pragma mark 设置指示器的imageView
- (void)progressHUDImageView:(UIImage *)image animation:(BOOL)animation
{
    _volumeAnimation=animation;
    UIView *customView=_progressHUD.customView;
    UIImageView *imageView=(UIImageView *)[customView viewWithTag:HUD_IMG_TAG];
    [imageView setImage:image];
}
#pragma mark 发送语音信息
/**
 *  发送语言信息
 *
 *  @param sendflag    YES发送，NO取消发送
 *  @param timeoutFlag YES超时，NO没有超时
 */
- (void)sendAudioMessageWithSendFlag:(BOOL)sendflag timeout:(BOOL)timeoutFlag
{
//    DDLogInfo(@"发送消息%d %d",sendflag,timeoutFlag);
    [showview removeFromSuperview];
    [self removeNotification];
    //获取录音时长
    double longTime = timeoutFlag?self.recorderDuration:_recorder.currentTime;
    //停止录音
    [_recorder stop];
    //录音权限设置
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    //    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    [audioSession setActive:NO withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:nil];
    //button状态切换
    [self setTitle:_originTitle forState:UIControlStateNormal];
    [self setImage:_originImage forState:UIControlStateNormal];
    [self setBackgroundImage:_originBackgroundImage forState:UIControlStateNormal];
    //停止运行计时器
    if ([_timer isValid]) {
        [_timer invalidate];
    }
    //发送语音
    NSMutableDictionary *dicAudioInfo=[[NSMutableDictionary alloc]init];
    if (sendflag) {             //发送语音
        if (longTime < 1) {
            
            [self initialProgressHUD];
            [self progressHUDLabel:@"说话时间太短" warning:NO];
            [self progressHUDImageView:[UIImage imageNamed:@"ButtonAudioRecorder.bundle/record_shorttime.png"] animation:NO];
            //0.5秒后隐藏指示器
            [_progressHUD hide:YES afterDelay:0.5];
            _progressHUD.userInteractionEnabled=NO;
            
            //删除录音文件
            [_recorder deleteRecording];
            sendflag=NO;
        }else{
            //转为mp3
            
            NSString *fileName=[_recorder.url.path lastPathComponent];
            NSString *filePath=_recorder.url.path;
            NSString *mp3Path=[self audio_PCMtoMP3Path:filePath fileName:[fileName stringByDeletingPathExtension]];
            if (mp3Path) {
                [_progressHUD hide:YES];
                
                NSString *voiceName=[fileName stringByDeletingPathExtension];
                [dicAudioInfo setValue:[NSString stringWithFormat:@"%@%@",voice_path,[mp3Path lastPathComponent]] forKey:AudioRecorderPath];
                voiceName=[NSString stringWithFormat:@"%@_%.0f.mp3",voiceName,(longTime*10+0.5)/10];
                [dicAudioInfo setValue:voiceName forKey:AudioRecorderName];
                [dicAudioInfo setValue:[NSString stringWithFormat:@"%.0f",(longTime*10+0.5)/10] forKey:AudioRecorderDuration];
            }else{
                DDLogInfo(@"mp3转换失败");
                [_progressHUD hide:YES];
            }
            
            
        }
    }else{                  //取消发送
        [_recorder deleteRecording];
        [_progressHUD hide:YES];
    }
    //调用委托
    [self.delegate buttonAudioRecorder:self didFinishRcordWithAudioInfo:dicAudioInfo sendFlag:sendflag];
    //移除监听器
    //    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _timer = nil;
    _recorder = nil;
    _progressHUD = nil;
    _sendFlag = YES;
}

- (NSString *)audio_PCMtoMP3Path:(NSString *)aacPath fileName:(NSString *)voiceName
{
    //    NSString *cafFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.caf"];
    
    //    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/downloadFile.mp3"];
    //                20141110162028350_7_audiorecord.mp3
    NSString *mp3FilePath=[[NSString stringWithFormat:@"/file/voice/%@.mp3", voiceName] filePathOfCaches];
    
    //判断目录是否存在不存在则创建
    
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([aacPath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        
        //        NSFileManager* fileManager=[NSFileManager defaultManager];
        //        if([fileManager removeItemAtPath:aacPath error:nil])
        //        {
        //            DDLogInfo(@"删除aac文件");
        //        }
        [_recorder deleteRecording];
        return mp3FilePath;
    }
    @catch (NSException *exception) {
        DDLogInfo(@"%@",[exception description]);
        return nil;
    }
}
#pragma mark 初始化
-(void)longtouch{
    [self.delegate buttonAudioRecorder:self begintouch:islongtouch];
    if(islongtouch){
        [self allocButtAudio:self];
        [self initshowview];
        isneedsend=YES;
    }else{
        islongtouch=NO;
        isneedsend=NO;
        //        [self.delegate buttonAudioRecorder:self begintouch:islongtouch];
    }
}
-(void)allocButtAudio:(UIButton *)button{
    _sendFlag=NO;
    _volumeAnimation=YES;
    [button setTitle:_changeTitle forState:UIControlStateNormal];
    [button setImage:_changeImage forState:UIControlStateNormal];
    [button setBackgroundImage:_changeBackgroundImage forState:UIControlStateNormal];
    //设置AVAudioRecorder
    [self initialRecord];
    //指示器设置
    //    [self initialProgressHUD];
    //注册进入后台监听事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //程序进入挂起监听事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    //程序重新激活
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}
-(UIImage*) imageWithColor:(UIColor*)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
-(void)initshowview{
    

    
    showview=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    [showview setBackgroundColor:[UIColor clearColor]];
    UIImageView *tt=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    
    tt.image=self.image;
    
//    tt.image=[[self imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]] applyLightEffect];
//    tt.alpha=0.5;
    [showview addSubview:tt];
    UIView *bcview=[[UIView alloc]initWithFrame:showview.frame];
    bcview.alpha=0.8;
    bcview.backgroundColor=[UIColor whiteColor];
    [showview addSubview:bcview];
    voiceimage=[[UIImageView alloc]initWithFrame:CGRectMake(117, 239-subheight, 85, 85)];
    voiceimage.image=[UIImage imageNamed:@"icon_voice_nm.png"];
    voiceimage.tag=HUD_IMG_TAG;
    [showview addSubview:voiceimage];
    UILabel *label1=[[UILabel alloc]initWithFrame:CGRectMake(50, 145-subheight, 220, 20)];
    label1.textAlignment=NSTextAlignmentCenter;
    label1.font= [UIFont systemFontOfSize:19];
    label1.text=@"按住说话  松手发送";
    label1.textColor=[UIColor colorWithRed:64/255.0 green:134/255.0 blue:244/255.0 alpha:1];
    UILabel *label2=[[UILabel alloc]initWithFrame:CGRectMake(50, 180-subheight, 220, 15)];
    label2.textAlignment=NSTextAlignmentCenter;
    label2.font= [UIFont systemFontOfSize:15];
    label2.text=@"手指左滑  取消发送";
    label2.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    [showview addSubview:label1];
//    [showview addSubview:label2];
    cancelbutton =[[UIImageView alloc]initWithFrame:CGRectMake(115, 418-subheight, 90, 90)];
    cancelbutton.image=[UIImage imageNamed:@"voice_del_nm.png"];
    [showview addSubview:cancelbutton];
    [showview addSubview:pointview];
    label3=[[UILabel alloc]initWithFrame:CGRectMake(100, 354-subheight, 120, 15)];
    label3.textAlignment=NSTextAlignmentCenter;
    label3.textColor=[UIColor colorWithRed:64/255.0 green:134/255.0 blue:244/255.0 alpha:1];
    label3.text=[NSString stringWithFormat:@"%d\"",(int)_recorder.currentTime];
    [showview addSubview:label3];
    [self.window addSubview:showview];
    
    //    NSArray* windows = [UIApplication sharedApplication].windows;
    //    UIWindow *window = [windows objectAtIndex:0];
    //    [window addSubview:showview];
}
#pragma  mark touch三事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.window];
    DDLogInfo(@"按下坐标 %f==%f",touchPoint.x,touchPoint.y);
    islongtouch=YES;
    [self performSelector:@selector(longtouch) withObject:nil afterDelay:0.1];
    
    pointview=[[UIImageView alloc]initWithFrame:CGRectMake(touchPoint.x, touchPoint.y, 70, 70)];
    pointview.image=[UIImage imageNamed:@"speaking_icon_press-down.png"];
    pointview.layer.position=CGPointMake(touchPoint.x, touchPoint.y);
    istosend=YES;
    isneedsend=NO;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.window];
    
    if(touchPoint.x>=90&&touchPoint.x<=230&&touchPoint.y>(393-subheight)&&touchPoint.y<=(533-subheight)){
        [cancelbutton setImage:[UIImage imageNamed:@"voice_del_red.png"]];
        istosend=NO;
    }else{
        istosend=YES;
        [cancelbutton setImage:[UIImage imageNamed:@"voice_del_nm.png"]];
    }
    //    pointview.frame=CGRectMake(touchPoint.x, touchPoint.y, 70, 70);
    pointview.layer.position=CGPointMake(touchPoint.x, touchPoint.y);
    //    DDLogInfo(@"移动坐标 %f==%f",touchPoint.x,touchPoint.y);
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    islongtouch=NO;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.window];
    DDLogInfo(@"结束坐标 %f==%f",touchPoint.x,touchPoint.y);
    if(isneedsend){
        [self sendAudioMessageWithSendFlag:istosend timeout:NO];
    }
    
}
-(void)cancelsend{
    [self sendAudioMessageWithSendFlag:NO timeout:NO];
}
@end
