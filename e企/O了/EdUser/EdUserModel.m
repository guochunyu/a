//
//  EdUserModel.m
//
//  Created by   on 14-11-3
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "EdUserModel.h"
#import "Uinfo.h"


NSString *const kEdUserModelStatus = @"status";
NSString *const kEdUserModelUinfo = @"uinfo";
NSString *const kEdUserModelMsg = @"msg";
NSString *const kEdUserModelTime = @"time";


@interface EdUserModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EdUserModel

@synthesize status = _status;
@synthesize uinfo = _uinfo;
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
            self.status = [[self objectOrNilForKey:kEdUserModelStatus fromDictionary:dict] doubleValue];
            self.uinfo = [Uinfo modelObjectWithDictionary:[dict objectForKey:kEdUserModelUinfo]];
            self.msg = [self objectOrNilForKey:kEdUserModelMsg fromDictionary:dict];
            self.time = [self objectOrNilForKey:kEdUserModelTime fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.status] forKey:kEdUserModelStatus];
    [mutableDict setValue:[self.uinfo dictionaryRepresentation] forKey:kEdUserModelUinfo];
    [mutableDict setValue:self.msg forKey:kEdUserModelMsg];
    [mutableDict setValue:self.time forKey:kEdUserModelTime];

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

    self.status = [aDecoder decodeDoubleForKey:kEdUserModelStatus];
    self.uinfo = [aDecoder decodeObjectForKey:kEdUserModelUinfo];
    self.msg = [aDecoder decodeObjectForKey:kEdUserModelMsg];
    self.time = [aDecoder decodeObjectForKey:kEdUserModelTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_status forKey:kEdUserModelStatus];
    [aCoder encodeObject:_uinfo forKey:kEdUserModelUinfo];
    [aCoder encodeObject:_msg forKey:kEdUserModelMsg];
    [aCoder encodeObject:_time forKey:kEdUserModelTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    EdUserModel *copy = [[EdUserModel alloc] init];
    
    if (copy) {

        copy.status = self.status;
        copy.uinfo = [self.uinfo copyWithZone:zone];
        copy.msg = [self.msg copyWithZone:zone];
        copy.time = [self.time copyWithZone:zone];
    }
    
    return copy;
}


@end
