//
//  MyDepartmentViewController.m
//  e企
//
//  Created by zxdDong on 15-4-12.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "MyDepartmentViewController.h"
#import "ContactsViewController.h"
#import "Contact.h"
#import "menber_info.h"
#import "enterprise_info.h"
#import "MessageChatViewController.h"
#import "CellOrganization.h"
#import "CellContact.h"
//#import "HtppEngine.h"
//#import "HttpRequestEngine.h"//请求通讯录的类


#import "AFClient.h"

#import "MainNavigationCT.h"
#import "MainViewController.h"
#import "ServiceNumberAllListViewController.h"
#import "OrganizationViewController.h"
#import "NewOrgViewController.h"

#import "HttpRequstUrl.h"

#import "TKContactsMultiPickerController.h"
#import "UserDetailViewController.h"
#import "SqlAddressData.h"
#import "EmployeeModel.h"
#import "ContactsModel.h"
#import "SqlLiteCreate.h"
#import "UIImageView+WebCache.h"


#define HEAD_CELLHEIGHT 30 //区的高度
#define ROW_CELLHEIGHT  54 //行高
#define SEARCH_CELLHEIGHT 44 //搜索框的高度
#define DAOHANG_HEIGHT 94
#define TEXT_FONT  15
#define TOP_Y 17
#define LABLE_WIDTH 20
#define LINE_HEIGHT 0.5
#define LINE_WIDTH 320


@interface MyDepartmentViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    UIImageView * btn_img;//区尾的小按钮
    NSDictionary * dataDic;
    NSMutableArray * sectionArray;
    NSMutableDictionary * sectionFlag;
    //    NSArray * commanArray;
    NSString * org_id;
    //每行的数据源
    NSMutableDictionary * cellDic;
    NSString     *sectionStr;
    //    BOOL         _flag[1000];
    BOOL         isFirstIn;
    BOOL         openOrClose;
    int         clickIndex;
    UIButton *oneOrgBtn;
    UIButton *twoOrgBtn;
    
    BOOL isLoadFirst;
    NSString * search_text;///<搜索的关键字
    
    BOOL isSearch;///<是否是搜索
    
    UISearchBar *searchBarContacts;
    UISearchDisplayController *searchDisplayControllerContacts;
    UIView *viewTranslucentBG;
    UIButton *buttonTranslucent;
    UITableView *tableViewSearch;
    UIView *viewSearchBG;
    UIView *viewSearchBG_1;
}



@end

@implementation MyDepartmentViewController

