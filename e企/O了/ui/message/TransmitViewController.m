//
//  TransmitViewController.m
//  O了
//
//  Created by 化召鹏 on 14-7-22.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "TransmitViewController.h"

@interface TransmitViewController ()<UITableViewDataSource,UITableViewDelegate>{
    UIButton *_rightButt;
    
    UITableView *_latelyMessageListTable;
    
    NSArray *recentlyArray;//最近回话列表
    
}

@end

@implementation TransmitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar addSubview:_rightButt];
}
- (void)viewWillDisappear:(BOOL)animated{
    if (_rightButt) {
        [_rightButt removeFromSuperview];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor grayColor];
    
    _imageViewArray=[[NSMutableArray alloc] init];
    
    //获取回话头像
    [self getUrlImageHead:recentlyArray];
    //右侧按钮
    
    
    _rightButt=[UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButt setTitle:@"取消" forState:UIControlStateNormal];
    _rightButt.titleLabel.font=[UIFont systemFontOfSize:14];
    [_rightButt setBackgroundImage:[UIImage imageNamed:@"top_right.png"] forState:UIControlStateNormal];
    [_rightButt setBackgroundImage:[UIImage imageNamed:@"top_right_pre.png"] forState:UIControlStateHighlighted];
    _rightButt.frame=CGRectMake(320-50-10, (44-29)/2, 50, 29);
    [_rightButt addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    self.title=@"发送到";
    
    //表格
    _latelyMessageListTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-(IS_IOS_7?64:44)) style:UITableViewStylePlain];
    _latelyMessageListTable.dataSource=self;
    _latelyMessageListTable.delegate=self;
    [self.view addSubview:_latelyMessageListTable];
    
}
-(void)getUrlImageHead:(NSArray *)groupArray{
    
    
    //存放头像
    
    
}
//表格数据源
#pragma mark - UITableViewDataSource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else{
        return recentlyArray.count;
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIdentifre=@"transmitCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifre];
    if (!cell) {
        
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifre];
        cell.backgroundColor=[UIColor colorWithWhite:1.000 alpha:1.000];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }
    if (indexPath.section==0) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text=@"选择群聊";
    }else{
        
    }

    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section!=0) {
        return @"最近聊天";
    }
    return nil;
    
}
//表格数据代理
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    return 20.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {

        return;
    }
    if (indexPath.section!=0) {
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        
       
//        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
