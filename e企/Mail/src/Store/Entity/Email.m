//
//  Email.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "Email.h"
#import "CoreDataManager.h"
#import "LogicHelper.h"

static NSString * const kEntityName = @"Email";

@implementation Email

@dynamic subject;
@dynamic date;
@dynamic uid;
@dynamic plainText;
@dynamic sender;
@dynamic messageID;
@dynamic hasDeleted;
@dynamic receivers;
@dynamic mainPart;
@dynamic htmlText;
@dynamic isFlag;
@dynamic isRead;
@dynamic index;
@dynamic attachments;
@dynamic archiveType;
@dynamic account;
@dynamic cc;
//@dynamic draftContent;
//@dynamic customStr;
//@dynamic customStr2;
//@dynamic customStr3;

- (NSString *)getFormatDate
{
    //修改时间内容
    NSDateFormatter *formatter1 = [NSDateFormatter new];
      formatter1.dateFormat=@"yyyy-MM-dd";
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM-dd"];
    NSString *str=[formatter1 stringFromDate:self.date];
    if ([str isEqualToString:[formatter1 stringFromDate:[NSDate date]]]) {
        [dateFormatter setDateFormat:@"HH:mm"];
    }
    NSString *date = [dateFormatter stringFromDate:self.date];
    DDLogCInfo(@"dateFormatter:%@",date);
    return date;
}
//改变详情时间UI
- (NSString *)getstandardFormatDate
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH时mm分"];
//    double t= -self.date.timeIntervalSinceNow;
//    if (t<60*60*24) {
//        [dateFormatter setDateFormat:@"HH:mm"];
//    }
    NSString *date = [dateFormatter stringFromDate:self.date];
    DDLogCInfo(@"hhhhhhhhhhhdateFormatter:%@",date);
    return date;
}


+ (instancetype)create:(EmailAccount *)account
{
    Email *email = (Email *)[[CoreDataManager sharedInstance] createManagedObject:kEntityName];
    if ([EmailAccount findByAccount:account.username] != nil) {
        email.account = account;
    }
    return email;
}

- (void)decreate
{
    [[CoreDataManager sharedInstance] deleteManagedObject:self];
}

+ (NSArray *)listEmails:(NSString *)account
{
    NSString *filter = [NSString stringWithFormat:@"(account.username == '%@')", account];
    NSArray *result = [[CoreDataManager sharedInstance] fetch:kEntityName condition:nil filter:@[filter] sortKey:@"date" ascending:NO fetchOffset:-1 fetchLimit:-1];
    if (result == nil) {
        return @[];
    }
    return result;
}

+ (NSArray *)listEmails:(NSString *)account archiveType:(EmailArchiveType)type includeDeleted:(BOOL)includeDeleted searchStr:(NSString *)searchStr
{
    BOOL isFlag = NO;
    if (type == EmailArchiveTypeStar) {
        type = EmailArchiveTypeInbox;
        isFlag = YES;
    }
    NSMutableString *condition = [NSMutableString new];
    [condition appendFormat:@"(archiveType == %d)", type];
    if (isFlag) {
        condition= [[NSString stringWithFormat:@"(%@ OR (archiveType == %d))",condition,EmailArchiveTypeSendbox]mutableCopy];
        [condition appendFormat:@" AND (isFlag == %d)", [@(YES) unsignedIntValue]];
    }
    if (!includeDeleted) {
        [condition appendFormat:@"AND (hasDeleted == %d)", [@(NO) unsignedIntValue]];
    }
    
    NSString *filter = [NSString stringWithFormat:@"(account.username == '%@')", account];
    DDLogInfo(@"listEmails filter>>%@",filter);
    if (searchStr != nil) {
        [condition appendFormat:@"AND (subject LIKE '*%@*'", searchStr];
        [condition appendFormat:@"OR sender.displayName LIKE '%@'", searchStr];
        [condition appendFormat:@"OR sender.address LIKE '%@'", searchStr];
        [condition appendFormat:@"OR plainText LIKE '*%@*'", searchStr];
        [condition appendFormat:@"OR htmlText LIKE '*%@*')", searchStr];
    }
    DDLogInfo(@"listEmails condition>>%@",condition);
    NSArray *result = [[CoreDataManager sharedInstance] fetch:kEntityName condition:condition filter:@[filter] sortKey:@"date" ascending:NO fetchOffset:-1 fetchLimit:-1];
    if (result == nil) {
        return @[];
    }
    DDLogInfo(@"listEmails count:%lu",(unsigned long)[result count]);
    NSMutableArray *emails = [NSMutableArray new];
    for (Email *e in result) {
        if (e.subject == nil && e.sender == nil && [e.archiveType integerValue] != EmailArchiveTypeDraft) {
            
        } else {
            [emails addObject:e];
        }
    }
    return emails;
}

