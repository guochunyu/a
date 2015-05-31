//
//  CreateEnterPriseViewController.m
//  e企
//
//  Created by zw on 15/4/20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "CreateEnterPriseViewController.h"
#import "CreateEnterPriseMemberCell.h"
#import "LocalPhoneListViewController.h"
#import "TaskTools.h"
#import "UIImage+ColorImage.h"
#import "UIViewExt.h"
#import "AFClient.h"
#import "DesEncrypt.h"
#import "LoginViewController.h"
#import "RegistHelper.h"

#define NameTextFieldTag        234125
#define EditNameButtonTag       432123
#define DeleteContactButtonTag  890887
#define EnterPriseNameTfTag     333444

#define UncorrectNameColor    UIColorFromRGB(0xffa3a3)

#define DoneButtonUnableColor  UIColorFromRGB(0xc2d5fb)

#define PlaceHolderWidth   165
#define ExtraRightWidth   5

#define BgColor  RGB(234, 235, 236, 1)

@interface CreateEnterPriseViewController ()<UITableViewDataSource,UITableViewDelegate,SelectContactDoneDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    UITableView *enterPriseTableView;
    NSMutableArray *memberArray;
    
    UIButton *doneButton;
    
    UITextField *nameTextField;
    CGFloat keyBoardHeight;
    CGRect textFieldFrame;
    
    NSDictionary *creatorDict;
    
    NSMutableArray *unCorrectNameIndexArray;
}
@property (nonatomic, strong) MBProgressHUD *HUD;
@end

@implementation CreateEnterPriseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"创建企业";
    
    NSLog(@"account = %@,password = %@",self.account,self.password);
    [[NSUserDefaults standardUserDefaults] setObject:self.account forKey:MOBILEPHONE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    creatorDict = @{@"name":@"",@"phone":self.account};
    
    memberArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    unCorrectNameIndexArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.view.backgroundColor = bgcor3;
    
    keyBoardHeight = 0;
    
    enterPriseTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ScreenHeight) style:UITableViewStylePlain];
    enterPriseTableView.backgroundColor = BgColor;
    enterPriseTableView.delegate = self;
    enterPriseTableView.dataSource = self;
    enterPriseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:enterPriseTableView];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 0, 40, 35);
    doneButton.layer.cornerRadius = 2;
    doneButton.titleLabel.font = [UIFont systemFontOfSize:15.5f];
    doneButton.clipsToBounds = YES;
    [doneButton setTitleColor:DoneButtonUnableColor forState:UIControlStateNormal];
    doneButton.userInteractionEnabled = NO;
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(createEnterPrise) forControlEvents:UIControlEventTouchUpInside];
//    [self changeMembers:nil];
    [self.view addSubview:doneButton];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, KScreenWidth-20, 44)];
    nameTextField.placeholder = @"请输入企业名称（2-20个字符）";
    nameTextField.textColor = cor1;
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.delegate = self;
    nameTextField.tag = EnterPriseNameTfTag;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:nameTextField];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                name:@"UITextFieldTextDidChangeNotification"
                                              object:nameTextField];
    
    //键盘上去下去的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 创建企业
-(void)createEnterPrise
{
    [doneButton setTitleColor:DoneButtonUnableColor forState:UIControlStateNormal];
    doneButton.userInteractionEnabled = NO;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view.window addSubview:HUD];
    HUD.labelText = @"正在创建企业...";
    [HUD show:YES];

    NSDictionary *userinfo = @{@"psd":[DesEncrypt encryptWithText:self.password],@"phone":self.account,@"corporationName":nameTextField.text,@"name":[creatorDict objectForKey:@"name"]};

    NSDictionary *content = @{@"personList":memberArray,@"userinfo":userinfo};
    [[AFClient sharedClient] postPath:[NSString stringWithFormat:Regist] parameters:@{@"content":[content JSONString]} success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         doneButton.userInteractionEnabled = YES;
         [HUD hide:YES];
         if([[responseObject objectForKey:@"status"] intValue] == 1)
         {
             NSLog(@"创建成功！");
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"创建成功！" isCue:0 delayTime:1 isKeyShow:NO];
             [[NSUserDefaults standardUserDefaults] setObject:self.account forKey:myLastLoginUser];
             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
         }
         else
         {
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[responseObject objectForKey:@"msg"] isCue:1 delayTime:1 isKeyShow:NO];
             NSLog(@"%@",responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"请求失败" isCue:1 delayTime:1 isKeyShow:NO];
         [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
         doneButton.userInteractionEnabled = YES;
         [HUD hide:YES];
         NSLog(@"error %@",error);
     }];
}

