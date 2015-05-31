//
//  CrypoUtil.m
//  iPhoneDSM
//
//  Created by Maserati on 11-6-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CrypoUtil.h"

#define CHUNK_SIZE 1024  

@implementation CrypoUtil

/**
 * @brief 对传入的字符串做进行摘要计算。
 *
 * 
 * @param [in] aSrcStr 待摘要计算的输入数据
 * @param [in]
 * @return NSString* 加密后的字符串
 * @note 
 */
+ (NSString*) SHADigestWithSrc:(NSString *)aSrcStr{

    const char *s=[aSrcStr cStringUsingEncoding:NSASCIIStringEncoding];
    NSData *keyData=[NSData dataWithBytes:s length:strlen(s)];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH]={0};
    CC_SHA256(keyData.bytes, keyData.length, digest);
    NSData *out=[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
    NSString *hash=[out description];
    DDLogInfo(@"%@", hash);
    hash = [hash stringByReplacingOccurrencesOfString:@" " withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@"<" withString:@""];
    hash = [hash stringByReplacingOccurrencesOfString:@">" withString:@""];
    return hash;
}

/**
 * @brief 对传入的字符串做进行MD5摘要计算。
 *
 * 
 * @param [in] str 待摘要计算的输入数据
 * @param [in]
 * @return NSString* 计算出的MD5值
 * @note 
 */
+(NSString*) md5:(NSString*) str
{  
    const char *cStr = [str UTF8String];  
    unsigned char result[CC_MD5_DIGEST_LENGTH];  
    CC_MD5( cStr, strlen(cStr), result );  
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}

+(NSString*) md5WithData:(NSData*)data
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, data.length, result );
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}

/**
 * @brief 对文件做进行摘要计算。
 *
 * 
 * @param [in] path 待MD5摘要计算的文件的文件名
 * @param [in]
 * @return NSString* 计算出的MD5值
 * @note 
 */
+(NSString *)file_md5:(NSString*) path
{  
    NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:path];  
    if(handle == nil)  
        return nil;  
    
    CC_MD5_CTX md5_ctx;  
    CC_MD5_Init(&md5_ctx);  
    
    NSData* filedata;  
    do {  
        filedata = [handle readDataOfLength:CHUNK_SIZE];  
        CC_MD5_Update(&md5_ctx, [filedata bytes], [filedata length]);  
    }  
    while([filedata length]);  
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(result, &md5_ctx);  
    
    [handle closeFile];  
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02x",result[i]];
    }
    return [hash lowercaseString];
}

@end
