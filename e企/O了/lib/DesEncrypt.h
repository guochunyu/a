//
//  DesEncrypt.h
//  EIMClient
//
//  Created by 许学 on 14/11/18.
//  Copyright (c) 2014年 xuxue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesEncrypt : NSObject

+ (NSString *)encryptWithText:(NSString *)sText;
+ (NSString *)decryptWithText:(NSString *)sText;

@end
