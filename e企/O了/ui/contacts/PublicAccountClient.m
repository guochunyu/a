//
//  PublicAccountClient.m
//  e企
//
//  Created by roya-7 on 14/11/24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "PublicAccountClient.h"

@implementation PublicAccountClient

static PublicAccountClient *publicClient=nil;

+(PublicAccountClient *)sharedPublicClient{
    if (!publicClient) {
        publicClient=[[PublicAccountClient alloc] init];
    }
    return publicClient;
}

- (AFHTTPRequestOperation *)requestOperationWithMsgname:(NSString *)name withVersion:(NSString *)version withBodyStr:(NSString *)bodyStr success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [manager.requestSerializer setValue:[[QFXmppManager shareInstance] checkJid:[ConstantObject sharedConstant].userInfo.imacct] forHTTPHeaderField:@"userid"];
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [manager.requestSerializer setValue:name forHTTPHeaderField:@"msgname"];
    [manager.requestSerializer setValue:version forHTTPHeaderField:@"version"];
    NSString *afBaseUrlString=[NSString stringWithFormat:@"http://%@:%@/padata/eclient/msg",HTTP_IP,HTTP_PORT];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:afBaseUrlString parameters:nil error:nil];
    
    [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFHTTPRequestOperation *operation=[manager HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [manager.operationQueue addOperation:operation];
    
    return operation;
    
}
#pragma mark - 获取body
//body
+(NSString *)xmlGetpubliclistWithPagesize:(NSString *)size withPageNum:(NSString *)num{
    NSXMLElement *x=[NSXMLElement elementWithName:@"body"];
    NSXMLElement *c=[NSXMLElement elementWithName:@"order" stringValue:@"1"];
    [x addChild:c];
    
    c=[NSXMLElement elementWithName:@"pagesize" stringValue:size];
    [x addChild:c];
    
    c=[NSXMLElement elementWithName:@"keyword" stringValue:@""];
    [x addChild:c];
    
    c=[NSXMLElement elementWithName:@"pagenum" stringValue:num];
    [x addChild:c];
    NSString *myGid_=[[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    c=[NSXMLElement elementWithName:@"corporation_id" stringValue:myGid_];
    [x addChild:c];
    NSString *bodyStr=[x XMLString];

    return bodyStr;
}
+(NSString *)xmlGetpublicdetailWithPa_uuid:(NSString *)pa_uuid{
//    <body><pa_uuid>5472fd7e24ac9b648a6e6cef</pa_uuid><updatetime>2014-11-24 22:04:03</updatetime></body>
    NSXMLElement *x=[NSXMLElement elementWithName:@"body"];
    NSXMLElement *c=[NSXMLElement elementWithName:@"pa_uuid" stringValue:pa_uuid];
    [x addChild:c];
    
    NSDate *date=[NSDate date];
    NSString *nowTime=[date nowDateStringWithFormatter:@"yyyy-MM-dd hh:mm:ss"];
    
    c=[NSXMLElement elementWithName:@"updatetime" stringValue:nowTime];
    [x addChild:c];
    NSString *str=[x XMLString];
    return str;
}
+(NSString *)xmlAddsubscribeWithPa_uuid:(NSString *)pa_uuid{
//    <body><num>1</num><publicaccounts><pa_uuid>547305a824ac9b648a6e6d00</pa_uuid></publicaccounts></body>
    NSXMLElement *x=[NSXMLElement elementWithName:@"body"];
    
    NSXMLElement *c=[NSXMLElement elementWithName:@"num" stringValue:@"1"];
    [x addChild:c];
    
    NSXMLElement *x_01=[NSXMLElement elementWithName:@"publicaccounts"];
    NSXMLElement *c_01=[NSXMLElement elementWithName:@"pa_uuid" stringValue:pa_uuid];
    
    
    [x_01 addChild:c_01];
    [x addChild:x_01];
    
    return [x XMLString];
    
    
}
+(NSString *)xmlCancelsubscribeWithPa_uuid:(NSString *)pa_uuid{
//    ><body><num>1</num><publicaccounts><pa_uuid>5472fd9724ac9b648a6e6cf0</pa_uuid></publicaccounts></body>
    NSXMLElement *x=[NSXMLElement elementWithName:@"body"];
    NSXMLElement *c=[NSXMLElement elementWithName:@"num" stringValue:@"1"];
    [x addChild:c];
    
    NSXMLElement *x_01=[NSXMLElement elementWithName:@"publicaccounts"];
    NSXMLElement *c_01=[NSXMLElement elementWithName:@"pa_uuid" stringValue:pa_uuid];
    [x_01 addChild:c_01];
    [x addChild:x_01];
    
    return [x XMLString];
}
+(NSString *)xmlQueryusersubWithPagesize:(NSString *)size withPageNum:(NSString *)num{
//    <body><order>0</order><pagesize>100</pagesize><pagenum>1</pagenum><corporation_id>3398351030</corporation_id></body>
    NSXMLElement *x=[NSXMLElement elementWithName:@"body"];
    NSXMLElement *c=[NSXMLElement elementWithName:@"order" stringValue:@"0"];
    [x addChild:c];
    
    c=[NSXMLElement elementWithName:@"pagesize" stringValue:size];
    [x addChild:c];

    
    c=[NSXMLElement elementWithName:@"pagenum" stringValue:num];
    [x addChild:c];
    NSString *myGid_=[[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    c=[NSXMLElement elementWithName:@"corporation_id" stringValue:myGid_];
    [x addChild:c];
    NSString *bodyStr=[x XMLString];
    return bodyStr;
}
+(NSString *)xmlGetpremessageWithPa_uuid:(NSString *)pa_uuid withNumber:(NSString *)number{
//    <body><pa_uuid>546045d324ac1296d934c562</pa_uuid><timestamp></timestamp><order>1</order><number>10</number></body>
    NSXMLElement *x=[NSXMLElement elementWithName:@"body"];
    NSXMLElement *c=[NSXMLElement elementWithName:@"pa_uuid" stringValue:pa_uuid];
    [x addChild:c];
    c=[NSXMLElement elementWithName:@"timestamp" stringValue:@""];
    [x addChild:c];
    c=[NSXMLElement elementWithName:@"order" stringValue:@"1"];
    [x addChild:c];
    
    c=[NSXMLElement elementWithName:@"number" stringValue:number];
    [x addChild:c];
    return [x XMLString];
}
@end