-(void)resignKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - TableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1)
    {
        return 1;
    }
    else
        return [memberArray count]+1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return 30;
    else if (section == 1)
        return 40;
    else
        return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 || section == 1)
    {
        
        UIView *headerView = [[UIView alloc] init];
        
        UIView *topLineView = [[UIView alloc] init];
        topLineView.frame = CGRectMake(0, 14.5f, KScreenWidth, 0.7f);
        topLineView.backgroundColor = LineBgColor;
        [headerView addSubview:topLineView];
        
        headerView.backgroundColor = BgColor;
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, KScreenWidth, 30)];
        headerLabel.textColor = cor3;
        UIFont *font = [UIFont fontWithName:@"Helvetica Neue Light" size:12];
        if (font)
        {
            headerLabel.font = font;
        }
        else
        {
            headerLabel.font = [UIFont systemFontOfSize:12];
        }
        
        headerLabel.backgroundColor = bgcor2;
        if (section == 0)
        {
            headerLabel.frame = CGRectMake(0, 0, KScreenWidth, 30);
            headerLabel.text = @"    企业名称";
        }
        else if(section == 1)
        {
            headerLabel.frame = CGRectMake(0, 15, KScreenWidth, 30);
            headerLabel.text = @"    企业成员";
        }
        [headerView addSubview:headerLabel];
        UIView *bottomLineView = [[UIView alloc] init];
        bottomLineView.frame = CGRectMake(0, headerLabel.bottom, KScreenWidth, 0.7f);
        bottomLineView.backgroundColor = LineBgColor;
        [headerView addSubview:bottomLineView];
        return headerView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        return 44.0f;
    }
    return 65.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"enterPriseName"];
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.7f)];
        topLineView.backgroundColor = LineBgColor;
        [cell.contentView addSubview:topLineView];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5f, KScreenWidth, 0.7f)];
        bottomLineView.backgroundColor = LineBgColor;
        [cell.contentView addSubview:bottomLineView];
        
        [cell.contentView addSubview:nameTextField];
        cell.contentView.tag = 0;
        return cell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"enterPriseMembers"];
        
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.7f)];
        topLineView.backgroundColor = linecor1;
        [cell.contentView addSubview:topLineView];
        
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5f, KScreenWidth, 0.7f)];
        bottomLineView.backgroundColor = linecor1;
        [cell.contentView addSubview:bottomLineView];
        cell.contentView.tag = 0;
        
        UILabel *addMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, KScreenWidth, 30)];
        addMemberLabel.text = @"添加企业成员";
        addMemberLabel.textColor = cor1;
        addMemberLabel.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:addMemberLabel];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else
    {
        NSString *memberIder = @"memberider";
        CreateEnterPriseMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:memberIder];
        if (cell == nil)
        {
            cell = [[CreateEnterPriseMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:memberIder];
        }
        cell.contentView.tag = 0;
        NSDictionary *contactDict;
        if (indexPath.row == 0)
        {
            contactDict = creatorDict;
        }
        else
        {
            contactDict = [memberArray objectAtIndex:indexPath.row-1];
        }
        NSString *name =[contactDict objectForKey:@"name"];
        cell.nameTextfield.text = name;
        
        CGSize nameSize = [self sizeWithString:name andWidth:200];
        if ([name length] == 0)
        {
            nameSize = CGSizeMake(PlaceHolderWidth, 25);
        }
        cell.nameTextfield.frame = CGRectMake(33, 10, nameSize.width+ExtraRightWidth, 25);
        cell.nameTextfield.returnKeyType = UIReturnKeyDone;
        cell.nameTextfield.delegate = self;
        cell.nameTextfield.font = [UIFont systemFontOfSize:15];
        cell.nameTextfield.placeholder = @"请输入姓名(1-10个字符)";
        cell.nameTextfield.tag = NameTextFieldTag + indexPath.row;
        
        
        if ([self memberNameCorrect:name showTips:NO])
        {
            cell.nameTextfield.textColor = cor1;
        }
        else
        {
            [unCorrectNameIndexArray addObject:indexPath];
            cell.nameTextfield.textColor = UncorrectNameColor;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nameTextFieldChanged:) name:UITextFieldTextDidChangeNotification object:cell.nameTextfield];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:cell.nameTextfield];
        
        cell.editButton.frame = CGRectMake(CGRectGetMaxX(cell.nameTextfield.frame), CGRectGetMinY(cell.nameTextfield.frame)-12.5, 50, 50);
        cell.editButton.tag = EditNameButtonTag + indexPath.row;
        [cell.editButton addTarget:self action:@selector(editContactName:) forControlEvents:UIControlEventTouchUpInside];
        [cell.editButton setImage:[UIImage imageNamed:@"contact_edit"] forState:UIControlStateNormal];
        
        NSString *phone = [contactDict objectForKey:@"phone"];
        cell.phoneNumLabel.frame = CGRectMake(33, 35, 250, 25);
        cell.phoneNumLabel.text = phone;
        cell.phoneNumLabel.font = [UIFont systemFontOfSize:15];
        cell.phoneNumLabel.textColor = UIColorFromRGB(0x999999);
        
        cell.bottomLineView.frame = CGRectMake(30, 64.5f, KScreenWidth, 0.7f);
        
        if ([phone isEqualToString:USER_ID])
        {
            cell.deleteButton.frame = CGRectMake(KScreenWidth-60, 13, 50, 18);
            [cell.deleteButton setTitle:@"创建人" forState:UIControlStateNormal];
            [cell.deleteButton setTitleColor:RGB(68, 141, 241, 1) forState:UIControlStateNormal];
            cell.deleteButton.layer.cornerRadius = 3;
            cell.deleteButton.layer.borderColor = RGB(68, 141, 241, 1).CGColor;
            cell.deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
            cell.deleteButton.layer.borderWidth = 1.0f;
            [cell.deleteButton setImage:nil forState:UIControlStateNormal];
            cell.deleteButton.enabled = NO;
        }
        else
        {
            cell.deleteButton.frame = CGRectMake(KScreenWidth-60, 5, 50, 50);
            [cell.deleteButton setTitle:@"" forState:UIControlStateNormal];
            cell.deleteButton.layer.cornerRadius = 0;
            cell.deleteButton.layer.borderColor = [UIColor clearColor].CGColor;
            cell.deleteButton.layer.borderWidth = 0.0f;
            [cell.deleteButton setImage:[UIImage imageNamed:@"contact_delete"] forState:UIControlStateNormal];
            cell.deleteButton.enabled = YES;
        }
    
        cell.deleteButton.tag = DeleteContactButtonTag + indexPath.row;
        [cell.deleteButton addTarget:self action:@selector(deleteContact:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.backgroundColor = RGB(247, 248, 249, 1);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        LocalPhoneListViewController *localPhoneListVC = [[LocalPhoneListViewController alloc] init];
        localPhoneListVC.selectDoneDel = self;
        localPhoneListVC.selectedContacts = memberArray;
        localPhoneListVC.account = self.account;
        [self.navigationController pushViewController:localPhoneListVC animated:YES];
    }
    
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 获得字符串size

-(CGSize)sizeWithString:(NSString *)string
               andWidth:(CGFloat)width
{
    UILabel *label = [[UILabel alloc] init];
    label.text = string;
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(0, 0, width, 10000);
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [label sizeToFit];
    CGRect labelFrame = label.frame;
    return labelFrame.size;
}

#pragma mark - 键盘通知

-(void)keyboardShow:(NSNotification *)note
{
    CGRect keyBoardRect=[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyBoardHeight = keyBoardRect.size.height;
    if (ABS(textFieldFrame.origin.y - 64) > KScreenHeight-keyBoardHeight-50)
    {
        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, -ABS(textFieldFrame.origin.y+keyBoardHeight-64));
        }];
    }
}

