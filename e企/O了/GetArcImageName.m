//
//  GetArcImageName.m
//  O了
//
//  Created by 化召鹏 on 14-5-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "GetArcImageName.h"

@implementation GetArcImageName
+(UIImage *)arcImageNameStr:(NSString *)tel{
    //手机号最后一位
    
//    NSString *lastTelNum;
//    
//    if (tel.length>1) {
//        lastTelNum=[tel substringFromIndex:tel.length-1];
//    }else{
//        lastTelNum=tel;
//    }
//    
//    int lastNumTel=[lastTelNum intValue];
//    int index=lastNumTel%4+1;
//    NSString *imageNameStr=[NSString stringWithFormat:@"yezi_%d",index];
//    DDLogInfo(@"%@",imageNameStr);
    UIImage *image=[UIImage imageNamed:@"public_default_avatar_80"];
    return image;
}
@end
