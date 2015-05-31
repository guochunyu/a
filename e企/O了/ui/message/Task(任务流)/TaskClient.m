//
//  TaskClient.m
//  e企
//
//  Created by huangxiao on 15/1/19.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "TaskClient.h"
#import "HttpRequstUrl.h"
#import "TaskTools.h"

@implementation TaskClient

//static NSString * const BaseURLString = @"http://218.205.81.12/task_group/service/";

+ (instancetype)shareClient {
    static TaskClient *_shareTaskClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareTaskClient = [[self alloc] init];
    });
    return _shareTaskClient;
}

- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    self.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    return self;
}


#pragma mark - 用户任务列表
- (void)getTaskListWithOrg_id:(NSString *)org_id withUid:(NSString *)uid
                     withPage:(int)page WithCount:(int)count
                      success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"uid"] = uid;
    parameters[@"page"] = @(page);
    parameters[@"count"] = @(count);
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,@"task/user_timeline.json"];
    [self GET:newPath parameters:parameters
       success:^(NSURLSessionDataTask *task, id responseObject) {
           if (success) {
               success(task,responseObject);
           }
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           if (failure) {
               failure(task,error);
           }
       }];
}

#pragma mark - 更新任务
- (void)postUpdateWithOrg_id:(NSString *)org_id withUid:(NSString *)uid
                 withTask_id:(NSString *)task_id withUpdate_param:(NSString *)update_param
                     success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"uid"] = uid;
    parameters[@"task_id"] = task_id;
    parameters[@"update_param"] = update_param;
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,UpdateTask];
    [super POST:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark - 删除任务
- (void)postDeleteTaskWithParameters:(NSDictionary *)parameters
                             andPath:(NSString *)path
                     success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                     failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,path];
    DDLogCInfo(@"path==%@\n para==%@",newPath,parameters);
    [self POST:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}


#pragma mark - 任务完成接口
- (void)postCompleteWithOrg_id:(NSString *)org_id
                       withUid:(NSString *)uid withTask_id:(NSString *)task_id
                      packetId:(NSString *)packetid
                       success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"uid"] = uid;
    parameters[@"task_id"] = task_id;
    parameters[@"packetid"] = packetid;
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,StatusComplete];
    [self POST:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark - 创建任务
- (void)postTaskCreateWithOrg_id:(NSString *)org_id
                         withUid:(NSString *)uid
                   withTask_name:(NSString *)task_name
                   withDead_line:(NSString *)dead_line
                 withTask_member:(NSArray *)task_member
                 withDescription:(NSString *)description
                   withTask_type:(int)task_type
                         success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSMutableString *member = [[NSMutableString alloc] initWithString:@""];
    if ([task_member count] > 0)
    {
        [member insertString:@"[" atIndex:[member length]];
        for (NSString *user in task_member)
        {
            [member insertString:[NSString stringWithFormat:@"%@,",user] atIndex:[member length]];
        }
        [member insertString:@"]" atIndex:[member length]-1];
    }
    if ([member length] == 0)
    {
        [member insertString:@"[]" atIndex:0];
    }
    else
    {
        [member deleteCharactersInRange:NSMakeRange([member length]-1, 1)];
    }
    
    parameters[@"org_id"] = org_id?org_id:@"";
    parameters[@"uid"] = uid?uid:@"";
    parameters[@"task_name"] = task_name?task_name:@"未标题任务";
    parameters[@"dead_line"] = dead_line?dead_line:@"0";
    parameters[@"task_member"] = member?member:@"";
    parameters[@"description"] = description?description:@"";
    parameters[@"task_type"] = @(task_type);
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,CreateTask];
    
    [self POST:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}


#pragma mark - 任务动态列表
- (void)getTimelineWithOrg_id:(NSString *)org_id Task_id:(NSString *)task_id
                    withCount:(int)count withSince_id:(NSString *)since_id
                      success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"uid"] = USER_ID;
    parameters[@"task_id"] = task_id;
    parameters[@"count"] = @(count);
    parameters[@"since_id"] = since_id?since_id:@"0";
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,TaskTimeLine];
    DDLogInfo(@"url = %@\n para = %@",newPath,parameters);
//    NSLog(@"url = %@\n para = %@",newPath,parameters);
    [self GET:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark - 发布文本动态
- (void)postStatusCreateWithOrg_id:(NSString *)org_id withUid:(NSString *)uid
                          packetID:(NSString *)packetId
                       withTask_id:(NSString *)task_id withContent:(NSString *)content
                           success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"uid"] = uid;
    parameters[@"packetid"] = packetId;
    parameters[@"task_id"] = task_id;
    parameters[@"content"] = content;
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,CreateTextStatu];
    NSLog(@"%@===%@",newPath,parameters);
    
    [self POST:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }      }];
}

#pragma mark - 发布图片/音频动态
- (void)postPic_mediaWithParameters:(NSDictionary *)parameters
          constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                            success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                            failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,CreatePictureStatu];
    [self POST:newPath parameters:parameters constructingBodyWithBlock:block success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark - 获取成员
- (void)getMemberWithOrg_id:(NSString *)org_id withPage:(int)page withCount:(int)count
                    success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                    failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"page"] = @(page);
    parameters[@"count"] = @(count);
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,MemberContacts];
    [self GET:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

#pragma mark - 搜索联系人
- (void)searchMemberWithOrg_id:(NSString *)org_id withKeyword:(NSString *)keyword
                      withPage:(int)page withCount:(int)count
                       success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"org_id"] = org_id;
    parameters[@"keyword"] = keyword;
    parameters[@"page"] = @(page);
    parameters[@"count"] = @(count);
    NSString *newPath = [NSString stringWithFormat:@"%@%@",BaseURLString,@"member/search.json"];
    [self GET:newPath parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

-(void)postRequestWithParameters:(NSDictionary *)parameters
                         andPath:(NSString *)subPath
                         success:(void(^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    [self POST:[NSString stringWithFormat:@"%@%@",BaseURLString,subPath] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

@end
