//
//  GetContactDate.m
//  O了
//
//  Created by macmini on 14-02-11.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "GetContactDate.h"
#import "menber_info.h"
#import "enterprise_info.h"
#import "menber_enterprise.h"
#import "FrequentContacts.h"
#import "NSArray+FirstLetterArray.h"
#import "Contact.h"
#import "AllMenber.h"

static GetContactDate* getcontactdate;
@implementation GetContactDate

-(id)init{
    self = [super init];
    if (self) {
        self.contact_MutDic = [[NSMutableDictionary alloc]init];
        FrequentContacts *freq = [FrequentContacts sharedInstanse];
        AllMenber *allmenb = [AllMenber sharedInstanse];
        
        self.contact_MutDic = allmenb.menberDic;
        NSDictionary *dic = [freq.FreqmenberAraay sortedArrayUsingFirstLetter];
        self.sortDict = dic;
        self.sortArray = [[self.sortDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.firstThree = [[NSArray alloc]initWithObjects:
                                     [Contact contactOfCategory:@"0" name:@"服务号" image:@"服务号.png" phoneNumber:@"12318650579"],
                                     [Contact contactOfCategory:@"1" name:@"群聊" image:@"群聊.png" phoneNumber:@"12318650570"],
                           [Contact contactOfCategory:@"2" name:@"公司通讯录" image:@"集团通讯录.png" phoneNumber:@"12318650570"],
                           [Contact contactOfCategory:@"3" name:@"个人通讯录" image:@"gr_address.png" phoneNumber:@"12318650570"],
                           [Contact contactOfCategory:@"4" name:@"客户服务" image:@"kefu.png" phoneNumber:@"12318650570"],nil];
    }
    return self;
}

+(GetContactDate *)sharedInstanse{
    if (!getcontactdate) {
        getcontactdate = [[self alloc]init];
    }
    return getcontactdate;
}


-(void)releaseInstanse
{
    getcontactdate =nil;
}

@end