@synthesize search_array = _search_array;
@synthesize search_array1 = _search_array1;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!isSearch && searchBarContacts)
    {
        searchBarContacts.delegate = nil;
        [searchBarContacts removeFromSuperview];
        searchBarContacts = nil;
        searchDisplayControllerContacts.delegate = nil;
        searchDisplayControllerContacts = nil;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的部门";
    
    CGRect rect =[UIScreen mainScreen].applicationFrame;
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320, rect.size.height - 44) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.dataArray=[[NSArray alloc]init];
    sectionArray=[[NSMutableArray alloc]init];
    cellDic=[[NSMutableDictionary alloc]init];
    sectionFlag = [[NSMutableDictionary alloc] init];
    isFirstIn=YES;
    isLoadFirst=YES;
    isSearch = NO;
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
    
    
    UIBarButtonItem *barButtonItemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2_icon_search"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(iemcBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItemRight;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView reloadData];
    
    
}
-(void)initData{
    ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
    if (contactsCheck.executeStatus !=1 && [SqlAddressData queryContactIsNull]) {
        [self getAddress];
    }
    //    if (isSearch) {
    //        return;
    //    }
    
    [self.tableView reloadData];
}
-(void)getAddress{
    //   得到区的名字数组
    sectionArray=[NSMutableArray arrayWithArray:[SqlAddressData selectOrgName]];
    for (NSString * str in sectionArray) {
        NSLog(@"%@",str);
    }
    BOOL isOne=NO;
    
    if (sectionArray.count==1) {
        isOne=YES;
    }
    isLoadFirst=YES;
    
    if (isLoadFirst) {
        if (isOne) {
            NSString * str = [sectionArray objectAtIndex:0];
            org_id= [[ConstantObject sharedConstant].userInfo.orgid objectAtIndex:0];
            self.dataArray=[SqlAddressData getOrgPeopleByOrgId:org_id];
            NSLog(@"%d",self.dataArray.count);
            [cellDic setValue:self.dataArray forKey:str];
            [sectionFlag setValue:[NSNumber numberWithInt:1] forKey:str];
            
        }else{
            //                    for (int i=1; i<sectionArray.count; i++) {
            //                    _flag[i-1]=_flag[i];
            //                }
        }
    }
    
    //
    //    if (isSearch) {
    //        return;
    //    }
    
    [self.tableView reloadData];
}
-(NSArray*)getCommanData
{
    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    NSArray* commanArray= [SqlAddressData selectCommanContact:uid];
    return commanArray;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberofSection = 0;
    if (tableView == tableViewSearch)
    {
        return 1;
    }
    
    numberofSection=sectionArray.count;
    return numberofSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberofRow = 0;
    
    if (tableView == tableViewSearch)
    {
        numberofRow = self.search_array.count;
    }
    else{
        NSArray * cellArray=cellDic[[sectionArray objectAtIndex:section]];
        numberofRow=cellArray.count;
    }
    return numberofRow;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == tableViewSearch)
    {
        return 0;
    }
    CGFloat flt = 0;
    flt=HEAD_CELLHEIGHT;
    return flt;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ROW_CELLHEIGHT;
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UITableViewHeaderFooterView *head = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!head) {
        head = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
    }else{
        //      防止重用
        while ([head.contentView.subviews lastObject] != nil)
        {
            [(UIView*)[head.contentView.subviews lastObject] removeFromSuperview];
        }
        
    }
    if (tableView == tableViewSearch)
    {
        return nil;
    }
    else{
        NSString *str = [sectionArray objectAtIndex:section];
        
        UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.frame=CGRectMake(0, 0, 320, 30);
        [button addTarget:self action:@selector(openOrClosed:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor=HEXCOLOR(0xEEEEEE);
        button.tag=section+100;
        
        
        UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14,0, tableView.frame.size.width-20, button.frame.size.height)];
        butt_label.text=str;
        butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        butt_label.textAlignment=NSTextAlignmentLeft;
        butt_label.font=[UIFont systemFontOfSize:12];
        [button addSubview:butt_label];
        UIView* lineView               = [[UIView alloc] init];
        lineView.frame=CGRectMake(0, 29.5, 320,LINE_HEIGHT);
        lineView.opaque             = YES;
        lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];;
        [button addSubview:lineView];
        
        [head.contentView addSubview:button];
        
        
        btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 27, 13, 11, 6)];
        if ([(NSNumber*)[sectionFlag valueForKey:str] intValue]== 0) {
            btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
        }else{
            btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
        }
        [head.contentView addSubview:btn_img];
        
        
        
        if([sectionArray count] == 1)
        {
            oneOrgBtn = button;
        }
    }
    
    return head;
    
    
}


