//
//  Contact.m
//  O了
//
//  Created by macmini on 14-01-09.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "Contact.h"

@implementation Contact

-(id)initWithCategory:(NSString *)id_contact name:(NSString *)name image:(NSString *)image
          phoneNumber:(NSString *)phone{
    self = [super init];
    if (self) {
        self.id_contact = id_contact;
        self.name = name;
        self.image = image;
        self.phoneNumber = phone;
    }
    
    return self;

}

+ (id)contactOfCategory:(NSString *)id_contact name:(NSString *)name image:(NSString *)image phoneNumber:(NSString *)phone{
    Contact *newContact = [[self alloc] init];
    [newContact setName:name];
    [newContact setImage:image];
    [newContact setId_contact:id_contact];
    [newContact setPhoneNumber:phone];
//    NSString *STR = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//方法只是去掉左右两边的空格
//    NSMutableString *mstr = [[NSMutableString alloc]initWithString:STR];;
//    
//    if (CFStringTransform((__bridge CFMutableStringRef)mstr, 0, kCFStringTransformMandarinLatin, NO)) {
////        DDLogInfo(@"Pingying: %@", mstr); // wǒ shì zhōng guó rén
//    }
//    if (CFStringTransform((__bridge CFMutableStringRef)mstr, 0, kCFStringTransformStripDiacritics, NO)) {
//        [newContact setPinyin:mstr];
////        DDLogInfo(@"str::%@",mstr);
//    }
    return newContact;
}
@end
