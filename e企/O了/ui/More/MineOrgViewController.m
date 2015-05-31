//
//  MineOrgViewController.m
//  e企
//
//  Created by royaMAC on 14/11/20.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MineOrgViewController.h"

#define WIDTH 320

@interface MineOrgViewController ()
{
    UIButton *leftButton;
}

@end

@implementation MineOrgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];

    leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.titleLabel.font=[UIFont systemFontOfSize:14];
    leftButton.frame=CGRectMake(10, (44-29)/2, 53, 29);
    [leftButton setTitle:@" 返回" forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    [leftButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor=[UIColor whiteColor];
    self.title=@"部门及职位";
    
    _table=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, self.view.frame.size.height) style:UITableViewStylePlain];
    [self.view addSubview:self.table];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (leftButton) {
        [self.navigationController.navigationBar addSubview:leftButton];
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (leftButton) {
        [leftButton removeFromSuperview];
    }
}
#pragma mark----返回上一级页面
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
