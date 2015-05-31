//
//  MailActSettingHandler.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActSettingHandler.h"
#import "MailActSettingRouter.h"
#import "MailActSettingController.h"
#import "LogicHelper.h"

@implementation MailActSettingHandler

- (void)initData
{
    NSString *serverHost = _userInfo[@"host"];
    NSNumber *serverPort = _userInfo[@"port"];
    if (serverPort != nil) {
        NSNumberFormatter* numberFormatter = [NSNumberFormatter new];
        NSString *p = [numberFormatter stringFromNumber:serverPort];
        [_controller setValue:p forKey:@"serverPort"];
    }
    if (serverHost != nil) {
        [_controller setValue:serverHost forKey:@"serverHost"];
    }
}

- (void)settingCompleted:(NSString *)serverHost port:(NSString *)serverPort
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (![LogicHelper isBlankOrNil:serverPort]) {
        dict[@"host"] = serverHost;
    }
    if (![LogicHelper isBlankOrNil:serverHost]) {
        NSUInteger port = [serverPort integerValue];
        dict[@"port"] = @(port);
    }
    [_router popController:dict];
}

@end
