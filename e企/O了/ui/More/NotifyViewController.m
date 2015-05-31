//
//  NotifyViewController.m
//  e企
//
//  Created by 许学 on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NotifyViewController.h"
//#import "TimePickerViewController.h"
#import "TimePickerView.h"
#define HEADHIGHT   10
#define FOOTHIGHT   0.5
#define CELLHIGHT   44

@interface NotifyViewController ()
{
    NSArray *arrayData;
    NSArray *buttonData;
    
    UISwitch *switchIs;
    UISwitch *switchIs_1;
    UISwitch *switchIs_2;
    UISwitch *switchIs_3;
    UISwitch *switchIs_4;
    UISwitch *switchIs_5;
    
    UILabel *timelabel;
    UILabel *timelabel_1;
    
    UIImageView*imagev;
    UILabel*label;
}

@end

@implementation NotifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //将通知提醒的标题隐藏
   // self.title=@"通知提醒";
//    arrayData = [[NSArray alloc]initWithObjects:@"接收新消息通知",@"声音",@"震动",@"免打扰",@"开始",@"结束", nil];
//    buttonData=[[NSArray alloc]initWithObjects:REMIND_MSG,REMIND_SOUND,REMIND_SHAKE,NO_DISTURB_CLOSED,NO_DISTURB_STARTTIME,NO_DISTURB_ENDTIME, nil];
    
    arrayData = @[@[@"接收新消息",/*@"通知显示消息详情",*/@"声音",@"振动"],@[/*@"新邮件提醒",@"声音",@"振动",*/@"勿扰模式",@"开始",@"结束"]];
    
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height-50) style:UITableViewStyleGrouped];
    _table.backgroundColor = UIColorFromRGB(0xebebeb);
    
//    BOOL isOn = [[NSUserDefaults standardUserDefaults]boolForKey:REMIND_MSG];
//    if(isOn)
//    {
//        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELLHIGHT*2 + HEADHIGHT*2 + FOOTHIGHT*2) style:UITableViewStyleGrouped];
//    }
//    else
//    {
//        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELLHIGHT + HEADHIGHT + FOOTHIGHT) style:UITableViewStyleGrouped];
//    }
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.scrollEnabled = NO;
    [self.view addSubview:_table];
    
    
//    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_icon_back.@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    leftBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBtn;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 90, 20);
    label.text = @"通知提醒";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:label];
}

