//
//  AFClient.m
//  O了
//
//  Created by 化召鹏 on 14-1-26.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "AFClient.h"

#define afBaseUrlString [NSString stringWithFormat:@"http://%@:%@/",HTTP_IP,HTTP_PORT]

@implementation AFClient
@synthesize timeoutInterval=_timeoutInterval;

//AFClient *_sharedClient=nil;
static AFClient *_sharedClient=nil;
+ (AFClient *)sharedClient{
    
    if (!_sharedClient) {
        _sharedClient=[AFClient manager];
        _sharedClient.timeoutInterval=30;
    }
    
    return _sharedClient;
}
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    NSString *newPath=[NSString stringWithFormat:@"%@%@",afBaseUrlString,path];
    [super POST:newPath parameters:parameters success:success failure:failure];
    
}
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSString *newPath=[NSString stringWithFormat:@"%@%@",afBaseUrlString,path];
    [super GET:newPath parameters:parameters success:success failure:failure];
    
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
        constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
         success:(void (^)(AFHTTPRequestOperation *, id))success
         failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSString *newPath = [NSString stringWithFormat:@"%@%@",afBaseUrlString,path];
    [super POST:newPath parameters:parameters constructingBodyWithBlock:block success:success failure:failure];
}

-(void)cancelOperationWithRequestUuid:(NSString *)requestUUID{
//    AFHTTPRequestOperation *operation_=(AFHTTPRequestOperation *)[self.afOperationDict objectForKey:requestUUID];
//    [operation_ cancel];
}
-(void)setHeaderValue:(NSString *)value headerKey:(NSString *)key{
    [self.requestSerializer setValue:value forHTTPHeaderField:key];
//    [self.requestSerializer];

}

- (void)setTimeoutInterval:(NSInteger)timeoutInterval{
    _timeoutInterval=timeoutInterval;
    [_sharedClient.requestSerializer setTimeoutInterval:_timeoutInterval];
}

-(void)releaseAFClient{
    if (_sharedClient) {
        _sharedClient=nil;
    }
}
@end
