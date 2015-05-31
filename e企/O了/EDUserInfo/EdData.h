//
//  EdData.h
//
//  Created by   on 14-11-3
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface EdData : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *qrcard;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *imacct;
@property (nonatomic, strong) NSArray *duty;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSArray *orgid;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSArray *department;
@property (nonatomic, strong) NSString *shortnum;
@property (nonatomic, strong) NSString *name;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
