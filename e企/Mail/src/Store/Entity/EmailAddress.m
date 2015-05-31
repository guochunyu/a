//
//  EmailAddress.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "EmailAddress.h"
#import "Email.h"
#import "CoreDataManager.h"
#import "LogicHelper.h"

static NSString * const kEntityName = @"EmailAddress";

@implementation EmailAddress

@dynamic address;
@dynamic displayName;
@dynamic sender;
@dynamic receivers;
@dynamic cc;

+ (instancetype)create
{
    EmailAddress *address = (EmailAddress *)[[CoreDataManager sharedInstance] createManagedObject:kEntityName];
    return address;
}

- (NSString *)displayNameOrAddress
{
    NSString *name = self.displayName;
    if ([LogicHelper isBlankOrNil:name]) {
        name = self.address;
    }
    return name;
}

@end
