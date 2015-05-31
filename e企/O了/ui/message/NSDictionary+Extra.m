//
//  NSDictionary+Extra.m
//  O了
//
//  Created by 卢鹏达 on 14-1-13.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#import "NSDictionary+Extra.h"

@implementation NSDictionary (Extra)
- (id)keyForObject:(id)object
{
    for (id key in self.allKeys) {
        if (self[key]==object) {
            return key;
        }
    }
    return nil;
}
@end
