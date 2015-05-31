//
//  LocalPhoneListViewController.h
//  e企
//
//  Created by zw on 4/20/15.
//  Copyright (c) 2015 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectContactDoneDelegate <NSObject>

-(void)getSelectedContacts:(NSArray *)contactsArray;

@end

@interface LocalPhoneListViewController : UIViewController
@property (nonatomic, assign) id<SelectContactDoneDelegate> selectDoneDel;
@property (nonatomic, strong) NSArray *selectedContacts;
@property (nonatomic, strong) NSString *account;
@end
