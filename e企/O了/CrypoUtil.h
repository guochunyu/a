//
//  CrypoUtil.h
//  iPhoneDSM
//
//  Created by Maserati on 11-6-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>

@interface CrypoUtil : NSObject {
    
}

/**
 * @brief 对传入的字符串做进行摘要计算。
 *
 * 
 * @param [in] aSrcStr 待摘要计算的输入数据
 * @param [in]
 * @return NSString* 加密后的字符串
 * @note 
 */
+ (NSString*) SHADigestWithSrc:(NSString *)aSrcStr;

/**
 * @brief 对传入的字符串做进行MD5摘要计算。
 *
 * 
 * @param [in] str 待摘要计算的输入数据
 * @param [in]
 * @return NSString* 计算出的MD5值
 * @note 
 */
+(NSString*) md5:(NSString*) str;
+(NSString*) md5WithData:(NSData*)data;

/**
 * @brief 对文件做进行摘要计算。
 *
 * 
 * @param [in] path 待MD5摘要计算的文件的文件名
 * @param [in]
 * @return NSString* 计算出的MD5值
 * @note 
 */
+(NSString *)file_md5:(NSString*) path;


@end
