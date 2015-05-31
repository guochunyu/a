//
//  LogRecord.m
//  O了
//
//  Created by 化召鹏 on 14-6-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "LogRecord.h"
#import "NSString+FilePath.h"

@implementation LogRecord
@synthesize isWriteLog;
static LogRecord *lr=nil;
+(LogRecord *)sharedWriteLog{
    
    if (!lr) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            lr=[[LogRecord alloc] init];
        });
    }
    return lr;
}

-(NSString *)getFilePath{
    
    NSString *nowDate=[[self nowTime] substringToIndex:10];
    
    NSString *fileName=[NSString stringWithFormat:@"log/%@_log.txt",nowDate];
    
    
    NSString *filePath=[fileName filePathOfCaches];
    NSString *sqliteDictionary = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:sqliteDictionary]){
        //判断目录是否存在，不存在则创建目录
        [fileManager createDirectoryAtPath:sqliteDictionary withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    if (![fileManager fileExistsAtPath:filePath]) {
        /**
         *  判断是否存在这个文件，如果不存在创建
         */
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    return filePath;
}
-(NSString *)nowTime{
    NSString *timeNowStr;
    
    NSDate *nowDate=[NSDate date];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    timeNowStr=[dateFormatter stringFromDate:nowDate];
    
    return timeNowStr;
}
-(void)changeIsWriteLog:(BOOL)isWrite{
    isWriteLog=isWrite;
}
-(void)writeLog:(NSString *)log{
 
    
    return;
    if (isWriteLog) {
        /**
         *  如果为yes，直接返回
         */
        return;
    }
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    //组装日志
    
    
    
    NSString *logStr=[NSString stringWithFormat:@"\n\n[时间:%@  当前用户:%@ 信息:%@]",[self nowTime],[defaults objectForKey:MOBILEPHONE],log];
    
    if ([log isEqualToString:@"打开应用"]) {
        logStr=[NSString stringWithFormat:@"\n\n\n=========================================================================================\n%@",logStr];
    }
    
    NSFileHandle *outFile;
    
    
    outFile=[NSFileHandle fileHandleForWritingAtPath:[self getFilePath]];
    if (!outFile) {
        DDLogInfo(@"失败");
        
        return;
    }
    //定位到文件尾部
    [outFile seekToEndOfFile];
    //写入文件
    [outFile writeData:[logStr dataUsingEncoding:NSUTF8StringEncoding]];
    //关闭
    [outFile closeFile];
    
}
-(void)releaseLogRecord{
    if (lr) {
        lr=nil;
    }
}



















@end
