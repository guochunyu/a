//
//  DataToDict.m
//  O了
//
//  Created by 化召鹏 on 14-4-15.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "DataToDict.h"
static NSDictionary *resultDict=nil;

@implementation DataToDict
+(NSDictionary *)dataToDict:(id)sender{
    
    if (!sender) {
        return nil;
    }
    
    if ([sender isKindOfClass:[NSDictionary class]]) {
        resultDict=sender;
    }else{
        resultDict=[NSJSONSerialization JSONObjectWithData:sender options:NSJSONReadingMutableLeaves error:nil];
    }
    return resultDict;
}
+(void)releaseDict{
    resultDict=nil;
}
@end
