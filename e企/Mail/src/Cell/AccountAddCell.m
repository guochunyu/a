//
//  AccountAddCell.m
//  e企
//
//  Created by 陆广庆 on 15/1/4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "AccountAddCell.h"
#import "ACEAutocompleteBar.h"
#import "LogicHelper.h"
#import "EmailAccount.h"
#import "MailLogic.h"
#import "CoreDataManager.h"
#import "Reachability.h"

@interface AccountAddCell () <ACEAutocompleteDataSource, ACEAutocompleteDelegate>

@property (nonatomic) NSArray *sampleStrings;

@end

@implementation AccountAddCell



-(void)recrive:(NSNotification*)sender{
    DDLogInfo(@"ssssssss");
    _ad.hidden=YES;
}

- (void)configure:(id<AccountAddCellDelegate>)delegate
{
    DDLogInfo(@"输入的时候调用");
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
  
    [center addObserver:self selector:@selector(recrive:) name:@"WWDC" object:nil];

    _iLoginButton.hidden = NO;
    [_iLoginProgress stopAnimating];
    _delegate = delegate;
//    self.sampleStrings = @[@"@139.com",
//                           @"@126.com",
//                           @"@chinamobile.com",
//                           @"@163.com",
//                           @"@yeah.net",
//                           @"@sina.cn",
//                           @"@sina.com",
//                           @"@hotmail.com",
//                           @"@tom.com",
//                           @"@outlook.com",
//                           @"@qq.com",
//                           @"@foxmail.com",
//                           @"@yahoo.com",
//                           @"@gmail.com",
//                           @"@sohu.com"];
    [_iAccountText addTarget:self action:@selector(textChangeAction:)forControlEvents:UIControlEventEditingChanged];
    [_iAccountText setAutocompleteWithDataSource:self
                                        delegate:self
                                       customize:^(ACEAutocompleteInputView *inputView) {
                                           
                                           // customize the view (optional)
//                                           inputView.font = [UIFont systemFontOfSize:20];
                                           inputView.textColor = [UIColor clearColor];
                                           DDLogInfo(@"hehe:%@",inputView);
                                           DDLogInfo(@"gaga:%@",_iAccountText);
//                                           inputView.backgroundColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.9 alpha:0.8];
                                           
                                       }];
//    _iAccountText.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [_iAccountText becomeFirstResponder];
    
    //输入邮箱
    _iAccountText.clearButtonMode = UITextFieldViewModeWhileEditing;
    //登陆按钮
    _iLoginButton.layer.cornerRadius = 3.0f;
}

#pragma mark - Autocomplete Delegate

- (void)textField:(UITextField *)textField didSelectObject:(id)object inInputView:(ACEAutocompleteInputView *)inputView
{
    DDLogInfo(@"1");
    NSString *org = textField.text;
    NSString *append = (NSString *)object;
    append = [org stringByAppendingString:[append substringWithRange:NSMakeRange(1, append.length - 1)]];
    textField.text = append; // NSString
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DDLogInfo(@"2");
    [textField resignFirstResponder];
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    DDLogInfo(@"3");
    return YES;
}

#pragma mark - Autocomplete Data Source

- (NSUInteger)minimumCharactersToTrigger:(ACEAutocompleteInputView *)inputView
{
    DDLogInfo(@"4");
//    [_ad removeFromSuperview];
//    _ad=nil;
    return 1;
}

- (void) textChangeAction:(id) sender {
    if ([_iAccountText.text isEqualToString:@""]) {
        _ad.hidden = YES;
    }
}


