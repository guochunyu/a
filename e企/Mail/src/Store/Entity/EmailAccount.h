//
//  EmailAccount.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/10.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface EmailAccount : NSManagedObject

@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * pop3Port;
@property (nonatomic, retain) NSString * pop3Host;
@property (nonatomic, retain) NSNumber * smtpPort;
@property (nonatomic, retain) NSString * smtpHost;
@property (nonatomic, retain) NSSet *email;


+ (instancetype)create;
- (void)decreate;
+ (instancetype)findByAccount:(NSString *)account;
+ (NSArray *)listAccounts;



@end
