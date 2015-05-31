//
//  LogicHelper.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
#import <MailCore/MailCore.h>
#import "SqlAddressData.h"

#define NetworkIndicatorVisible(a) [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:a]
#define ABDEVICE_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define ABDEVICE_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define ABIOS7_STATUS_BAR_HEIGHT (64.0)
#define ABTableCellHeight (44.0)
#define ABTabBarHeight (49.0)
#define ABToolBarHeight (44.0)
#define ABFontGlobalSize (15.0)

@interface LogicHelper : NSObject

+ (BOOL)isBlankOrNil:(NSString *)str;

+ (NSString * )attachmentSize:(NSInteger)size;

+ (NSString *)sandboxFilePath;

+ (NSString *)sandboxFilePath:(NSString *)fileName;
+ (NSString *)sandboxHtmlFilePath:(NSString *)fileName;

+ (NSString *)sandboxPathTmp;

+ (NSString *)fileSuffix:(NSString *)filename;

//+ (NSString *)writeImageAssetToLocal:(NSString *)filePath imageOrAsset:(NSObject *)imageOrAsset isThumbnail:(BOOL)thumbnail;
//+ (void)deleteImageAssetFromLocal:(NSArray *)filePaths;

+ (void)writeFileToLocal:(NSString *)filename data:(NSData *)data;
+ (NSString *)getLocalFilePath:(NSString *)filename;

+ (CGRect)sizeWithWidth:(NSString *)str width:(CGFloat)width font:(UIFont *)font;
+(CGFloat)hightWith:(NSString*)str width:(CGFloat)width attributesDict:(NSDictionary*)attributesdict;
+(NSString*) getDisplayName:(MCOAddress *) address;

@end
