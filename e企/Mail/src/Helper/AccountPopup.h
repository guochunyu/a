//
//  AccountPopup.h
//  EnterpriseMail
//
//  Created by 冯倩 on 14/12/19.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailAccount.h"

@protocol AccountPopupDelegate <NSObject>

- (void)didAccountChanged:(EmailAccount *)account;

@end


@interface AccountPopup : UIView

@property (nonatomic) NSArray *accounts;

@property (nonatomic) id<AccountPopupDelegate> delegate;

- (instancetype)initWithAccount:(NSArray *)accounts delegate:(id<AccountPopupDelegate>)delegate;
- (instancetype)initWithMiddleAccount:(NSArray *)accounts delegate:(id<AccountPopupDelegate>)delegate;
- (void)createAccountsPopupLeft;
- (void)createAccountsPopupMiddle;



@end