-(void)keyboardHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.25f animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - textfielddelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag >= NameTextFieldTag && textField.tag < NameTextFieldTag+[memberArray count]+1)
    {
        textFieldFrame = [textField convertRect:textField.frame fromView:self.view];
        if (ABS(textFieldFrame.origin.y - 64+30) > KScreenHeight-keyBoardHeight-50)
        {
            [UIView animateWithDuration:0.25f animations:^{
                self.view.transform = CGAffineTransformMakeTranslation(0, -ABS(textFieldFrame.origin.y+keyBoardHeight-74));
            }];
        }
    }
    else
    {
        textFieldFrame = CGRectZero;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (NSNotFound == textField.superview.tag) {
        textField.superview.tag = 0;
    }
    else if (textField.tag >= NameTextFieldTag && textField.tag <= NameTextFieldTag+[memberArray count]+1)
    {
        if ([textField.text length] > 0)
        {
            CGSize size = [self sizeWithString:textField.text andWidth:200];
            [UIView animateWithDuration:0.1f animations:^{
                CGRect tmpRect = textField.frame;
                textField.frame = CGRectMake(tmpRect.origin.x, tmpRect.origin.y, size.width+ExtraRightWidth,25);
                [enterPriseTableView viewWithTag:EditNameButtonTag+(textField.tag-NameTextFieldTag)].frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMinY(textField.frame)-12.5, 50, 50);
            }];
        }
        else
        {
            [UIView animateWithDuration:0.1f animations:^{
                CGRect tmpRect = textField.frame;
                textField.frame = CGRectMake(tmpRect.origin.x, tmpRect.origin.y, PlaceHolderWidth+ExtraRightWidth ,tmpRect.size.height);
                [enterPriseTableView viewWithTag:EditNameButtonTag+(textField.tag-NameTextFieldTag)].frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMinY(textField.frame)-12.5, 50, 50);
            }];
        }
        
        NSString *name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (textField.tag == NameTextFieldTag)
        {
            creatorDict = @{@"phone":self.account,@"name":name};
        }
        else
        {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:[memberArray objectAtIndex:textField.tag-NameTextFieldTag-1]];
            [tmpDict setObject:name forKey:@"name"];
            [memberArray replaceObjectAtIndex:textField.tag-NameTextFieldTag-1 withObject:tmpDict];
        }
        textField.text = name;
        [self.view endEditing:YES];
        [self changeMembers:textField.text];
    }
    else
    {
        NSString *qiyeName = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        textField.text = qiyeName;
        if([qiyeName length] < 2)
        {
            //[self showHudView: keyboardShow:NO];
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"企业名称不能少于2个字符" isCue:1 delayTime:1 isKeyShow:NO];
            textField.textColor = UncorrectNameColor;
            [self changeMembers:nil];
        }
        else if([qiyeName length] > 20)
        {
            [self changeMembers:nil];
        }
        else
        {
            textField.textColor = cor1;
            [self changeMembers:nil];
        }
    }
    [self findErroNameIndexPaths];
}

