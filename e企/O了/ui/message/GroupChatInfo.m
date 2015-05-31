//
//  GroupChatInfo.m
//  O了
//
//  Created by roya on 14-2-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "GroupChatInfo.h"

@implementation GroupChatInfo
- (NSString *)taskID{
    if (_taskID) {
        return _taskID;
    }
    return @"";
}
@end
