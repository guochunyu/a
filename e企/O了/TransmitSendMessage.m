//
//  TransmitSendMessage.m
//  O了
//
//  Created by 化召鹏 on 14-8-13.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "TransmitSendMessage.h"

@implementation TransmitSendMessage
+(TransmitSendMessage *)sharedTransmit{
    static TransmitSendMessage *tsm=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tsm=[[TransmitSendMessage alloc] init];
    });
    return tsm;
}
-(void)sendMessage:(NSArray *)queueArray{
    
}
-(void)sendMessageFail:(NSString *)cfuuidString sendDict:(NSDictionary *)dict error:(NSError *)error{
    
    //                DDLogInfo(@"11");
    //发送失败
    
}
@end
