//
//  AFClient.h
//  O了
//
//  Created by 化召鹏 on 14-1-26.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface AFClient : AFHTTPRequestOperationManager{
//    NSString *requestUUID;
}
+ (AFClient *)sharedClient;


@property (assign,nonatomic)NSInteger timeoutInterval;//超时设置,默认30

-(void)cancelOperationWithRequestUuid:(NSString *)requestUUID;
/**
 *  post请求
 */
- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
/**
 *  get请求
 */
- (void)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
   上传图片Post请求
 */

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;



-(void)setHeaderValue:(NSString *)value headerKey:(NSString *)key;


-(void)releaseAFClient;
@end
