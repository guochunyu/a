//
//  CalculateCharLength.m
//  O了
//
//  Created by 化召鹏 on 14-6-23.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CalculateCharLength.h"

@implementation CalculateCharLength
+ (int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
    
}
@end