+ (instancetype)findByIndex:(NSString *)account index:(NSNumber *)index
{
    NSString *condition = [NSString stringWithFormat:@"(account.account == '%@') AND (index == %lu)",account, (unsigned long)[index unsignedIntegerValue]];
    NSArray *result = [[CoreDataManager sharedInstance] fetch:kEntityName condition:condition filter:nil sortKey:nil ascending:NO fetchOffset:-1 fetchLimit:-1];
    return (result != nil && [result count] > 0) ? result[0] : nil;
}

+ (instancetype)findByUid:(NSString *)account uid:(NSNumber *)uid
{
    NSString *condition = [NSString stringWithFormat:@"(account.username == '%@') AND (uid == '%@')",account, uid];
    NSArray *result = [[CoreDataManager sharedInstance] fetch:kEntityName condition:condition filter:nil sortKey:nil ascending:NO fetchOffset:-1 fetchLimit:-1];
    return (result != nil && [result count] > 0) ? result[0] : nil;
}

- (void)convertFromMCOIMAPMessageHeader:(MCOMessageHeader *)header
{
    self.subject = header.subject;
    self.messageID = header.messageID;
    self.date = header.receivedDate;
    EmailAddress *sender = [EmailAddress create];
    sender.displayName = [LogicHelper getDisplayName:header.from];
    sender.address = header.from.mailbox;
    self.sender = sender;
    
    NSMutableSet *receivers = [NSMutableSet new];
    NSArray *to = header.to;
    for (MCOAddress *address in to) {
        EmailAddress *receiver = [EmailAddress create];
        receiver.displayName = [LogicHelper getDisplayName:address];
        receiver.address = address.mailbox;
        [receivers addObject:receiver];
    }
    self.receivers = receivers;
    NSMutableSet *ccers = [NSMutableSet new];
    NSArray *cc = header.cc;
    for (MCOAddress *address in cc) {
        EmailAddress *ccer = [EmailAddress create];
        ccer.displayName = [LogicHelper getDisplayName:address];
        ccer.address = address.mailbox;
        [ccers addObject:ccer];
    }
    self.cc = ccers;
}

- (void)convertFromMCOIMAPMessage:(MCOMessageParser *)msg
{
    if (self.isFault) {
        return;
    }
    self.plainText = msg.plainTextBodyRendering;
    self.htmlText = msg.htmlBodyRendering;
    if (msg.attachments != nil && [msg.attachments count] > 0) {
        NSMutableSet *set = [NSMutableSet new];
        for (MCOAttachment *p in msg.attachments) {
            Attachment *a = [Attachment create];
            a.filename = p.filename;
            a.partType = @(p.partType);
            a.charset = p.charset;
            //a.data = p.data;
            a.contentDescription = p.contentDescription;
            a.contentID = p.contentID;
            a.contentLocation = p.contentLocation;
            a.inlineAttachment = @(p.inlineAttachment);
            a.mimeType = p.mimeType;
            a.uniqueID = p.uniqueID;
            NSString *filePath = [LogicHelper sandboxFilePath:p.filename];
            a.filepath = filePath;
            [p.data writeToFile:filePath atomically:true];
            [set addObject:a];
            p.data = nil;
        }
        self.attachments = set;
    } else {
        self.attachments = [NSSet new];
    }
   if (msg.htmlInlineAttachments != nil) {
            for (MCOAttachment *p in msg.htmlInlineAttachments) {
                NSString *filePath = [LogicHelper sandboxHtmlFilePath:p.contentID];
                [p.data writeToFile:filePath atomically:true];
            }
    }
    [[CoreDataManager sharedInstance] save];
}



@end