-(void)backView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_table reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    int membercout;
//    BOOL remind_msg=[[NSUserDefaults standardUserDefaults] boolForKey:REMIND_MSG];
//    if(remind_msg){
//        //DDLogInfo(@"接受消息提醒开启");
//        membercout=2;
//        
//    }else{
//        //DDLogInfo(@"接受消息提醒关闭");
//        membercout=1;
//         [[UIApplication sharedApplication] unregisterForRemoteNotifications];
//    }
//    return membercout;
//
//    return 2;
    
    return arrayData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(section==0){
//        return 1;
//    }else{
//        int membercout;
//        BOOL isno_disturb_closed=[[NSUserDefaults standardUserDefaults] boolForKey:NO_DISTURB_CLOSED];
//        if(isno_disturb_closed){
////            DDLogInfo(@"免打扰开启状态");
//            membercout=5;
//            
//        }else{
////            DDLogInfo(@"免打扰关闭状态");
//            membercout=3;
//        }
//        return membercout;
//    }
    
    BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:REMIND_MSG];
    if (section == 0)
    {
        if (boolIsOn)
        {
            return 2+1;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        BOOL boolIsOn_1 = [[NSUserDefaults standardUserDefaults] boolForKey:NO_DISTURB_CLOSED];;
        if (boolIsOn_1)
        {
            if (boolIsOn)
            {
                return 5-2;
            }
            else
            {
                return 0;
            }
        }
        else
        {
            if (boolIsOn)
            {
                return 3-2;
            }
            else
            {
                return 0;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FOOTHIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADHIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        return 100;
    }
    return CELLHIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSString *identify = @"identify";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    NSString *stringCellData = arrayData[indexPath.section][indexPath.row];
    NSString * cellIdenttifier=[NSString stringWithFormat:@"cell_%d_%d",indexPath.row,indexPath.section];
    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIdenttifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenttifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([stringCellData isEqualToString:@"接收新消息"])
        {
            switchIs = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 - 15, 0, 0)];
            BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:REMIND_MSG];
            [switchIs setOn:boolIsOn animated:YES];
            switchIs.onTintColor = UIColorFromRGB(0x408af4);
            [switchIs addTarget:self action:@selector(switchIsAction:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchIs];
        }
        if ([stringCellData isEqualToString:@"通知显示消息详情"])
        {
            switchIs_1 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 - 15, 0, 0)];
            BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:SHOWMSGDETAILINFO];
            [switchIs_1 setOn:boolIsOn animated:YES];
            switchIs_1.onTintColor = UIColorFromRGB(0x408af4);
            [switchIs_1 addTarget:self action:@selector(switchIs_1Action:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchIs_1];
        }
        if ([stringCellData isEqualToString:@"新邮件提醒"])
        {
            switchIs_2 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 - 15, 0, 0)];
            BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:REMIND_EMAIL];
            [switchIs_2 setOn:boolIsOn animated:YES];
            switchIs_2.onTintColor = UIColorFromRGB(0x408af4);
            [switchIs_2 addTarget:self action:@selector(switchIs_2Action:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchIs_2];
        }
        if ([stringCellData isEqualToString:@"声音"])
        {
            switchIs_3 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 - 15, 0, 0)];
            BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:REMIND_SOUND];
            [switchIs_3 setOn:boolIsOn animated:YES];
            switchIs_3.onTintColor = UIColorFromRGB(0x408af4);
            [switchIs_3 addTarget:self action:@selector(switchIs_3Action:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchIs_3];
        }
        if ([stringCellData isEqualToString:@"振动"])
        {
            switchIs_4 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 - 15, 0, 0)];
            BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:REMIND_SHAKE];
            [switchIs_4 setOn:boolIsOn animated:YES];
            switchIs_4.onTintColor = UIColorFromRGB(0x408af4);
            [switchIs_4 addTarget:self action:@selector(switchIs_4Action:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchIs_4];
        }
        if ([stringCellData isEqualToString:@"勿扰模式"])
        {
            cell.textLabel.hidden = YES;
            
            UILabel *labelDoNotDisturb = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 20)];
            labelDoNotDisturb.text = @"勿扰模式";
            labelDoNotDisturb.font = size14;
            [cell.contentView addSubview:labelDoNotDisturb];
            
            switchIs_5 = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 - 15, 0, 0)];
            BOOL boolIsOn = [[NSUserDefaults standardUserDefaults] boolForKey:NO_DISTURB_CLOSED];
            [switchIs_5 setOn:boolIsOn animated:YES];
            switchIs_5.onTintColor = UIColorFromRGB(0x408af4);
            [switchIs_5 addTarget:self action:@selector(switchIs_5Action:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchIs_5];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, CELLHIGHT * 1.5 - 25, 320-15, 50)];
