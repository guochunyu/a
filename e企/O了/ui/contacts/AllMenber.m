//
//  AllMenber.m
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "AllMenber.h"
#import "NSString+FilePath.h"
#import "HttpRequstUrl.h"

static AllMenber* allmenberstance;
@implementation AllMenber
@synthesize menberAraay,menberDic;

+(AllMenber *)sharedInstanse{
    if (!allmenberstance) {
        allmenberstance = [[AllMenber alloc] init];
        
        NSString *sqlitePath=[SQLITE_PATH filePathOfCaches];
//        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentDirectory = [path objectAtIndex:0];
//        NSString *dppath = [documentDirectory stringByAppendingPathComponent:@"groupAddress.sqlite"];
        FMDatabase *db = [FMDatabase databaseWithPath:sqlitePath];
        if (![db open]) {
            NSLog(@"Could not open dp");
        }else{
            NSLog(@"连接groupAddress成功");
        }
        
        NSMutableArray *mutArraymenb = [[NSMutableArray alloc]init];
        NSMutableDictionary *mutDic = [[NSMutableDictionary alloc]init];
#warning 不知道这样写有没有影响
#pragma mark ---查询所有人员信息放到内存中,后期考虑不放到内存中
        
        FMResultSet *rs=[db executeQuery:@"select * from menber_info where partName <> '公司领导'"];
        while ([rs next]) {
            menber_info *menber = [[menber_info alloc] init];
            menber.ID = [rs intForColumn:@"id"];
            menber.OrgNum = [rs intForColumn:@"orgNum"];
            menber.partName = [rs stringForColumn:@"partName"];
            menber.telNum = [rs stringForColumn:@"telNum"];
            menber.menberName = [rs stringForColumn:@"menberName"];
            menber.shortNum = [rs stringForColumn:@"shortNum"];
            menber.reserve1 = [rs stringForColumn:@"reserve1"];
            menber.reserve2 = [rs stringForColumn:@"reserve2"];
            menber.reserve3 = [rs stringForColumn:@"reserve3"];
            menber.reserve4 = [rs stringForColumn:@"reserve4"];
            menber.reserve5 = [rs stringForColumn:@"reserve5"];
//            menber.reserve6 = [rs stringForColumn:@"reserve6"];//未知
//            menber.reserve7 = [rs stringForColumn:@"reserve7"];//性别
            menber.reserve8 = [rs stringForColumn:@"reserve8"];
//            menber.reserve9 = [rs stringForColumn:@"reserve9"];//邮箱
            menber.reserve10 = [rs stringForColumn:@"reserve10"];
            menber.avatar = [rs stringForColumn:@"avatar"];
            menber.freqFlag=[rs intForColumn:@"freqFlag"];
            
//            if ([rs stringForColumn:@"avatar"]) {
//                NSString *fileURL = [NSString stringWithFormat:@"%@%@",HTTP_GetAny,[rs stringForColumn:@"avatar"]];
//                NSURL *url = [NSURL URLWithString:fileURL];
//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//                    NSError *error = nil;
//                    NSData *dataImg = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
//                    if ([error code] == 0) {
//                         menber.avatar_data = dataImg;
//                    }
//                });
//
//            }
            
          /*  if ([rs stringForColumn:@"avatar"]) {
                NSString *fileURL = [NSString stringWithFormat:@"%@%@",HTTP_GetAny,[rs stringForColumn:@"avatar"]];
                NSURL *url = [NSURL URLWithString:fileURL];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    // Do something...
                
                    NSError *error = nil;
                    NSData *dataImg = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
                    if ([error code] == 0) {
                        menber.avatar_data = dataImg;
                    }
//                    menber.avatar_data = dataImg;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        menber_info *menb1 = [menber copy];
//                        menber.avatar_data = dataImg;
//                        NSInteger int_count = [allmenberstance.menberAraay indexOfObject:menb1];
//                        [allmenberstance.menberAraay replaceObjectAtIndex:int_count withObject:menber];
//                        
//                    });
                });
                
            }*/
            if (![menber.reserve5 isEqualToString:@"公司领导"]) {
                [mutArraymenb addObject:menber];
            }
            
            [mutDic setObject:menber forKey:[NSString stringWithFormat:@"%d",menber.ID]];
        }
        allmenberstance.menberAraay = mutArraymenb;
        allmenberstance.menberDic = mutDic;
        [rs close];
        [db close];
    }
    return allmenberstance;
}

-(void)releaseInstanse
{
    allmenberstance = nil;
}

@end
