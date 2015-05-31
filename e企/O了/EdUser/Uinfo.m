//
//  Uinfo.m
//
//  Created by   on 14-11-3
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Uinfo.h"


NSString *const kUinfoCid = @"cid";
NSString *const kUinfoUid = @"uid";
NSString *const kUinfoCity = @"city";
NSString *const kUinfoCname = @"cname";
NSString *const kUinfoUname = @"uname";
NSString *const kUinfoClogo = @"clogo";
NSString *const kUinfoGid = @"gid";
NSString *const kUinfoProvince = @"province";


@interface Uinfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Uinfo

@synthesize cid = _cid;
@synthesize uid = _uid;
@synthesize city = _city;
@synthesize cname = _cname;
@synthesize uname = _uname;
@synthesize clogo = _clogo;
@synthesize gid = _gid;
@synthesize province = _province;


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
            self.cid = [self objectOrNilForKey:kUinfoCid fromDictionary:dict];
            self.uid = [self objectOrNilForKey:kUinfoUid fromDictionary:dict];
            self.city = [self objectOrNilForKey:kUinfoCity fromDictionary:dict];
            self.cname = [self objectOrNilForKey:kUinfoCname fromDictionary:dict];
            self.uname = [self objectOrNilForKey:kUinfoUname fromDictionary:dict];
            self.clogo = [self objectOrNilForKey:kUinfoClogo fromDictionary:dict];
            self.gid = [self objectOrNilForKey:kUinfoGid fromDictionary:dict];
            self.province = [self objectOrNilForKey:kUinfoProvince fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForCid = [NSMutableArray array];
    for (NSObject *subArrayObject in self.cid) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCid addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCid addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCid] forKey:kUinfoCid];
    [mutableDict setValue:self.uid forKey:kUinfoUid];
    NSMutableArray *tempArrayForCity = [NSMutableArray array];
    for (NSObject *subArrayObject in self.city) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCity addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCity addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCity] forKey:kUinfoCity];
    NSMutableArray *tempArrayForCname = [NSMutableArray array];
    for (NSObject *subArrayObject in self.cname) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCname addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCname addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCname] forKey:kUinfoCname];
    [mutableDict setValue:self.uname forKey:kUinfoUname];
    NSMutableArray *tempArrayForClogo = [NSMutableArray array];
    for (NSObject *subArrayObject in self.clogo) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForClogo addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForClogo addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForClogo] forKey:kUinfoClogo];
    NSMutableArray *tempArrayForGid = [NSMutableArray array];
    for (NSObject *subArrayObject in self.gid) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForGid addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForGid addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForGid] forKey:kUinfoGid];
    NSMutableArray *tempArrayForProvince = [NSMutableArray array];
    for (NSObject *subArrayObject in self.province) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForProvince addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForProvince addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForProvince] forKey:kUinfoProvince];

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

    self.cid = [aDecoder decodeObjectForKey:kUinfoCid];
    self.uid = [aDecoder decodeObjectForKey:kUinfoUid];
    self.city = [aDecoder decodeObjectForKey:kUinfoCity];
    self.cname = [aDecoder decodeObjectForKey:kUinfoCname];
    self.uname = [aDecoder decodeObjectForKey:kUinfoUname];
    self.clogo = [aDecoder decodeObjectForKey:kUinfoClogo];
    self.gid = [aDecoder decodeObjectForKey:kUinfoGid];
    self.province = [aDecoder decodeObjectForKey:kUinfoProvince];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_cid forKey:kUinfoCid];
    [aCoder encodeObject:_uid forKey:kUinfoUid];
    [aCoder encodeObject:_city forKey:kUinfoCity];
    [aCoder encodeObject:_cname forKey:kUinfoCname];
    [aCoder encodeObject:_uname forKey:kUinfoUname];
    [aCoder encodeObject:_clogo forKey:kUinfoClogo];
    [aCoder encodeObject:_gid forKey:kUinfoGid];
    [aCoder encodeObject:_province forKey:kUinfoProvince];
}

- (id)copyWithZone:(NSZone *)zone
{
    Uinfo *copy = [[Uinfo alloc] init];
    
    if (copy) {

        copy.cid = [self.cid copyWithZone:zone];
        copy.uid = [self.uid copyWithZone:zone];
        copy.city = [self.city copyWithZone:zone];
        copy.cname = [self.cname copyWithZone:zone];
        copy.uname = [self.uname copyWithZone:zone];
        copy.clogo = [self.clogo copyWithZone:zone];
        copy.gid = [self.gid copyWithZone:zone];
        copy.province = [self.province copyWithZone:zone];
    }
    
    return copy;
}


@end
