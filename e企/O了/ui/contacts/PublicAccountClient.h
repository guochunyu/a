//
//  PublicAccountClient.h
//  e企
//
//  Created by roya-7 on 14/11/24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define pageSize @"1000"///<获取公众号数量
#define premessageNum @"100"///<获取历史消息数量

@interface PublicAccountClient : NSObject
+(PublicAccountClient *)sharedPublicClient;///<初始化
- (AFHTTPRequestOperation *)requestOperationWithMsgname:(NSString *)name withVersion:(NSString *)version withBodyStr:(NSString *)bodyStr success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
/**
 *  获取未关注公共号列表
 *
 *  @return
 */
+(NSString *)xmlGetpubliclistWithPagesize:(NSString *)size withPageNum:(NSString *)num;
/**
 *  获取公众号详情
 *
 *  @return
 */
+(NSString *)xmlGetpublicdetailWithPa_uuid:(NSString *)pa_uuid;
/**
 *  关注公众号
 *
 *  @param pa_uuid
 *
 *  @return
 */
+(NSString *)xmlAddsubscribeWithPa_uuid:(NSString *)pa_uuid;
/**
 *  取消关注公众号
 *
 *  @return
 */
+(NSString *)xmlCancelsubscribeWithPa_uuid:(NSString *)pa_uuid;
/**
 *  获取已关注公共号列表
 *
 *  @return
 */
+(NSString *)xmlQueryusersubWithPagesize:(NSString *)size withPageNum:(NSString *)num;
/**
 *  获取历史消息
 *
 */
+(NSString *)xmlGetpremessageWithPa_uuid:(NSString *)pa_uuid withNumber:(NSString *)number;
@end