- (void)inputView:(ACEAutocompleteInputView *)inputView itemsFor:(NSString *)query result:(void (^)(NSArray *items))resultBlock;
{
    
    DDLogInfo(@"文本框跳出");
    NSMutableString *mailAddr = [[NSMutableString alloc] init];
    for (NSInteger i = 0 ;i<query.length ; i++) {
        int ch = [query characterAtIndex:i];
        if (8198 != ch) {
            NSRange chRang = NSMakeRange(i, 1);
            [mailAddr appendString:[query substringWithRange:chRang]];
        }
        
    }
    query = mailAddr;
    if (resultBlock != nil) {
        // execute the filter on a background thread to demo the asynchronous capability
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            DDLogInfo(@"5");
            // execute the filter
           
//            NSMutableArray *array;
            _emaillala = @[@"139.com",@"chinamobile.com",@"163.com",@"126.com",@"sina.cn",@"tom.com",@"qq.com",@"yahoo.com",@"hotmail.com",@"outlook.com",@"gmail.com",@"sina.com"];
            
//            if (_iAccountText.text=nil) {
//                _ad.hidden=YES;
//            }else{
//                _ad.hidden=NO;
//            }
            
            if (_iAccountText.isFirstResponder) {
               // array = [self.sampleStrings mutableCopy];
                
                DDLogCInfo(@"fffffffffffff:%@",_iAccountText.text);
                //定义了NSMutableArray类型的eArray，在空的情况下调用防止重复开空间
                if (_eArray==nil) {
                      _eArray= [[NSMutableArray alloc]init];
                }

              NSArray * segmentation = [query componentsSeparatedByString:@"@"];
                if (segmentation.count==1) {
                    [_eArray removeAllObjects];
                    for (NSString * forInArrayEmail in _emaillala) {
                        [_eArray addObject:[NSString stringWithFormat:@"%@@%@",query,forInArrayEmail]];
                    }
                  
                }else{
                    
                    [_eArray removeAllObjects];
               
                    NSString* lastOb = segmentation.lastObject;
                  
                    for (NSString *forInArrayEmail1 in _emaillala) {
                        
                        if (lastOb==nil||[lastOb isEqualToString:@""]) {
                            
                            [_eArray addObject:[NSString stringWithFormat:@"%@@%@",segmentation.firstObject,forInArrayEmail1]];
                
                        }else if ([forInArrayEmail1 hasPrefix:lastOb]) {
                            [_eArray addObject:[NSString stringWithFormat:@"%@@%@",segmentation.firstObject,forInArrayEmail1]];
                        }

                        
                    }
                  
                }
                
            }
            
//            NSMutableArray *data = [NSMutableArray array];
//            DDLogInfo(@"%@",query);
//            NSString *at = [query substringWithRange:NSMakeRange(query.length - 1,1)];
//            for (NSString *s in array) {
//                if ([s hasPrefix:at]) {
//                    [data addObject:s];
//                }
//            }
//
            // return the filtered array in the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                resultBlock(nil);
                
                    if (_ad==nil) {
                        _ad = [[UITableView alloc]initWithFrame:CGRectMake(15, 143, 290, 180) style:UITableViewStylePlain];
                        _ad.separatorColor=[UIColor lightGrayColor];
                        _ad.separatorStyle = UITableViewCellSeparatorStyleNone;
                        _ad.backgroundColor=[UIColor clearColor];
                        _ad.delegate=self;
                        _ad.dataSource = self;
                        [_ad bringSubviewToFront:self];
                        [self.window addSubview:_ad];
                    }else{
                        _ad.hidden=NO;
                    }
             [self.ad reloadData];

            });
        });
    }
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _eArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             TableSampleIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:TableSampleIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = _eArray[row];
    cell.textLabel.font=[UIFont systemFontOfSize:11.5];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        NSString * str = _eArray[indexPath.row];
        _iAccountText.text = str;
        if (self.iAccountText.text!=nil) {
            _ad.hidden = YES;
        }
   
   
    
    
    
}
-(void)dealloc{
    //找到通知中心
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:@"WWDC" object:nil];
    
}
- (IBAction)login:(id)sender {
    NSString *email = _iAccountText.text;
    NSString *password = _iPasswordText.text;
    // 邮箱为空
    if ([LogicHelper isBlankOrNil:email]) {
        [self alertMessage:NSLocalizedString(@"MailActAdd.email.empty", nil)];
        return;
    }
    // 密码为空
    if ([LogicHelper isBlankOrNil:password]) {
        [self alertMessage:NSLocalizedString(@"MailActAdd.password.empty", nil)];
        return;
    }
    // 已存在
    if ([EmailAccount findByAccount:email] != nil) {
        [self alertMessage:NSLocalizedString(@"MailActAdd.email.exist", nil)];
        return;
    }
    _iAccountText.enabled = NO;
    _iPasswordText.enabled = NO;
    // 格式判断
    NSUInteger location = [email rangeOfString:@"@"].location;
    if (location == NSNotFound || location == email.length - 1 || location == 0) {
        [self alertMessage:NSLocalizedString(@"MailActAdd.email.format", nil)];
        return;
    }
    
    if (![Reachability isNetWorkReachable])
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        return;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"登陆中" object:nil];
    
    NSString *_serverHost = nil;
    
    NSString *sufix = [email substringWithRange:NSMakeRange(location + 1, email.length - location - 1)];
    NSString *smtpHost = [NSString stringWithFormat:kDefaultSMTPHostFormat,sufix];
    if (_serverHost == nil) {
        _serverHost = [NSString stringWithFormat:kDefaultPOPHostFormat,sufix];
    }
    NSNumber *_serverPort = nil;
    if (_serverPort == nil) {
        _serverPort = @(kDefaultPOPPort);
    }
    
    // 登录验证：
    //[_controller enableUIForNetworking:NO];
    _iLoginButton.hidden = YES;
    [_iLoginProgress startAnimating];
    NetworkIndicatorVisible(YES);
    DDLogInfo(@"邮件账户登录:%@ host:%@ port:%ld",email,_serverHost,(long)[_serverPort integerValue]);
    EmailAccount *account = [EmailAccount create];
    //EmailAccount *account=[[EmailAccount alloc]init];
    account.username = email;
    account.password = password;
    account.pop3Host = _serverHost;
    account.pop3Port = _serverPort;
    account.smtpPort = @(kDefaultSMTPPort);
    account.smtpHost = smtpHost;
    [MailLogic checkAccount:account completion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NetworkIndicatorVisible(NO);
            _iAccountText.enabled = YES;
            _iPasswordText.enabled = YES;
            _iLoginButton.hidden = NO;
            [_iLoginProgress stopAnimating];
            //[_controller enableUIForNetworking:YES];
            if (error == nil) {
                DDLogInfo(@"邮件账户登录成功");
                _iAccountText.text = nil;
                _iPasswordText.text = nil;
                [[CoreDataManager sharedInstance] save];
                [_delegate refreshViewForAccount];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"登陆后" object:nil];
            } else {
                DDLogInfo(@"邮件账户登录失败:%@",error);
                [account decreate];
                [self alertMessage:@"登录失败，请确认邮箱或密码是否正确"];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"登陆后" object:nil];
            }
        });
    }];
}

- (void)alertMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"app.confirm", nil) otherButtonTitles:nil, nil];
    [alert show];
}

@end
