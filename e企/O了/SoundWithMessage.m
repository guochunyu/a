//
//  SoundWithMessage.m
//  O了
//
//  Created by 化召鹏 on 14-2-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "SoundWithMessage.h"

@interface SoundWithMessage ()



@end

@implementation SoundWithMessage

+ (void)playSoundWithName:(NSString *)name type:(NSString *)type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        SystemSoundID sound;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
        AudioServicesPlaySystemSound(sound);
    }
    else {
        DDLogInfo(@"Error: audio file not found at path: %@", path);
    }
}

+ (void)playMessageReceivedSound
{
    [SoundWithMessage playSoundWithName:@"in" type:@"caf"];
}

+ (void)playMessageSentSound
{
//    [SoundWithMessage playSoundWithName:@"msg" type:@"caf"];
}

+(void)loadRemind{
    NSString * noDisturbFlag = [[NSUserDefaults standardUserDefaults] valueForKey:@"loadRemind"];
//        DDLogInfo(@"当前配置--消息提醒%d声音%d震动%d免打扰%d ***%@",[[NSUserDefaults standardUserDefaults] boolForKey:REMIND_MSG],[[NSUserDefaults standardUserDefaults] boolForKey:REMIND_SOUND],[[NSUserDefaults standardUserDefaults] boolForKey:REMIND_SHAKE],[[NSUserDefaults standardUserDefaults] boolForKey:NO_DISTURB_CLOSED],noDisturbFlag);
    
    
    if ( !noDisturbFlag || [noDisturbFlag isEqualToString:NO_DISTURB_CLOSED]) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        if([userDefaults boolForKey:NO_DISTURB_CLOSED]){
            NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
            long long int dateTime=(long long int) nowTime;
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH"];
            NSString *nowhour=[dateFormatter stringFromDate:time];
            [dateFormatter setDateFormat:@"mm"];
            NSString *nowminute=[dateFormatter stringFromDate:time];
//            DDLogInfo(@"当前时间 %@ %@",nowhour,nowminute);
            int nowtt=[nowhour intValue]*60+[nowminute intValue];
            int sttime=[userDefaults integerForKey:NO_DISTURB_STARTTIME];
            int endtime=[userDefaults integerForKey:NO_DISTURB_ENDTIME];
            if(sttime<endtime){
                if(nowtt>sttime&&nowtt<=endtime){
                    DDLogInfo(@"在免打扰期间");
                    return;
                }
            }else{
                if(nowtt>sttime||nowtt<=endtime){
                    DDLogInfo(@"在免打扰期间");
                    return;
                }
            }
//            DDLogInfo(@"%@ %@",[NSString stringWithFormat:@"%d:%d:00",sttime/60,sttime%60],[NSString stringWithFormat:@"%d:%d:00",endtime/60,endtime%60]);
//            [dateFormatter setDateFormat:@"HH:mm:ss"];
//            NSString *destDateString=[dateFormatter stringFromDate:time];
//            if([destDateString compare:[NSString stringWithFormat:@"%d:%d:00",sttime/60,sttime%60]]==NSOrderedDescending){
//                DDLogInfo(@"晚于起始时间");
//            }
//            if([destDateString compare:[NSString stringWithFormat:@"%d:%d:00",sttime/60,sttime%60]]==NSOrderedAscending){
//                DDLogInfo(@"早于起始时间");
//            }
//            if([destDateString compare:[NSString stringWithFormat:@"%d:%d:00",endtime/60,endtime%60]]==NSOrderedDescending){
//                DDLogInfo(@"晚于终止时间");
//            }
//            if([destDateString compare:[NSString stringWithFormat:@"%d:%d:00",endtime/60,endtime%60]]==NSOrderedAscending){
//                DDLogInfo(@"早于终止时间");
//            }
//
//            
//            
//            if ([destDateString compare:[NSString stringWithFormat:@"%d:%d:00",sttime/60,sttime%60]] == NSOrderedDescending &&[destDateString compare:[NSString stringWithFormat:@"%d:%d:00",endtime/60,endtime%60]] == NSOrderedAscending) {
//                
//                DDLogInfo(@"在免打扰的区间内");
//                return ;
//            }
        }
        if ([userDefaults boolForKey:REMIND_SHAKE]&&[userDefaults boolForKey:REMIND_SOUND]) {
            
            //振动和声音提醒
            //1307跟QQ声音一样
            //            AudioServicesPlaySystemSound(1307);
            [self playMessageReceivedSound];
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            return;
        }
        if ([userDefaults boolForKey:REMIND_SOUND]) {
            //声音提醒
            [self playMessageReceivedSound];
            return;
        }
        if ([userDefaults boolForKey:REMIND_SHAKE]) {
            //振动提醒
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            return;
        }
        
    }else if ([noDisturbFlag isEqualToString:NO_DISTURB_ONLY_NIGHT]){
        //夜间免打扰
        NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
        long long int dateTime=(long long int) nowTime;
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm:ss"];
        NSString *destDateString=[dateFormatter stringFromDate:time];
        if ([destDateString compare:@"22:00:00"] == NSOrderedAscending &&[destDateString compare:@"08:00:00"] == NSOrderedDescending) {
            NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
            if ([userDefaults boolForKey:REMIND_SHAKE]&&[userDefaults boolForKey:REMIND_SOUND]) {
//                AudioServicesPlaySystemSound(1307);
                [self playMessageReceivedSound];
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                return;
            }
            if ([userDefaults boolForKey:REMIND_SOUND]) {
                //1307跟QQ声音一样
                [self playMessageReceivedSound];
                return;
            }
            if ([userDefaults boolForKey:REMIND_SHAKE]) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                return;
            }
        }
    }

}
+ (void)loadRemindWithTaskID:(NSString *)taskID
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    //取消消息提醒
    if (![userDefaults boolForKey:REMIND_MSG]) {
        return;
    }
    NSDate *last_time_date=[userDefaults objectForKey:REMIND_LAST_TIME];
    if (last_time_date) {
        //十秒内只提醒一次
        
        if ([[NSDate date] timeIntervalSinceDate:last_time_date]>5) {
            [userDefaults setObject:[NSDate date] forKey:REMIND_LAST_TIME];
            [userDefaults synchronize];
        }else{
            return;
        }
    }else{
        [userDefaults setObject:[NSDate date] forKey:REMIND_LAST_TIME];
        [userDefaults synchronize];
    }
    
    NSArray *arrayMember=[userDefaults arrayForKey:NO_DISTURB_MEMBER];
    if (![arrayMember containsObject:taskID]) {
        [self loadRemind];
    }
}
+ (void)loadRemindForOffLineWithTaskID:(NSString *)taskID
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSArray *arrayMember=[userDefaults arrayForKey:NO_DISTURB_MEMBER];
    if (![arrayMember containsObject:taskID]) {
        //取消消息提醒
        if (![userDefaults boolForKey:REMIND_MSG]) {
            return;
        }
        NSMutableDictionary *remindOffLine=[[userDefaults dictionaryForKey:SET_REMIND_OFFLINE]mutableCopy];
        if (remindOffLine==nil) {
            remindOffLine=[[NSMutableDictionary alloc]init];
        }
        if ([remindOffLine.allKeys containsObject:taskID]) {
            NSDate *remindDate=[remindOffLine objectForKey:taskID];
            if ([[NSDate date] timeIntervalSinceDate:remindDate]>10) {
                //提醒
                DDLogInfo(@"+++%f",[[NSDate date] timeIntervalSinceDate:remindDate]);
                [remindOffLine setObject:[NSDate date] forKey:taskID];
                [userDefaults setObject:remindOffLine forKey:SET_REMIND_OFFLINE];
                [userDefaults synchronize];
                [self loadRemind];
            }
        }else{
            //提醒
            [remindOffLine setObject:[NSDate date] forKey:taskID];
            [userDefaults setObject:remindOffLine forKey:SET_REMIND_OFFLINE];
            [userDefaults synchronize];
            [self loadRemind];
        }
    }
}

@end
