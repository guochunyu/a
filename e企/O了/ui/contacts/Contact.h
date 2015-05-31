//
//  Contact.h
//  O了
//
//  Created by macmini on 14-01-09.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic, strong) NSString *pinyin;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *id_contact;
@property (nonatomic, strong) NSString *phoneNumber;

-(id)initWithCategory:(NSString *)id_contact name:(NSString *)name image:(NSString *)image
          phoneNumber:(NSString *)phone;

//+(id)contactOfCategory:(NSString *)id_contact name:(NSString *)name image:(NSString *)image phoneNumber:(NSString *)phone;
@end
