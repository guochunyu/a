//
//  Uinfo.h
//
//  Created by   on 14-11-3
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Uinfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *cid;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSArray *city;
@property (nonatomic, strong) NSArray *cname;
@property (nonatomic, strong) NSString *uname;
@property (nonatomic, strong) NSArray *clogo;
@property (nonatomic, strong) NSArray *gid;
@property (nonatomic, strong) NSArray *province;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