-(void)nameTextFieldChanged:(NSNotification *)note
{
    id object = note.object;
    if ([object isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField *)object;
        if (textField.tag != EnterPriseNameTfTag)
        {
            if ([textField.text length] > 0)
            {
                CGSize size = [self sizeWithString:textField.text andWidth:160];
                [UIView animateWithDuration:0.1f animations:^{
                    CGRect tmpRect = textField.frame;
                    textField.frame = CGRectMake(tmpRect.origin.x, tmpRect.origin.y, size.width+ExtraRightWidth,25);
                    [enterPriseTableView viewWithTag:EditNameButtonTag+(textField.tag-NameTextFieldTag)].frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMinY(textField.frame)-12.5, 50, 50);
                }];
            }
            else
            {
                [UIView animateWithDuration:0.1f animations:^{
                    CGRect tmpRect = textField.frame;
                    textField.frame = CGRectMake(tmpRect.origin.x, tmpRect.origin.y, PlaceHolderWidth+ExtraRightWidth ,tmpRect.size.height);
                    [enterPriseTableView viewWithTag:EditNameButtonTag+(textField.tag-NameTextFieldTag)].frame = CGRectMake(CGRectGetMaxX(textField.frame), CGRectGetMinY(textField.frame)-12.5, 50, 50);
                }];
            }
        }
        
        if (textField.tag >= NameTextFieldTag && textField.tag < NameTextFieldTag+[memberArray count]+1)
        {
            NSString *name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([name length] > 10)
            {
                name = [name substringToIndex:10];
            }
            if (textField.tag == NameTextFieldTag)
            {
                creatorDict = @{@"phone":self.account,@"name":name};
            }
            else
            {
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:[memberArray objectAtIndex:textField.tag-NameTextFieldTag-1]];
                
                [tmpDict setObject:name forKey:@"name"];
                [memberArray replaceObjectAtIndex:textField.tag-NameTextFieldTag-1 withObject:tmpDict];
            }
            if([self firstCharCorrect:textField.text showTips:YES])
            {
                textField.textColor = cor1;
            }
            else
            {
                textField.textColor = UncorrectNameColor;
            }
            [self changeMembers:textField.text];
        }
        else
        {
            [self changeMembers:nil];
        }
    }
}

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    int maxLength = 0;
    if (textField.tag >= NameTextFieldTag && textField.tag < NameTextFieldTag+[memberArray count]+1)
    {
        maxLength = 10;
    }
    else if(textField.tag == EnterPriseNameTfTag)
    {
        maxLength = 20;
    }
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            
            {
                if (toBeString.length > maxLength) {
                    if(maxLength == 20)
                    {
                        //[self showHudView: keyboardShow:NO];
                        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"企业名称不能多于20个字符" isCue:1 delayTime:1 isKeyShow:NO];
                    }
                    else if(maxLength == 10)
                    {
                        //[self showHudView: keyboardShow:NO];
                        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"成员姓名应1-10个字符" isCue:1 delayTime:1 isKeyShow:NO];
                    }
                    textField.text = [toBeString substringToIndex:maxLength];
                }
                else if(maxLength == 10 && ![self memberNameCorrect:toBeString showTips:NO])
                {
                    textField.textColor = UncorrectNameColor;
                }
                else
                {
                    textField.textColor = cor1;
                }
            }
            
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > maxLength) {
            if(maxLength == 20)
            {
                //[self showHudView: keyboardShow:NO];
                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"企业名称不能多于20个字符" isCue:1 delayTime:1 isKeyShow:NO];
            }
            else if(maxLength == 10)
            {
                //[self showHudView: keyboardShow:NO];
                [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"成员姓名应1-10个字符" isCue:1 delayTime:1 isKeyShow:NO];
            }
            textField.text = [toBeString substringToIndex:maxLength];
        }
        else if(maxLength == 10 && ![self memberNameCorrect:toBeString showTips:NO])
        {
            textField.textColor = UncorrectNameColor;
        }
        else
        {
            textField.textColor = cor1;
        }
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}


