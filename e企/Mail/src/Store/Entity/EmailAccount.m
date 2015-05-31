//
//  EmailAccount.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "EmailAccount.h"
#import "CoreDataManager.h"

static NSString * const kEntityName = @"EmailAccount";

@interface EmailAccount ()

@end


@implementation EmailAccount

@dynamic username;
@dynamic password;
@dynamic createTime;
@dynamic pop3Host;
@dynamic pop3Port;
@dynamic smtpPort;
@dynamic smtpHost;
@dynamic email;

+ (instancetype)create
{
    EmailAccount *act = (EmailAccount *)[[CoreDataManager sharedInstance] createManagedObject:kEntityName];
    return act;
}

- (void)decreate
{
    [[CoreDataManager sharedInstance] deleteManagedObject:self];
    [[CoreDataManager sharedInstance] save];
}

+ (instancetype)findByAccount:(NSString *)account
{
    NSString *condition = [NSString stringWithFormat:@"username == '%@' ",account];
    NSArray *result = [[CoreDataManager sharedInstance] fetch:kEntityName condition:condition filter:nil sortKey:nil ascending:NO fetchOffset:-1 fetchLimit:-1];
    DDLogInfo(@"%@",result);
    return (result != nil && [result count] > 0) ? result[0] : nil;
}

+ (NSArray *)listAccounts
{
    NSArray *result = [[CoreDataManager sharedInstance] fetch:kEntityName condition:nil filter:nil sortKey:@"createTime" ascending:YES fetchOffset:-1 fetchLimit:-1];
    return result == nil ? @[] : result;
}




@end











