//
//  MailLogic.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailLogic.h"
#import <MailCore/MailCore.h>
#import "EmailAccount.h"


NSUInteger const kDefaultIMAPPort = 993;
NSUInteger const kDefaultPOPPort = 110;
NSUInteger const kDefaultSMTPPort = 465;
NSString * const kDefaultIMAPHostFormat = @"imap.%@";
NSString * const kDefaultSMTPHostFormat = @"smtp.%@";
NSString * const kDefaultPOPHostFormat = @"pop.%@";
NSString * const kInbox = @"INBOX";
@interface MailLogic ()
@end


@implementation MailLogic

+ (void)checkAccount:(EmailAccount *)account completion:(void(^)(NSError *error))completion
{
    MCOPOPSession *session = [self sessionWithAccount:account];
    MCOPOPOperation *operation = [session checkAccountOperation];
    [operation start:^(NSError *error) {
        if (error != nil && error.code == 5) {
            error = [[NSError alloc] initWithDomain:@"MCOErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"邮箱服务器认证失败，请检查用户名密码是否正确，并尝试重新登录"}];
        }
        if (completion) {
            completion(error);
        }
    }];
}

+ (void)sendNoop:(EmailAccount *)account completion:(void(^)(NSError *error))completion
{
    if (account == nil) {
        completion(nil);
    }
    MCOPOPSession *session = [self sessionWithAccount:account];
    MCOPOPOperation * op = [session noopOperation];
    [op start:^(NSError * error) {
        if (error != nil && error.code == 5) {
            error = [[NSError alloc] initWithDomain:@"MCOErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"邮箱服务器认证失败，请检查用户名密码是否正确，并尝试重新登录"}];
        }
        if (error) {
            [self sessionWithAccount:account new:YES];
        }
        if (completion) {
            completion(error);
        }
    }];
}

+ (void)loadMessageInfos:(EmailAccount *)account completion:(void(^)(NSError *error, NSArray *messageInfos))completion
{
    if (account == nil) {
        completion(nil,@[]);
    }
    MCOPOPSession *session = [self sessionWithAccount:account];
    MCOPOPFetchMessagesOperation *messagesFetchOp = [session fetchMessagesOperation];
    [messagesFetchOp start:^(NSError *error, NSArray *messages ) {//*MCOPOPMessageInfo *
            completion(error, messages);
    }];
}
     
+ (void)loadMessageHeader:(EmailAccount *)account index:(NSUInteger)index completion:(void(^)(NSError *error, MCOMessageHeader *header))completion
{
    if (account == nil) {
        completion([NSError new],nil);
    }
    MCOPOPSession *session = [self sessionWithAccount:account];
    MCOPOPFetchHeaderOperation *headerOp = [session fetchHeaderOperationWithIndex:[@(index) unsignedIntValue]];
    [headerOp start:^(NSError *error, MCOMessageHeader *header) {
            completion(error,header);
    }];
}
     
+ (void)loadMessageBody:(EmailAccount *)account index:(NSUInteger)index completion:(void(^)(NSError *error, MCOMessageParser *message))completion
{
    if (account == nil) {
        completion([NSError new],nil);
    }
    MCOPOPSession *session = [self sessionWithAccount:account];

    MCOPOPFetchMessageOperation *msgOp = [session fetchMessageOperationWithIndex:[@(index) unsignedIntValue]];
    [msgOp start:^(NSError *error, NSData *messageData) {
        if (error) {
          completion(error, nil);
            return;
        }
        MCOMessageParser *parser = [MCOMessageParser messageParserWithData:messageData];
        completion(error, parser);
    }];
    
}

     
//        for (MCOPOPMessageInfo *info in messages) {
//            DDLogInfo(@"index:%d,",info.index);
//            DDLogInfo(@"size:%d",info.size);
//            DDLogInfo(@"uid:%@",info.uid);
//            MCOPOPFetchHeaderOperation *headerOp = [session fetchHeaderOperationWithIndex:info.index];
//            [headerOp start:^(NSError *error, MCOMessageHeader *header) {
//                DDLogInfo(@"id:%@",header.messageID);
//                DDLogInfo(@"标题:%@",header.subject);
//                DDLogInfo(@"发件人名称:%@",header.sender.displayName);
//                DDLogInfo(@"发件人邮箱:%@",header.sender.mailbox);
//                DDLogInfo(@"时间:%@",header.date);
//            }];
//            
//            MCOPOPFetchMessageOperation *msgOp = [session fetchMessageOperationWithIndex:info.index];
//            [msgOp start:^(NSError *error, NSData *messageData) {
//                MCOMessageParser *parser = [MCOMessageParser messageParserWithData:messageData];
//                
//                
//            }];
//            
//        }
        
        
        
        //completion(nil,messages);
    //}];
    
    //    [inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
    //        if (error != nil) {
    //            DDLogInfo(@"loadMessages error:%@",[error localizedDescription]);
    //            completion(error, nil);
    //            return;
    //        }
    //        int count = [info messageCount];
    //        DDLogInfo(@"邮件总数:%d",count);
    //        MCORange fetchRange = MCORangeMake(1, count);
    //
    //        MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    //        (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
    //         MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
    //         MCOIMAPMessagesRequestKindFlags);
    //
    //        MCOIMAPFetchMessagesOperation *imapMessagesFetchOp = [session fetchMessagesByNumberOperationWithFolder:kInbox requestKind:requestKind numbers:[MCOIndexSet indexSetWithRange:fetchRange]];
    //        [imapMessagesFetchOp setProgress:^(unsigned int progress) {
    //            DDLogInfo(@"Progress: %u of %u", progress, count);
    //        }];
    //
    //        [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
    //            if (error != nil) {
    //                DDLogInfo(@"loadMessages error:%@",[error localizedDescription]);
    //                completion(error, nil);
    //                return;
    //            }
    //            completion(nil,messages);
    //        }];
    //    }];
//}

+ (void)loadEmailPlainText:(EmailAccount *)account message:(MCOIMAPMessage *)message completion:(void(^)(NSString *plainText, NSError *error))completion
{
    //    MCOPOPSession *session = [self sessionWithAccount:account];
    //    MCOIMAPMessageRenderingOperation *messageRenderingOperation = [session plainTextBodyRenderingOperationWithMessage:message folder:kInbox];
    //    [messageRenderingOperation start:^(NSString *htmlString, NSError *error) {
    //        completion(htmlString, error);
    //    }];
}

+ (void)loadEmailHtmlText:(EmailAccount *)account message:(MCOIMAPMessage *)message completion:(void(^)(NSString *htmlString, NSError *error))completion
{
    //    MCOPOPSession *session = [self sessionWithAccount:account];
    //    MCOIMAPMessageRenderingOperation *messageRenderingOperation = [session htmlBodyRenderingOperationWithMessage:message folder:kInbox];
    //    [messageRenderingOperation start:^(NSString *htmlString, NSError *error) {
    //        completion(htmlString, error);
    //    }];
}

+ (void)deleteMessage:(EmailAccount *)account messageIndex:(NSUInteger)messageIndex completion:(void(^)(NSError *error))completion
{
    MCOPOPSession *session = [self sessionWithAccount:account];
    MCOIndexSet *indexes = [MCOIndexSet indexSet];
    [indexes addIndex:messageIndex];
    MCOPOPOperation *op = [session deleteMessagesOperationWithIndexes:indexes];
    [op start:^(NSError *error) {
        if (!error) {
            DDLogInfo(@"删除邮件成功");
        } else {
            DDLogInfo(@"删除邮件失败%@",[error localizedDescription]);
        }
        completion (error);
    }];
    
    
    //    MCOIMAPOperation *op = [session storeFlagsOperationWithFolder:kInbox
    //                                                             uids:[MCOIndexSet indexSetWithIndex:messageUID]
    //                                                             kind:MCOIMAPStoreFlagsRequestKindSet
    //                                                            flags:MCOMessageFlagDeleted];
    //
    //    [op start:^(NSError *error) {
    //        if(error != nil) {
    //            completion (error);
    //            return;
    //        }
    //        MCOIMAPOperation *deleteOp = [session expungeOperation:kInbox];
    //        [deleteOp start:^(NSError *error) {
    //            completion (error);
    //        }];
    //    }];
}

+ (void)sendEmailWithAccount:(EmailAccount *)account to:(NSArray *)to cc:(NSArray *)cc subject:(NSString *)subject body:(NSString *)body files:(NSArray *)files completion:(void(^)(NSError *error))completion
{
    MCOSMTPSession *smtpSession = [MCOSMTPSession new];
    smtpSession.hostname = account.smtpHost;
    
    smtpSession.username = account.username;
    smtpSession.password = account.password;
    if([account.username hasSuffix:@"@chinamobile.com"] ||[account.username hasSuffix:@"@nm.chinamobile.com"]|| [account.username hasSuffix:@"@sina.com"]|| [account.username hasSuffix:@"@163.com"]||[account.username hasSuffix:@"@qq.com"]||[account.username hasSuffix:@"@msn.com"]||[account.username hasSuffix:@"@126.com"]||[account.username hasSuffix:@"@yeah.com"]||[account.username hasSuffix:@"@sina.cn"]||[account.username hasSuffix:@"@hotmail.com"]||[account.username hasSuffix:@"@outlook.com"]||[account.username hasSuffix:@"@foxmail.com"]||[account.username hasSuffix:@"@yahoo.com"]||[account.username hasSuffix:@"@gmail.com"]||[account.username hasSuffix:@"@sohu.com"]){
        smtpSession.port = 25;
        smtpSession.connectionType = MCOConnectionTypeClear;
    }else{
        smtpSession.port = 465;
        smtpSession.connectionType = MCOConnectionTypeTLS;
    }
    MCOMessageBuilder * builder = [MCOMessageBuilder new];
    [[builder header] setFrom:[MCOAddress addressWithMailbox:account.username]];
    NSMutableArray *tos = [NSMutableArray new];
    for(NSString *toAddress in to) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:toAddress];
        [tos addObject:newAddress];
    }
    [[builder header] setTo:tos];
    NSMutableArray *ccs = [NSMutableArray new];
    for(NSString *ccAddress in cc) {
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
        [ccs addObject:newAddress];
    }
    [[builder header] setCc:ccs];
//    NSMutableArray *bcc = [NSMutableArray new];
//    for(NSString *bccAddress in BCC) {
//        MCOAddress *newAddress = [MCOAddress addressWithMailbox:bccAddress];
//        [bcc addObject:newAddress];
//    }
//    [[builder header] setBcc:bcc];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:body];
    
    NSMutableArray *atts = [NSMutableArray new];
    for (NSDictionary *dict in files) {
        for (NSString *key in dict) {
            MCOAttachment *att = [MCOAttachment attachmentWithData:dict[key] filename:key];
            [att setCharset:@"utf-8"];
            [atts addObject:att];
        }
    }
    [builder setAttachments:atts];
    
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if (error != nil && error.code == 1) {
            error = [[NSError alloc] initWithDomain:@"MCOErrorDomain" code:0 userInfo:@{NSLocalizedDescriptionKey:@"当前网络不稳定，发送失败，请确保网络稳定并重新发送。"}];
        }
        completion(error);
    }];
}
+ (MCOPOPSession *)sessionWithAccount:(EmailAccount *)account
{
    return [MailLogic sessionWithAccount:account new:NO];
}
+ (MCOPOPSession *)sessionWithAccount:(EmailAccount *)account new:(bool) new
{
    static BOOL newCompletion = YES;
    static MCOPOPSession *session;
    static NSTimeInterval lastNewTime = 0;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - lastNewTime >10) {
        lastNewTime = [[NSDate date] timeIntervalSince1970];
        new = YES;
    }
    if ((session == nil ||
         ![session.username isEqualToString:account.username]||
         ![session.password isEqualToString:account.password]||
         new) && newCompletion) {
        
//        newCompletion = NO;
        session = [MCOPOPSession new];
        [session setHostname:account.pop3Host];
        
        [session setUsername:account.username];
        [session setPassword:account.password];
        [session setCheckCertificateEnabled:NO];
        if([account.username hasSuffix:@"@chinamobile.com"] ||[account.username hasSuffix:@"@nm.chinaMobile.com"]||[account.username hasSuffix:@"@nm.chinamobile.com"] || [account.username hasSuffix:@"@sina.com"]|| [account.username hasSuffix:@"@163.com"]||[account.username hasSuffix:@"@msn.com"]||[account.username hasSuffix:@"@126.com"]||[account.username hasSuffix:@"@yeah.com"]||[account.username hasSuffix:@"@sina.cn"]||[account.username hasSuffix:@"@hotmail.com"]||[account.username hasSuffix:@"@outlook.com"]||[account.username hasSuffix:@"@foxmail.com"]||[account.username hasSuffix:@"@yahoo.com"]||[account.username hasSuffix:@"@gmail.com"]||[account.username hasSuffix:@"@sohu.com"]){
            [session setPort:110];
            [session setConnectionType:MCOConnectionTypeClear];
        }else{
            [session setPort:995];
            [session setConnectionType:MCOConnectionTypeTLS];
        }
//        MCOPOPOperation *operation = [session checkAccountOperation];
//        
//        [operation start:^(NSError *error) {
//            newCompletion = YES;
//            if (error) {
//                DDLogInfo(@"%@",error.debugDescription);
//            }else{
//                DDLogInfo(@"ok");
//            }
//        }];
    }
    return session;
}

@end




















