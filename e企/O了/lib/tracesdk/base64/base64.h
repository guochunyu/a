//
//  base64.h
//  MobileSDK
//
//  Created by Dora.Lin on 14-1-24.
//  Copyright (c) 2014年 LiPo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface base64 : NSObject
+ (void) base64Initialize;
+(NSString*) base64EncodeString:(NSString*)input;//编码
+ (NSString*) base64Encode:(const uint8_t*) input length:(NSInteger) length;
+ (NSString*) base64Encode:(NSData*) rawBytes;
+ (NSData*) base64Decode:(const char*) string length:(NSInteger) inputLength;
+ (NSData*) base64DecodeToData:(NSString*) string;//解码
+ (NSString*) base64DecodeToString:(NSString*) string;
+ (NSString*) removeStringSpace:(NSString*)input;
@end