-(void)openOrClosed:(UIButton*)sender
{
    int index=sender.tag-100;
    //纪录点击的索引
    clickIndex=index;
    NSString *str=sectionArray[index];
    if ([(NSNumber*)[sectionFlag valueForKey:str] intValue]== 1) {
        [cellDic removeObjectForKey:str];
        [sectionFlag setValue:[NSNumber numberWithInt:0] forKey:str];
    }else{
        
        if ([str isEqualToString:commanName]) {
            NSArray * commanArray=[self getCommanData];
            [cellDic setValue:commanArray forKey:str];
        }else{
            
            //NSString *orgID= [SqlAddressData getOrganiztionsBySection:str];
            //int orgIndex = index + ([self getCommanData].count ==0 ? 0 : 1);
            
            NSString *orgID= [SqlAddressData getOrganiztionsBySection:sectionArray[index]];
            
            //NSString *orgID= [[ConstantObject sharedConstant].userInfo.orgid objectAtIndex:orgIndex];
            //      通过自己所在部门的id，找到这个部门下所有的人以及这个部门下的部门
            NSArray *memberArray=[SqlAddressData getOrgPeopleByOrgId:orgID];
            [cellDic setValue:memberArray forKey:str];
        }
        [sectionFlag setValue:[NSNumber numberWithInt:1] forKey:str];
    }
    //    if (isSearch) {
    //        return;
    //    }
    [self.tableView reloadData];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == tableViewSearch)
    {
        if (indexPath.section == 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            EmployeeModel *contact = [self.search_array objectAtIndex:indexPath.row];
            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
            userDetail.userInfo=contact;
            tableViewSearch.hidden = YES;
            viewSearchBG.hidden = YES;
            userDetail.tableViewSearch = tableViewSearch;
            userDetail.viewSearchBG = viewSearchBG;
            userDetail.searchBarContacts = searchBarContacts;
            [searchBarContacts resignFirstResponder];
            userDetail.organizationName=contact.comman_orgName;
            [self.navigationController pushViewController:userDetail animated:YES];
        }
        else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            EmployeeModel *contact = [self.search_array1 objectAtIndex:indexPath.row];
            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
            userDetail.userInfo=contact;
            [searchBarContacts resignFirstResponder];
            userDetail.organizationName=contact.comman_orgName;
            [self.navigationController pushViewController:userDetail animated:YES];
        }
        
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
        NewOrgViewController *viewController=[[NewOrgViewController alloc]initWithNibName:@"NewOrgViewController" bundle:nil];
        //           有问题需要改
        NSArray * array=[cellDic objectForKey:[sectionArray objectAtIndex:indexPath.section]];
        EmployeeModel *model = [array objectAtIndex:indexPath.row];
        userDetail.hidesBottomBarWhenPushed=YES;
        if (model.type==1) {
            userDetail.userInfo=model;
            NSArray * commanArray=[self getCommanData];
            
            NSArray * memberIsHave=[SqlAddressData selectCommanContactByPhone:model.phone];
            if (memberIsHave.count>0) {
                userDetail.userInfo.freqFlag=1;
            }else{
                userDetail.userInfo.freqFlag=0;
            }
            if (commanArray.count>0) {
                if (indexPath.section==0) {
                    userDetail.organizationName=model.comman_orgName;
                    DDLogInfo(@"%@",model.comman_orgName);
                }else{
                    userDetail.organizationName=[sectionArray objectAtIndex:indexPath.section];
                    
                }
            }else{
                userDetail.organizationName=[sectionArray objectAtIndex:indexPath.section];
            }
            userDetail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userDetail animated:YES];
            
        }
        if (model.type==2) {
            NSArray * newArray=[[NSArray alloc]init];
            newArray=[SqlAddressData getOfContactPeople:model.orgId];
            viewController.dataArray=newArray;
            viewController.organizationName=model.name;
            viewController.orgId=model.orgId;
            [self.navigationController pushViewController:viewController animated:YES];
        }
        
    }
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier1 = @"Cell1";
    static NSString *CellIdenttifier0= @"Cell0";
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
        if (cell_contact == nil) {
            cell_contact = [[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        }else{
            //删除cell的所有子视图
            while ([cell.contentView.subviews lastObject] != nil)
            {
                [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
            }
        }
        NSString * sectionStr = [sectionArray objectAtIndex:indexPath.section ];
        NSArray * array=[cellDic objectForKey:[sectionArray objectAtIndex:indexPath.section]];
        EmployeeModel *model = [array objectAtIndex:indexPath.row];
        //    if ([sectionStr isEqualToString:commanName]) {
        //        cell_contact.label_name.text = model.name;
        //        DDLogInfo(@"+++++++++++++%@=======",model.name);
        //        CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        //        cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
        //        if ([model.comman_orgName isEqualToString:@"(null)"]) {
        //            cell_contact.label_position.text = @" ";
        //        }
        //        else{
        //            cell_contact.label_position.text = model.title;
        //            DDLogInfo(@"%@",model.comman_orgName);
        //            //根据str获取宽高
        //            CGSize size1=[ model.title sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
        //            cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
        //        }
        //        if(indexPath.row==array.count-1){
        //            [cell_contact.lineView setFrame:CGRectMake(0, 53.5, 320, 0.5)];
        //        }
        //        if (model.avatarimgurl) {
        //            NSString *fileURL = model.avatarimgurl;
        //            NSURL *url = [NSURL URLWithString:fileURL];
        //            [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
        //
        //        }
        //    }
        if (model.type==1) {
            
            cell_contact.label_name.text = model.name;
            DDLogInfo(@"+++++++++++++%@=======",model.name);
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
            if(indexPath.row==array.count-1){
                [cell_contact.lineView setFrame:CGRectMake(0, 53.5, 320, 0.5)];
            }
            if (model.avatarimgurl) {
                NSString *fileURL = model.avatarimgurl;
                NSURL *url = [NSURL URLWithString:fileURL];
                [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
            }else{
            }
        }
        if (model.type==2) {
            if (cell_org==nil) {
                cell_org=[[CellOrganization alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdenttifier0];
            }
            cell_org.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell_org.nameLabel.text=model.name;
            CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            cell_org.nameLabel.frame=CGRectMake(10, 15, size.width, 30);
            cell_org.nameLabel.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
            return cell_org;
        }
        
        
        NSString *selfNumber=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
        if ([model.phone isEqualToString:selfNumber]) {
            cell_contact.messageBtn.hidden = YES;
            cell_contact.calliphoneBtn.hidden = YES;
        }else{
            cell_contact.messageBtn.hidden = NO;
            cell_contact.calliphoneBtn.hidden = NO;
        }
        cell_contact.menssegeID=indexPath;
        cell_contact.isSearchTB = NO;
        if (indexPath.row == array.count - 1) {
            cell_contact.lineView.frame = CGRectMake(0, ROW_CELLHEIGHT - 0.5, 320, 0.5);
        }
        
        cell_contact.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = cell_contact;
        
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
#pragma mark - 滑动收起键盘
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchBarContacts resignFirstResponder];
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
    //    [tableViewSearch reloadData];
    
    
}


#pragma mark - =======================

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)didReceiveMemoryWarning {
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
