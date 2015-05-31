//
//  VersionComparison.m
//  O了
//
//  Created by 化召鹏 on 14-5-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "VersionComparison.h"

@implementation VersionComparison
/**
 *  版本号对比(前者是否小于后者)
 *
 *  @param str1 第一个参数为服务端版本号，第二个参数为本地客户端版本号
 *  @param str2 如果返回yes为本地版本号大于或者等于服务器版本号(前者小余后者)，返回NO为本地版本号小余服务器版本号（前者不小于后者）
 *
 *  @return
 */
+(BOOL)versionComparison:(NSString *)str1 :(NSString *)str2{
    
    NSArray *array1=[str1 componentsSeparatedByString:@"."];//服务号版本
    NSArray *array2=[str2 componentsSeparatedByString:@"."];//本地版本
    for (int i=0;i<[array1 count];i++) {
        NSString *num1=array1[i];
        NSString *num2=array2[i];
        if([num1 intValue]>[num2 intValue]){
            //服务端大于客户端
            return NO;
        }else if ([num1 intValue]==[num2 intValue]) {
            continue;
        }else if([num1 intValue]<[num2 intValue]){
            //服务端小于客户端,直接返回yes
            return YES;
        }
    }

    return YES;
    
}
@end