#pragma mark - 验证成员名字知否正确

-(BOOL)memberNameCorrect:(NSString *)name showTips:(BOOL)showTips
{
    if ([self firstCharCorrect:name showTips:showTips] &&
        [name length] >=1 &&
        [name length] <= 10)
    {
        return YES;
    }
    return NO;
}

-(BOOL)firstCharCorrect:(NSString *)name showTips:(BOOL)showTips
{
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([name length] > 0)
    {
        unichar c1 = [name characterAtIndex:0];
        if (((c1 >=0x4E00 && c1 <=0x9FFF) ||
             (c1 >='a' && c1 <= 'z') ||
             (c1 >='A' && c1 <= 'Z')))
        {
            return YES;
        }
        //[self showHudView: keyboardShow:NO];
        if (showTips)
        {
            [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"名字只能由汉字或字母开头" isCue:1 delayTime:1 isKeyShow:NO];
        }
    }
    return NO;
}

-(void)editContactName:(UIButton *)button
{
    UITextField *tmpTextField =  (UITextField *)[enterPriseTableView viewWithTag:NameTextFieldTag+(button.tag - EditNameButtonTag)];
    tmpTextField.enabled = YES;
    [tmpTextField becomeFirstResponder];
}

-(void)deleteContact:(UIButton *)button
{
    button.superview.tag = NSNotFound;
    [memberArray removeObjectAtIndex:button.tag - DeleteContactButtonTag-1];
    [self reloadPriseTabelView];
    [self changeMembers:nil];
}

