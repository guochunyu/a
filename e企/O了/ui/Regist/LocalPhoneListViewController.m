//
//  LocalPhoneListViewController.m
//  e企
//
//  Created by zw on 4/20/15.
//  Copyright (c) 2015 QYB. All rights reserved.
//

#import "LocalPhoneListViewController.h"
#import "MacroDefines.h"
#import "LocalPhoneCell.h"
#import "LocalPhoneTools.h"
#import "UIImage+ColorImage.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#define IconImageViewRowTag 222
#define IconImageViewSectionTag  777777

@interface LocalPhoneListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *phoneListTableView;
    
    NSMutableArray *phoneListArray;
    NSMutableArray *groupContactArray;
    NSMutableArray *indexArray;
    
    NSMutableArray *selectedContactArray;
    
    UIButton *doneButton;
    
    NSArray *colorArray;
    
    UIView *bottomView;
    UIScrollView *bottomScrollView;
    
    UILabel *tipLabel;
    
}
@end

@implementation LocalPhoneListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view .backgroundColor = bgcor3;
    self.title = @"添加成员";
    
    phoneListArray = [[NSMutableArray alloc] initWithCapacity:0];
    groupContactArray = [[NSMutableArray alloc] initWithCapacity:0];
    indexArray = [[NSMutableArray alloc] initWithCapacity:0];
    selectedContactArray = [[NSMutableArray alloc] initWithArray:self.selectedContacts];
    
    colorArray = @[RGB(253, 125, 156, 1),
                   RGB(127, 201, 252, 1),
                   RGB(208, 198, 190, 1),
                   RGB(150, 136, 219, 1),
                   RGB(253, 184, 140, 1),
                   RGB(119, 210, 198, 1),
                   RGB(165, 148, 241, 1)];
    
    phoneListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,  ScreenWidth, ScreenHeight-45) style:UITableViewStylePlain];
    phoneListTableView.dataSource = self;
    phoneListTableView.delegate = self;
    phoneListTableView.sectionIndexColor = cor1;
    phoneListTableView.sectionIndexMinimumDisplayRowCount = 5;
    phoneListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:phoneListTableView];
    
    //提示label
    tipLabel = [[UILabel alloc] init];
    tipLabel.frame = CGRectMake(15, (ScreenHeight-50)/2-80, ScreenWidth-30, 100);
    tipLabel.numberOfLines = 2;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.textColor = cor2;
    tipLabel.hidden = YES;
    tipLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:tipLabel];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-45, ScreenWidth, 45)];
    bottomView.backgroundColor = bgcor3;
    [self.view addSubview:bottomView];
    
    bottomScrollView = [[UIScrollView alloc] init];
    bottomScrollView.frame = CGRectMake(0, 0, ScreenWidth-80, 45);
    bottomScrollView.backgroundColor = [UIColor clearColor];
    [bottomView addSubview:bottomScrollView];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([self.selectedContacts count] > 0)
    {
        [doneButton setTitle:[NSString stringWithFormat:@"确定(%d)",[self.selectedContacts count]] forState:UIControlStateNormal];
    }
    else
    {
        [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    }

    doneButton.frame = CGRectMake(ScreenWidth-70, 7.5f, 60, 30);
    [doneButton addTarget:self action:@selector(doneClick) forControlEvents:UIControlEventTouchUpInside];
    doneButton.layer.cornerRadius = 3;
    doneButton.clipsToBounds = YES;
    doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [doneButton setBackgroundImage:[UIImage imageWithColor:RGB(68, 141, 241, 1)] forState:UIControlStateNormal];
    [bottomView addSubview:doneButton];
   
    [self getLocalContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneClick
{
    if ([self.selectDoneDel respondsToSelector:@selector(getSelectedContacts:)])
    {
        [self.selectDoneDel getSelectedContacts:selectedContactArray];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexArray;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [groupContactArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[groupContactArray objectAtIndex:section] objectForKey:@"count"] integerValue];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"  %@",[[groupContactArray objectAtIndex:section] objectForKey:@"key"]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *phoneListIder = @"phonelistIder";
    LocalPhoneCell *phoneCell = [tableView dequeueReusableCellWithIdentifier:phoneListIder];
    if (phoneCell == nil);
    {
        phoneCell = [[LocalPhoneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:phoneListIder];
    }
    NSArray *tmpArray = [[groupContactArray objectAtIndex:indexPath.section] objectForKey:@"array"];
    NSDictionary *contactDict = [tmpArray objectAtIndex:indexPath.row];
    
    phoneCell.iconImageView.tag = IconImageViewSectionTag*(indexPath.section+11)+(indexPath.row+11)*IconImageViewRowTag;
    phoneCell.iconImageView.frame = CGRectMake(10, 20, 20, 20);
    if ([self haveSelectThisPhone:[contactDict objectForKey:@"phone"]])
    {
        [phoneCell.iconImageView setImage:[UIImage imageNamed:@"checkcontact"]];
    }
    else
    {
        [phoneCell.iconImageView setImage:[UIImage imageNamed:@"nocheckcontact"]];
    }
    
    NSString *name = [contactDict objectForKey:@"name"];
    phoneCell.nameIconLabel.frame = CGRectMake(40, 10, 40, 40);
    int i = arc4random() % 5 ;
    phoneCell.nameIconLabel.backgroundColor = [colorArray objectAtIndex:i];
    phoneCell.nameIconLabel.layer.cornerRadius = 20;
    phoneCell.nameIconLabel.textAlignment = NSTextAlignmentCenter;
    phoneCell.nameIconLabel.clipsToBounds = YES;
    if ([name length] >= 2)
    {
        unichar c1 = [name characterAtIndex:0];
        unichar c2 = [name characterAtIndex:1];
        if (!((c1 >=0x4E00 && c1 <=0x9FFF) &&
              (c2 >=0x4E00 && c2 <=0x9FFF)))
        {
            //英文
            phoneCell.nameIconLabel.text = [name substringToIndex:2];
        }
        else
        {
            //汉字
            phoneCell.nameIconLabel.text = [name substringFromIndex:[name length]-2];
        }
    }
    else
    {
        phoneCell.nameIconLabel.text = name;
    }
    
    phoneCell.nameLabel.frame = CGRectMake(90, 10, 200, 20);
    phoneCell.nameLabel.text = name;
    
    phoneCell.phoneLabel.frame = CGRectMake(90, 35, 250, 20);
    phoneCell.phoneLabel.text = [contactDict objectForKey:@"phone"];
    
    if ([[[groupContactArray objectAtIndex:indexPath.section] objectForKey:@"count"] integerValue]-1 == indexPath.row && indexPath.row == 0)
    {
        phoneCell.topLineView.frame = CGRectMake(0, 0, ScreenWidth, 0.7f);
        phoneCell.bottomLineView.frame = CGRectMake(0, 59.5f, ScreenWidth, 0.7f);
        phoneCell.topLineView.hidden = NO;
        phoneCell.bottomLineView.hidden = NO;
    }
    else if ([[[groupContactArray objectAtIndex:indexPath.section] objectForKey:@"count"] integerValue]-1 == indexPath.row)
    {
        phoneCell.topLineView.hidden = YES;
        phoneCell.bottomLineView.frame = CGRectMake(0, 59.5f, ScreenWidth, 0.7f);
    }
    else if(indexPath.row == 0)
    {
        phoneCell.bottomLineView.frame = CGRectMake(55, 59.5f, ScreenWidth, 0.7f);
        phoneCell.topLineView.frame = CGRectMake(0, 0, ScreenWidth, 0.7f);
    }
    else
    {
        phoneCell.topLineView.frame = CGRectMake(55, 59.5f, ScreenWidth, 0.7f);
        phoneCell.bottomLineView.hidden = YES;
    }
    phoneCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return phoneCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *tmpArray = [[groupContactArray objectAtIndex:indexPath.section] objectForKey:@"array"];
    NSDictionary *contactDict = [tmpArray objectAtIndex:indexPath.row];
    if ([self haveSelectThisPhone:[contactDict objectForKey:@"phone"]])
    {
        [((UIImageView *)[phoneListTableView viewWithTag:IconImageViewSectionTag*(indexPath.section+11)+(indexPath.row+11)*IconImageViewRowTag]) setImage:[UIImage imageNamed:@"nocheckcontact"]];
        if ([self indexOfThisPhone:[contactDict objectForKey:@"phone"]] < [selectedContactArray count])
        {
            [selectedContactArray removeObjectAtIndex:[self indexOfThisPhone:[contactDict objectForKey:@"phone"]]];
        }
    }
    else
    {
        [((UIImageView *)[phoneListTableView viewWithTag:IconImageViewSectionTag*(indexPath.section+11)+(indexPath.row+11)*IconImageViewRowTag]) setImage:[UIImage imageNamed:@"checkcontact"]];
        [selectedContactArray addObject:contactDict];
    }
    if ([selectedContactArray count] > 0)
    {
        [doneButton setTitle:[NSString stringWithFormat:@"确定(%d)",[selectedContactArray count]] forState:UIControlStateNormal];
    }
    else
    {
        [doneButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    [self selectedMemberChanged];
}

-(NSString *)nameOfThePhone:(NSString *)phone
{
    for(int i=0;i<[selectedContactArray count];i++)
    {
        NSDictionary *contactDict = [selectedContactArray objectAtIndex:i];
        if ([[contactDict objectForKey:@"phone"] isEqualToString:phone])
        {
            return [contactDict objectForKey:@"name"];
        }
    }
    return nil;
}

-(BOOL)haveSelectThisPhone:(NSString *)phone
{
    for(int i=0;i<[selectedContactArray count];i++)
    {
        if ([[[selectedContactArray objectAtIndex:i] objectForKey:@"phone"] isEqualToString:phone])
        {
            return YES;
        }
    }
    return NO;
}

-(NSInteger)indexOfThisPhone:(NSString *)phone
{
    for(int i=0;i<[selectedContactArray count];i++)
    {
        if ([[[selectedContactArray objectAtIndex:i] objectForKey:@"phone"] isEqualToString:phone])
        {
            return i;
        }
    }
    return [selectedContactArray count] + 100;
}

-(void)selectedMemberChanged
{
    for (UIView *view in bottomScrollView.subviews)
    {
        [view removeFromSuperview];
    }
    CGFloat space = 7.5;
    CGFloat size = 30;
    for (int i = 0; i<[selectedContactArray count]; i++)
    {
        NSDictionary *contactDict = [selectedContactArray objectAtIndex:i];
        NSString *name = [contactDict objectForKey:@"name"];
        
        if ([name length] >= 2)
        {
            unichar c1 = [name characterAtIndex:0];
            unichar c2 = [name characterAtIndex:1];
            if (!((c1 >=0x4E00 && c1 <=0x9FFF) &&
                  (c2 >=0x4E00 && c2 <=0x9FFF)))
            {
                //英文
                name = [name substringToIndex:2];
            }
            else
            {
                //汉字
                name = [name substringFromIndex:[name length]-2];
            }
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(space+(size+space)*(i), space, size, size);
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        int colorIndex = arc4random() % [colorArray count];
        button.layer.cornerRadius = size/2;
        button.clipsToBounds = YES;
        [button setBackgroundImage:[UIImage imageWithColor:[colorArray objectAtIndex:colorIndex]] forState:UIControlStateNormal];
        [button setTitle:name forState:UIControlStateNormal];
        [bottomScrollView addSubview:button];
    }
    bottomScrollView.contentSize = CGSizeMake(space+(space+size)*([selectedContactArray count]), bottomScrollView.frame.size.height);
    if (bottomScrollView.contentSize.width > bottomScrollView.frame.size.width)
    {
        bottomScrollView.contentOffset = CGPointMake(bottomScrollView.contentSize.width-bottomScrollView.frame.size.width, 0);
    }
}

#pragma mark - 获取本地通讯录
-(void)getLocalContacts
{
    //获取通讯录权限
    ABAddressBookRef tmpAddressBook = NULL;
    // ABAddressBookCreateWithOptions is iOS 6 and up.
    if (&ABAddressBookCreateWithOptions)
    {
        CFErrorRef error = nil;
        tmpAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (error)
        {
            NSLog(@"%@", error);
        }
    }
    if (tmpAddressBook == NULL)
    {
        tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"允许访问通讯录" message:@"请到 手机设置->隐私->通讯录中，允许[和企录]访问权限" delegate:nil cancelButtonTitle:@"好的，明白了" otherButtonTitles: nil];
        [al show];
        return ;
    }
    if (tmpAddressBook)
    {
        // ABAddressBookRequestAccessWithCompletion is iOS 6 and up. 适配IOS6以上版本
        if (&ABAddressBookRequestAccessWithCompletion)
        {
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook,
                                                     ^(bool granted, CFErrorRef error)
                                                     {
                                                         if (granted)
                                                         {
                                                             
                                                             // constructInThread: will CFRelease ab.
                                                             [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                                                                      toTarget:self
                                                                                    withObject:CFBridgingRelease(tmpAddressBook)];
                                                         }
                                                         else
                                                         {
                                                             //                                                             CFRelease(ab);
                                                             // Ignore the error
                                                         }
                                                     });
        }
        else
        {
            // constructInThread: will CFRelease ab.
            [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                     toTarget:self
                                   withObject:CFBridgingRelease(tmpAddressBook)];
        }
    }
}
-(void)constructInThread:(ABAddressBookRef) ab
{
    [phoneListArray removeAllObjects];
    [groupContactArray removeAllObjects];
    [indexArray removeAllObjects];
    
    NSMutableDictionary *tmpContactsDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(ab);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        NSString *firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastname = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        
        //读取电话多值
        NSString* phoneString1 = @"";
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取該Label下的电话值
            NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
            phoneString1 = [phoneString1 stringByAppendingFormat:@",%@",personPhone];
            personPhone = nil;
        }
        CFRelease(phone);
        
        NSString *phoneString = [phoneString1 length]>0?[phoneString1 substringFromIndex:1]:@"";
        phoneString = [self getPhonesString:phoneString];
        if ([phoneString rangeOfString:@","].length > 0)
        {
            NSArray *phones = [phoneString componentsSeparatedByString:@","];
            for (NSString *phone in phones)
            {
                
                if ([self isPhoneNumber:phone] &&
                    ![tmpContactsDict objectForKey:phone] &&
                    ![phone isEqualToString:self.account])
                {
                    NSDictionary* dic = @{@"name":[NSString stringWithFormat:@"%@%@",lastname?lastname:@"", firstName?firstName:@"" ],
                                          @"phone": phone?phone:[NSNull null]};
                    [tmpContactsDict setObject:dic forKey:phone];
                }
            }
        }
        else
        {
            if ([self isPhoneNumber:phoneString] &&
                ![tmpContactsDict objectForKey:phoneString] &&
                ![phoneString isEqualToString:self.account])
            {
                NSDictionary* dic = @{@"name":[NSString stringWithFormat:@"%@%@",lastname?lastname:@"", firstName?firstName:@"" ],
                                      @"phone": phoneString?phoneString:[NSNull null]};
                [tmpContactsDict setObject:dic forKey:phoneString];
            }
            
        }
    }
    [phoneListArray addObjectsFromArray:[tmpContactsDict allValues]];
    NSArray *tmpArray = [LocalPhoneTools getSpellSortArrayFromChineseArray:phoneListArray andKey:@"name"];
    [groupContactArray addObjectsFromArray:tmpArray];
    for (int i=0; i<[groupContactArray count]; i++)
    {
        NSDictionary *contactDict = [groupContactArray objectAtIndex:i];
        [indexArray addObject:[contactDict objectForKey:@"key"]];
    }
    
    
    if([groupContactArray count] > 0)
    {
        tipLabel.hidden = YES;
        bottomView.hidden = NO;
        [phoneListTableView reloadData];
    }
    else
    {
        tipLabel.hidden = NO;
        bottomView.hidden = YES;
        tipLabel.text = @"本地通讯录为空，无法添加成员。";
    }
    CFRelease(results);
}

-(NSString *)getPhonesString:(NSString *)phonesString
{
    NSMutableString *num = [[NSMutableString alloc] initWithString:phonesString];
    [num replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
    [num replaceOccurrencesOfString:@"-" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
//    [num replaceOccurrencesOfString:@"+86" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
    NSRange range = [num rangeOfString:@"+86"];
    while (range.length > 0)
    {
        [num deleteCharactersInRange:range];
        range = [num rangeOfString:@"+86"];
    }
    if ([num rangeOfString:@"("].length > 0)
    {
        [num deleteCharactersInRange:[num rangeOfString:@"("]];
    }
    if ([num rangeOfString:@")"].length > 0)
    {
        [num deleteCharactersInRange:[num rangeOfString:@")"]];
    }
    return num;
}

-(BOOL)isPhoneNumber:(NSString *)numStr
{
    NSString *mobileNum = @"^1(3[0-9]|5[0-35-9]|8[0-35-9]|10|7[70])\\d{8}$";
    NSPredicate *mobilePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",mobileNum];
    return [mobilePredicate evaluateWithObject:numStr];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
