//
//  SoundWithMessage.h
//  O了
//
//  Created by 化召鹏 on 14-2-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define SET_REMIND_OFFLINE @"remindOffLine" //离线消息提醒设置

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundWithMessage : NSObject
+ (void)playMessageReceivedSound;
+ (void)playMessageSentSound;
+ (void)loadRemind;
/**
 *  根据任务ID确定是否提醒
 *
 *  @param taskID 要提醒的任务ID
 */
+ (void)loadRemindWithTaskID:(NSString *)taskID;
/**
 *  根据任务ID确定离线消息是否提醒
 *
 *  @param taskID 任务ID
 */
+ (void)loadRemindForOffLineWithTaskID:(NSString *)taskID;

//播放对应名字的声音
+ (void)playSoundWithName:(NSString *)name type:(NSString *)type;

@end
