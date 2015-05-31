//
//  TaskDetailCell.h
//  e企
//
//  Created by cjl on 15-2-2.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"
#import <AVFoundation/AVFoundation.h>

#import "TaskTools.h"

@interface TaskDetailCell : UITableViewCell<AVAudioPlayerDelegate> {
    UIButton *_logoBtn;
    UILabel *_nameLabel;
    UIView *_statusView;
    UILabel *_timeLabel;
    UIView *contentBgView;
    MLEmojiLabel *_contentLabel;
    UIView *_view1;
    UIView *_view2;
    
    UIButton *voiceButton;
    UIImageView *voiceImageView;
    UILabel *voiceTimeLabel;
    UILabel *voiceListenedLabel;
    
    UIButton *statusImageBtn;
    
    AVAudioPlayer *player;
    
    UIImageView *_lastImageView;
    UIImageView *_finishView;
    NSString *_selectNoteString;
    
    UIActivityIndicatorView *sendingIndicatior;
    UIImageView *sendFailedIcon;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier state:(BOOL)state;

@property (nonatomic, strong)NSString *taskType;
@property (nonatomic, assign)BOOL state;
@property (nonatomic, strong)NSDictionary *taskDetail;
@property (nonatomic, copy) void (^UpdateBlock)(void);

- (void)setTaskDetail:(NSDictionary *)taskDetail;

@end
