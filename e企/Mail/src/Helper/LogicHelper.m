//
//  LogicHelper.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "LogicHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation LogicHelper

+ (BOOL)isBlankOrNil:(NSString *)str
{
    return !str || str == nil || [str isEqualToString:[NSString new]];
}

+ (NSString * )attachmentSize:(NSInteger)size
{
    NSString * sizeStr;
    NSInteger integer;//整数
    float remainder;//余数
    integer = size / 1024;
    remainder = size % 1024;
    sizeStr = [NSString stringWithFormat:@"%ld.%.0f KB",(long)integer,remainder];
    if (integer > 1024) {
        integer = integer /1024;
        remainder = integer % 1024;
        sizeStr = [NSString stringWithFormat:@"%ld.%.0f MB",(long)integer,remainder];
    }
    return sizeStr;
}

+ (NSString *)sandboxPathTmp
{
    return NSTemporaryDirectory();
}

+ (NSString *)sandboxFilePath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = @"EmailFiles";
    NSString *dir = [[self sandboxPathTmp] stringByAppendingPathComponent:folder];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return dir;
}

+ (NSString *)sandboxFilePath:(NSString *)fileName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = @"EmailFiles";
    NSString *dir = [[self sandboxPathTmp] stringByAppendingPathComponent:folder];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [dir stringByAppendingPathComponent:fileName];
}
+ (NSString *)sandboxHtmlFilePath:(NSString *)fileName
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = @"HtmlEmailFiles";
    NSString *dir = [[self sandboxPathTmp] stringByAppendingPathComponent:folder];
    BOOL isDir;
    BOOL exist = [manager fileExistsAtPath:dir isDirectory:&isDir];
    if (!isDir || !exist) {
        [manager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [dir stringByAppendingPathComponent:fileName];
}

+ (void)writeFileToLocal:(NSString *)filename data:(NSData *)data
{
    //NSString *fileName = [self md5:filename];
    NSString *filePath = [[self sandboxFilePath] stringByAppendingPathComponent:filename];
    //filePath = [filePath stringByAppendingFormat:@".%@",[self fileSuffix:filename]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return;
    }
    [data writeToFile:filePath atomically:YES];
}

+ (NSString *)getLocalFilePath:(NSString *)filename
{
    //NSString *fileName = [self md5:filename];
    NSString *filePath = [[self sandboxFilePath] stringByAppendingPathComponent:filename];
    //filePath = [filePath stringByAppendingFormat:@".%@",[self fileSuffix:filename]];
    return filePath;
}

+ (NSString *) md5:(id)stringOrData
{
    NSParameterAssert([stringOrData isKindOfClass: [NSData class]] || [stringOrData isKindOfClass: [NSString class]]);
    const char *c;
    if ([stringOrData isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)stringOrData;
        c = [string UTF8String];
    } else {
        NSData *data = (NSData *)stringOrData;
        c = (const char *)[data bytes];
    }
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5( c, (CC_LONG)strlen(c), digist );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [result appendFormat:@"%02x",digist[i]];
    }
    return result;
}

+ (NSString *)fileSuffix:(NSString *)filename
{
    NSString *suffix = [filename lastPathComponent];
    suffix = [suffix pathExtension];
    return suffix;
}

//+ (NSString *)writeImageAssetToLocal:(NSString *)filePath imageOrAsset:(NSObject *)imageOrAsset isThumbnail:(BOOL)thumbnail
//{
//    if (thumbnail) {
//        filePath = [filePath stringByAppendingString:ThumbnailSuffix];
//    }
//    if ([imageOrAsset isKindOfClass:[ALAsset class]]) {
//        ALAsset *asset = (ALAsset *)imageOrAsset;
//        return [self writeAssetToLocal:filePath asset:asset isThumbnail:thumbnail];
//    } else if ([imageOrAsset isKindOfClass:[UIImage class]]) {
//        UIImage *image = (UIImage *)imageOrAsset;
//        return [self writeImageToLocal:filePath image:image isThumbnail:thumbnail];
//    }
//    return [NSString new];
//}
//
//+ (NSString *)writeAssetToLocal:(NSString *)filePath asset:(ALAsset *)asset isThumbnail:(BOOL)thumbnail
//{
//    ALAssetRepresentation *representation = asset.defaultRepresentation;
//    long long size = representation.size;
//    NSUInteger usize = (unsigned int)size;
//    NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:usize];
//    void *buffer = [rawData mutableBytes];
//    [representation getBytes:buffer fromOffset:0 length:usize error:nil];
//    NSData *assetData = [[NSData alloc] initWithBytes:buffer length:usize];
//    UIImage *image = [UIImage imageWithData:assetData];
//    
//    filePath = [self writeImageToLocal:filePath image:image isThumbnail:thumbnail];
//    return filePath;
//    
//}

+ (CGRect)sizeWithWidth:(NSString *)str width:(CGFloat)width font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:str
                                                                        attributes:@{NSFontAttributeName : font,//NSParagraphStyleAttributeName:paragraphStyle
                                                                                     }];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect;
}

+(CGFloat)hightWith:(NSString*)str width:(CGFloat)width attributesDict:(NSDictionary*)attributesdict
{
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]initWithString:str
                                                                        attributes:attributesdict];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size.height;

}

+(NSString*) getDisplayName:(MCOAddress *) address{
    NSString *name = [SqlAddressData queryMemberInfoWithEmail:address.mailbox].name;
    if (name) {
        return name;
    }
    if (address.displayName) {
        return address.displayName;
    }
    return address.mailbox;
}

@end
