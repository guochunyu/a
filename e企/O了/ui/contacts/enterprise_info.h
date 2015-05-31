//
//  enterprise_info.h
//  O了
//
//  Created by macmini on 14-01-22.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface enterprise_info : NSObject

@property (assign, nonatomic)NSInteger ID;
@property (assign, nonatomic)NSInteger OrgNum;
@property (copy, nonatomic)NSString *orgName;
@property (copy, nonatomic)NSString *pinyin;


//+ (id)enterprise_infoOfCategory:(NSInteger)id_contact name:(NSString *)orgName num:(NSInteger)orgnum;
@end
