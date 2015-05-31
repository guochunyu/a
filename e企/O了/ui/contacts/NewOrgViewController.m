//
//  NewOrgViewController.m
//  e企
//
//  Created by royaMAC on 14-11-11.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NewOrgViewController.h"
#import "UserDetailViewController.h"
#import "CellContact.h"
#import "CellOrganization.h"
#import "CustomButton.h"
#import "AddGroupScrollButt.h"

#define ROW_HEIGHT 54
#define TEXT_FONT  14
#define TOP_Y 20
#define LABLE_WIDTH 20

@interface NewOrgViewController ()
{
    UIButton *leftButton;
    NSMutableArray  * sectionArray;
}

@end

@implementation NewOrgViewController


- (void)viewDidLoad {
    _table=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-50) style:UITableViewStylePlain];
    [self.view addSubview:self.table];
    
    self.table.dataSource=self;
    self.table.delegate=self;
    [super viewDidLoad];
//    [self.navigationItem setHidesBackButton:YES];

//    leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    leftButton.titleLabel.font=[UIFont systemFontOfSize:14];
//    leftButton.frame=CGRectMake(10, (44-29)/2, 53, 29);
//    [leftButton setTitle:@" 单位" forState:UIControlStateNormal];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
//    [leftButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
//    [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    
    sectionArray=[NSMutableArray arrayWithCapacity:0];
    EmployeeModel * model=[[EmployeeModel alloc]init];
    model.name=self.organizationName;
    
    model.comman_orgName=self.organizationName;
    model.orgId=self.orgId;
    [sectionArray addObject:model];
    [self hideMoreLine];
}
-(void)hideMoreLine
{
    UIView *hide_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, 1)];
    hide_line.backgroundColor = [UIColor whiteColor];
    [self.table setTableFooterView:hide_line];
}

