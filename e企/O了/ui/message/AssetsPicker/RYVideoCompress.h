//
//  RY3GPCompress.h
//  O了
//
//  Created by 卢鹏达 on 14-2-15.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

@interface RYVideoCompress : NSObject
/**
 *  初始化
 *
 *  @param inputURL       视频保存URL
 *  @param outputURL      视频转换后的URL
 *  @param presetName     视频压缩质量
 *  @param outputFileType 视频转换后的格式
 *
 *  @return id
 */
- (id)initWithInputURL:(NSURL *)inputURL outputURL:(NSURL *)outputURL presentName:(NSString *)presetName outputFileType:(NSString *)outputFileType;
/**
 *  开始执行视频压缩转换
 *
 *  @param handler 转换结束后的Block语法调用——YES：成功、NO：失败
 */
- (void)executeWithCompletionHandler:(void (^)(BOOL result))handler;

@property (nonatomic, strong) NSURL *inputURL;
@property (nonatomic, strong) NSString *presetName;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, strong) NSString *outputFileType;
@property (nonatomic, assign) BOOL shouldOptimizeForNetworkUse;

@end
