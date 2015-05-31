//
//  CrashLog.m
//  O了
//
//  Created by 化召鹏 on 14-6-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CrashLog.h"
#import "LogRecord.h"

@implementation CrashLog
void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    
    NSString *reason = [exception reason];
    
    NSString *name = [exception name];
    
    
//    [CrashLogHelper uploadCrashLogWithName:name reason:reason callStackSymbols:arr];
    NSString *crashLogString = [NSString stringWithFormat:@"错误日志：\n\nnsme:%@\n\n\nreason:\n\n\n%@\n\ncallStackSymbols:\n%@",name,reason,[arr componentsJoinedByString:@"/n"]];
//    DDLogInfo(@"%@",crashLogString);
    [[LogRecord sharedWriteLog] writeLog:crashLogString];
}
+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}
@end
