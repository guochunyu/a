//
//  TaskTools.h
//  e企
//
//  Created by zw on 15/2/6.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "base64.h"
#import "SqliteDataDao.h"
#import "MacroDefines.h"

#pragma mark - aboutColor

#define KScreenWidth [UIScreen  mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

#define TaskRedColor  UIColorFromRGB(0xff566a)

#define TEXT_PADDING  8
#define IMAGE_PADDING  5
#define STATUS_PADDING  5
#define STATUS_CONTENT_FONT_SIZE 14

#define ReceiveNewTaskPush  @"ReceiveNewtaskPush"
#define ApplicationEnterBackground  @"applicationenterbackground"

#define UpdateVoiceToListened @"updatevoicetolistened"

#define SECPERYEAR          (SECPERDAY*365)
#define SECPERDAY           (60*60*24)
#define HOUR                (60*60)
#define MINUTE              60

#define TaskStatusSendStatusFailed    @"0"
#define TaskStatusSendStatusSuccessed @"1"
#define TaskStatusSendStatusSending   @"2"


typedef enum
{
    TaskStatusSourceTypeServer = 0,
    TaskStatusSourceTypePush
}TaskStatusSourceType;

typedef NS_ENUM(NSInteger, TaskStatusType)
{
    TaskStatusTypeContent = 1,
    TaskStatusTypeImage,
    TaskStatusTypeAudio,
    TaskStatusTypeAddSelfToTask,
    TaskStatusTypeTaskDeleted,
    TaskStatusTypeCreateTask=6,
    TaskStatusTypeComplete = 7,
    TaskStatusTypeUpdateName = 32,
    TaskStatusTypeUpdateMember = 16,
    TaskStatusTypeUpdateNameAndMember = 48,
    TaskStatusTypeUpdateDescription = 64,
    TaskStatusTypeUpdateDeadLine = 8,
    TaskStatusTypeUpdateNameAndDescription = 96,
    TaskStatusTypeUpdateNameMemberDescription = 112
};

@interface TaskTools : NSObject
+(NSDictionary *)dictFromString:(NSString *)string;
+(NSArray *)arrayFromString:(NSString *)string;

+(CGFloat)taskStatusHeightWithStatusDict:(NSDictionary *)taskStatusDict
                           andTimeHidden:(BOOL)timeHidden;

+(NSString *)showTime:(NSString *)time;

+(NSDictionary *)dealWithTaskStatusDict:(NSDictionary *)statusDict
                             sourceType:(TaskStatusSourceType)taskStatusType;

+(NSString *)encodingString:(NSString *)string;
+(NSString *)decodingString:(NSString *)string;

+(CGSize)sizeWithString:(NSString *)string
               andWidth:(CGFloat)width
            andFoneSize:(int)fontSize;

+(BOOL)checkNetWork;
@end
