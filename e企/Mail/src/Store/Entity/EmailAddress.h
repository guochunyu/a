//
//  EmailAddress.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Email;

@interface EmailAddress : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSSet *sender;
@property (nonatomic, retain) NSSet *receivers;
@property (nonatomic, retain) NSSet *cc;


+ (instancetype)create;

- (NSString *)displayNameOrAddress;

@end


