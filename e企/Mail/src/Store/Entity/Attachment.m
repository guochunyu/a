//
//  Attachment.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/16.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "Attachment.h"
#import "Email.h"
#import "CoreDataManager.h"

static NSString * const kEntityName = @"Attachment";

@implementation Attachment

@dynamic charset;
@dynamic contentDescription;
@dynamic contentID;
@dynamic contentLocation;
@dynamic filename;
@dynamic inlineAttachment;
@dynamic mimeType;
@dynamic partType;
@dynamic uniqueID;
@dynamic email;
@dynamic filepath;

+ (instancetype)create
{
    Attachment *a = (Attachment *)[[CoreDataManager sharedInstance] createManagedObject:kEntityName];
    return a;
}

@end
