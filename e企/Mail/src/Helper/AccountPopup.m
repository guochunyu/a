//
//  AccountPopup.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/19.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AccountPopup.h"
#import "LogicHelper.h"


static const CGFloat kCellHeight = 35.0f;

@interface AccountPopup () <UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic) UITableView *table;

@end


@implementation AccountPopup

- (instancetype)initWithAccount:(NSArray *)accounts delegate:(id<AccountPopupDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _accounts = accounts;
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0, ABIOS7_STATUS_BAR_HEIGHT, ABDEVICE_SCREEN_WIDTH / 2, kCellHeight * [_accounts count]);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithMiddleAccount:(NSArray *)accounts delegate:(id<AccountPopupDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _accounts = accounts;
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake(0, ABIOS7_STATUS_BAR_HEIGHT, ABDEVICE_SCREEN_WIDTH, ABDEVICE_SCREEN_HEIGHT);
        self.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)createAccountsPopupLeft
{
    CGRect frame = CGRectMake(0 , 0, ABDEVICE_SCREEN_WIDTH / 2 + 20, kCellHeight * [_accounts count]);
    UITableView *table = [[UITableView alloc] initWithFrame:frame];
    [table setDelegate:self];
    [table setDataSource:self];
    table.backgroundColor = [UIColor blackColor];
    table.alpha = 1;
    _table = table;
    [self addSubview:table];
}

- (void)createAccountsPopupMiddle
{
    CGRect frame = CGRectMake(ABDEVICE_SCREEN_WIDTH / 4 , 0, ABDEVICE_SCREEN_WIDTH / 2, kCellHeight * [_accounts count]);
    UITableView *table = [[UITableView alloc] initWithFrame:frame];
    [table setDelegate:self];
    [table setDataSource:self];
    table.backgroundColor = [UIColor blackColor];
    table.alpha = 1;
    _table = table;
    [self addSubview:table];
}

- (void)tapped
{
    self.hidden = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view != self) {
        return NO;
    }
    return YES;
}

- (void)setAccounts:(NSArray *)accounts
{
    _accounts = accounts;
    //[_table reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_accounts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableSampleIdentifier = @"MailAccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MailAccountCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableSampleIdentifier];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
        
    EmailAccount *account = _accounts[indexPath.row];
    if ([account.username length] > 15)
    {
        NSRange atRange = [account.username rangeOfString:@"@"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@...@%@",[account.username substringToIndex:7],[account.username substringFromIndex:atRange.location+1]];
    }
    else
    {
        cell.textLabel.text = account.username;
    }
    
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidden = YES;
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didAccountChanged:)]) {
        EmailAccount *act = _accounts[indexPath.row];
        [_delegate didAccountChanged:act];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}


@end
