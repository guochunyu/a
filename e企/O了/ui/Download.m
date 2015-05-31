//
//  Download.m
//  day23-下载类
//
//  Created by qianfeng on 14-11-19.
//  Copyright (c) 2014年 a. All rights reserved.
//

#import "Download.h"

@implementation Download


-(id)init
{
    if (self=[super init]) {
        _data=[[NSMutableData alloc]init];
        _downloadDictionary=[[NSMutableDictionary alloc]init];
    }
    return self;
}

-(id)initWithURLString:(NSString*)urlString
{
    if (self=[self init]) {
        NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
    return self;
}

-(void)downloadWithURLString:(NSString*)urlString
{
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(id)initPostRequestWithURLString:(NSString*)urlString andHTTPBodyDictionaryString:(NSString*)dictString
{
    if(self=[self init]){
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        request.HTTPMethod=@"POST";
        request.HTTPBody=[dictString dataUsingEncoding:NSUTF8StringEncoding];
        _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    }
    return self;
}

-(void)downloadPostRequestWithURLString:(NSString*)urlString andHTTPBodyDictionaryString:(NSString*)dictString
{
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    request.HTTPMethod=@"POST";
    request.HTTPBody=[dictString dataUsingEncoding:NSUTF8StringEncoding];
    _connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.data.length=0;
    self.downloadDictionary=nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.downloadDictionary=[NSJSONSerialization JSONObjectWithData:_data options:NSJSONReadingMutableContainers error:nil];
    if (self.finishDownload) {
        self.finishDownload(self);
    }
    if ([self.delegate respondsToSelector:@selector(downloadDidFinishLoading:)]) {
            [self.delegate downloadDidFinishLoading:self];
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"下载失败error:%@",error);
}


-(void)cancel
{
    [_connection cancel];
    self.connection=nil;
}

-(void)dealloc
{
    if (_connection) {
        [self cancel];
    }
}

@end




