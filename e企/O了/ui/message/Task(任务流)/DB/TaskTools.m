//
//  TaskTools.m
//  e企
//
//  Created by zw on 15/2/6.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskTools.h"
#import "MLEmojiLabel.h"
#import "FMDatabaseAdditions.h"
#import <Foundation/Foundation.h>

@implementation TaskTools

+(NSDictionary *)dictFromString:(NSString *)string
{
    NSString *trimmingString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]];
    trimmingString = [trimmingString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *array = [trimmingString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=;"]];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    for(int i=0;i<[array count]-1;i++)
    {
        NSString *key = [[array objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        key  = [key stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
        NSString *value = [[array objectAtIndex:i+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        value  = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
        if (value && key)
        {
            [dict setObject:value forKey:key];
        }
        else
        {
            break;
        }
        i++;
    }
    return dict;
}

+(NSArray *)arrayFromString:(NSString *)string
{
    if ([string isKindOfClass:[NSArray class]])
    {
        string = [(NSArray *)string firstObject];
    }
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *trimmingString = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"( )"]];
    trimmingString = [trimmingString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *tmpArray = [trimmingString componentsSeparatedByString:@",\n"];
    for (int i=0;i<[tmpArray count];i++)
    {
        NSString *strObj = [tmpArray objectAtIndex:i];
        strObj = [strObj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        strObj = [strObj stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\"\\"]];
        [array addObject:strObj];
    }
    return array;
}

+(CGFloat)taskStatusHeightWithStatusDict:(NSDictionary *)taskStatusDict
                           andTimeHidden:(BOOL)timeHidden
{
    CGFloat height = 0;
    
    if ([[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeContent ||
        [[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateDeadLine ||
        [[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateMember ||
        [[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateName ||
        [[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeUpdateNameAndMember)
    {
        //文字
        DDLogInfo(@"taskStatusDict==%@",[taskStatusDict objectForKey:@"content"]);
        NSString *content = [taskStatusDict objectForKey:@"content"];
        MLEmojiLabel *label = [[MLEmojiLabel alloc] init];
        UIFont *font=[UIFont systemFontOfSize:STATUS_CONTENT_FONT_SIZE];
        label.font = font;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByCharWrapping;
        label.frame=CGRectMake(0, 0, 150, 1000);
        label.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        label.customEmojiPlistName = @"expressionImage_custom.plist";
        [label setEmojiText:content];
        [label sizeToFit];
        CGSize size = label.frame.size;
        height = size.height + 2*TEXT_PADDING;
    }
    else if ([[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeImage)
    {
        //图片
        NSString *imageSize=[taskStatusDict objectForKey:@"original_pic_width_height"];
        
        NSRange range = [imageSize rangeOfString:@"/"];
        CGFloat width = 0;
        if (range.length > 0)
        {
            NSString *heightStr = [imageSize substringFromIndex:range.location + 1];
            height = [heightStr floatValue];
            NSString *widthStr = [imageSize substringToIndex:range.location];
            width = [widthStr floatValue];
        }
        if (range.length > 0)
        {
            if (width > 80)
            {
                height = 80*height/width;
                width = 80;
            }
            height = height + IMAGE_PADDING*2;
        }
        
    }
    else if ([[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAudio)
    {
        //语音
        height = 37+IMAGE_PADDING * 2;
    }
    else if ([[taskStatusDict objectForKey:@"feature"] intValue] == TaskStatusTypeComplete)
    {
        height = 20;
    }
    return height + STATUS_PADDING * 2 + 3;
}

#pragma mark - abouttime
//+(NSString *)showTime:(NSString *)time
//{
//    if ([time length] > 10)
//    {
//        time = [time substringToIndex:10];
//    }
//    NSDate *localDate = [NSDate date];
//    NSTimeInterval localTimeInterVal = [localDate timeIntervalSince1970];
//    NSString *localtimeStr = [NSString stringWithFormat:@"%.0lf",localTimeInterVal];
//    NSString *timeStr = [NSString stringWithFormat:@"%@",time];
//    int resultTime = [localtimeStr intValue] - [timeStr intValue];
//    
//    NSString *resultStr;
//    if (resultTime > SECPERYEAR)
//    {
//        {
//            long sec = (long)[time longLongValue];
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//            [dateFormatter setDateFormat:@"YYYY年MM月dd日hh:mm"];
//            NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
//            resultStr = [dateFormatter stringFromDate:datetimeDate];
//        }
//    }
//    else if (resultTime > SECPERDAY)
//    {
//        long sec = (long)[time longLongValue];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//        [dateFormatter setDateFormat:@"MM月dd日hh:mm"];
//        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
//        resultStr = [dateFormatter stringFromDate:datetimeDate];
//    }
//    else if(resultTime > 1*MINUTE || resultTime < 0)
//    {
//        long sec = (long)[time longLongValue];
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//        [dateFormatter setDateFormat:@"今天 hh:mm"];
//        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
//        resultStr = [dateFormatter stringFromDate:datetimeDate];
//    }
//    else
//    {
//        resultStr = [NSString stringWithFormat:@"刚刚"];
//    }
//    return resultStr;
//}


+(NSString *)showTime:(NSString *)time
{
    @autoreleasepool {
        if([time isKindOfClass:[NSString class]] &&
           [time length] > 13)
        {
            time = [time substringToIndex:13];
        }
    
        NSDate *localDate               = [NSDate date];
        NSTimeInterval createTimeSec    = [time doubleValue] / 1000.0;
        NSTimeInterval currentTimeSec   = [localDate timeIntervalSince1970];
        NSDate *createDate              = [[NSDate alloc] initWithTimeIntervalSince1970:createTimeSec];
        NSTimeInterval secInterval      = currentTimeSec - createTimeSec;
        
        NSCalendar *calendar            = [NSCalendar currentCalendar];
        NSDateComponents *comps;
        NSInteger createYear, createMonth, createDay;
        NSInteger currentYear, currentMonth, currentDay;
        NSString *resultStr;
        
        // 获取年月日.
        comps       = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:createDate];
        createYear  = [comps year];
        createMonth = [comps month];
        createDay   = [comps day];
        
        comps           = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:localDate];
        currentYear     = [comps year];
        currentMonth    = [comps month];
        currentDay      = [comps day];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (createYear != currentYear) {
            [dateFormatter setDateFormat:@"YYYY年MM月dd日hh:mm"];
            resultStr = [dateFormatter stringFromDate:createDate];
        }
        else if (createDay != currentDay) {
            [dateFormatter setDateFormat:@"MM月dd日hh:mm"];
            resultStr = [dateFormatter stringFromDate:createDate];
        }
        else if (secInterval > MINUTE) {
            [dateFormatter setDateFormat:@"今天 hh:mm"];
            resultStr = [dateFormatter stringFromDate:createDate];
        }
        else {
            resultStr = [NSString stringWithFormat:@"刚刚"];
        }
        
        return resultStr;
    }
}

+(NSDictionary *)dealWithTaskStatusDict:(NSDictionary *)statusDict
                   sourceType:(TaskStatusSourceType)taskStatusType
{
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (taskStatusType == TaskStatusSourceTypePush)
    {
        if ([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeContent ||
            [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeImage ||
            [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeAudio ||
            [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeComplete)
        {
            //新的任务状态
            [tmpDict setObject:USER_ID forKey:@"user_id"];
            [tmpDict setObject:[statusDict objectForKey:@"status_id"] forKey:@"status_id"];
            [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[statusDict objectForKey:@"create_time"]longLongValue]] forKey:@"create_time"];
            [tmpDict setObject:@"0" forKey:@"readed"];
            [tmpDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
            [tmpDict setObject:ORG_ID forKey:@"org_id"];
            [tmpDict setObject:[statusDict objectForKey:@"feature"] forKey:@"feature"];
            [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[statusDict objectForKey:@"uid"] longLongValue]]  forKey:@"from_user_id"];
            [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[statusDict objectForKey:@"task_id"] longLongValue]] forKey:@"task_id"];
            [tmpDict setObject:[TaskTools decodingString:[statusDict objectForKey:@"task_name"]] forKey:@"task_name"];
            if ([statusDict objectForKey:@"packetid"])
            {
                [tmpDict setObject:[statusDict objectForKey:@"packetid"] forKey:@"packetid"];
            }
            if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeContent)
            {
                [tmpDict setObject:[TaskTools decodingString:[statusDict objectForKey:@"content"]] forKey:@"content"];
            }
            else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeImage)
            {
                NSError *error;
                NSString *contentString = [statusDict objectForKey:@"content"];
                
//                contentString = [contentString stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                contentString = [contentString stringByReplacingOccurrencesOfString:@"]" withString:@""];
                
                NSDictionary *contentDict = [contentString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
                if (error)
                {
                    DDLogInfo(@"%@",error.description);
                }
                
                NSString *thumbnailPic = [[contentDict objectForKey:@"thumbnail_pic"] firstObject];
                NSString *originalPic = [[contentDict objectForKey:@"original_pic"] firstObject];
                NSString *picWidthHeight = [[contentDict objectForKey:@"pic_width_height"] firstObject];
                
                thumbnailPic = thumbnailPic ? thumbnailPic : @"";
                originalPic = originalPic ? originalPic : @"";
                picWidthHeight = picWidthHeight ? picWidthHeight : @"";
                
                [tmpDict setObject:thumbnailPic forKey:@"thumbnail_pic"];
                [tmpDict setObject:originalPic forKey:@"original_pic"];
                [tmpDict setObject:picWidthHeight forKey:@"original_pic_width_height"];
            }
            else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAudio)
            {
                NSError *error;
                NSString *contentString = [statusDict objectForKey:@"content"];
                NSDictionary *contentDict = [contentString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
                if (error)
                {
                    DDLogInfo(@"%@",error.description);
                }
                [tmpDict setObject:[contentDict objectForKey:@"audio_url"] forKey:@"audio_url"];
                [tmpDict setObject:[contentDict objectForKey:@"audio_duration"] forKey:@"audio_duration"];
                if ([contentDict objectForKey:@"audio_name"])
                {
                    [tmpDict setObject:[contentDict objectForKey:@"audio_name"] forKey:@"audio_name"];
                }else {
                    NSString *audio_name = [[contentDict objectForKey:@"audio_url"] lastPathComponent];
                    [tmpDict setObject:[NSString stringWithFormat:@"%@.amr",audio_name] forKey:@"audio_name"];
                }
                [tmpDict setObject:@"0" forKey:@"listened"];
            }
            else  if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeComplete)
            {
                [tmpDict setObject:[statusDict objectForKey:@"content"] forKey:@"content"];
                if (![[SqliteDataDao sharedInstanse] updeteKey:@"complete_state" toValue:@"1" withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                {
                    NSLog(@"update task complete state failed");
                }
            }
        }
        else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateName ||
                [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateMember ||
                [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateNameAndMember ||
                [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateDeadLine ||
                [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeCreateTask ||
                [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeAddSelfToTask ||
                [[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateDescription)
        {
            [tmpDict setObject:USER_ID forKey:@"user_id"];
            [tmpDict setObject:[statusDict objectForKey:@"create_time"] forKey:@"create_time"];
            [tmpDict setObject:[statusDict objectForKey:@"task_id"] forKey:@"task_id"];
            [tmpDict setObject:[statusDict objectForKey:@"feature"] forKey:@"feature"];
            [tmpDict setObject:@"0" forKey:@"readed"];
            [tmpDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
            [tmpDict setObject:ORG_ID forKey:@"org_id"];
            NSString *creator_uid = nil;
            if([statusDict objectForKey:@"uid"])
            {
                [tmpDict setObject:[statusDict objectForKey:@"uid"] forKey:@"from_user_id"];
                creator_uid = [statusDict objectForKey:@"uid"];
            }
            else if([statusDict objectForKey:@"creator_uid"])
            {
                [tmpDict setObject:[statusDict objectForKey:@"creator_uid"] forKey:@"from_user_id"];
                creator_uid = [statusDict objectForKey:@"creator_uid"];
            }
            if ([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateDescription)
            {
                EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                [tmpDict setObject:[NSString stringWithFormat:@"%@：修改了任务描述",model.name] forKey:@"content"];
                
                if([[SqliteDataDao sharedInstanse] updeteKey:@"description" toValue:[statusDict objectForKey:@"description"] withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                {
                    DDLogCError(@"update task description failed!");
                }
                
            }
            else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateName)
            {
                //任务名
                EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                [tmpDict setObject:[NSString stringWithFormat:@"%@：修改了任务名称",model.name] forKey:@"content"];
            
                NSError *error;
                NSString *contentString = [statusDict objectForKey:@"content"];
                NSDictionary *contentDict = [contentString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
                
                if (error)
                {
                    DDLogInfo(@"%@",error.description);
                }
                if ([contentDict objectForKey:@"new_task_name"] &&
                    ![[SqliteDataDao sharedInstanse] updeteKey:@"task_name" toValue:[TaskTools decodingString:[contentDict objectForKey:@"new_task_name"]] withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                {
                    DDLogError(@"update task name failed!");
                }
            }
            else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateMember)
            {
                //成员
                EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                [tmpDict setObject:[NSString stringWithFormat:@"%@：添加了任务成员",model.name] forKey:@"content"];
                NSError *error;
                NSString *contentString = [statusDict objectForKey:@"content"];
                NSDictionary *contentDict = [contentString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
                if (error)
                {
                    NSLog(@"%@",error.description);
                }
                NSArray *addedMember = [contentDict objectForKey:@"add_member"];
                NSArray *taskArray = [[SqliteDataDao sharedInstanse] findSetWithKey:@"task_id" andValue:[statusDict objectForKey:@"task_id"] andTableName:TASK_TABLE];
                if ([taskArray count] > 0)
                {
                    NSString *memstring = [[taskArray firstObject] objectForKey:@"task_member"];
                    NSArray *tempMemberArr = [memstring componentsSeparatedByString:@","];
                    NSMutableArray *members = [[NSMutableArray alloc] initWithArray:tempMemberArr];
                    [members addObjectsFromArray:addedMember];
                    if (![[SqliteDataDao sharedInstanse] updeteKey:@"task_member" toValue:[members componentsJoinedByString:@","] withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                    {
                        DDLogInfo(@"update members failed!");
                    }
                }
            }
            else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateNameAndMember)
            {
                //成员，名字
                
                EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                [tmpDict setObject:[NSString stringWithFormat:@"%@：修改了任务名称并且添加了成员",model.name] forKey:@"content"];
                NSError *error;
                NSString *contentString = [statusDict objectForKey:@"content"];
                NSDictionary *contentDict = [contentString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
                NSArray *addedMember = [contentDict objectForKey:@"add_member"];
                NSArray *taskArray = [[SqliteDataDao sharedInstanse] findSetWithKey:@"task_id" andValue:[statusDict objectForKey:@"task_id"] andTableName:TASK_TABLE];
                if ([taskArray count] > 0)
                {
                    NSString *memstring = [[taskArray firstObject] objectForKey:@"task_member"];
                    NSArray *tempMemberArr = [memstring componentsSeparatedByString:@","];
                    NSMutableArray *members = [[NSMutableArray alloc] initWithArray:tempMemberArr];
                    [members addObjectsFromArray:addedMember];
                    if (![[SqliteDataDao sharedInstanse] updeteKey:@"task_member" toValue:[members componentsJoinedByString:@","] withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                    {
                        DDLogInfo(@"update members failed!");
                    }
                }
                
                if ([contentDict objectForKey:@"new_task_name"] &&
                    ![[SqliteDataDao sharedInstanse] updeteKey:@"task_name" toValue:[TaskTools decodingString:[contentDict objectForKey:@"new_task_name"]] withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                {
                    DDLogError(@"update task name failed!");
                }
            }
            else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateDeadLine)
            {
                //截止时间
                EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                [tmpDict setObject:[NSString stringWithFormat:@"%@：修改了任务截止时间",model.name] forKey:@"content"];
                
                NSError *error;
                NSString *contentString = [statusDict objectForKey:@"content"];
                NSDictionary *contentDict = [contentString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
                if (error)
                {
                    NSLog(@"%@",error.description);
                }
                if ([contentDict objectForKey:@"new_dead_line"] &&
                    ![[SqliteDataDao sharedInstanse] updeteKey:@"dead_line" toValue:[NSString stringWithFormat:@"%lld",[[contentDict objectForKey:@"new_dead_line"] longLongValue]] withParaDict:@{@"task_id":[statusDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                {
                    DDLogError(@"update task deadline failed!");
                }
            }
            else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeCreateTask)
            {
                EmployeeModel *model = [SqlAddressData queryMemberInfoWithPhone:creator_uid];
                
                [tmpDict setObject:[NSString stringWithFormat:@"%@：创建了任务",model.name] forKey:@"content"];
                [tmpDict setObject:@"0" forKey:@"readed"];
                
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                
                for(NSString *key in statusDict)
                {
                    NSString *valueType = NSStringFromClass([[statusDict objectForKey:key] class]);
                    if ([valueType isEqualToString:@"__NSCFNumber"] && ![key isEqualToString:@"feature"])
                    {
                        [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[statusDict objectForKey:key] longLongValue]] forKey:key];
                    }
                    else
                    {
                        if ([key isEqualToString:@"task_name"] &&[TaskTools decodingString:[statusDict objectForKey:key]] && [[TaskTools decodingString:[statusDict objectForKey:key]] length] > 0
                            )
                        {
                            [tmpDict setObject:[TaskTools decodingString:[statusDict objectForKey:key]] forKey:key];
                        }
                        else if([key isEqualToString:@"task_member"])
                        {
                            NSArray *memberArray = [statusDict objectForKey:@"task_member"];
                            NSMutableString *memberString = [[NSMutableString alloc] initWithCapacity:0];
                            for(NSString *tmpStr in memberArray)
                            {
                                [memberString appendFormat:@"%@,",tmpStr];
                            }
                            [tmpDict setObject:[memberArray count] > 1?[memberString substringToIndex:[memberString length]-1]:memberString forKey:key];
                        }
                        else if(![key isEqualToString:@"feature"])
                        {
                            [tmpDict setObject:[NSString stringWithFormat:@"%@",[statusDict objectForKey:key]] forKey:key];
                        }
                        
                    }
                }
                
                if ([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeAddSelfToTask)
                {
                    if ([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeAddSelfToTask)
                    {
                        [tmpDict setObject:[NSString stringWithFormat:@"%@：邀请你加进这个任务",model.name] forKey:@"content"];
                    }
                    if (![[SqliteDataDao sharedInstanse]  insertTaskRecord:tmpDict andTableName:TASK_TABLE])
                    {
                        DDLogInfo(@"insert task fail");
                    }
                }
                else if ([[[SqliteDataDao sharedInstanse]  findSetWithDictionary:@{@"task_id":[tmpDict objectForKey:@"task_id"]} andTableName:TASK_TABLE orderBy:nil] count] == 0)
                {
                    if (![[SqliteDataDao sharedInstanse]  insertTaskRecord:tmpDict andTableName:TASK_TABLE])
                    {
                        DDLogInfo(@"insert task fail");
                    }
                }
                else
                {
                    if ([[SqliteDataDao sharedInstanse]  deleteRecordWithDict:@{@"task_id":[tmpDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
                    {
                        if (![[SqliteDataDao sharedInstanse] insertTaskRecord:tmpDict andTableName:TASK_TABLE])
                        {
                            DDLogInfo(@"insert task fail");
                        }
                    }
                }
            }
        }
        else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeTaskDeleted)
        {
            [tmpDict setObject:[statusDict objectForKey:@"feature"] forKey:@"feature"];
            [tmpDict setObject:[statusDict objectForKey:@"task_id"] forKey:@"task_id"];
            [tmpDict setObject:[statusDict objectForKey:@"task_name"] forKey:@"task_name"];
            [tmpDict setObject:USER_ID forKey:@"user_id"];
            [tmpDict setObject:ORG_ID forKey:@"org_id"];
            [tmpDict setObject:@"1" forKey:@"readed"];
            [tmpDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
        }
        else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateNameAndDescription)
        {
            //同时更新任务名，任务描述
            NSLog(@"TaskStatusTypeUpdateNameAndDescription == %@",statusDict);
        }
        else if([[statusDict objectForKey:@"feature"]intValue] == TaskStatusTypeUpdateNameMemberDescription)
        {
            //同时更新任务名，任务描述，任务成员
            NSLog(@"TaskStatusTypeNameMemberDescription == %@",statusDict);
        }
        if ([tmpDict count] > 0 &&
            [[tmpDict objectForKey:@"feature"] intValue] != TaskStatusTypeAddSelfToTask && [[tmpDict objectForKey:@"feature"] intValue] != TaskStatusTypeTaskDeleted  &&
            ![[SqliteDataDao sharedInstanse] updeteKey:@"update_time" toValue:[tmpDict objectForKey:@"create_time"] withParaDict:@{@"task_id":[tmpDict objectForKey:@"task_id"]} andTableName:TASK_TABLE])
        {
            DDLogError(@"update update time failed!");
        }
    }
    else if(taskStatusType == TaskStatusSourceTypeServer)
    {
        [tmpDict setObject:USER_ID forKey:@"user_id"];
        [tmpDict setObject:ORG_ID forKey:@"org_id"];
        [tmpDict setObject:[statusDict objectForKey:@"status_id"] forKey:@"status_id"];
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[statusDict objectForKey:@"create_time"]longLongValue]] forKey:@"create_time"];
        [tmpDict setObject:@"1" forKey:@"readed"];
        [tmpDict setObject:TaskStatusSendStatusSuccessed forKey:@"successed"];
        [tmpDict setObject:[statusDict objectForKey:@"feature"] forKey:@"feature"];
        [tmpDict setObject:[NSString stringWithFormat:@"%lld",[[[statusDict objectForKey:@"user"] objectForKey:@"uid"] longLongValue]]  forKey:@"from_user_id"];
        if ([statusDict objectForKey:@"packetid"])
        {
            [tmpDict setObject:[statusDict objectForKey:@"packetid"] forKey:@"packetid"];
        }

        if ([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeContent)
        {
            [tmpDict setObject:[[self class] decodingString:[statusDict objectForKey:@"content"]] forKey:@"content"];
        }
        else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeImage)
        {
            [tmpDict setObject:[statusDict objectForKey:@"thumbnail_pic"] forKey:@"thumbnail_pic"];
            [tmpDict setObject:[statusDict objectForKey:@"original_pic"] forKey:@"original_pic"];
            [tmpDict setObject:[[statusDict objectForKey:@"original_pic_width_height"] firstObject] forKey:@"original_pic_width_height"];
        }
        else if([[statusDict objectForKey:@"feature"] intValue] == TaskStatusTypeAudio)
        {
            [tmpDict setObject:[statusDict objectForKey:@"audio_url"] forKey:@"audio_url"];
            [tmpDict setObject:[statusDict objectForKey:@"audio_duration"] forKey:@"audio_duration"];
            [tmpDict setObject:[statusDict objectForKey:@"audio_name"] forKey:@"audio_name"];
            if ([[tmpDict objectForKey:@"from_user_id"] isEqualToString:USER_ID])
            {
                [tmpDict setObject:@"1" forKey:@"listened"];
            }
            else if(([statusDict objectForKey:@"read"] && [[statusDict objectForKey:@"read"] intValue] == 1) ||
                    ![statusDict objectForKey:@"read"])
            {
                //1是未读，0是已读
                [tmpDict setObject:@"0" forKey:@"listened"];
            }
            else if([statusDict objectForKey:@"read"] && [[statusDict objectForKey:@"read"] intValue] == 0)
            {
                [tmpDict setObject:@"1" forKey:@"listened"];
            }
        }
    }
    return tmpDict;
}


+(NSString *)encodingString:(NSString *)string
{
    if ([string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding])
        return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return string;
}

+(BOOL)checkNetWork
{
    if (![Reachability isNetWorkReachable])
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        return NO;
    }
    return YES;
}

+(NSString *)decodingString:(NSString *)string
{
    if ([string respondsToSelector:@selector(stringByReplacingPercentEscapesUsingEncoding:)] &&
        [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding])
        return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return string;
}

+(CGSize)sizeWithString:(NSString *)string
               andWidth:(CGFloat)width
            andFoneSize:(int)fontSize
{
    UILabel *label = [[UILabel alloc] init];
    label.text = string;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.frame = CGRectMake(0, 0, width, 10000);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label sizeToFit];
    CGRect labelFrame = label.frame;
    return labelFrame.size;
}

@end
