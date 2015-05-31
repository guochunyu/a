//
//  NSString+FilePath.m
//  O了
//
//  Created by 卢鹏达 on 14-1-23.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NSString+FilePath.h"
#import <objc/runtime.h>
@implementation NSObject (identifyTag)
@dynamic identifyTag;
-(void)setIdentifyTag:(id)identifyTag
{
    objc_setAssociatedObject(self,@"identifyTag", identifyTag,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)identifyTag
{
    return objc_getAssociatedObject(self, @"identifyTag");
}
@end

@implementation NSString (FilePath)
#pragma mark 获取项目沙盒中Documents所在路径
- (NSString *)filePathOfDocuments
{
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    path=[path stringByAppendingPathComponent:self];
    return path;
}
#pragma mark 获取项目沙盒中Caches所在路径
- (NSString *)filePathOfCaches
{
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    path=[path stringByAppendingPathComponent:self];
    return path;
}
#pragma mark 获取项目沙盒中Library所在路径
- (NSString *)filePathOfLibrary
{
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject];
    path=[path stringByAppendingPathComponent:self];
    return path;
}
#pragma mark 获取项目沙盒中Tmp所在路径
- (NSString *)filePathOfTmp
{
    NSString *path=NSTemporaryDirectory();
    path=[path stringByAppendingPathComponent:self];
    return path;
}
#pragma mark - 设备型号
- (NSString *)deviceString{
    UIDevice *device_=[[UIDevice alloc] init];
    DDLogInfo(@"设备所有者的名称－－%@",device_.name);
    DDLogInfo(@"设备的类别－－－－－%@",device_.model);
    DDLogInfo(@"设备的的本地化版本－%@",device_.localizedModel);
    DDLogInfo(@"设备运行的系统－－－%@",device_.systemName);
    DDLogInfo(@"当前系统的版本－－－%@",device_.systemVersion);
    DDLogInfo(@"设备识别码－－－－－%@",device_.identifierForVendor.UUIDString);
    return nil;
}
#pragma mark - 拼装网络请求的path
//- (NSString *)pathRequestUuid:(NSString *)uuid{
//    NSString *newPath=[NSString stringWithFormat:@"%@%@%@",self,request_path_uuid,uuid];
//    return newPath;
//}
- (NSString *)timeWithSecondAndFormat:(NSString *)format{
//    NSString *s = @”1295355600000″; //对应21:00
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]/1000];
    DDLogInfo(@"dddd:%@",d); //2011-01-18 13:00:00 +0000
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    if (!format) {
        format=@"yyyy-MM-dd hh:mm:ss";
    }
    [formatter1 setDateFormat:format];
    NSString *showtimeNew = [formatter1 stringFromDate:d];
    DDLogInfo(@"showtimeNew:%@",showtimeNew); //21:00 比d的时间 +8小时
    return showtimeNew;
}
#pragma mark - 根据时间获取秒数
- (NSString *)secondWithTimeAndFormat:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    if(!format){
        format=@"YYYY-MM-dd HH:mm:ss";
    }
    [formatter setDateFormat:format];
    NSDate* date = [formatter dateFromString:self];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}
- (NSString *)pathRequestUuid:(NSString *)uuid{
    return nil;
}
-(NSString *)deleteOpenFireName{
    NSArray *tempArray=[self componentsSeparatedByString:@"@"];
    NSString *imacct = tempArray[0];
    NSRange range = [imacct rangeOfString:E_APP_KEY];
    if(!(range.location == NSNotFound))
    {
        imacct = [imacct stringByReplacingOccurrencesOfString:E_APP_KEY withString:@""];
    }
    return imacct;
}
-(NSString *)getFromWithRoomMessageFrom{
    NSArray *array=[self componentsSeparatedByString:@"/"];
    if (array.count>1) {
        return array[1];
    }
    return nil;
}
@end
