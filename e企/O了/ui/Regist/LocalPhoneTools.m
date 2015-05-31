//
//  LocalPhoneTools.m
//  e企
//
//  Created by zw on 4/21/15.
//  Copyright (c) 2015 QYB. All rights reserved.
//

#import "LocalPhoneTools.h"
#import "ChineseToPinyin.h"
@implementation LocalPhoneTools
#pragma mark - aboutSort
+ (NSArray *)getSpellSortArrayFromChineseArray:(NSArray *)sourceArray andKey:(NSString *)key
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *letters = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z", nil];
    NSArray *letters1 = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    
    for (int i=0; i<[letters count]+1; ++i)
    {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        int count = 0;
        if (i == [letters count])
        {
            for (int j = 0; j < [sourceArray count]; ++j)
            {
                NSDictionary *dict = [sourceArray objectAtIndex:j];
                NSString *first = [NSString stringWithFormat:@"%c",[[ChineseToPinyin pinyinFromChiniseString:[dict objectForKey:key]] characterAtIndex:0]];
                if (![letters containsObject:first] && ![letters1 containsObject:first])
                {
                    [array addObject:dict];
                    count ++;
                }
            }
            [dict setObject:@"#" forKey:@"key"];
        }
        else
        {
            
            [dict setObject:[letters objectAtIndex:i] forKey:@"key"];
            for (int j = 0; j < [sourceArray count]; ++j)
            {
                NSDictionary *dict = [sourceArray objectAtIndex:j];
                NSString *first = [NSString stringWithFormat:@"%c",[[ChineseToPinyin pinyinFromChiniseString:[dict objectForKey:key]] characterAtIndex:0]];
                if([first length] > 0)
                {
                    char ch1 = [first characterAtIndex:0];
                    char ch2 = [[letters objectAtIndex:i] characterAtIndex:0];
                    if ([[letters objectAtIndex:i]isEqualToString:first] ||
                        ch1 == ch2 || (ch1+32) == ch2)
                    {
                        [array addObject:dict];
                        count++;
                    }
                }
            }
        }
        
        
        for (int i=0; i<[array count]; i++)
        {
            NSDictionary *maxDict = [array objectAtIndex:i];
            NSString *maxJIanPin = [ChineseToPinyin pinyinFromChiniseString:[maxDict objectForKey:key]];
            for (int j=i; j<[array count]; j++)
            {
                NSDictionary *tmpDict = [array objectAtIndex:j];
                NSString *tmpPinYin = [ChineseToPinyin pinyinFromChiniseString:[tmpDict objectForKey:key]];
                if ([maxJIanPin compare:tmpPinYin options:NSLiteralSearch] == NSOrderedDescending)
                {
                    [array exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
        
        if (count > 0)
        {
            [dict setObject:[NSString stringWithFormat:@"%d",count] forKey:@"count"];
            [dict setObject:array forKey:@"array"];
            [resultArray addObject:dict];
        }
    }
    return resultArray;
}
@end
