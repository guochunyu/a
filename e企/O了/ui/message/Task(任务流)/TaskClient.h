//
//  TaskClient.h
//  e企
//
//  Created by huangxiao on 15/1/19.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "AFHTTPSessionManager.h"

#define BaseURLString [NSString stringWithFormat:@"http://%@/task_group/service/",HTTP_IP]
#define UpdateTask          @"task/update.json"
#define UserTaskList        @"task/user_timeline.json"
#define StatusComplete      @"status/complete.json"
#define CreateTask          @"task/create.json"
#define TaskTimeLine        @"status/timeline.json"
#define CreateTextStatu     @"status/create.json"
#define CreatePictureStatu  @"status/create_pic_media.json"
#define MemberContacts      @"member/contacts.json"
#define MemberSearch        @"member/search.json"
#define ReadStatus          @"status/read.json"

@interface TaskClient : AFHTTPSessionManager

+ (instancetype)shareClient;

#pragma mark - 用户任务列表
- (void)getTaskListWithOrg_id:(NSString *)org_id withUid:(NSString *)uid
                     withPage:(int)page WithCount:(int)count
                      success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 更新任务
- (void)postUpdateWithOrg_id:(NSString *)org_id withUid:(NSString *)uid
                 withTask_id:(NSString *)task_id withUpdate_param:(NSString *)update_param
                     success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 删除任务
- (void)postDeleteTaskWithParameters:(NSDictionary *)parameters
                             andPath:(NSString *)path
                             success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 任务完成接口
- (void)postCompleteWithOrg_id:(NSString *)org_id
                       withUid:(NSString *)uid withTask_id:(NSString *)task_id
                      packetId:(NSString *)packetid
                       success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 创建任务
- (void)postTaskCreateWithOrg_id:(NSString *)org_id withUid:(NSString *)uid
                   withTask_name:(NSString *)task_name
                   withDead_line:(NSString *)dead_line
                 withTask_member:(NSArray *)task_member
                 withDescription:(NSString *)description withTask_type:(int)task_type
                         success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 任务动态列表
- (void)getTimelineWithOrg_id:(NSString *)org_id Task_id:(NSString *)task_id
                    withCount:(int)count withSince_id:(NSString *)since_id
                      success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 发布文本动态
- (void)postStatusCreateWithOrg_id:(NSString *)org_id
                           withUid:(NSString *)uid
                          packetID:(NSString *)packetId
                       withTask_id:(NSString *)task_id withContent:(NSString *)content
                           success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 发布图片/音频动态
- (void)postPic_mediaWithParameters:(NSDictionary *)parameters
          constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                            success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                            failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure ;

#pragma mark - 获取成员
- (void)getMemberWithOrg_id:(NSString *)org_id withPage:(int)page withCount:(int)count
                    success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                    failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;

#pragma mark - 搜索联系人
- (void)searchMemberWithOrg_id:(NSString *)org_id withKeyword:(NSString *)keyword
                      withPage:(int)page withCount:(int)count
                       success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
#pragma mark - 发送请求
-(void)postRequestWithParameters:(NSDictionary *)parameters
                         andPath:(NSString *)subPath
                         success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
