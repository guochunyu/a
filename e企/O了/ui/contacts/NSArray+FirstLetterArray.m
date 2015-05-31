//
//  NSArray+FirstLetterArray.m
//  LetterDescent
//
//  Created by Mr.Yang on 13-8-20.
//  Copyright (c) 2013年 Hunter. All rights reserved.
//

#import "NSArray+FirstLetterArray.h"
//#import "pinyin.h"
#import "menber_info.h"

@implementation NSArray (FirstLetterArray)

- (NSDictionary *)sortedArrayUsingFirstLetter
{
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    const char *letterPoint = NULL;
    NSString *firstLetter = nil;
    for (menber_info *contact in self) {
        NSString *str = contact.reserve1;
        NSString *strId = [NSString stringWithFormat:@"%d",contact.ID];
        //检查 str 是不是 NSString 类型
        if (![str isKindOfClass:[NSString class]]) {
            assert(@"object in array is not NSString");
#ifdef DEBUG
            NSLog(@"object in array is not NSString, it's [%@]", NSStringFromClass([str class]));
#endif
            continue;
        }
        
        letterPoint = [str UTF8String];

//        //如果开头不是大小写字母则读取 首字符
//        if (!(*letterPoint > 'a' && *letterPoint < 'z') &&
//            !(*letterPoint > 'A' && *letterPoint < 'Z')) {
//            
////            //汉字或其它字符
//            char letter = pinyinFirstLetter([str characterAtIndex:0]);
//            letterPoint = &letter;
//            
//        }
        //首字母转成大写
        firstLetter = [[NSString stringWithFormat:@"%c", *letterPoint] uppercaseString];
        //首字母所对应的 姓名列表
        NSMutableArray *mutArray = [mutDic objectForKey:firstLetter];
        
        if (mutArray == nil) {
            mutArray = [NSMutableArray array];
            [mutDic setObject:mutArray forKey:firstLetter];
        }
        
        [mutArray addObject:strId];
    }

    
    //字典是无序的，数组是有序的，
    //将数组排序
    for (NSString *key in [mutDic allKeys]) {
        NSArray *nameArray = [[mutDic objectForKey:key] sortedArrayUsingSelector:@selector(compare:)];
        [mutDic setValue:nameArray forKey:key];
    }
    
    return mutDic;
}

- (NSMutableArray *)sortedArrayOfContact
{
    NSArray *resultArray = [self sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        menber_info *contact1 = obj1;
        menber_info *contact2 = obj2;
        NSString *str1 = contact1.reserve1;
        NSString *str2 = contact2.reserve1;
        NSComparisonResult result = [str1 compare:str2];
        return result == NSOrderedDescending;
    }];
    
    NSMutableArray *mutarray = [[NSMutableArray alloc]initWithArray:resultArray];
    return mutarray;
}

+ (void) changeArray:(NSMutableArray *)dicArray orderWithKey:(NSString *)key ascending:(BOOL)yesOrNo{
    
        NSSortDescriptor *distanceDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:yesOrNo];
    	NSArray *descriptors = [NSArray arrayWithObjects:distanceDescriptor,nil];
    	[dicArray sortUsingDescriptors:descriptors];
   
}

@end
