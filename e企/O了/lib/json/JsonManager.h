//
//  JsonManager.h
//  Mclub
//
//  Created by Hong Liang on 12-8-3.
//  Copyright (c) 2012年 Shanghai Hongju Network Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsonManager : NSObject

+ (id)dictFromData:(NSData *)data;
+ (NSData *)dataFromDict:(id)dict;

+ (id)dictFromJson:(NSString *)json;
+ (NSString *)jsonFromDict:(id)dict;

@end