-(void)viewWillAppear:(BOOL)animated
{

}
- (void)viewWillDisappear:(BOOL)animated{
//    if (leftButton) {
//        [leftButton removeFromSuperview];
//    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.table.backgroundColor=[UIColor whiteColor];
    self.table.backgroundView=nil;
    if (IS_IOS_7) {
        if ([UIScreen mainScreen].bounds.size.height==480||[UIScreen mainScreen].bounds.size.height==568) {
            
            self.table.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
        }
        
    }
    
}
#pragma mark----区头的处理
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    static int height=30;
    return height;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return nil;
    }
    UIScrollView * scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.table.frame.size.width, 30)];
    scrollView.backgroundColor=[UIColor colorWithWhite:0.917 alpha:1.000];
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    float butt_x=0;
    EmployeeModel * model = [sectionArray objectAtIndex:0];
    NSString * companyStr = model.name;
    for (int i=0; i<sectionArray.count; i++) {
        EmployeeModel * model=[sectionArray objectAtIndex:i];
        AddGroupScrollButt *butt=[[AddGroupScrollButt alloc] init];
        butt.orgId=model.orgId;
        [butt setBackgroundColor:[UIColor colorWithWhite:0.917 alpha:1.000]];
        
        if (i == 0) {
            [butt setTitle:companyStr  forState:UIControlStateNormal];
            CGSize titleSize=[companyStr sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            butt.frame=CGRectMake(butt_x,-2, titleSize.width+20+14, 32);
            butt.tag=i+100;
            NSLog(@"%d",butt.tag);
            [butt setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        }else{
            UIButton * button =((AddGroupScrollButt *)[scrollView viewWithTag:100]);
            //   NSLog(@"%@",button);
            NSString * str =companyStr;
            [button setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
            CGSize Size=[str sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            if (Size.width > 110) {
                button.frame=CGRectMake(0, 0,100, 30);
                [button setTitle:companyStr  forState:UIControlStateNormal];
            }else{
                [button  setTitle:companyStr  forState:UIControlStateNormal];
            }
            [butt setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
            if (i == sectionArray.count - 1) {
                [butt setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
            }
            
            [button setImage:[UIImage imageNamed:@"title_arrow.png"] forState:UIControlStateNormal];
            [butt setTitle:model.name  forState:UIControlStateNormal];
            CGSize titleSize=[model.name sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            butt.frame=CGRectMake(butt_x, 0, titleSize.width+20+14, 30);
            
            
            [butt setImage:[UIImage imageNamed:@"title_arrow.png"] forState:UIControlStateNormal];
        }
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0,butt.frame.size.height-0.5, self.table.frame.size.width, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        [butt addSubview:lineView];
        UIFont *font=[UIFont systemFontOfSize:12];
        butt.titleLabel.font=font;
        butt.tag=i+100;
        butt.titleLabel.textAlignment=NSTextAlignmentCenter;
        if(i==0){
            CGSize Size=[companyStr sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            if (Size.width > 110) {
                butt_x = 100;
            }else{
                butt_x= Size.width + 20 + 14;}
        }else{
            butt_x+=butt.frame.size.width;
            
        }
        [butt addTarget:self action:@selector(checkOutSql:) forControlEvents:UIControlEventTouchUpInside];
        
        //       [butt setEnlargeEdgeWithTop:20 right:0 bottom:0 left:0];
        [scrollView addSubview:butt];
        
    }
  /*  for (int i=0; i<sectionArray.count; i++) {
        EmployeeModel * model=[sectionArray objectAtIndex:i];
        AddGroupScrollButt *butt=[[AddGroupScrollButt alloc] init];
        butt.orgId=model.orgId;
        [butt setBackgroundColor:[UIColor colorWithWhite:0.917 alpha:1.000]];
        [butt setTitle:model.name  forState:UIControlStateNormal];
        [butt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIFont *font=[UIFont systemFontOfSize:14];
        butt.titleLabel.font=font;
        butt.tag=i;
        butt.titleLabel.textAlignment=NSTextAlignmentCenter;
        CGSize titleSize=[model.name sizeWithFont:font constrainedToSize:CGSizeMake(MAXFLOAT, 35) lineBreakMode:NSLineBreakByCharWrapping];
        butt.frame=CGRectMake(butt_x, 0, titleSize.width+20+14, 35);
        [butt setImage:[UIImage imageNamed:@"navi_adress"] forState:UIControlStateNormal];
        [butt addTarget:self action:@selector(checkOutSql:) forControlEvents:UIControlEventTouchUpInside];
        [butt setEnlargeEdgeWithTop:20 right:0 bottom:0 left:0];

        [scrollView addSubview:butt];
        butt_x+=butt.frame.size.width;
    }
   */
    scrollView.contentSize=CGSizeMake(butt_x, 30);
    if (butt_x>tableView.frame.size.width) {
        [scrollView setContentOffset:CGPointMake(butt_x, 0)];
    }
    return scrollView;
 }
-(void)checkOutSql:(AddGroupScrollButt*)sender
{
    int index=sender.tag;
    while (sectionArray.count-1>index) {
        [sectionArray removeLastObject];
    }
    
    NSString * org_id=sender.orgId;
    self.dataArray=[SqlAddressData getOfContactPeople:org_id];
    [self.table reloadData];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
//返回的行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier0 = @"Cell";
    static NSString *CellIdentifier1 = @"Cell1";
    CellContact *cell_contact = [tableView dequeueReusableCellWithIdentifier:CellIdentifier0];
    CellOrganization * cell_org=[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    EmployeeModel * model=[self.dataArray objectAtIndex:indexPath.row];
        if (model.type==1) {
            if (cell_contact==nil) {
                cell_contact=[[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier0];
            }
            [self.table setSeparatorColor:[UIColor clearColor]];
            cell_contact.label_name.text = model.name;
            DDLogInfo(@"model.name%@model.name",model.name);
            CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
            cell_contact.label_position.text = model.position;
            CGSize size1=[ model.position sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
            cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);

            if (model.avatarimgurl) {
                NSString *fileURL = model.avatarimgurl;
                NSURL *url = [NSURL URLWithString:fileURL];
                [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
            }else{
            }
            cell_contact.isSearchTB = NO;
            cell=cell_contact;
        }if (model.type==2) {
            if (cell_org==nil) {
                cell_org=[[CellOrganization alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            }
            cell_org.nameLabel.text=model.name;
 
            cell=cell_org;
        }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmployeeModel * model=[self.dataArray objectAtIndex:indexPath.row];
    if (model.type==1) {
        UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
        userDetail.hidesBottomBarWhenPushed=YES;
        userDetail.userInfo=model;
        userDetail.organizationName=model.comman_orgName;
        [self.navigationController pushViewController:userDetail animated:YES];
    }if (model.type==2) {
        self.dataArray=[SqlAddressData getOfContactPeople:model.orgId];
        [sectionArray addObject:model];
        [self.table reloadData];
    }  
}
#pragma mark--返回
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
