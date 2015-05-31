//
//  Created by mronge on 1/31/13.
//


#import "NSError+MCO.h"

#import "MCOConstants.h"

static NSString * MCOLocalizedDescriptionTable[] = {
    @"操作成功.", /** MCOErrorNone */
    @"无法连接服务器",                   /** MCOErrorConnection */
    @"服务器不支持TLS / SSL连接.",                              /** MCOErrorTLSNotAvailable */
    @"无法解析服务器的响应.",                                         /** MCOErrorParse */
    @"服务器的证书无效.",                                   /** MCOErrorCertificate */
    @"用户名或密码错误,请重新输入",
    /** MCOErrorAuthentication */
    @"IMAP不启用Gmail帐户.",                                   /** MCOErrorGmailIMAPNotEnabled */
    @"Gmail帐户请求数据，超过带宽限制.", /** MCOErrorGmailExceededBandwidthLimit */
    @"太多的并发连接了Gmail帐户.",            /** MCOErrorGmailTooManySimultaneousConnections */
    @"MobileMe is no longer an active mail service.",                                 /** MCOErrorMobileMeMoved */
    @"Yahoo!'s servers are currently unavailable.",                                   /** MCOErrorYahooUnavailable */
    @"文件夹选择失败，请求的文件夹不存在。",                 /** MCOErrorNonExistantFolder */
    @"An error occured while renaming the requested folder.",                         /** MCOErrorRename */
    @"An error occured while deleting the requested folder.",                         /** MCOErrorDelete */
    @"An error occured while creating the requested folder.",                         /** MCOErrorCreate */
    @"An error occured while (un)subscribing to the requested folder.",               /** MCOErrorSubscribe */
    @"An error occured while appending a message to the requested folder.",           /** MCOErrorAppend */
    @"An error occured while copying a message to the requested folder.",             /** MCOErrorCopy */
    @"An error occured while expunging a message in the requested folder.",           /** MCOErrorExpunge */
    @"An error occured while fetching messages in the requested folder.",             /** MCOErrorFetch */
    @"An error occured during an IDLE operation.",                                    /** MCOErrorIdle */
    @"An error occured while requesting the server's identity.",                      /** MCOErrorIdentity */
    @"An error occured while requesting the server's namespace.",                     /** MCOErrorNamespace */
    @"An error occured while storing flags.",                                         /** MCOErrorStore */
    @"An error occured while requesting the server's capabilities.",                  /** MCOErrorCapability */
    @"The server does not support STARTTLS connections.",                             /** MCOErrorStartTLSNotAvailable */
    @"Attempted to send a message with an illegal attachment.",                       /** MCOErrorSendMessageIllegalAttachment */
    @"The SMTP storage limit was hit while trying to send a large message.",          /** MCOErrorStorageLimit */
//    @"Sending messages is not allowed on this server.",                               /** MCOErrorSendMessageNotAllowed */
    @"不允许在这个服务器上发送消息.",
    
    @"The current HotMail account cannot connect to WebMail.",                        /** MCOErrorNeedsConnectToWebmail */
    @"发送消息时发生一个错误。",
    /** MCOErrorSendMessage */
    @"Authentication is required for this SMTP server.",                              /** MCOErrorAuthenticationRequired */
    @"An error occured while fetching a message list on the POP server.",             /** MCOErrorFetchMessageList */
    @"An error occured while deleting a message on the POP server.",                  /** MCOErrorDeleteMessage */
    @"Account check failed because the account is invalid.",                          /** MCOErrorInvalidAccount */
    @"File access error",                                                             /** MCOErrorFile */
    @"Compression is not available",                                                  /** MCOErrorCompression */
    @"A sender is required to send message",                                          /** MCOErrorNoSender */
    @"收件人格式错误，请正确输入",                                       /** MCOErrorNoRecipient */
    @"An error occured while performing a No-Op operation.",                          /** MCOErrorNoop */
    @"An application specific password is required",                                  /** MCOErrorGmailApplicationSpecificPasswordRequired */
};

@implementation NSError (MCO)
+ (NSError *)mco_errorWithErrorCode:(mailcore::ErrorCode)code {
    if (code == mailcore::ErrorNone) {
        return nil;
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    if ((NSInteger) code < MCOErrorCodeCount && (NSInteger) code >=0) {
        NSString * localizedString = NSLocalizedStringFromTable(MCOLocalizedDescriptionTable[code], @"description of errors of mailcore", @"MailCore");
        [userInfo setObject:localizedString forKey:NSLocalizedDescriptionKey];
    }
    
    NSError *error = [NSError errorWithDomain:MCOErrorDomain
                                         code:(int)code
                                     userInfo:userInfo];
    [userInfo release];
    return error;
}
@end
