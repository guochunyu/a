//
//  GetContactDate.h
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetContactDate : NSObject

@property (nonatomic, strong)NSDictionary *sortDict;
@property (nonatomic, strong)NSArray *sortArray;
@property (nonatomic, strong)NSArray *firstThree;
@property (nonatomic, strong)NSDictionary *contact_MutDic;

+(GetContactDate *)sharedInstanse;
-(void)releaseInstanse;
@end
