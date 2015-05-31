//
//  DownManage.m
//  O了
//
//  Created by 化召鹏 on 14-3-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "DownManage.h"
#import "NSString+FilePath.h"

static DownManage *downManage=nil;
@implementation DownManage

+(DownManage *)sharedDownload{
    
    if (!downManage) {
        downManage=[[DownManage alloc] init];
    }
    
    return downManage;
}

-(void)downloadWhithUrl:(NSString *)url fileName:(NSString *)fileName type:(int)type downFinish:(void (^) (NSString *filePath))downFinish downFail:(void (^) (NSError *error))fail{
    //指定文件保存路径
    NSString *filePath;
    NSString *fileExtention = [[fileName componentsSeparatedByString:@"."]objectAtIndex:1];
    if (type == 1) {
        filePath=[[NSString stringWithFormat:@"%@%@",image_path,fileName] filePathOfCaches];
    }else if (type==2){
        if([fileExtention isEqualToString:@"amr"])
        {
            filePath=[[NSString stringWithFormat:@"%@temp/%@",voice_path,fileName] filePathOfCaches];
        }
        else
            filePath=[[NSString stringWithFormat:@"%@%@",voice_path,fileName] filePathOfCaches];
    }else if (type==4){
        //视频
        filePath=[[NSString stringWithFormat:@"%@%@",video_path,fileName] filePathOfCaches];
    }
    
    //判断目录是否存在，不存在则创建目录
    NSString *voiceDictionary = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:voiceDictionary]) {
        [fileManager createDirectoryAtPath:voiceDictionary withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSURL *downUrl=[NSURL URLWithString:url];
    
    AFHTTPRequestOperation *operation;
    //创建请求管理
    operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:downUrl]];
    
    //添加下载请求（获取服务器的输出流）
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    //设置下载进度条
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        //显示下载进度
        
    }];
    
    //请求管理判断请求结果
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (type == 1){
            //图片下载完成
        }
        else if(type == 2) {
            //声音下载完成
            if([fileExtention isEqualToString:@"amr"])
            {
                downFinish([NSString stringWithFormat:@"%@temp/%@",voice_path,fileName]);
            }
            else
            {
                downFinish([NSString stringWithFormat:@"%@%@",voice_path,fileName]);
            }

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail(error);
    }];
    [operation start];

}
@end
