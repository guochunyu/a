//
//  FrequentContacts.h
//  O了
//
//  Created by macmini on 14-01-23.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrequentContacts : NSObject
@property (strong, nonatomic)NSMutableArray *FreqmenberAraay;
@property (strong, nonatomic)NSDictionary *FreqmenberDict;

+(FrequentContacts *)sharedInstanse;
-(void)releaseInstanse;
@end