-(void)getSelectedContacts:(NSArray *)contactsArray
{
    [memberArray removeAllObjects];
    [memberArray addObjectsFromArray:contactsArray];
    [enterPriseTableView reloadData];
    [unCorrectNameIndexArray removeAllObjects];
    for (int i=0; i<[memberArray count]; i++)
    {
        NSDictionary *memberDict = [memberArray objectAtIndex:i];
        NSString *name = [memberDict objectForKey:@"name"];
        if (![self memberNameCorrect:name showTips:NO])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:2];
            [unCorrectNameIndexArray addObject:indexPath];
        }
    }
    if ([unCorrectNameIndexArray count] > 0)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"成员姓名不合规范，姓名由汉字或字母开头，1-10个字符，请修改" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [al show];
    }
    
    [self changeMembers:nil];
}

- (void)showHudView:(NSString *)failMessage keyboardShow:(BOOL)keyboardShow
{
    @autoreleasepool {
        if(!keyboardShow)
        {
            //[self.view endEditing:YES];
        }
        if (!_HUD) {
            _HUD=[MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
            _HUD.delegate = self;
        }
        _HUD.frame = CGRectMake((ScreenWidth-_HUD.frame.size.width)/2, (ScreenHeight-_HUD.frame.size.height)/2, _HUD.frame.size.width, _HUD.frame.size.height);
        _HUD.detailsLabelText=failMessage;
        _HUD.mode=MBProgressHUDModeText;
        _HUD.userInteractionEnabled=NO;
        [_HUD hide:YES afterDelay:1];
    }
}

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [hud removeFromSuperview];
    _HUD.delegate = nil;
    _HUD = nil;
}

#pragma mark - 更新完成

-(void)changeMembers:(NSString *)nameString
{
    if (nameString && ([nameString length] <1 ||
        [nameString length] > 10 ||![self firstCharCorrect:nameString showTips:NO]))
    {
        [doneButton setTitleColor:DoneButtonUnableColor forState:UIControlStateNormal];
        doneButton.userInteractionEnabled = NO;
        return ;
    }
    
    if ([nameTextField.text length] >= 2 &&
        [nameTextField.text length] <= 20)
    {
        if (creatorDict && [creatorDict objectForKey:@"name"] &&
            [[creatorDict objectForKey:@"name"] length] >= 1 &&
            [[creatorDict objectForKey:@"name"] length] <= 10 &&
            [self firstCharCorrect:[creatorDict objectForKey:@"name"] showTips:NO])
        {
            [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            doneButton.userInteractionEnabled = YES;
        }
        else
        {
            [doneButton setTitleColor:DoneButtonUnableColor forState:UIControlStateNormal];
            doneButton.userInteractionEnabled = NO;
        }
    }
    else
    {
        [doneButton setTitleColor:DoneButtonUnableColor forState:UIControlStateNormal];
        doneButton.userInteractionEnabled = NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

-(void)reloadPriseTabelView
{
    [enterPriseTableView reloadData];
    [self findErroNameIndexPaths];
}

-(void)findErroNameIndexPaths
{
    [unCorrectNameIndexArray removeAllObjects];
    for (int i=0; i<[memberArray count]; i++)
    {
        NSDictionary *memberDict = [memberArray objectAtIndex:i];
        NSString *name = [memberDict objectForKey:@"name"];
        if (![self memberNameCorrect:name showTips:NO])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i+1 inSection:2];
            [unCorrectNameIndexArray addObject:indexPath];
        }
    }
    if ([unCorrectNameIndexArray count] > 0)
    {
        if ([NSStringFromClass([[self.navigationController visibleViewController] class]) isEqualToString:@"CreateEnterPriseViewController"])
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"成员姓名不合规范，姓名由汉字或字母开头，1-10个字符，请修改" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [al show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        if ([unCorrectNameIndexArray count] > 0)
        {
            [self.view endEditing:YES];
            [enterPriseTableView scrollToRowAtIndexPath:[unCorrectNameIndexArray firstObject] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:@"UITextFieldTextDidChangeNotification"
                                                 object:nameTextField];
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
