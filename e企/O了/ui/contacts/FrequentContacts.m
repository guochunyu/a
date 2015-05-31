//
//  FrequentContacts.m
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "FrequentContacts.h"
#import "FMDatabase.h"
#import "menber_info.h"
#import "NSString+FilePath.h"

static FrequentContacts* frequentcontacts;
@implementation FrequentContacts
@synthesize FreqmenberAraay,FreqmenberDict;
+(FrequentContacts *)sharedInstanse{
    if (!frequentcontacts) {
        frequentcontacts = [[FrequentContacts alloc] init];
        NSString *sqlitePath=[SQLITE_PATH filePathOfCaches];
        //        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //        NSString *documentDirectory = [path objectAtIndex:0];
        //        NSString *dppath = [documentDirectory stringByAppendingPathComponent:@"groupAddress.sqlite"];
        FMDatabase *db = [FMDatabase databaseWithPath:sqlitePath];
        if (![db open]) {
            NSLog(@"Could not open dp");
        }else{
            NSLog(@"连接常用联系人成功");
        }
        
        NSMutableArray *mutArraymenb = [[NSMutableArray alloc]init];
        NSMutableDictionary *mutDic = [[NSMutableDictionary alloc]init];
        FMResultSet *rs=[db executeQuery:@"select * from menber_info where freqFlag=1"];
        while ([rs next]) {
            menber_info *menber = [[menber_info alloc]init];
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
            menber.reserve6 = [rs stringForColumn:@"reserve6"];
            menber.reserve7 = [rs stringForColumn:@"reserve7"];
            menber.reserve8 = [rs stringForColumn:@"reserve8"];
            menber.reserve9 = [rs stringForColumn:@"reserve9"];
            menber.reserve10 = [rs stringForColumn:@"reserve10"];
            menber.avatar = [rs stringForColumn:@"avatar"];
            menber.freqFlag=[rs intForColumn:@"freqFlag"];
//            if ([rs stringForColumn:@"avatar"]) {
//                NSString *fileURL = [NSString stringWithFormat:@"%@%@",HTTP_GetAny,[rs stringForColumn:@"avatar"]];
//                NSURL *url = [NSURL URLWithString:fileURL];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    NSError *error = nil;
//                    NSData *dataImg = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
//                    if ([error code] == 0) {
//                        menber.avatar_data = dataImg;
//                    }
//                });
//                
//            }
            
//            if (menber.freqFlag==1) {
//                NSString *fileURL = [NSString stringWithFormat:@"%@%@",HTTP_GetAny,[rs stringForColumn:@"avatar"]];
//                NSURL *url = [NSURL URLWithString:fileURL];
//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//                    NSError *error = nil;
//                    NSData *dataImg = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
//                    if ([error code] == 0) {
//                        menber.avatar_data = dataImg;
//                    }
//                });
                 NSString *selfNumber=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
                if (![menber.telNum isEqualToString:selfNumber]) {
                    [mutArraymenb addObject:menber];
                    [mutDic setObject:menber forKey:[NSString stringWithFormat:@"%d",menber.ID]];
                }
                
                
//            }
            
//            if ([rs stringForColumn:@"avatar"]) {
//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//                    // Do something...
//                    NSString *fileURL = [NSString stringWithFormat:@"%@%@",HTTP_GetAny,[rs stringForColumn:@"avatar"]];
//                    NSURL *url = [NSURL URLWithString:fileURL];
//                    NSError *error = nil;
//                    NSData *dataImg = [NSData dataWithContentsOfURL:url options:NSDataReadingMappedIfSafe error:&error];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        menber.avatar_data = dataImg;
//                    });
//                });
//                
//            }
            
//            if ([menber.partName isEqualToString:@"研发二部"]) {
//                [mutArraymenb addObject:menber];
//            }
//            
//            if ([menber.telNum isEqualToString:@"18039283037"]) {
//                [mutArraymenb addObject:menber];
//            }
//            
//            if ([menber.telNum isEqualToString:@"18502531083"]) {
//                [mutArraymenb addObject:menber];
//            }
        }
        frequentcontacts.FreqmenberAraay = mutArraymenb;
        frequentcontacts.FreqmenberDict = mutDic;

    }
    
    return frequentcontacts;
}

-(void)releaseInstanse
{
    frequentcontacts = nil;
}

@end
