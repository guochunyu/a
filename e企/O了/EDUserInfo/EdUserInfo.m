//
//  EdUserInfo.m
//
//  Created by   on 14-11-3
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "EdUserInfo.h"
#import "EdData.h"


NSString *const kEdUserInfoStatus = @"status";
NSString *const kEdUserInfoData = @"data";
NSString *const kEdUserInfoMsg = @"msg";
NSString *const kEdUserInfoTime = @"time";


@interface EdUserInfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EdUserInfo

@synthesize status = _status;
@synthesize data = _data;
@synthesize msg = _msg;
@synthesize time = _time;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.status = [[self objectOrNilForKey:kEdUserInfoStatus fromDictionary:dict] doubleValue];
            self.data = [EdData modelObjectWithDictionary:[dict objectForKey:kEdUserInfoData]];
            self.msg = [self objectOrNilForKey:kEdUserInfoMsg fromDictionary:dict];
            self.time = [self objectOrNilForKey:kEdUserInfoTime fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.status] forKey:kEdUserInfoStatus];
    [mutableDict setValue:[self.data dictionaryRepresentation] forKey:kEdUserInfoData];
    [mutableDict setValue:self.msg forKey:kEdUserInfoMsg];
    [mutableDict setValue:self.time forKey:kEdUserInfoTime];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.status = [aDecoder decodeDoubleForKey:kEdUserInfoStatus];
    self.data = [aDecoder decodeObjectForKey:kEdUserInfoData];
    self.msg = [aDecoder decodeObjectForKey:kEdUserInfoMsg];
    self.time = [aDecoder decodeObjectForKey:kEdUserInfoTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_status forKey:kEdUserInfoStatus];
    [aCoder encodeObject:_data forKey:kEdUserInfoData];
    [aCoder encodeObject:_msg forKey:kEdUserInfoMsg];
    [aCoder encodeObject:_time forKey:kEdUserInfoTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    EdUserInfo *copy = [[EdUserInfo alloc] init];
    
    if (copy) {

        copy.status = self.status;
        copy.data = [self.data copyWithZone:zone];
        copy.msg = [self.msg copyWithZone:zone];
        copy.time = [self.time copyWithZone:zone];
    }
    
    return copy;
}


@end
