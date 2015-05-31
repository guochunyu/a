//
//  ContactsCheck.h
//  e企
//
//  Created by shawn on 14/12/5.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ContactsCheckDelegate <NSObject>
-(void)beginUpdate;
-(void)endUpdate:(bool)hasUpdate;
@end

@interface ContactsCheck : NSObject

+(ContactsCheck*) sharedInstance;

@property (strong, nonatomic) id<ContactsCheckDelegate> contactsCheckDelegate;
@property (assign,nonatomic) int executeStatus;

-(void)execute;

@end
