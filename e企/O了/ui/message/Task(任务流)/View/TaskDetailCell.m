//
//  TaskDetailCell.m
//  e企
//
//  Created by cjl on 15-2-2.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskDetailCell.h"
#import "UIImageView+WebCache.h"
#import "TaskTools.h"
#import "TaskStatusViewController.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "UIButton+WebCache.h"
#import "DownManage.h"
#import "VoiceConverter.h"
#import "SqliteDataDao.h"
#import "SqlAddressData.h"
#import "UIViewExt.h"
#import "TaskClient.h"
#import "PersonInfoViewController.h"
#import "UserDetailViewController.h"

#define StopPalyAudio  @"stoppalyaudio"

@interface TaskDetailCell ()<TaskStatusStopPlayDelegate>

@end

@implementation TaskDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier state:(BOOL)state {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.state = state;
        [self initViews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlay) name:ApplicationEnterBackground object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPlay) name:StopPalyAudio object:nil];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor clearColor];
    _view1 = [[UIView alloc] initWithFrame:CGRectZero];
//    _view1.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_view1];
    
    _view2 = [[UIView alloc] initWithFrame:CGRectZero];
//    _view2.backgroundColor = [UIColor brownColor];
    [self.contentView addSubview:_view2];
    
    _logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_view2 addSubview:_logoBtn];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:_nameLabel];
    
    _statusView = [[UIView alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:_statusView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_view1 addSubview:_timeLabel];
    
    voiceListenedLabel = [[UILabel alloc] init];
    voiceListenedLabel.backgroundColor = TaskRedColor;
    voiceListenedLabel.layer.cornerRadius = 4;
    voiceListenedLabel.clipsToBounds = YES;
    [_view2 addSubview:voiceListenedLabel];
    
    contentBgView = [[UIView alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:contentBgView];
    
    _contentLabel = [[MLEmojiLabel alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:_contentLabel];
    
    _finishView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:_finishView];
    
    voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_view2 addSubview:voiceButton];
    
    voiceImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:voiceImageView];
    
    voiceTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_view2 addSubview:voiceTimeLabel];
    
    sendingIndicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    sendingIndicatior.hidesWhenStopped = YES;
    [_view2 addSubview:sendingIndicatior];
    
    sendFailedIcon = [[UIImageView alloc] init];
    sendFailedIcon.backgroundColor = [UIColor clearColor];
    [_view2 addSubview:sendFailedIcon];
    
    statusImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [statusImageBtn addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_view2 addSubview:statusImageBtn];
}

