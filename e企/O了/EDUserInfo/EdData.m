//
//  EdData.m
//
//  Created by   on 14-11-3
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "EdData.h"


NSString *const kEdDataPhone = @"phone";
NSString *const kEdDataQrcard = @"qrcard";
NSString *const kEdDataUid = @"uid";
NSString *const kEdDataImacct = @"imacct";
NSString *const kEdDataDuty = @"duty";
NSString *const kEdDataAvatar = @"avatar";
NSString *const kEdDataOrgid = @"orgid";
NSString *const kEdDataEmail = @"email";
NSString *const kEdDataDepartment = @"department";
NSString *const kEdDataShortnum = @"shortnum";
NSString *const kEdDataName = @"name";


@interface EdData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EdData

@synthesize phone = _phone;
@synthesize qrcard = _qrcard;
@synthesize uid = _uid;
@synthesize imacct = _imacct;
@synthesize duty = _duty;
@synthesize avatar = _avatar;
@synthesize orgid = _orgid;
@synthesize email = _email;
@synthesize department = _department;
@synthesize shortnum = _shortnum;
@synthesize name = _name;


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
            self.phone = [self objectOrNilForKey:kEdDataPhone fromDictionary:dict];
            self.qrcard = [self objectOrNilForKey:kEdDataQrcard fromDictionary:dict];
            self.uid = [self objectOrNilForKey:kEdDataUid fromDictionary:dict];
            self.imacct = [self objectOrNilForKey:kEdDataImacct fromDictionary:dict];
            self.duty = [self objectOrNilForKey:kEdDataDuty fromDictionary:dict];
            self.avatar = [self objectOrNilForKey:kEdDataAvatar fromDictionary:dict];
            self.orgid = [self objectOrNilForKey:kEdDataOrgid fromDictionary:dict];
            self.email = [self objectOrNilForKey:kEdDataEmail fromDictionary:dict];
            self.department = [self objectOrNilForKey:kEdDataDepartment fromDictionary:dict];
            self.shortnum = [self objectOrNilForKey:kEdDataShortnum fromDictionary:dict];
            self.name = [self objectOrNilForKey:kEdDataName fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.phone forKey:kEdDataPhone];
    [mutableDict setValue:self.qrcard forKey:kEdDataQrcard];
    [mutableDict setValue:self.uid forKey:kEdDataUid];
    [mutableDict setValue:self.imacct forKey:kEdDataImacct];
    NSMutableArray *tempArrayForDuty = [NSMutableArray array];
    for (NSObject *subArrayObject in self.duty) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForDuty addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForDuty addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForDuty] forKey:kEdDataDuty];
    [mutableDict setValue:self.avatar forKey:kEdDataAvatar];
    NSMutableArray *tempArrayForOrgid = [NSMutableArray array];
    for (NSObject *subArrayObject in self.orgid) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForOrgid addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForOrgid addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForOrgid] forKey:kEdDataOrgid];
    [mutableDict setValue:self.email forKey:kEdDataEmail];
    NSMutableArray *tempArrayForDepartment = [NSMutableArray array];
    for (NSObject *subArrayObject in self.department) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForDepartment addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForDepartment addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForDepartment] forKey:kEdDataDepartment];
    [mutableDict setValue:self.shortnum forKey:kEdDataShortnum];
    [mutableDict setValue:self.name forKey:kEdDataName];

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

    self.phone = [aDecoder decodeObjectForKey:kEdDataPhone];
    self.qrcard = [aDecoder decodeObjectForKey:kEdDataQrcard];
    self.uid = [aDecoder decodeObjectForKey:kEdDataUid];
    self.imacct = [aDecoder decodeObjectForKey:kEdDataImacct];
    self.duty = [aDecoder decodeObjectForKey:kEdDataDuty];
    self.avatar = [aDecoder decodeObjectForKey:kEdDataAvatar];
    self.orgid = [aDecoder decodeObjectForKey:kEdDataOrgid];
    self.email = [aDecoder decodeObjectForKey:kEdDataEmail];
    self.department = [aDecoder decodeObjectForKey:kEdDataDepartment];
    self.shortnum = [aDecoder decodeObjectForKey:kEdDataShortnum];
    self.name = [aDecoder decodeObjectForKey:kEdDataName];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_phone forKey:kEdDataPhone];
    [aCoder encodeObject:_qrcard forKey:kEdDataQrcard];
    [aCoder encodeObject:_uid forKey:kEdDataUid];
    [aCoder encodeObject:_imacct forKey:kEdDataImacct];
    [aCoder encodeObject:_duty forKey:kEdDataDuty];
    [aCoder encodeObject:_avatar forKey:kEdDataAvatar];
    [aCoder encodeObject:_orgid forKey:kEdDataOrgid];
    [aCoder encodeObject:_email forKey:kEdDataEmail];
    [aCoder encodeObject:_department forKey:kEdDataDepartment];
    [aCoder encodeObject:_shortnum forKey:kEdDataShortnum];
    [aCoder encodeObject:_name forKey:kEdDataName];
}

- (id)copyWithZone:(NSZone *)zone
{
    EdData *copy = [[EdData alloc] init];
    
    if (copy) {

        copy.phone = [self.phone copyWithZone:zone];
        copy.qrcard = [self.qrcard copyWithZone:zone];
        copy.uid = [self.uid copyWithZone:zone];
        copy.imacct = [self.imacct copyWithZone:zone];
        copy.duty = [self.duty copyWithZone:zone];
        copy.avatar = [self.avatar copyWithZone:zone];
        copy.orgid = [self.orgid copyWithZone:zone];
        copy.email = [self.email copyWithZone:zone];
        copy.department = [self.department copyWithZone:zone];
        copy.shortnum = [self.shortnum copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
    }
    
    return copy;
}


@end
