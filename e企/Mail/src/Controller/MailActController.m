//
//  MailActController.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/8.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailActController.h"
#import "MailActHandler.h"
#import "MailActCell.h"
#import "MainNavigationCT.h"
#import "MainViewController.h"
#define AUTO_REFRESH @"eAutoRefresh"

@interface MailActController ()
{
    __weak IBOutlet UITableView *tableViewAutoRefresh;
    __weak IBOutlet UIView *viewFoot;
    
    NSArray *arrayData;
    
    UISwitch *switchIs;
    
    UILabel *labelTime;
    
    UIDatePicker *datePicker; // 显示时间
    UIView *viewDetermineCanceled; // 显示确定取消背景图
    UIView *viewBG; // 遮罩层
    NSDate *dateSelected;
    UIImageView*imagev;
    UILabel*label;
}

@property (weak, nonatomic) IBOutlet UIButton *addActBtn;


@property (nonatomic) NSMutableArray *accounts;

@end

@implementation MailActController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    //将邮箱设置标题隐藏
    //self.title =@"邮箱设置";
    
//    arrayData = @[@"自动刷新",@"刷新频率"];
    tableViewAutoRefresh.scrollEnabled = NO;
    
    self.view.backgroundColor = UIColorFromRGB(0xebebeb);
    
    UIView *viewHaderLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
    viewHaderLine.backgroundColor = UIColorFromRGB(0xdcdcdc);
    [viewFoot addSubview:viewHaderLine];
    
    UIView *viewFootLine = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 0.5)];
    viewFootLine.backgroundColor = UIColorFromRGB(0xdcdcdc);
    [viewFoot addSubview:viewFootLine];
    

    //添加返回按钮
//    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_icon_back.@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    leftBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 90, 20);
    label.text = @"邮箱设置";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:label];
    //将添加邮箱返回按钮设置为白色
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}




