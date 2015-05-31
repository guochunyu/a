//
//  SendMassMessage.m
//  e企
//
//  Created by roya-7 on 14/11/22.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "SendMassMessage.h"

@implementation SendMassMessage
+(void)sendMassMessageWithMemberList:(NSArray *)memberList message:(NSString *)text messageId:(NSString *)uuid complition:(SendMassMessageCompltion)sendMassMessageCompltion{
    NSXMLElement *x=[NSXMLElement elementWithName:@"msg_content"];
    NSXMLElement *c=[NSXMLElement elementWithName:@"media_type" stringValue:@"10"];
    [x addChild:c];
    NSDate *date=[NSDate date];
    NSString *nowTimeStr=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
    c=[NSXMLElement elementWithName:@"create_time" stringValue:nowTimeStr];
    [x addChild:c];
    
    c=[NSXMLElement elementWithName:@"text" stringValue:text];
    [x addChild:c];
    
    NSMutableString *str=[[NSMutableString alloc] init];
//    NSMutableString *memberNameStr=[[NSMutableString alloc] init];
//    NSMutableString *memberImaccStr=[[NSMutableString alloc] init];

    
    for (EmployeeModel *emp in memberList) {
        [str appendFormat:@"%@;",[[QFXmppManager shareInstance] checkJid:emp.imacct]];
//        [memberNameStr appendFormat:@"%@,",emp.name];
//        [memberImaccStr appendFormat:@"%@;",emp.imacct];
    }
    
    NSString *memberListStr=[str substringToIndex:str.length-1];
//    NSString *memberNameListStr=[memberNameStr substringToIndex:memberNameStr.length-1];
//    NSString *memberImaccListStr=[memberImaccStr substringToIndex:memberImaccStr.length-1];
//    NSString *myName=[ConstantObject sharedConstant].userInfo.name;

    
    NSDictionary *extparamDict=@{@"sender_id":[[QFXmppManager shareInstance] checkJid:[ConstantObject sharedConstant].userInfo.imacct],
                                 @"msg_type":@"1"};
    NSError *error=nil;
    NSData *dataJson=[NSJSONSerialization dataWithJSONObject:extparamDict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *extparamStr=[[NSString alloc] initWithData:dataJson encoding:NSUTF8StringEncoding];
    
    c=[NSXMLElement elementWithName:@"extparam" stringValue:extparamStr];
    [x addChild:c];
    
    NSString *xmlStr=[x XMLString];
    
    NSDictionary *dict=@{@"serverid":[[QFXmppManager shareInstance] checkJid:[ConstantObject sharedConstant].userInfo.imacct],
                         @"receivers":memberListStr,
                         @"contentxml":xmlStr};
    [[AFClient sharedClient] postPath:@"padata/open/sendmsg/sendxmlmsg/" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
       // DDLogInfo(@"---:%@",operation.responseString);
        sendMassMessageCompltion(YES);
//        MessageModel *mm=[[MessageModel alloc] init];
//        mm.chatType=1;
//        mm.fileType=0;
//        
//        mm.receivedTime=nowTimeStr;
//        
////        NSDate *nowDate=[NSDate date];
////        NSString *nowTimeStr=[nowDate nowDateStringWithFormatter:@"yyyy-MM-dd hh:mm:ss:SSS"];
//        
//        mm.messageID=uuid;
//        
//        mm.msg = text;
//        
//        mm.from = [ConstantObject sharedConstant].userInfo.imacct;
//        mm.to  = memberImaccListStr;
//        mm.thread=@"";
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"---:%@",operation.responseString);
        sendMassMessageCompltion(NO);
    }];
}
@end
