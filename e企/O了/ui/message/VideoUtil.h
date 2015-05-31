//
//  VideoUtil.h
//  O了
//
//  Created by royasoft on 14-2-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface VideoUtil : NSObject

//获取文件的大小
+(NSInteger)getFileSizeWithURL:(NSString *)url;

//获取视频文件的时长
+(CGFloat)getTimeWithURL:(NSURL *)url;


+(UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end
