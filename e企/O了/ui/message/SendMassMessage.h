//
//  SendMassMessage.h
//  e企
//
//  Created by roya-7 on 14/11/22.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SendMassMessageCompltion)(BOOL ret);

@interface SendMassMessage : NSObject
+(void)sendMassMessageWithMemberList:(NSArray *)memberList message:(NSString *)text messageId:(NSString *)uuid complition:(SendMassMessageCompltion)sendMassMessageCompltion;
@end
