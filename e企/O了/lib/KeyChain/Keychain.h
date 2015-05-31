//
//  Keychain.h
//  HuaXinShop
//
//  Created by roya-hua on 13-8-13.
//  Copyright (c) 2013年 huaxin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>



static NSString * const KEY_UUID =@"com.cmcc.eq.UUID";
static NSString * const KEY_LOGIN_IN_KEYCHAIN =@"com.cmcc.eq.UUIDInKeychain";

static NSString *const KEY_USERNAME=@"com.cmcc.eq.USERNAME";
static NSString *const KEY_USER_NAME_IN_KEYCHAIN=@"com.cmcc.eq.userNameKeychain";

@interface Keychain : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;
@end
