//
//  CreateHttpHeader.m
//  e企
//
//  Created by 许学 on 14/12/6.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CreateHttpHeader.h"
#import "NSData+Base64.h"
#import "CrypoUtil.h"

@implementation CreateHttpHeader

+ (NSString *)createHttpHeaderWithNoce:(NSString *)nonce
{
    NSString *passWord = [[NSUserDefaults standardUserDefaults]objectForKey:myPassWord];
    NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
    NSString *passMd5=[CrypoUtil md5:passWord];
    NSData *strData=[passMd5 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Md5=[strData base64EncodedString];
    NSString *md5Str=[NSString stringWithFormat:@"%@%@%@",nonce,phoneNum,base64Md5];
    
    NSString *md5Str_1=[CrypoUtil md5:md5Str];
    NSString *headStr=[[md5Str_1 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    
    return headStr;
}

@end
