//
//  JsonManager.m
//  Mclub
//
//  Created by Hong Liang on 12-8-3.
//  Copyright (c) 2012年 Shanghai Hongju Network Technology Co., Ltd. All rights reserved.
//

#import "JsonManager.h"
#import "JSONKit.h"

@implementation JsonManager

//传入data转换成字典或者array
+ (id)dictFromData:(NSData *)data
{
    if (![data isKindOfClass:[NSData class]]) {
        NSLog(@"dictFromData data error");
        
        return nil;
    }
    
    //检查版本，如果是5.0以上，就用系统的库 否则，就使用sbjson之类的库
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 5.0) {
        //使用系统版本
        NSError *error  = nil;
        id result       = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error) {
            NSLog(@"jsonManager dict error->%@", error);
        }
        
        return result;
    }
    
    //如果不是5.0以上，就使用别的jsonKit转换器
    return [data objectFromJSONData];
}

//传入字典或者array 转换成data
+ (NSData *)dataFromDict:(id)dict;
{
    if (![dict isKindOfClass:[NSDictionary class]]
        && ![dict isKindOfClass:[NSArray class]]
        ) {
        NSLog(@"dataFromDict dict error");
        
        return nil;
    }
    
    //检查版本，如果是5.0以上，就用系统的库 否则，就使用sbjson之类的库
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (version >= 5.0) {
        //使用系统版本
        NSError *error  = nil;
        id result       = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        
        if (error) {
            NSLog(@"jsonManager data error->%@", error);
        }
        
        return result;
    }
    
    //如果不是5.0以上，就使用别的json转换器
    return [dict JSONData];
    
}

//json字符串转字典
+ (id)dictFromJson:(NSString *)json;
{
    if (![json isKindOfClass:[NSString class]]) {
        NSLog(@"dictFromJson json error");
        
        return nil;
    }
    
    //所有的数据判断都放到上面的方法，这里直接调用上面的方法即可
    return [JsonManager dictFromData:[json dataUsingEncoding:NSUTF8StringEncoding]];
}

//字典转json字符串
+ (NSString *)jsonFromDict:(id)dict;
{
    if (![dict isKindOfClass:[NSDictionary class]]
        && ![dict isKindOfClass:[NSArray class]]
    ) {
        NSLog(@"jsonFromDict dict error");
        
        return nil;
    }
    
    //所有的数据判断都放到上面的方法，这里直接调用上面的方法即可
    NSData *data = [JsonManager dataFromDict:dict];
        
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

@end
