//
//  Download.h
//  day23-下载类
//
//  Created by qianfeng on 14-11-19.
//  Copyright (c) 2014年 a. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Download;
@protocol DownloadDelegate <NSObject>
-(void)downloadDidFinishLoading:(Download *)download;
@end

@interface Download : NSObject<NSURLConnectionDataDelegate>
@property(strong,nonatomic) NSMutableData *data;

@property(strong,nonatomic) NSURLConnection *connection;

@property(strong,nonatomic)NSMutableDictionary *downloadDictionary;

@property(weak,nonatomic) id<DownloadDelegate> delegate;

@property(nonatomic,copy) void(^finishDownload)(Download* down);

-(id)initWithURLString:(NSString*)urlString;

-(void)downloadWithURLString:(NSString*)urlString;

-(id)initPostRequestWithURLString:(NSString*)urlString andHTTPBodyDictionaryString:(NSString*)dictString;

-(void)downloadPostRequestWithURLString:(NSString*)urlString andHTTPBodyDictionaryString:(NSString*)dictString;

-(void)cancel;

@end