//            label.backgroundColor = [UIColor lightGrayColor];
            label.text = @"“勿扰模式”启用后，手机在该时段收到的通知将不会有任何声音和振动";
            label.font = [UIFont systemFontOfSize:14.f];
            label.textColor = [UIColor grayColor];
            label.numberOfLines = 2;
            [cell.contentView addSubview:label];
        }
        if ([stringCellData isEqualToString:@"开始"])
        {
            timelabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-55, CELLHIGHT * 0.5 - 22, 100, CELLHIGHT)];
            [cell.contentView addSubview:timelabel];
        }
        if ([stringCellData isEqualToString:@"结束"])
        {
            timelabel_1=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-55, CELLHIGHT * 0.5 - 22, 100, CELLHIGHT)];
            [cell.contentView addSubview:timelabel_1];
        }
    }
    
    if ([stringCellData isEqualToString:@"开始"])
    {
        int time=[[NSUserDefaults standardUserDefaults] integerForKey:NO_DISTURB_STARTTIME];
        if(time<0||time>1440){
            if(indexPath.row==3){
                time=22*60;
            }else{
                time=7*60;
            }
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:time] forKey:NO_DISTURB_STARTTIME];
        }

        if (time/60 <= 9 && time%60 > 9)
        {
            timelabel.text=[NSString stringWithFormat:@"0%d:%d",time/60,time%60];
        }
        else if (time/60 > 9 && time%60 <= 9)
        {
            timelabel.text=[NSString stringWithFormat:@"%d:0%d",time/60,time%60];
        }
        else if (time/60 <= 9 && time%60 <= 9)
        {
            timelabel.text=[NSString stringWithFormat:@"0%d:0%d",time/60,time%60];
        }
        else
        {
            timelabel.text=[NSString stringWithFormat:@"%d:%d",time/60,time%60];
        }
        timelabel.textColor = UIColorFromRGB(0x408af4);
    }
    if ([stringCellData isEqualToString:@"结束"])
    {
        int time=[[NSUserDefaults standardUserDefaults] integerForKey:NO_DISTURB_ENDTIME];
        if(time<0||time>1440){
            if(indexPath.row==3){
                time=22*60;
            }else{
                time=7*60;
            }
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:time] forKey:NO_DISTURB_ENDTIME];
        }
        
        if (time/60 <= 9 && time%60 > 9)
        {
            timelabel_1.text=[NSString stringWithFormat:@"0%d:%d",time/60,time%60];
        }
        else if (time/60 > 9 && time%60 <= 9)
        {
            timelabel_1.text=[NSString stringWithFormat:@"%d:0%d",time/60,time%60];
        }
        else if (time/60 <= 9 && time%60 <= 9)
        {
            timelabel_1.text=[NSString stringWithFormat:@"0%d:0%d",time/60,time%60];
        }
        else
        {
            timelabel_1.text=[NSString stringWithFormat:@"%d:%d",time/60,time%60];
        }
        timelabel_1.textColor = UIColorFromRGB(0x408af4);
    }

    cell.textLabel.text = stringCellData;
    cell.textLabel.font = size14;
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    
    
//    NSString * cellIdenttifier=[NSString stringWithFormat:@"cell_%d_%d",indexPath.row,indexPath.section];
//    UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellIdenttifier];
//    if(cell == nil)
//    {
//        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenttifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        if(indexPath.section==0){
//            UISwitch *switch_Rev=[[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 -15, 0, 0)];
//            [switch_Rev addTarget:self action:@selector(switchRevAction:) forControlEvents:UIControlEventValueChanged];
//            BOOL isOn=[[NSUserDefaults standardUserDefaults] boolForKey:[buttonData objectAtIndex:indexPath.row]];
//            [switch_Rev setOn:isOn animated:YES];
//            switch_Rev.tag=1000+indexPath.row;
//            [cell.contentView addSubview:switch_Rev];
//        }else if(indexPath.section==1){
//            if(indexPath.row<3){
//                UISwitch *switch_Rev=[[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 -15, 0, 0)];
//                [switch_Rev addTarget:self action:@selector(switchRevAction:) forControlEvents:UIControlEventValueChanged];
//                BOOL isOn=[[NSUserDefaults standardUserDefaults] boolForKey:[buttonData objectAtIndex:indexPath.row+indexPath.section]];
//                [switch_Rev setOn:isOn animated:YES];
//                switch_Rev.tag=1000+indexPath.row+indexPath.section;
//                [cell.contentView addSubview:switch_Rev];
//            }
//            if (indexPath.row>2&&indexPath.row<5) {
//                UILabel *timelabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-60, CELLHIGHT * 0.5 -15,100 , CELLHIGHT)];
//                timelabel.tag=2000;
//                [cell.contentView addSubview:timelabel];
//            }
//        }
//    }
//    if (indexPath.section==1&&indexPath.row>2&&indexPath.row<5) {
//        UILabel *timelabel=(UILabel *)[cell viewWithTag:2000];
//        int time=[[NSUserDefaults standardUserDefaults] integerForKey:[buttonData objectAtIndex:indexPath.row+indexPath.section]];
//        if(time<0||time>1440){
//            if(indexPath.row==3){
//                time=22*60;
//            }else{
//                time=7*60;
//            }
//            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:time] forKey:[buttonData objectAtIndex:indexPath.row+indexPath.section]];
//        }
//          timelabel.text=[NSString stringWithFormat:@"%d:%d",time/60,time%60];
//    }
//    
////    else
////    {
////        BOOL isOn=[[NSUserDefaults standardUserDefaults] boolForKey:SHOWMSGDETAILINFO];
////        if(_switch_Noty == nil)
////        {
////            _switch_Noty = [[UISwitch alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 60, CELLHIGHT * 0.5 -15, 0, 0)];
////            [_switch_Noty addTarget:self action:@selector(switchNotyAction) forControlEvents:UIControlEventValueChanged];
////        }
////        [_switch_Noty setOn:isOn animated:YES];
////        [[NSUserDefaults standardUserDefaults]setBool:isOn forKey:SHOWMSGDETAILINFO];
////        [cell.contentView addSubview:_switch_Noty];
////    }
//    
//    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
//    cell.textLabel.text = [arrayData objectAtIndex:indexPath.row + indexPath.section];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1&&indexPath.row>/*3*/0&&indexPath.row</*6*/5-2){
        TimePickerView *pVc=[[TimePickerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) sourcetype:indexPath.row-/*4*/1];
        pVc.delegate=self;
        [[[UIApplication sharedApplication].delegate window]addSubview:pVc];
