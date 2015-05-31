//
//  OrganizationViewController.m
//  e企
//
//  Created by royaMAC on 14-11-7.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "OrganizationViewController.h"
#import "SqlAddressData.h"
#import "CellOrganization.h"
#import "CellContact.h"
#import "UserDetailViewController.h"
#import "CustomButton.h"
#import "AddGroupScrollButt.h"
#import "CellContact.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define ROW_HEIGHT 54
#define TEXT_FONT  15
#define TOP_Y 17
#define LABLE_WIDTH 20
@interface OrganizationViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    UIButton *leftButton;
    NSMutableArray  * sectionArray;
    NSMutableDictionary * saveOrgId;
    NSMutableArray * buttonArray;
    
    UISearchBar *searchBarContacts;
    UISearchDisplayController *searchDisplayControllerContacts;
    UIView *viewTranslucentBG;
    UIButton *buttonTranslucent;
    UITableView *tableViewSearch;
    UIView *viewSearchBG;
    UIView *viewSearchBG_1;
    NSString * search_text;///<搜索的关键字
    
    NSArray *filterData;
    UIButton*back;
    BOOL isSearch;
}

@end

@implementation OrganizationViewController
@synthesize search_array = _search_array;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"组织架构";
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320, self.view.bounds.size.height-64) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    isSearch = NO;
    
    UIBarButtonItem *barButtonItemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2_icon_search"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(iemcBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItemRight;
    
    //    [self.navigationItem setHidesBackButton:YES];
    
    leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    //    leftButton.titleLabel.font=[UIFont systemFontOfSize:14];
    leftButton.frame=CGRectMake(10, (44-29)/2, 53, 5);
    //    [leftButton setTitle:@" 单位" forState:UIControlStateNormal];
    //    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    //    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    //    [leftButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1] forState:UIControlStateNormal];
    //    [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    UIView *backBtnView = [[UIView alloc] initWithFrame:leftButton.bounds];
    backBtnView.bounds = CGRectOffset(backBtnView.bounds, -10, 0);
    backBtnView.backgroundColor=[UIColor redColor];
    [backBtnView addSubview:leftButton];
    
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtnView];
    backBarBtn.title = @"通讯录";
    self.navigationItem.backBarButtonItem = backBarBtn;
    
    
    
    //    self.navigationItem.leftBarButtonItem = backBarBtn;
    
    saveOrgId=[NSMutableDictionary dictionaryWithCapacity:0];
    
    sectionArray=[NSMutableArray arrayWithCapacity:0];
    buttonArray=[NSMutableArray arrayWithCapacity:0];
    
    NSDictionary * root=[SqlAddressData getRootOrganiztions];
    EmployeeModel * model=[[EmployeeModel alloc] init];
    model.name=root[@"organiztion_name"];
    model.orgId=root[@"organiztion_tag"];
    [sectionArray addObject:model];
    //  获取数据源
    [self initData];
    //  [self hideMoreLine];
}
-(void)initData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.dataArray=[SqlAddressData getOrgName];
        if (self.dataArray.count>0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
        }
    });
}
-(void)hideMoreLine
{
    UIView *hide_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    hide_line.backgroundColor = [UIColor whiteColor];
    //   [self.tableView setTableFooterView:hide_line];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tableView.backgroundColor= UIColorFromRGB(0xebebeb);
    if (leftButton) {
        [self.navigationController.navigationBar addSubview:leftButton];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.tableView.backgroundView=nil;
    if (IS_IOS_7) {
        if ([UIScreen mainScreen].bounds.size.height==480||[UIScreen mainScreen].bounds.size.height==568) {
            
            self.tableView.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    
    if(!isSearch && searchBarContacts)
    {
        searchBarContacts.delegate = nil;
        [searchBarContacts removeFromSuperview];
        searchBarContacts = nil;
        searchDisplayControllerContacts.delegate = nil;
        searchDisplayControllerContacts = nil;
    }
    
    if (leftButton) {
        [leftButton removeFromSuperview];
    }
}

#pragma mark----返回上一级页面
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark----返回的区
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == tableViewSearch)
    {
        return 0;
    }
    
    return 30.0;
}
#pragma mark----区头的处理
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == tableViewSearch)
    {
        
        return nil;
        //        if (section == 0) {
        //            NSString *str =[[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
        //
        //            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
        //            button.frame=CGRectMake(0, 0, 320, 30);
        //            button.backgroundColor=UIColorFromRGB(0xf8f8f8);
        //            //            HEXCOLOR(0xEEEEEE);
        //            button.tag=section+100-1;
        //
        //
        //            UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
        //            butt_label.text=str;
        //            butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        //            butt_label.textAlignment=NSTextAlignmentLeft;
        //            butt_label.font=[UIFont systemFontOfSize:12];
        //            [button addSubview:butt_label];
        //            //线
        //            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, button.frame.size.width, 0.5)];
        //            lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        //            [button addSubview:lineView];
        //
        //            return button;
        //        }
        //        else{
        //            NSString *str =@"我的部门";
        //            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
        //            button.frame=CGRectMake(0, 0, 320, 30);
        //            button.backgroundColor=UIColorFromRGB(0xf8f8f8);
        //            //            HEXCOLOR(0xEEEEEE);
        //            button.tag=section+100-1;
        //
        //
        //            UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
        //            butt_label.text=str;
        //            butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        //            butt_label.textAlignment=NSTextAlignmentLeft;
        //            butt_label.font=[UIFont systemFontOfSize:12];
        //            [button addSubview:butt_label];
        //            //线
        //            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, button.frame.size.width, 0.5)];
        //            lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        //            [button addSubview:lineView];
        //
        //            return button;
        //        }
        
    }
    else{
        NSString * companyStr = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
        UIScrollView * scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        scrollView.backgroundColor=[UIColor colorWithWhite:0.917 alpha:1.000];
        scrollView.showsHorizontalScrollIndicator=NO;
        scrollView.showsVerticalScrollIndicator=NO;
        float butt_x=0;
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
                    button.frame=CGRectMake(0,-2,100, 32);
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
                butt.frame=CGRectMake(butt_x, -2, titleSize.width+20+14, 32);
                
                
                [butt setImage:[UIImage imageNamed:@"title_arrow.png"] forState:UIControlStateNormal];
            }
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0,butt.frame.size.height-0.5, self.tableView.frame.size.width, 0.5)];
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
        scrollView.contentSize=CGSizeMake(butt_x, 30);
        if (butt_x>tableView.frame.size.width) {
            [scrollView setContentOffset:CGPointMake(butt_x, 0)];
        }
        return scrollView;
    }
    return nil;
}
-(void)checkOutSql:(AddGroupScrollButt*)sender
{
    int index=sender.tag - 100;
    while (sectionArray.count-1>index) {
        [sectionArray removeLastObject];
    }
    
    NSString * org_id=sender.orgId;
    self.dataArray=[SqlAddressData getOfContactPeople:org_id];
    
    [self.tableView reloadData];
    //        self.dataArray=[SqlAddressData getOfContactPeople:[NSString stringWithFormat:@"%d",sender.tag]];
    //        for (int i=sectionArray.count-1; i>-1; i--) {
    //            if (i>sender.index) {
    //                [sectionArray removeObjectAtIndex:i];
    //            }
    //        }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == tableViewSearch)
    {
        return 1;
    }
    
    return 1;
}
#pragma mark----返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tableViewSearch)
    {
        return self.search_array.count;
    }
    return self.dataArray.count;
}
#pragma mark----单元格的处理
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = nil;
    static NSString *CellIdentifier1 = @"Cell1";
    static NSString *CellIdentifier0 = @"Cell";
    CellOrganization * cell_org=nil;
    CellContact *cell_contact = nil;
    
    if (tableView == tableViewSearch)
    {
        [tableViewSearch setSeparatorColor:[UIColor clearColor]];
        //        static NSString *stringCell = @"stringCell";
        //        UITableViewCell *cell = [tableViewSearch dequeueReusableCellWithIdentifier:stringCell];
        //        if (cell == nil)
        //        {
        //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell];
        //        }
        
        
        if (cell_contact == nil) {
            
            cell_contact = [[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            
            
        }else{
            //删除cell的所有子视图
            while ([cell.contentView.subviews lastObject] != nil)
            {
                [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }
        
        
        EmployeeModel *contact = [self.search_array objectAtIndex:indexPath.row];
        cell_contact.label_name.text = contact.name;
        DDLogInfo(@"contact.name%@contact.name",contact.name);
        
        CGSize size=[contact.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        if (size.width > 80) {
            size.width = 80;
        }
        cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
        /*
         if ([contact.phone containsString:search_text]) {
         [self dispalyCell:cell_contact Content:contact.phone];
         }if ([contact.pinyin_name containsString:search_text]) {
         [self dispalyCell:cell_contact Content:contact.pinyin_name];
         }if ([contact.name containsString:search_text]) {
         [self dispalyCell:cell_contact Content:contact.name];
         }if ([contact.shotNum containsString:search_text]) {
         
         //            if ([contact.shotNum isEqualToString:@"(null)"]) {
         
         //            }else{
         [self dispalyCell:cell_contact Content:contact.shotNum];
         //            }
         }if ([contact.first_name containsString:search_text]) {
         [self dispalyCell:cell_contact Content:contact.pinyin_name];
         }if ([contact.orgName containsString:search_text]) {
         [self dispalyCell:cell_contact Content:contact.orgName];
         }if ([contact.nameSuoXie containsString:search_text]) {
         [self dispalyCell:cell_contact Content:contact.nameSuoXie];
         }
         */
        cell_contact.label_position.text=contact.comman_orgName;
        UIColor * color =[UIColor lightGrayColor];
        cell_contact.label_position.textColor = color;
        cell_contact.label_position.font = [UIFont systemFontOfSize:12];
        CGSize size1=[contact.comman_orgName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
        if (size1.width > 150) {
            size1.width = 150;
        }
        cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
        
        if (contact.avatarimgurl) {
            NSString *fileURL = contact.avatarimgurl;
            NSURL *url = [NSURL URLWithString:fileURL];
            [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:default_headImage]];
        }else{
            cell_contact.imageView.image=[UIImage imageNamed:default_headImage];
        }
        if (indexPath.row == _search_array.count - 1) {
            cell_contact.lineView.frame = CGRectMake(0, 53.5, 320, 0.5);
        }
        cell = cell_contact;
        
        
        //        else {
        //            EmployeeModel *contact = [self.search_array1 objectAtIndex:indexPath.row];
        //            cell_contact.label_name.text = contact.name;
        //            DDLogInfo(@"contact.name%@contact.name",contact.name);
        //
        //            CGSize size=[contact.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        //            if (size.width > 80) {
        //                size.width = 80;
        //            }
        //            cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
        //            /*
        //             if ([contact.phone containsString:search_text]) {
        //             [self dispalyCell:cell_contact Content:contact.phone];
        //             }if ([contact.pinyin_name containsString:search_text]) {
        //             [self dispalyCell:cell_contact Content:contact.pinyin_name];
        //             }if ([contact.name containsString:search_text]) {
        //             [self dispalyCell:cell_contact Content:contact.name];
        //             }if ([contact.shotNum containsString:search_text]) {
        //
        //             //            if ([contact.shotNum isEqualToString:@"(null)"]) {
        //
        //             //            }else{
        //             [self dispalyCell:cell_contact Content:contact.shotNum];
        //             //            }
        //             }if ([contact.first_name containsString:search_text]) {
        //             [self dispalyCell:cell_contact Content:contact.pinyin_name];
        //             }if ([contact.orgName containsString:search_text]) {
        //             [self dispalyCell:cell_contact Content:contact.orgName];
        //             }if ([contact.nameSuoXie containsString:search_text]) {
        //             [self dispalyCell:cell_contact Content:contact.nameSuoXie];
        //             }
        //             */
        //            cell_contact.label_position.text=contact.comman_orgName;
        //            UIColor * color =[UIColor lightGrayColor];
        //            cell_contact.label_position.textColor = color;
        //            cell_contact.label_position.font = [UIFont systemFontOfSize:12];
        //            CGSize size1=[contact.comman_orgName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
        //            if (size1.width > 150) {
        //                size1.width = 150;
        //            }
        //            cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
        //
        //            if (contact.avatarimgurl) {
        //                NSString *fileURL = contact.avatarimgurl;
        //                NSURL *url = [NSURL URLWithString:fileURL];
        //                [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:default_headImage]];
        //            }else{
        //                cell_contact.imageView.image=[UIImage imageNamed:default_headImage];
        //            }
        //            if (indexPath.row == _search_array1.count - 1) {
        //                cell_contact.lineView.frame = CGRectMake(0, 53.5, 320, 0.5);
        //            }
        //            cell = cell_contact;
        //        }
        
        return cell;
    }
    else{
        
        EmployeeModel * model=[self.dataArray objectAtIndex:indexPath.row];
        //       显示联系人
        
        if (model.type==1) {
            if (cell_contact==nil) {
                cell_contact=[[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            }
            [self.tableView setSeparatorColor:[UIColor clearColor]];
            cell_contact.label_name.text=model.name;
            CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            if (size.width > 80) {
                size.width = 80;
            }
            cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
            cell_contact.label_position.text = model.title;
            CGSize size1=[ model.title sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
            if (size1.width > 150) {
                size1.width = 150;
            }
            cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
            if (indexPath.row == self.dataArray.count - 1) {
                cell_contact.lineView.frame = CGRectMake(0,53.5, 320, 0.5);
            }
            
            if (model.avatarimgurl) {
                NSString * fileStr=model.avatarimgurl;
                NSURL * urlStr=[NSURL URLWithString:fileStr];
                [cell_contact.imageView setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:@"address_icon_person.png"]];
            }
            cell_contact.selectionStyle = UITableViewCellSelectionStyleNone;
            cell_contact.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell=cell_contact;
        }
        else if (model.type==2) {
            if (cell_org==nil) {
                cell_org=[[CellOrganization alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier0];
            }
            [self.tableView setSeparatorColor:[UIColor clearColor]];
            NSMutableArray * array =[NSMutableArray arrayWithArray:[SqlAddressData getOfContactPeople:model.orgId]];
            cell_org.nameLabel.text=model.name;
            CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            //     cell_org.positionLabel.text = [NSString stringWithFormat:@"%d个",array.count];
            CGSize size1=[cell_org.positionLabel.text sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
            if (size1.width > 150) {
                size1.width = 150;
            }
            cell_org.positionLabel.frame=CGRectMake(cell_org.nameLabel.frame.size.width+cell_org.nameLabel.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
            cell_org.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell_org.nameLabel.frame=CGRectMake(10,TOP_Y, size.width, LABLE_WIDTH);
            cell_org.nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
            cell=cell_org;
        }
    }
    return cell;
    
}
-(void)dispalyCell:(CellContact*)cell_contact  Content:(NSString*)name
{
    
    NSString * showContent=name;
    if ([showContent containsString:search_text]) {
        NSRange range=[showContent rangeOfString:search_text];
        NSMutableAttributedString * attrString=[[NSMutableAttributedString alloc]initWithString:showContent];
        UIColor * color =[UIColor colorWithRed:68.0/255 green:140.0/255 blue:255.0/255 alpha:1];
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
        cell_contact.label_position.attributedText=attrString;
    }
    
    CGSize size1=[showContent sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
    cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == tableViewSearch)
    {
        
        EmployeeModel *contact = [self.search_array objectAtIndex:indexPath.row];
        UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
        userDetail.hidesBottomBarWhenPushed=YES;
        [searchBarContacts resignFirstResponder];
        userDetail.searchBarContacts = searchBarContacts;
        userDetail.userInfo=contact;
        userDetail.organizationName=contact.comman_orgName;
        [self.navigationController pushViewController:userDetail animated:YES];
    }
    else {
        EmployeeModel * model=[self.dataArray objectAtIndex:indexPath.row];
        if(model.type==2){
            self.dataArray=[SqlAddressData getOfContactPeople:model.orgId];
            [sectionArray addObject:model];
            [self.tableView reloadData];
        }
        if (model.type==1) {
            
            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
            userDetail.hidesBottomBarWhenPushed=YES;
            userDetail.userInfo=model;
            userDetail.organizationName=model.comman_orgName;
            [self.navigationController pushViewController:userDetail animated:YES];
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

#pragma mark - =====搜索功能实现方法=====
- (void)iemcBarButtonItemAction:(id)sender
{
    searchBarContacts = [[UISearchBar alloc] init];
    if (IS_IOS_8)
    {
        searchBarContacts.frame = CGRectMake(8, 0, self.view.frame.size.width-8, 44);
    }
    else
    {
        searchBarContacts.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    }
    //    searchBarContacts.frame = CGRectMake(8, 0, self.view.frame.size.width-8, 44);
    searchBarContacts.delegate = self;
    searchBarContacts.backgroundColor = cor6;
    searchBarContacts.placeholder = @"搜索";
    searchBarContacts.showsCancelButton = YES;
    [searchBarContacts becomeFirstResponder];
    [self.navigationController.navigationBar addSubview:searchBarContacts];
    searchDisplayControllerContacts = [[UISearchDisplayController alloc] initWithSearchBar:searchBarContacts contentsController:self];
    searchDisplayControllerContacts.delegate = self;
    searchDisplayControllerContacts.searchResultsDataSource = self;
    searchDisplayControllerContacts.searchResultsDelegate = self;
    searchDisplayControllerContacts.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    searchDisplayControllerContacts.searchResultsTableView.backgroundColor = [UIColor whiteColor];
    
    viewTranslucentBG = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)];
    viewTranslucentBG.backgroundColor = [UIColor blackColor];
    viewTranslucentBG.alpha = 0.3f;
    [self.view.window addSubview:viewTranslucentBG];
    
    buttonTranslucent = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //    buttonTranslucent.backgroundColor = [UIColor redColor];
    [buttonTranslucent addTarget:self action:@selector(buttonTranslucent) forControlEvents:UIControlEventTouchUpInside];
    [viewTranslucentBG addSubview:buttonTranslucent];
    isSearch = YES;
}

#pragma mark - 按钮响应
- (void)buttonTranslucent
{
    isSearch = NO;
    isSearch = NO;
    searchBarContacts.hidden = YES;
    [searchBarContacts resignFirstResponder];
    viewTranslucentBG.hidden = YES;
    buttonTranslucent.hidden = YES;
    viewSearchBG.hidden = YES;
    viewSearchBG_1.hidden = YES;
    if(!isSearch && searchBarContacts)
    {
        searchBarContacts.delegate = nil;
        [searchBarContacts removeFromSuperview];
        searchBarContacts = nil;
        searchDisplayControllerContacts.delegate = nil;
        searchDisplayControllerContacts = nil;
    }
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    viewTranslucentBG.hidden = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    isSearch = NO;
    searchBar.hidden = YES;
    [searchBar resignFirstResponder];
    viewTranslucentBG.hidden = YES;
    viewSearchBG.hidden = YES;
    viewSearchBG_1.hidden = YES;
    
    if(!isSearch && searchBarContacts)
    {
        searchBarContacts.delegate = nil;
        [searchBarContacts removeFromSuperview];
        searchBarContacts = nil;
        searchDisplayControllerContacts.delegate = nil;
        searchDisplayControllerContacts = nil;
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    viewSearchBG.hidden = YES;
    viewSearchBG_1.hidden = YES;
}
#pragma mark - 滑动收起键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBarContacts resignFirstResponder];
}

#pragma mark - UISearchDisplayDelegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (searchString.length == 0)
    {
        viewTranslucentBG.hidden = NO;
        buttonTranslucent.hidden = NO;
    }
    else if (searchString.length > 0)
    {
        viewTranslucentBG.hidden = YES;
        buttonTranslucent.hidden = YES;
        
        viewSearchBG = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
        viewSearchBG.backgroundColor = [UIColor whiteColor];
        
        tableViewSearch = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableViewSearch.delegate = self;
        tableViewSearch.dataSource = self;
        [tableViewSearch setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
        [viewSearchBG addSubview:tableViewSearch];
        
        [self.view addSubview:viewSearchBG];
        
        [self ContentForSearchText:searchString];
        
        if (_search_array.count == 0)
        {
            viewSearchBG_1 = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
            viewSearchBG_1.backgroundColor = [UIColor whiteColor];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-15, self.view.frame.size.height/2-200, 33, 33)];
            imageView.image = [UIImage imageNamed:@"input_icon_search"];
            [viewSearchBG_1 addSubview:imageView];
            
            UILabel *labelSearch = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-50, self.view.frame.size.height/2-160, 100, 20)];
            labelSearch.text = @"无结果";
            labelSearch.textAlignment = NSTextAlignmentCenter;
            labelSearch.textColor = cor3;
            labelSearch.font = [UIFont systemFontOfSize:17.f];
            [viewSearchBG_1 addSubview:labelSearch];
            
            [self.view addSubview:viewSearchBG_1];
        }
    }
    
    return YES;
}

-(void)ContentForSearchText:(NSString*)searchText{
    //  记录搜索的关键字
    search_text=searchText;
    if (_search_array==nil) {
        _search_array=[NSMutableArray array];
    }
    if (_search_array1 == nil) {
        _search_array1 = [NSMutableArray array];
    }
    [_search_array removeAllObjects];
    [_search_array1 removeAllObjects];
    [_search_array addObjectsFromArray:[SqlAddressData getNewContactWithRequirement:searchText]];
    //    int a = _search_array.count;
    //
    //    NSArray * array =[SqlAddressData selectOrgName];
    //    for (int i = 0; i< array.count; i++) {
    //        for (int j = 0; j < _search_array.count; j++) {
    //            if ([((EmployeeModel *)[_search_array objectAtIndex:j]).comman_orgName isEqualToString:[array objectAtIndex:i]])
    //            {
    //                NSString * str = ((EmployeeModel *)[_search_array objectAtIndex:j]).comman_orgName;
    //                [_search_array1 addObject:[_search_array objectAtIndex:j]];
    //            }
    //        }
    //        [_search_array removeObjectsInArray:_search_array1];
    //    }
    [tableViewSearch reloadData];
    
}
#pragma mark - =======================

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


