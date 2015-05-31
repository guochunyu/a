//
//  MailLogic.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@class EmailAccount;
@class MCOIMAPMessage;
@class MCOMessageParser;
@class MCOMessageHeader;


// 邮箱默认设置
extern NSUInteger const kDefaultIMAPPort;
extern NSUInteger const kDefaultPOPPort;
extern NSUInteger const kDefaultSMTPPort;
extern NSString * const kDefaultIMAPHostFormat;
extern NSString * const kDefaultPOPHostFormat;
extern NSString * const kDefaultSMTPHostFormat;
extern NSString * const kInbox;

typedef NS_ENUM(NSInteger, EmailSendType) {
    EmailSendTypeNew,
    EmailSendTypeReply,
    EmailSendTypeReplyAll,
    EmailSendTypeTransmit,
};

typedef NS_ENUM(NSInteger, EmailArchiveType) {
    EmailArchiveTypeInbox, // 收件箱
    EmailArchiveTypeStar, // 星标箱
    EmailArchiveTypeSendbox, // 发件箱
    EmailArchiveTypeDraft // 草稿
    
};


@interface MailLogic : NSObject

+ (void)sendNoop:(EmailAccount *)account completion:(void(^)(NSError *error))completion;
+ (void)checkAccount:(EmailAccount *)account completion:(void(^)(NSError *error))completion;

+ (void)loadMessageInfos:(EmailAccount *)account completion:(void(^)(NSError *error, NSArray *messageInfos))completion;

+ (void)loadMessageHeader:(EmailAccount *)account index:(NSUInteger)index completion:(void(^)(NSError *error, MCOMessageHeader *message))completion;

+ (void)loadMessageBody:(EmailAccount *)account index:(NSUInteger)index completion:(void(^)(NSError *error, MCOMessageParser *header))completion;

+ (void)deleteMessage:(EmailAccount *)account messageIndex:(NSUInteger)messageIndex completion:(void(^)(NSError *error))completion;

+ (void)sendEmailWithAccount:(EmailAccount *)account to:(NSArray *)to cc:(NSArray *)cc subject:(NSString *)subject body:(NSString *)body files:(NSArray *)files completion:(void(^)(NSError *error))completion;


@end
