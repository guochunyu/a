//
//  DepartmentLevelViewController.m
//  e企
//
//  Created by 独孤剑道(张洋) on 15/2/3.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "DepartmentLevelViewController.h"

@interface DepartmentLevelViewController ()
{
    __weak IBOutlet UITableView *tableViewDepartmentLevel;
}

@end

@implementation DepartmentLevelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"部门及职位";
    
//    [self setExtraCellLineHidden:tableViewDepartmentLevel];
    tableViewDepartmentLevel.scrollEnabled = NO;
    tableViewDepartmentLevel.backgroundColor = UIColorFromRGB(0xebebeb);
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ConstantObject sharedConstant].userInfo.department.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tableViewDepartmentLevel)
    {
        static NSString *stringCell = @"stringCell";
        UITableViewCell *cell = [tableViewDepartmentLevel dequeueReusableCellWithIdentifier:stringCell];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:stringCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSInteger row = indexPath.row;
        
        NSArray *arrayDepartment = [ConstantObject sharedConstant].userInfo.department;
        cell.textLabel.text = [arrayDepartment objectAtIndex:row];
        cell.textLabel.font = size14;
        
        NSArray *arrayDuty = [ConstantObject sharedConstant].userInfo.duty;
        cell.detailTextLabel.text = [arrayDuty objectAtIndex:row];
        cell.detailTextLabel.font = size14;
        
        return cell;
    }
    
    return nil;
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

#pragma mark - 设置隐藏多余的分割线
//- (void)setExtraCellLineHidden:(UITableView *)tableView
//{
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = [UIColor clearColor];
//    [tableView setTableFooterView:view];
//    
//    UIView *view_1 =[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.5)];
//    view_1.backgroundColor = [UIColor lightGrayColor];
//    [view addSubview:view_1];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
