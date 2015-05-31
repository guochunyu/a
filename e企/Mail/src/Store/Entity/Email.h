//
//  Email.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "EmailAddress.h"
#import "EmailPart.h"
#import "Attachment.h"
#import <MailCore/MailCore.h>
#import "EmailAccount.h"
#import "MailLogic.h"
#import "Attachment.h"

@interface Email : NSManagedObject

@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * plainText;
@property (nonatomic, retain) NSString * htmlText;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSNumber *hasDeleted;
@property (nonatomic, retain) EmailAddress *sender;
@property (nonatomic, retain) NSSet *receivers;
@property (nonatomic, retain) NSSet *cc;
@property (nonatomic, retain) EmailPart *mainPart;
@property (nonatomic, retain) NSNumber *isRead;// 是否已读
@property (nonatomic, retain) NSNumber *isFlag;// 星标
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSNumber *hasTransmit;
@property (nonatomic, retain) NSNumber *hasReply;
@property (nonatomic, retain) NSNumber *sendType;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) NSNumber *archiveType; // EmailArchiveType
@property (nonatomic, retain) EmailAccount *account;
//@property (nonatomic, retain) NSString *draftContent;
//@property (nonatomic, retain) NSString *customStr;
//@property (nonatomic, retain) NSString *customStr2;
//@property (nonatomic, retain) NSString *customStr3;


- (NSString *)getFormatDate;
- (NSString *)getstandardFormatDate;

+ (instancetype)create:(EmailAccount *)account;
- (void)decreate;
+ (NSArray *)listEmails:(NSString *)account archiveType:(EmailArchiveType)type includeDeleted:(BOOL)includeDeleted searchStr:(NSString *)searchStr/* isFlag:(BOOL)isFlag*/;
+ (NSArray *)listEmails:(NSString *)account;
+ (instancetype)findByIndex:(NSString *)account index:(NSNumber *)index;
+ (instancetype)findByUid:(NSString *)account uid:(NSString *)uid;

- (void)convertFromMCOIMAPMessageHeader:(MCOMessageHeader *)header;
- (void)convertFromMCOIMAPMessage:(MCOMessageParser *)msg;

@end














