//
//  enterprise_info.m
//  O了
//
//  Created by macmini on 14-01-22.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "enterprise_info.h"

@implementation enterprise_info
@synthesize ID,OrgNum,orgName,pinyin;

+ (id)enterprise_infoOfCategory:(NSInteger)id_contact name:(NSString *)orgName num:(NSInteger)orgnum{
    enterprise_info *newEnterprise = [[self alloc] init];
    [newEnterprise setID:id_contact];
    [newEnterprise setOrgName:orgName];
    [newEnterprise setOrgNum:orgnum];
//    NSString *STR = [orgName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//方法只是去掉左右两边的空格
//    
//    
//    dispatch_queue_t myqueue = dispatch_queue_create("new queue", NULL);
//    dispatch_async(myqueue, ^{
//        //转化成拼音
//        NSMutableString *mstr = [[NSMutableString alloc]initWithString:STR];;
//        
//        if (CFStringTransform((__bridge CFMutableStringRef)mstr, 0, kCFStringTransformMandarinLatin, NO)) {
//            //        DDLogInfo(@"Pingying: %@", mstr); // wǒ shì zhōng guó rén
//        }
//        if (CFStringTransform((__bridge CFMutableStringRef)mstr, 0, kCFStringTransformStripDiacritics, NO)) {
//            [newEnterprise setPinyin:mstr];
//            //        DDLogInfo(@"str::%@",mstr);
//        }
//        
//    });
       return newEnterprise;
}
@end
