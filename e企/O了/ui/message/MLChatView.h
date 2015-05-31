//
//  MLChatView.h
//  O了
//
//  Created by roya-7 on 14-9-16.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuButton.h"
#import "ChatView.h"
#import "NotesData.h"
#import "MLEmojiLabel.h"



@interface MLChatView : ChatView


@property(nonatomic,strong)MenuButton *send_Failed_Butt;///<再次发送按钮

@property(nonatomic,strong)ChatView *chat_View;

-(void)getChatView:(NotesData *)notesData :(MenuButton *)bubble :(BOOL)isMyself :(UIView *)bgView :(UIButton *)headImage :(UIView *)activityView :(UILabel *)headNameLabel :(UIImageView *)headImageView :(ChatView *)returnView :(MLEmojiLabel *)label isRoom:(BOOL)isRoom;
-(id)initWithData:(NotesData *)notesData :(MenuButton *)bubble :(BOOL)isMyself :(UIView *)bgView :(UIButton *)headImage :(UIView *)activityView :(UILabel *)headNameLabel :(UIImageView *)headImageView :(ChatView *)returnView :(MLEmojiLabel *)label isRoom:(BOOL)isRoom;
@end
