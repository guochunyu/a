//
//  AnalysisJsonUtil.m
//  O了
//
//  Created by royasoft on 14-2-11.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "AnalysisJsonUtil.h"
#import "NotesData.h"

@implementation AnalysisJsonUtil

+(NotesData *)getNotesDataFromMessageModelJson:(MessageModel *)msg{
    NotesData * data = [[NotesData alloc]init];
    return data;
}

#pragma mark -
#pragma mark - 解析msg内容，taskId为空时自动触发会话请求
+(NSMutableDictionary *)analysisMsg:(MessageModel *)msg{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]initWithCapacity:0];
    NSData * data = [msg.msg dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    return dict;
}

@end