//        [self.view addSubview:pVc];
    }
    
//    if(indexPath.section==1&&indexPath.row>2&&indexPath.row<5){
//        TimePickerView *pVc=[[TimePickerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) sourcetype:indexPath.row-3];
//        pVc.delegate=self;
//        [[[UIApplication sharedApplication].delegate window]addSubview:pVc];
//    }
}

- (void)switchIsAction:(id)sender
{
    UISwitch *switchIsOn = (UISwitch *)sender;
    BOOL boolIsOn = [switchIsOn isOn];
    if (boolIsOn)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMIND_MSG];
        [_table reloadData];
//        [_table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//        [_table insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REMIND_MSG];
        [_table reloadData];
//        [_table insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)switchIs_1Action:(id)sender
{
    UISwitch *switchIsOn = (UISwitch *)sender;
    BOOL boolIsOn = [switchIsOn isOn];
    if (boolIsOn)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOWMSGDETAILINFO];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOWMSGDETAILINFO];
    }
}

- (void)switchIs_2Action:(id)sender
{
    UISwitch *switchIsOn = (UISwitch *)sender;
    BOOL boolIsOn = [switchIsOn isOn];
    if (boolIsOn)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMIND_EMAIL];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REMIND_EMAIL];
    }
}

- (void)switchIs_3Action:(id)sender
{
    UISwitch *switchIsOn = (UISwitch *)sender;
    BOOL boolIsOn = [switchIsOn isOn];
    if (boolIsOn)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMIND_SOUND];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REMIND_SOUND];
    }
}

- (void)switchIs_4Action:(id)sender
{
    UISwitch *switchIsOn = (UISwitch *)sender;
    BOOL boolIsOn = [switchIsOn isOn];
    if (boolIsOn)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:REMIND_SHAKE];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:REMIND_SHAKE];
    }
}

- (void)switchIs_5Action:(id)sender
{
    UISwitch *switchIsOn = (UISwitch *)sender;
    BOOL boolIsOn = [switchIsOn isOn];
    if (boolIsOn)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NO_DISTURB_CLOSED];
        [_table reloadData];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NO_DISTURB_CLOSED];
        [_table reloadData];
    }
}

//- (void)switchRevAction:(id)sender
//{
//    UISwitch *switch_Rev=(UISwitch *)sender;
//    NSString *buttonname=[buttonData objectAtIndex:switch_Rev.tag-1000];
//    BOOL isButtonOn = [switch_Rev isOn];
//    if (isButtonOn) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:buttonname];
//    }else {
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:buttonname];
//    }
////    DDLogInfo(@"现在配置%d-%d-%d-%d",[[NSUserDefaults standardUserDefaults] boolForKey:[buttonData objectAtIndex:0]],[[NSUserDefaults standardUserDefaults] boolForKey:[buttonData objectAtIndex:1]],[[NSUserDefaults standardUserDefaults] boolForKey:[buttonData objectAtIndex:2]],[[NSUserDefaults standardUserDefaults] boolForKey:[buttonData objectAtIndex:3]]);
//    if(switch_Rev.tag>1002||switch_Rev.tag<1001){
//        [_table reloadData];
//    }
//}
//
//- (void)switchNotyAction
//{
//    BOOL isButtonOn = [_switch_Noty isOn];
//    if (isButtonOn) {
//        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:SHOWMSGDETAILINFO];
//    }else {
//        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:SHOWMSGDETAILINFO];
//    }
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)reload{
    [_table reloadData];
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
