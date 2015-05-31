//
//  MailEditController.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//
#import "NavigationVC_AddID.h"
@import UIKit;
@class MailEditHandler;

@interface MailEditController : UIViewController
@property(nonatomic,strong) NSString * str;
@property(nonatomic,strong) NSString * name1;


@property(nonatomic,strong) NSString * name;
@property(nonatomic,strong) NSString * str11;


@property (nonatomic) MailEditHandler *handler;
@property(nonatomic,assign)CGFloat hg;
- (void)onSendCompleted:(BOOL)success desc:(NSString *)desc;
- (void)addFiles:(NSArray *)files;
- (void)contactSelected:(AddScrollType)type member:(NSArray *)memberArray;
@end
