//
//  NSDate+string.m
//  O了
//
//  Created by roya-7 on 14-10-16.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NSDate+string.h"

@implementation NSDate (string)
-(NSString *)stringWithFormatter:(NSString *)formatter{
    NSDateFormatter *nowFormatter = [[NSDateFormatter alloc] init];
    if(!formatter){
        formatter=@"YYYY-MM-dd HH:mm:ss";
    }
    [nowFormatter setDateFormat:formatter];
    
    NSString *str=[nowFormatter stringFromDate:self];
    
    return str;
}

-(NSString *)nowDateStringWithFormatter:(NSString *)formatter{
    
    NSDate *date=[NSDate date];
    
    if(!formatter){
        formatter=@"YYYY-MM-dd HH:mm:ss";
    }
    
    NSString *str=[date stringWithFormatter:formatter];
    
    return str;
}
@end
