//
//  HeadImageDown.m
//  O了
//
//  Created by 化召鹏 on 14-3-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "HeadImageDown.h"
#import "NSString+FilePath.h"

@implementation HeadImageDown


+(void)downHeadImage:(NSURL *)url{
    NSString *filePath=[@"head_image" filePathOfCaches];
    //判断目录是否存在，不存在则创建目录
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    AFHTTPRequestOperation *headOperation;
    //创建请求管理
    headOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
    
    //添加下载请求（获取服务器的输出流）
    headOperation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    //请求管理判断请求结果
    [headOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //请求成功
        //下载完成
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //请求失败
        DDLogInfo(@"Error: %@",error);
    }];
    [headOperation start];
    
}

@end