- (void)setTaskDetail:(NSDictionary *)taskDetail
{
    if (_taskDetail != taskDetail) {
        _taskDetail = taskDetail;
    }
    
    _logoBtn.hidden = NO;
    _nameLabel.hidden = NO;
    _statusView.hidden = NO;
    _timeLabel.hidden = NO;
    contentBgView.hidden = NO;
    voiceListenedLabel.hidden = YES;

    NSString *userPhone = [taskDetail objectForKey:@"from_user_id"];
    EmployeeModel *userModel = [SqlAddressData queryMemberInfoWithPhone:userPhone];
    _logoBtn.frame = CGRectMake(15, 0, 36, 36);
    _logoBtn.layer.masksToBounds = YES;
    _logoBtn.layer.cornerRadius = 18;
    [_logoBtn setImageWithURL:[NSURL URLWithString:userModel.avatarimgurl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
    [_logoBtn addTarget:self action:@selector(headClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _nameLabel.frame = CGRectMake(10, 36, 46, 20);
    _nameLabel.font = [UIFont systemFontOfSize:11];
    _nameLabel.textColor = [UIColor lightGrayColor];
    _nameLabel.text = userModel.name;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    _statusView.frame = CGRectMake(58.3, 16, 4, 4);
    _statusView.layer.masksToBounds = YES;
    _statusView.layer.cornerRadius = 2;
    _statusView.backgroundColor = [UIColor lightGrayColor];
    
    _timeLabel.frame = CGRectMake(70, 5, 200, 20);
    _timeLabel.font = [UIFont systemFontOfSize:11];
    _timeLabel.textColor = [UIColor lightGrayColor];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    
    NSTimeInterval timeInterval = [[_taskDetail objectForKey:@"create_time"] doubleValue];
    if (timeInterval > 0.001) {
        _timeLabel.text = [TaskTools showTime:[_taskDetail objectForKey:@"create_time"]];
    }
    else {
        _timeLabel.text = @"";
    }
    
    contentBgView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    contentBgView.layer.masksToBounds = YES;
    contentBgView.layer.cornerRadius = 2;
    
    CGFloat viewHeight = 0;
    
    if ([[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeContent ||
        [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDeadLine ||
        [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateMember ||
        [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateName ||
        [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateNameAndMember )
    {
        //文字
        voiceImageView.hidden = YES;
        voiceButton.hidden = YES;
        voiceTimeLabel.hidden = YES;
        statusImageBtn.hidden = YES;
        _contentLabel.hidden = NO;
        contentBgView.hidden = NO;
        _finishView.hidden = YES;
        
        NSString *content = [taskDetail objectForKey:@"content"];
        UIFont *font=[UIFont systemFontOfSize:STATUS_CONTENT_FONT_SIZE];
        _contentLabel.font = font;
        _contentLabel.numberOfLines = 0;
        _contentLabel.disableAt=YES;
        _contentLabel.disablePhoneNumber=YES;
        _contentLabel.disablePoundSign=YES;
        _contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _contentLabel.frame=CGRectMake(0, 0, 150, 1000);
        _contentLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _contentLabel.customEmojiPlistName = @"expressionImage_custom.plist";
        [_contentLabel setEmojiText:content];
        [_contentLabel sizeToFit];
        CGSize size = _contentLabel.frame.size;
        _contentLabel.frame = CGRectMake(70+TEXT_PADDING, TEXT_PADDING+3, size.width, size.height);
        if([[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateNameAndMember ||
           [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateName ||
           [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDeadLine ||
           [[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateName)
        {
            _contentLabel.textColor = [UIColor lightGrayColor];
        }
        else
        {
            _contentLabel.textColor = [UIColor blackColor];
        }
        
        
        contentBgView.frame = CGRectMake(70, 3, size.width+2*TEXT_PADDING, size.height+2*TEXT_PADDING);
        viewHeight = size.height + 2 * TEXT_PADDING;
        
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(textLongPress:)];
        [_contentLabel addGestureRecognizer:longGesture];
    }
    else if([[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeImage)
    {
        //图片
        voiceImageView.hidden = YES;
        voiceButton.hidden = YES;
        voiceTimeLabel.hidden = YES;
        statusImageBtn.hidden = NO;
        _contentLabel.hidden = YES;
        contentBgView.hidden = NO;
        _finishView.hidden = YES;
        CGFloat height = 0;
        CGFloat width = 0;
        NSString *imageSizeStr=[taskDetail objectForKey:@"original_pic_width_height"];
        
        NSRange range = [imageSizeStr rangeOfString:@"/"];
        if (range.length > 0)
        {
            NSString *heightStr = [imageSizeStr substringFromIndex:range.location + 1];
            height = [heightStr floatValue];
            NSString *widthStr = [imageSizeStr substringToIndex:range.location];
            width = [widthStr floatValue];
        }
        if (width > 80)
        {
            height = 80*height/width;
            width = 80;
        }
        
        statusImageBtn.frame = CGRectMake(70+IMAGE_PADDING, 3+IMAGE_PADDING, width, height);
        
        NSString *localUrl = [self.taskDetail objectForKey:@"local_file_url"];
        if (!localUrl || (id)localUrl == [NSNull null] || localUrl.length <= 0) {
            [statusImageBtn setImageWithURL:[[TaskTools arrayFromString:[taskDetail objectForKey:@"thumbnail_pic"]] firstObject] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@""]];
        }
        else {
            NSString *localPath = localUrl;
            NSData *imageData=[NSData dataWithContentsOfFile:[localPath filePathOfCaches]];
            UIImage *testImage = [UIImage imageWithData: imageData];
            [statusImageBtn setImage:testImage forState:UIControlStateNormal];
        }
        contentBgView.frame = CGRectMake(70, 3, width+2*IMAGE_PADDING, height+2*IMAGE_PADDING);
        viewHeight = height+2*IMAGE_PADDING;
    }
    else if([[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeAudio)
    {
        //声音
        voiceImageView.hidden = NO;
        voiceButton.hidden = NO;
        voiceTimeLabel.hidden = NO;
        voiceImageView.hidden = NO;
        statusImageBtn.hidden = YES;
        _contentLabel.hidden = YES;
        contentBgView.hidden = YES;
        _finishView.hidden = YES;
        
        int voiceLength = [taskDetail[@"audio_duration"] intValue];
        
        voiceButton.layer.cornerRadius = 2;
        voiceButton.layer.masksToBounds = YES;
        voiceButton.frame = CGRectMake(70, STATUS_PADDING, [self voiceViewWidth:voiceLength], 37);
        
        voiceButton.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
        voiceTimeLabel.frame = CGRectMake(voiceButton.frame.size.width+voiceButton.frame.origin.x+10, 6.5, 30, 30);
        
        voiceImageView.frame = CGRectMake(voiceButton.frame.origin.x+5, voiceButton.frame.origin.y+6, 25, 25);
        [voiceImageView setImage:[UIImage imageNamed:@"icon_sound"]];
        [voiceButton addTarget:self action:@selector(voiceAction:) forControlEvents:UIControlEventTouchUpInside];
        voiceTimeLabel.text = [NSString stringWithFormat:@"%d\"",[taskDetail[@"audio_duration"] intValue]];

        voiceTimeLabel.backgroundColor = [UIColor clearColor];
        
        voiceListenedLabel.frame = CGRectMake(voiceTimeLabel.right-10, voiceTimeLabel.top-2, 8, 8);
        if ([[self.taskDetail objectForKey:@"listened"] intValue] == 1)
        {
            voiceListenedLabel.hidden = YES;
        }
        else
        {
            voiceListenedLabel.hidden = NO;
        }

        voiceTimeLabel.font = [UIFont systemFontOfSize:12];
        voiceTimeLabel.textColor = [UIColor grayColor];

        viewHeight = 37 + IMAGE_PADDING *2;
    }
    else if ([[taskDetail objectForKey:@"feature"] intValue] == TaskStatusTypeComplete)
    {
        //文字
        voiceImageView.hidden = YES;
        voiceButton.hidden = YES;
        voiceTimeLabel.hidden = YES;
        statusImageBtn.hidden = YES;
        _contentLabel.hidden = NO;
        contentBgView.hidden = YES;
        _finishView.hidden = NO;
        
        _finishView.frame = CGRectMake(70, 12, 13, 13);
        _finishView.image = [UIImage imageNamed:@"task_icon_finish"];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.text = @"已标记任务归档";
        _contentLabel.frame = CGRectMake(_finishView.right+5, 3+TEXT_PADDING, 150, 20);
    }
    
    viewHeight += (STATUS_PADDING*2);
    
    if (!self.state) {
        _view1.frame = CGRectMake(0, 0, KScreenWidth, 25);
        _view2.frame = CGRectMake(0, 25, KScreenWidth, viewHeight);
        _timeLabel.hidden = NO;
        _logoBtn.hidden = NO;
        _nameLabel.hidden = NO;
    }else {
        _view1.frame = CGRectMake(0, 0, KScreenWidth, 0);
        _view2.frame = CGRectMake(0, 0, KScreenWidth, viewHeight);
        _timeLabel.hidden = YES;
        _logoBtn.hidden = YES;
        _nameLabel.hidden = YES;
    }
    sendFailedIcon.hidden = YES;
    if ([[self.taskDetail objectForKey:@"successed"] isEqualToString:TaskStatusSendStatusSending])
    {
        sendingIndicatior.frame = CGRectMake(KScreenWidth-50, 0, 50, 50);
        [sendingIndicatior startAnimating];
    }
    else if([[self.taskDetail objectForKey:@"successed"] isEqualToString:TaskStatusSendStatusSuccessed] ||
            [[self.taskDetail objectForKey:@"successed"] isEqualToString:TaskStatusSendStatusFailed])
    {
        [sendingIndicatior stopAnimating];
        if ([[self.taskDetail objectForKey:@"successed"] isEqualToString:TaskStatusSendStatusFailed])
        {
            sendFailedIcon.frame = CGRectMake(KScreenWidth-20, 10, 15, 15);
            [sendFailedIcon setImage:[UIImage imageNamed:@"icon_out-of-date"]];
            sendFailedIcon.hidden = NO;
        }
    }
}

- (void)headClick:(UIButton *)button {
    if ([self.taskDetail[@"from_user_id"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]]) {
        PersonInfoViewController *pVC = [[PersonInfoViewController alloc] initWithNibName:@"PersonInfoViewController" bundle:nil];
        pVC.hidesBottomBarWhenPushed = YES;
        [[self viewController].navigationController pushViewController:pVC animated:YES];
        return;
    }
    EmployeeModel *eml = [SqlAddressData queryMemberInfoWithPhone:self.taskDetail[@"from_user_id"]];
    UserDetailViewController *userDetailVC = [[UserDetailViewController alloc] init];
    userDetailVC.userInfo = eml;
    userDetailVC.organizationName = eml.comman_orgName;
    userDetailVC.hidesBottomBarWhenPushed = YES;
    [[self viewController].navigationController pushViewController:userDetailVC animated:YES];

}

- (void)imageButtonClick:(UIButton *)button {
    TaskStatusViewController *taskDetailVC = (TaskStatusViewController *)[self viewController];
    [taskDetailVC endEditing];
    NSMutableArray *photos = [NSMutableArray array];
    MJPhoto *photo = [[MJPhoto alloc] init];
    
    NSString *localUrl = [self.taskDetail objectForKey:@"local_file_url"];
    if (!localUrl || (id)localUrl == [NSNull null] || localUrl.length <= 0) {
        photo.url = [NSURL URLWithString:[[TaskTools arrayFromString:[self.taskDetail objectForKey:@"original_pic"]] firstObject]];
    }
    else {
        NSString *localPath = [self.taskDetail objectForKey:@"local_file_url"];
        NSData *imageData=[NSData dataWithContentsOfFile:[localPath filePathOfCaches]];
        UIImage *testImage = [UIImage imageWithData: imageData];
        photo.image = testImage;
    }
    
//    if ([[self.taskDetail objectForKey:@"local_file_url"] length] > 0)
//    {
//        NSString *localPath = [self.taskDetail objectForKey:@"local_file_url"];
//        NSData *imageData=[NSData dataWithContentsOfFile:[localPath filePathOfCaches]];
//        UIImage *testImage = [UIImage imageWithData: imageData];
//        photo.image = testImage;
//    }
//    else
//    {
//        photo.url = [NSURL URLWithString:[[TaskTools arrayFromString:[self.taskDetail objectForKey:@"original_pic"]] firstObject]];
//    }
    
    photo.srcImageView = button.imageView;
    [photos addObject:photo];
    
    //2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    //    browser.currentPhotoIndex = tap.view.tag;
    browser.photos = photos;
    [browser show];
}

- (void)textLongPress:(UILongPressGestureRecognizer *)longRecognizer {
    MLEmojiLabel *label = (MLEmojiLabel *)longRecognizer.view;
    [[LogRecord sharedWriteLog] writeLog:@"文字长按"];
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        _selectNoteString = label.text;
        [self becomeFirstResponder];
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(myCopy:)];
        int x = 0;
        x = label.frame.origin.x - 10;
        CGRect rect = CGRectMake(x, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
        NSArray *menuArray = [NSArray arrayWithObjects:copyMenuItem,nil];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuArray];
        [menu setTargetRect:rect inView:label.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
#pragma mark - 复制
- (void)myCopy:(id)sender{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = _selectNoteString;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(myCopy:)) {
        return YES;
    }
    return NO;
}

- (void)voiceAction:(UIButton *)button {
    NSString *statusId = [self.taskDetail objectForKey:@"status_id"];
    
    if (!statusId || ([statusId isKindOfClass:[NSString class]] && [statusId isEqualToString:@""])) {
        return;
    }
    TaskStatusViewController *taskDetailVC = (TaskStatusViewController *)[self viewController];
    taskDetailVC.delegate = self;
//    NSString *statusId = [self.taskDetail objectForKey:@"status_id"];
    NSDictionary *dict = [[[SqliteDataDao sharedInstanse] findSetWithKey:@"status_id" andValue:statusId andTableName:TASK_STATUS_TABLE] firstObject];
    if ([[dict objectForKey:@"local_file_url"] isEqual:[NSNull null]]) {
        [[DownManage sharedDownload] downloadWhithUrl:[self.taskDetail objectForKey:@"audio_url"] fileName:[self.taskDetail objectForKey:@"audio_name"] type:2 downFinish:^(NSString *filePath) {
            NSString *fileExtention = [filePath pathExtension];
            if ([fileExtention isEqualToString:@"amr"]) {
                [self voiceAmrToWavMm:button voiceName:[self.taskDetail objectForKey:@"audio_name"] savePath:filePath];
            }else {
                NSString *path = [NSString stringWithFormat:@"%@%@",voice_path,[self.taskDetail objectForKey:@"audio_name"]];
                BOOL success = [[SqliteDataDao sharedInstanse] updeteKey:@"local_file_url" toValue:path withParaDict:@{@"status_id":[self.taskDetail objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE];
                if (success) {
                    [self voiceAction:button];
                }
            }
        } downFail:^(NSError *error) {
            
        }];
        return;
    }
    
    UIImageView *imageView = voiceImageView;
    
    imageView.animationImages = @[[UIImage imageNamed:@"icon_sound_f1@2x"],
                                  [UIImage imageNamed:@"icon_sound_f2@2x"],
                                  [UIImage imageNamed:@"icon_sound_f@2x"]];
    if (player) {
        if ([player isPlaying]) {
            [player stop];
            player = nil;
            [_lastImageView stopAnimating];
        }
    }
    if (button.selected) {
        
    }else {
        
        _lastImageView = imageView;
        
        NSString *localUrl = [self.taskDetail objectForKey:@"local_file_url"];
        
//        NSLog(@"local_file_url=%@,audio_url=%@",[self.taskDetail objectForKey:@"local_file_url"],[self.taskDetail objectForKey:@"audio_url"]);
        
        if (!localUrl || (id)localUrl == [NSNull null] || localUrl.length <= 0) {
            [self playVoice:[NSString stringWithFormat:@"%@%@",voice_path,[self.taskDetail objectForKey:@"audio_name"]]];
        }
        else {
            [self playVoice:[NSString stringWithFormat:@"%@",[self.taskDetail objectForKey:@"local_file_url"]]];
        }
        
        
//        if ([[self.taskDetail objectForKey:@"local_file_url"] length] > 0)
//        {
//            [self playVoice:[NSString stringWithFormat:@"%@",[self.taskDetail objectForKey:@"local_file_url"]]];
//        }
//        else
//        {
//            [self playVoice:[NSString stringWithFormat:@"%@%@",voice_path,[self.taskDetail objectForKey:@"audio_name"]]];
//        }
        
        imageView.animationDuration = 1;
        [imageView startAnimating];
    }
    button.selected = !button.selected;
}

- (void)playVoice:(NSString *)path {
    //从path路径中  加载播放器
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    //设置类别，此处只支持播放
//    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [audioSession setActive:YES error:nil];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StopPalyAudio object:nil];
    
    NSError *error = nil;
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[path filePathOfCaches]] error:&error];
    player.delegate = self;
    [player prepareToPlay];
    
    //设置播放循环次数，如果numberOfLoops为负数 音频文件就会一直循环播放下去
    player.numberOfLoops = 0;
    
    //设置音频音量 volume的取值范围在 0.0为最小 1。0为最大 可以根据自己的情况而设置
    player.volume = 1.0f;
    
    [player play];
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateVoiceToListened object:nil userInfo:self.taskDetail];
    if ([[self.taskDetail objectForKey:@"listened"] intValue] == 0)
    {
        [self postListenVoice];
    }
}

-(void)postListenVoice
{
    voiceListenedLabel.hidden = YES;
    if (![[SqliteDataDao sharedInstanse] updeteKey:@"listened" toValue:@"1" withParaDict:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"status_id":[self.taskDetail objectForKey:@"status_id"],@"task_id":[self.taskDetail objectForKey:@"task_id"]} andTableName:TASK_STATUS_TABLE])
    {
        DDLogCError(@"update audio listened to 1 failed!");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateVoiceToListened object:nil userInfo:self.taskDetail];
    NSLog(@"++++%@",[[SqliteDataDao sharedInstanse] findSetWithDictionary:@{@"user_id":USER_ID,@"org_id":ORG_ID,@"task_id":[self.taskDetail objectForKey:@"task_id" ],@"status_id":[self.taskDetail objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE orderBy:nil]);
    TaskClient *taskClient = [TaskClient shareClient];
    [taskClient postRequestWithParameters:@{@"org_id":ORG_ID,@"uid":USER_ID,@"status_id":[self.taskDetail objectForKey:@"status_id"]} andPath:ReadStatus success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        if ([[responseDict objectForKey:@"result"]intValue] == 0)
        {
            
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


#pragma mark - AVAudioPlayDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
//    [[AVAudioSession sharedInstance] setActive:NO withFlags:AVAudioSessionSetActiveFlags_NotifyOthersOnDeactivation error:nil];
    [voiceImageView stopAnimating];
    voiceButton.selected = !voiceButton.selected;
}

- (void)voiceAmrToWavMm:(UIButton *)button voiceName:(NSString *)voiceName savePath:(NSString *)filePath {
    NSString *wavfilePath = [[NSString stringWithFormat:@"%@%@",voice_path,voiceName] filePathOfCaches];
    [VoiceConverter amrToWav:[filePath filePathOfCaches] wavSavePath:wavfilePath];
    NSString *path = [NSString stringWithFormat:@"%@%@",voice_path,voiceName];
    BOOL success = [[SqliteDataDao sharedInstanse] updeteKey:@"local_file_url" toValue:path withParaDict:@{@"task_id":[self.taskDetail objectForKey:@"task_id"]} andTableName:TASK_STATUS_TABLE];
    if (success) {
        [self voiceAction:button];
    }
}

- (UIViewController *)viewController {
    for (UIView *next = [self superview]; next; next = [next superview]) {
        UIResponder *nextResponer = [next nextResponder];
        if ([nextResponer isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponer;
        }
    }
    return nil;
}

-(float)voiceViewWidth:(int)timeLength
{
    float length = 0;
    if (timeLength <= 10)
        length = 50+(timeLength)*1.5;
    else if(timeLength <= 20)
        length = [self voiceViewWidth:10]+(timeLength-10)*1;
    else if(timeLength <= 30)
        length = [self voiceViewWidth:20]+(timeLength-20)+0.7;
    else if (timeLength <= 40)
        length = [self voiceViewWidth:30]+(timeLength-30)*0.5;
    else if(timeLength <= 50)
        length = [self voiceViewWidth:40]+(timeLength-40)*0.4;
    else if(timeLength <= 60)
        length = [self voiceViewWidth:50]+(timeLength-50)*0.2;
    else
        length = 0;
    DDLogInfo(@"%d==%f",timeLength,length);
    return length;
}

- (void)stopPlay {
    if ([player isPlaying]) {
        [self performSelector:@selector(voiceAction:) withObject:voiceButton];
//        [player stop];
//        player = nil;
//        voiceButton.selected = NO;
//        [voiceImageView stopAnimating];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
