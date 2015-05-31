//
//  RegistHelper.h
//  e企
//
//  Created by xdx on 15/4/21.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Regist  @"eas/regist"

extern const int kIllegalParam;

@interface RegistHelper : NSObject

/**
 *  申请获取验证码
 *
 *  @param phoneNumber 输入：手机号码
 *  @param outMsg      输出：描述信息
 *
 *  @return kParamError:参数错误, 0:发送失败 , 1:成功, 2:已经是E企用户
 */
+ (int)getVerifyWithPhone:(NSString *)phoneNumber
                      msg:(NSString * __strong*)outMsg;

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
 *  @return kIllegalParam:参数错误, 0:验证失败; 1:验证成功;2:已经是E企用户；-1:密码格式错误；-2:设置eas密码失败；-3设置im密码失败。
 */
+ (int)verifyWithCode:(NSString *)code
                phone:(NSString *)phone
             password:(NSString *)password
             response:(NSDictionary * __strong*)response;

/**
 *  注册&创建企业
 *
 *  @param name       名字
 *  @param phone      手机
 *  @param psd        密码
 *  @param corpName   企业名称
 *  @param memberList 邀请人列表
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
                 response:(NSDictionary * __strong*)response;

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
                    response:(NSDictionary * __strong*)response;

@end
