//
//  TransmitSendMessage.h
//  O了
//
//  Created by 化召鹏 on 14-8-13.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransmitSendMessage : NSObject
+(TransmitSendMessage *)sharedTransmit;
//NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:0];
//[dict setObject:@"sendChat" forKey:@"act"];
//[dict setObject:selfNumber forKey:@"fromUserId"];
//[dict setObject:sendTime forKey:@"sendTime"];
//[dict setObject:contentsStr forKey:@"sendContents"];
//if (isTranmist) {
//    [self addHUD:@"转发中"];
//    [dict setObject:_selectQunliaoM.taskId forKey:@"taskId"];
//    //                [dict setObject:_selectNotesData.sendContents forKey:@"sendContents"];
//}else{
//    [dict setObject:taskId forKey:@"taskId"];
//    
//}
//
//[dict setObject:@"1" forKey:@"type"];
-(void)sendMessage:(NSArray *)queueArray;
@end
