//
//  LogRecord.h
//  O了
//
//  Created by 化召鹏 on 14-6-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogRecord : NSObject
@property(nonatomic,assign)BOOL isWriteLog;//是否记录log

+(LogRecord *)sharedWriteLog;
-(void)writeLog:(NSString *)log;
-(void)changeIsWriteLog:(BOOL)isWrite;
@end
