//
//  VideoUtil.m
//  O了
//
//  Created by royasoft on 14-2-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "VideoUtil.h"

@implementation VideoUtil

#pragma mark - 获取文件的大小
+(NSInteger)getFileSizeWithURL:(NSString *)url{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:url]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:url error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue]/1024;
        else{
            DDLogInfo(@"获取文件大小失败");
            return -1;
        }
        
    }
    else
    {
        DDLogInfo(@"文件不存在");
        return -1;
    }

}

#pragma mark - 获取视频文件的时长
+(CGFloat)getTimeWithURL:(NSURL *)url{
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        float second;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        return second;
}

#pragma mark - 获取视频文件某一帧的图片
+(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    DDLogInfo(@"videoURL = %@",videoURL);
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        DDLogInfo(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}

@end