-(void)backView{
    //更多选项中邮箱设置返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _accounts = [NSMutableArray arrayWithArray:[_handler findMailAccounts]];
    if ([_accounts count] > 0)
    {
        viewFoot.hidden = YES;
        
        self.editing = NO;
        [self.navigationItem setRightBarButtonItem:[self editButtonItem]];
    }
    [self.tableView reloadData];
    imagev.hidden = NO;
    label.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)didAddActBtnClick:(id)sender
{
    [_handler addMailAccount];
    imagev.hidden = YES;
    label.hidden = YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (tableView == tableViewAutoRefresh)
//    {
//        BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:AUTO_REFRESH];
//        if (boolIsOn)
//        {
//            return 2;
//        }
//        else
//        {
//            return 1;
//        }
//    }
//    else
    return [_accounts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (tableView == tableViewAutoRefresh)
//    {
//        NSString *stringCellData = arrayData[indexPath.row];
//        NSString *stringCell = [NSString stringWithFormat:@"%d", indexPath.row];
//        UITableViewCell *cell =[tableViewAutoRefresh dequeueReusableCellWithIdentifier:stringCell];
//        if (cell == nil)
//        {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            
//            if ([stringCellData isEqualToString:@"自动刷新"])
//            {
//                switchIs = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, 44*0.5-15, 0, 0)];
//                BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:AUTO_REFRESH];
//                [switchIs setOn:boolIsOn];
//                [switchIs addTarget:self action:@selector(switchIsAction:) forControlEvents:UIControlEventValueChanged];
//                [cell.contentView addSubview:switchIs];
//            }
//            if ([stringCellData isEqualToString:@"刷新频率"])
//            {
//                labelTime = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-70, 44*0.5-22, 100, 44)];
//                [cell.contentView addSubview:labelTime];
//            }
//        }
//        
//        if ([stringCellData isEqualToString:@"刷新频率"])
//        {
//            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
//            [outputFormatter setDateFormat:@"mm分钟"];
//            labelTime.text = [outputFormatter stringFromDate:dateSelected];
//        }
//        
//        cell.textLabel.text = stringCellData;
//        return cell;
//    }
    MailActCell *cell = (MailActCell *)[tableView dequeueReusableCellWithIdentifier:@"MailActCell" forIndexPath:indexPath];
    [cell configureWithEmailAccount:_accounts[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (tableView == tableViewAutoRefresh)
//    {
//        if (indexPath.row == 1)
//        {
//            [self eShowMaskLayerMethod];
//            [self eShowTimeMethod];
//        }
//    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
    EmailAccount *account = _accounts[indexPath.row];
    [_handler showMailBoard:account];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EmailAccount *account = _accounts[indexPath.row];
        [_accounts removeObject:account];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [_handler deleteAccount:account];
        //该段会导致闪退
//        MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
//        MainViewController *maivc = (MainViewController *)mainct.mainVC;
//        [maivc.tabbarButt3 setRemindNum:0];
        
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"未读个数"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        AppDelegate *app=(AppDelegate*)[UIApplication sharedApplication].delegate;
        app.mainVC.tabbarButt3.remindNum=0;
        viewFoot.hidden = NO;
        [self.navigationItem setRightBarButtonItem:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    static float height=1.0;
    if (section==0) {
        height=10;
    }else{
        height=15;
    }
    return height;
}

//- (void)switchIsAction:(id)sender
//{
//    UISwitch *switchIsOn = (UISwitch *)sender;
//    BOOL boolIsOn = [switchIsOn isOn];
//    if (boolIsOn)
//    {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:AUTO_REFRESH];
//        [tableViewAutoRefresh reloadData];
//    }
//    else
//    {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:AUTO_REFRESH];
//        [tableViewAutoRefresh reloadData];
//    }
//}
//
//// 显示时间方法
//- (void)eShowTimeMethod
//{
//    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-150, self.view.frame.size.width, 216)];
//    datePicker.alpha = 1.0;
//    datePicker.minuteInterval = 15;
//    datePicker.backgroundColor = [UIColor whiteColor];
//    datePicker.minimumDate = [[NSDate date] dateByAddingTimeInterval:15*60];
//    datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
//    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.view.window addSubview:datePicker];
//    
//    [self qsDetermineCanceledMethod];
//}
//
//- (void)datePickerValueChanged:(id)sender
//{
//    UIDatePicker *datePickerTime = (UIDatePicker *)sender;
//    dateSelected = datePickerTime.date;
//}
//
//#pragma mark - 确认或取消
//- (void)qsDetermineCanceledMethod
//{
//    viewDetermineCanceled = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-194, self.view.frame.size.width, 44)];
//    viewDetermineCanceled.backgroundColor = [UIColor whiteColor];
//    [self.view.window addSubview:viewDetermineCanceled];
//    
//    // 取消按钮
//    UIButton *buttonCanceled = [[UIButton alloc] initWithFrame:CGRectMake(10, 12, 50, 20)];
//    [buttonCanceled setTitle:@"取消" forState:UIControlStateNormal];
//    [buttonCanceled setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [buttonCanceled setTitle:@"取消" forState:UIControlStateHighlighted];
//    [buttonCanceled setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [buttonCanceled addTarget:self action:@selector(buttonCanceledAction:) forControlEvents:UIControlEventTouchUpInside];
//    [viewDetermineCanceled addSubview:buttonCanceled];
//    
//    // 确认按钮
//    UIButton *buttonDetermine = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-50-10, 12, 50, 20)];
//    [buttonDetermine setTitle:@"确认" forState:UIControlStateNormal];
//    [buttonDetermine setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [buttonDetermine setTitle:@"确认" forState:UIControlStateHighlighted];
//    [buttonDetermine setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//    [buttonDetermine addTarget:self action:@selector(buttonDetermineAction:) forControlEvents:UIControlEventTouchUpInside];
//    [viewDetermineCanceled addSubview:buttonDetermine];
//}
//
//#pragma mark - 取消按钮动作
//- (void)buttonCanceledAction:(UIButton *)button
//{
//    viewBG.hidden = YES;
//    viewDetermineCanceled.hidden = YES;
//    datePicker.hidden = YES;
//}
//
//#pragma mark - 确认按钮动作
//- (void)buttonDetermineAction:(UIButton *)sender
//{
//    viewBG.hidden = YES;
//    viewDetermineCanceled.hidden = YES;
//    datePicker.hidden = YES;
//    
//    [tableViewAutoRefresh reloadData];
//}
//
//#pragma mark - 遮罩层方法
//- (void)eShowMaskLayerMethod
//{
//    viewBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height+64)];
//    viewBG.backgroundColor = [UIColor blackColor];
//    viewBG.alpha = 0.5f;
//    [self.view.window addSubview:viewBG];
//}

@end


