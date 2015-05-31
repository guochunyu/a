//
//  RegistHelper.m
//  e企
//
//  Created by xdx on 15/4/21.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "RegistHelper.h"
#import "DesEncrypt.h"
#import "AFClient.h"

const int kIllegalParam = 111;

@implementation RegistHelper

/**
*  申请获取验证码
*
*  @param phoneNumber 输入：手机号码
*  @param outMsg      输出：描述信息
*
*  @return kIllegalParam:输入参数错误, 0:发送失败 , 1:成功, 2:已经是E企用户
*/
+ (int)getVerifyWithPhone:(NSString *)phoneNumber msg:(NSString * __strong*)outMsg
{
    @autoreleasepool {
        if (!phoneNumber || ![phoneNumber isKindOfClass:[NSString class]] || [phoneNumber isEqualToString:@""]) {
            return kIllegalParam;
        }
        __block int result      = 0;
        __block NSString *msg   = nil;
        __block BOOL isFinish   = NO;
        
        NSDictionary *dict  = @{@"phone":phoneNumber};
        AFClient *client    = [AFClient sharedClient];
        [client postPath:@"eas/getVerify" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *res   = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:nil];
            result      = [[res objectForKey:@"status"] intValue];
            msg         = [res objectForKey:@"msg"];
            isFinish    = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (error) {
                msg     = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }
            else {
                msg     = @"发送失败";
            }
            result      = 0;
            isFinish    = YES;
        }];
        
        while (!isFinish) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        if (outMsg) {
            *outMsg = msg;
        }
        return result;
    }
}

/**
 *  验证
 *
 *  @param code     验证码
 *  @param phone    手机号
 *  @param password 密码
 *  @param response 输出：返回结果
 *                          msg：结果描述；
 *                          data：用户类型（2:被邀请，未注册用户，4：新用户。验证失败没有该字段）
 *
 *  @return kIllegalParam:输入参数错误; 0:验证失败; 1:验证成功; 2:已经是E企用户; -1:密码格式错误; -2:设置eas密码失败; -3设置im密码失败.
 */
+ (int)verifyWithCode:(NSString *)code
                phone:(NSString *)phone
             password:(NSString *)password
             response:(NSDictionary * __strong*)response
{
    @autoreleasepool {
        if (!code || ![code isKindOfClass:[NSString class]] || [code isEqualToString:@""] ||
            !phone || ![phone isKindOfClass:[NSString class]] || [phone isEqualToString:@""] ||
            !password || ![password isKindOfClass:[NSString class]] || [password isEqualToString:@""]) {
            return kIllegalParam;
        }
        
        __block int resultCode  = 0;
        __block NSDictionary *data  = nil;
        __block BOOL isFinish       = NO;
        
        NSString *encode4psd    = [DesEncrypt encryptWithText:password];
        NSDictionary *dict      = @{@"phone":phone, @"verifyCode":code, @"psd":encode4psd};
        AFClient *client        = [AFClient sharedClient];
        [client postPath:@"eas/verify" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict   = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil];
            resultCode  = [[responseDict objectForKey:@"status"] intValue];
            data        = responseDict;
            isFinish    = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *msg   = @"验证失败";
            if (error) {
                msg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }
            resultCode  = 0;
            data        = @{@"msg":msg, @"status":@"0"};
            isFinish    = YES;
        }];
        
        while (!isFinish) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        if (response) {
            *response   = data;
        }
        return resultCode;
    }
}

/**
 *  注册&创建企业
 *
 *  @param name       名字
 *  @param phone      手机
 *  @param psd        密码
 *  @param corpName   企业名称
 *  @param memberList 邀请人列表，格式：[{phone:xxx, name:xxx}, {phone:xxx, name:xxx}]
 *  @param response   输出：返回结果
 *                              msg：描述信息；
 *                              status：0: 创建失败; 1: 创建企业成功.
 *
 *  @return kIllegalParam:输入参数错误; 0:创建失败; 1:创建成功;
 */
+ (int)registWithUserName:(NSString *)name
                    phone:(NSString *)phone
                 password:(NSString *)psd
          corporationName:(NSString *)corpName
               memberList:(NSArray *)memberList
                 response:(NSDictionary * __strong*)response
{
    @autoreleasepool {
        if (!name || ![name isKindOfClass:[NSString class]] || [name isEqualToString:@""] ||
            !phone || ![phone isKindOfClass:[NSString class]] || [phone isEqualToString:@""] ||
            !psd || ![psd isKindOfClass:[NSString class]] || [psd isEqualToString:@""] ||
            !corpName || ![corpName isKindOfClass:[NSString class]] || [corpName isEqualToString:@""]) {
            return kIllegalParam;
        }
        __block int resultCode      = 0;
        __block NSDictionary *data  = nil;
        __block BOOL isFinish       = NO;
        
        NSString *encode4psd    = [DesEncrypt encryptWithText:psd];
        NSDictionary *dict      = @{@"content":[@{@"personList":memberList,
                                                 @"userinfo":@{@"psd":encode4psd,
                                                               @"phone":phone,
                                                               @"corporationName":corpName,
                                                               @"name":name
                                                               }
                                                 } JSONString]
                                    };
        
        AFClient *client        = [AFClient sharedClient];
        [client postPath:@"eas/regist" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict   = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil];
            resultCode  = [[responseDict objectForKey:@"status"] intValue];
            data        = responseDict;
            isFinish    = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *msg   = @"注册失败";
            if (error) {
                msg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }
            resultCode  = 0;
            data        = @{@"status":@"0", @"msg":msg};
            isFinish    = YES;
        }];
        
        while (!isFinish) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        if (response) {
            *response   = data;
        }
        return resultCode;
    }
}

/**
 *  添加企业成员
 *
 *  @param gid        企业gid
 *  @param memberList 添加的成员列表
 *  @param response   添加结果（输出）
 *                      msg：描述信息；
 *                      status：0: 添加失败; 1: 添加成功.
 *
 *  @return kIllegalParam:输入参数错误; 0:添加失败; 1:添加成功;
 */
+ (int)addMembersWithGroupID:(NSString *)gid
                  memberList:(NSArray *)memberList
                    response:(NSDictionary * __strong*)response
{
    @autoreleasepool {
        if (!gid || ![gid isKindOfClass:[NSString class]] || [gid isEqualToString:@""] ||
            !memberList || ![memberList isKindOfClass:[NSArray class]] || memberList.count < 1) {
            return kIllegalParam;
        }
        __block int resultCode      = 0;
        __block NSDictionary *data  = nil;
        __block BOOL isFinish       = NO;
        
//        NSDictionary *dict      = @{@"content":[@{@"personList":memberList,
//                                                  @"groupcode":gid
//                                                  } JSONString]
//                                    };
        
        NSDictionary *dict      = @{@"content":@{@"personList":memberList,
                                                  @"groupcode":gid
                                                }
                                    };
        
        AFClient *client        = [AFClient sharedClient];
        [client postPath:@"eas/addPersons" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *responseDict   = [NSJSONSerialization JSONObjectWithData:operation.responseData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil];
            resultCode  = [[responseDict objectForKey:@"status"] intValue];
            data        = responseDict;
            isFinish    = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *msg   = @"添加失败";
            if (error) {
                msg = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }
            resultCode  = 0;
            data        = @{@"status":@"0", @"msg":msg};
            isFinish    = YES;
        }];
        
        while (!isFinish) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        if (response) {
            *response   = data;
        }
        return resultCode;
    }
}

@end
