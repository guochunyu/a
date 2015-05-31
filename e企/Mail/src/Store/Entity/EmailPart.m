//
//  EmailPart.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/14.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "EmailPart.h"
#import "Email.h"
#import "CoreDataManager.h"

static NSString * const kEntityName = @"EmailPart";

@implementation EmailPart

@dynamic partType;
@dynamic filename;
@dynamic mimeType;
@dynamic charset;
@dynamic uniqueID;
@dynamic contentID;
@dynamic contentLocation;
@dynamic contentDescription;
@dynamic inlineAttachment;
@dynamic email;

+ (instancetype)create
{
    EmailPart *part = (EmailPart *)[[CoreDataManager sharedInstance] createManagedObject:kEntityName];
    return part;
}

@end
