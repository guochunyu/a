//
//  EmailPart.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/14.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Email;

@interface EmailPart : NSManagedObject

@property (nonatomic, retain) NSNumber * partType;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSString * charset;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * contentID;
@property (nonatomic, retain) NSString * contentLocation;
@property (nonatomic, retain) NSString * contentDescription;
@property (nonatomic, retain) NSNumber * inlineAttachment;
@property (nonatomic, retain) Email *email;

+ (instancetype)create;

@end
