//
//  addMydepartController.m
//  e企
//
//  Created by zxdDong on 15-4-12.
//  Copyright (c) 2015年 QYB. All rights reserved.
//
#import "AddFromContact.h"
#import "Contact.h"
#import "menber_info.h"
#import "MessageChatViewController.h"
#import "GroupCell.h"

#import "addFromGroupVC.h"

#import "AFClient.h"
#import "SqliteDataDao.h"
#import "CellFirstThree.h"
#import "CellAddMenb.h"

#import "UIImageView+WebCache.h"
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
#define LINE_HEIGHT 1
#define LINE_WIDTH 320


#import "addFromGroupVC.h"
#define SEARCH_HEIGHT 40 //tableView头部高度
#define SCROLLVIEW_ICON_MARGIN 3    //scrollView的图标间距
#define SECTION_MAX_ROW 1000    //每组最大行数
#define ANIMATION_DURATION 0.2  //动画持续时间

#define tag_title_butt_start 1000 //头部butt的开始tag值

#import "addMydepartController.h"

@interface addMydepartController ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    UIButton *_rightButt;
    NSMutableArray *sectionTitleArray;
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
    
    BOOL isSearch;///<是否是搜索状态
    
    UISearchBar *searchBarContacts;
    UISearchDisplayController *searchDisplayControllerContacts;
    UIView *viewTranslucentBG;
    UIButton *buttonTranslucent;
    UITableView *tableViewSearch;
    UIView *viewSearchBG;
    UIView *viewSearchBG_1;
    NSString * search_text;///<搜索的关键字
}

@end

@implementation addMydepartController
@synthesize search_array = _search_array;
@synthesize contact_MutDic = _contact_MutDic;


//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    CGRect barFrame = self.searchBar.frame;
//    barFrame.size.width = self.view.bounds.size.width;
//    self.searchBar.frame = barFrame;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的部门";
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320, rect.size.height-44) style:UITableViewStylePlain];
    [self.tableView setSeparatorColor:[UIColor clearColor]];

    [self.view addSubview:self.tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    _addscrollMess = [addScrollView_messege sharedInstanse];
    self.dataArray=[[NSArray alloc]init];
    sectionArray=[[NSMutableArray alloc]init];
    cellDic=[[NSMutableDictionary alloc]init];
    sectionFlag = [[NSMutableDictionary alloc] init];
    isFirstIn=YES;
    isLoadFirst=YES;
    _addscrollMess = [addScrollView_messege sharedInstanse];
    if (IS_IOS_7) {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexColor = [UIColor grayColor];
    }else{
        //  [self initBackButton];
        //  [self initbarButton];
    }
    // [self hideMoreLine];
    
    ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
    contactsCheck.contactsCheckDelegate = self;
    if(contactsCheck.executeStatus == 0){
        [contactsCheck execute];
    }else if(contactsCheck.executeStatus == 1){
        [self beginUpdate];
    }else{
        [self endUpdate:YES];
    }
    
    isSearch=NO;
    // [self.tableView reloadData];
    
    UIBarButtonItem *barButtonItemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2_icon_search"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(iemcBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItemRight;
}

-(void)beginUpdate{
    if (_HUD != nil) {
        [_HUD removeFromSuperview];
    }
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view bringSubviewToFront:_HUD];
    [self.view addSubview:_HUD];
    _HUD.labelText = @"检查联系人更新...";
    [_HUD show:YES];
}
-(void)endUpdate:(bool)hasUpdate{
    if (_HUD != nil) {
        [_HUD removeFromSuperview];
    }
    [self initData];
    if (isSearch) {
        return;
    }
    [self.tableView reloadData];
}
-(void)initData{
    
    
    if (!sectionTitleArray) {
        sectionTitleArray=[[NSMutableArray alloc] init];
    }
    [sectionTitleArray removeAllObjects];
    DDLogInfo(@"--------------%@",[SqlAddressData selectOrgName]);
    
    [sectionTitleArray addObjectsFromArray:[SqlAddressData selectOrgName]];
    DDLogInfo(@"%@",[sectionTitleArray objectAtIndex:0]);
    
    BOOL isOne = NO;
    if (sectionTitleArray.count==1) {
        isOne=YES;
        
    }
    
    if (!_contact_MutDic) {
        _contact_MutDic=[[NSMutableDictionary alloc] init];
    }
    if (isOne)
    {
        NSString *org_id=[SqlAddressData getOrganiztionsBySection:[sectionTitleArray objectAtIndex:0]];
        NSArray *memberArray=[SqlAddressData getOrgPeopleByOrgId:org_id];
        
        [_contact_MutDic setValue:memberArray forKey:[sectionTitleArray objectAtIndex:0]];
        
        select[0]=YES;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberofSection = 0;
    if (tableView == tableViewSearch)
    {
        numberofSection = 1;
    }
    else{
        numberofSection = sectionTitleArray.count;
        DDLogInfo(@"%d",numberofSection);
    }
    return numberofSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberofRow = 0;
    if (tableView == tableViewSearch)
    {
        numberofRow = self.search_array.count;
    }
    else{
        
        NSString *str=sectionTitleArray[section];
        NSArray *memberArray=[_contact_MutDic objectForKey:str];
        numberofRow=memberArray.count;
        DDLogInfo(@"%d",numberofRow);
    }
    return numberofRow;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableView * cell = nil;
    
    static NSString * cellindertfer = @"cell";
    static NSString * cellindertfer1 = @"cell1";
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (tableView == tableViewSearch)
    {
        [tableViewSearch setSeparatorColor:[UIColor clearColor]];
        CellAddMenb *cell_addmenb = [tableView dequeueReusableCellWithIdentifier:cellindertfer1];
        if (cell_addmenb == nil) {
            cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindertfer1];
        }
        EmployeeModel *employeeModel = [self.search_array objectAtIndex:indexPath.row];
        cell_addmenb.label_name.text = employeeModel.name;
        CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
        if (employeeModel.leaderType==1) {
            cell_addmenb.label_phonenumber.text=employeeModel.comman_orgName;
        }
        else{
            cell_addmenb.label_phonenumber.text = employeeModel.comman_orgName;
        }
        cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
        [cell_addmenb.imageView setImageWithURL:[NSURL URLWithString:employeeModel.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
        
        
        
        NSString  *imageName=@"people_not-select.png";
        if ([_addscrollMess.array_addcontact containsObject:employeeModel.phone]) {
            imageName=@"people_select.png";
        }
        if ([nav.phoneArray containsObject:employeeModel.phone]) {
            imageName=@"check_pre_contact.png";
        }
        NSString *selfNumber=[ConstantObject sharedConstant].userInfo.phone;
        if ([selfNumber isEqualToString:employeeModel.phone]) {
            imageName=@"check_pre_contact.png";
        }
        
        UIImageView *accessoryView=(UIImageView *)cell_addmenb.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
        cell = cell_addmenb;
        
    }
    else{
        CellAddMenb *cell_addmenb = [tableView dequeueReusableCellWithIdentifier:cellindertfer];
        if (cell_addmenb == nil) {
            cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellindertfer];
        }
        NSString *str=sectionTitleArray[indexPath.section];
        NSArray *memberArray=[_contact_MutDic objectForKey:str];
        
        EmployeeModel *employeeModel=[memberArray objectAtIndex:indexPath.row];
        
        if (employeeModel.type==2) {
            static NSString *cellIdentifier_1=@"AddgGroupCell";
            
            GroupCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
            
            if (group_cell == nil) {
                group_cell=[[[NSBundle mainBundle] loadNibNamed:@"GroupCell" owner:self options:nil] lastObject];
                
            }
            UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, 320, 0.5)];
            lineView.opaque             = YES;
            lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [group_cell addSubview:lineView];
            group_cell.label.text = employeeModel.name;;
            
            return group_cell;
        }
        
        //    if (cell_addmenb == nil) {
        //        cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        //    }
        
        cell_addmenb.label_name.text = employeeModel.name;
        CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
        
        if (employeeModel.leaderType==1) {
            cell_addmenb.label_phonenumber.text=employeeModel.title;
        }else{
            cell_addmenb.label_phonenumber.text = employeeModel.title;
        }
        cell_addmenb.label_phonenumber.frame = CGRectMake(cell_addmenb.label_name.frame.size.width + 95 + 10, 15, 100, 20);
        [cell_addmenb.imageView setImageWithURL:[NSURL URLWithString:employeeModel.avatarimgurl] placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
        
        
        //Cell的CheckBox
        //            NSString *str = [NSString stringWithFormat:@"%d",menber.ID];
        NSString  *imageName=@"people_not-select.png";
        if ([_addscrollMess.array_addcontact containsObject:employeeModel.phone]) {
            imageName=@"people_select.png";
        }
        //            NSArray *memberArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"add_group_member"];
        if ([nav.phoneArray containsObject:employeeModel.phone]) {
            imageName=@"check_pre_contact.png";
        }
        
        if ([employeeModel.phone isEqualToString:[ConstantObject sharedConstant].userInfo.phone]) {
            //自己
            imageName=@"check_pre_contact.png";
        }
        
        UIImageView *accessoryView=(UIImageView *)cell_addmenb.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
        
        cell = cell_addmenb;
        
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (tableView == tableViewSearch)
    {
        [searchBarContacts resignFirstResponder];
        EmployeeModel *currentObject=self.search_array[indexPath.row];
        //        (EmployeeModel *) currentObject = 0x030e323f
        //        (EmployeeModel *) currentObject = 0x030e323f
        NSString *selfNumber=[ConstantObject sharedConstant].userInfo.phone;
        NSString *str_phone = currentObject.phone;
        if ([selfNumber isEqualToString:str_phone]) {
            return;
        }
        if ([nav.phoneArray containsObject:str_phone]) {
            return;
        }
        NSString *key=[NSString stringWithFormat:@"%@",currentObject.phone];
        if ([_addscrollMess.array_addcontact containsObject:key]) {
            for (int i=0; i<_addscrollMess.allmenber.count; i++) {
                EmployeeModel *deleModel=[_addscrollMess.allmenber objectAtIndex:i];
                if ([deleModel.phone isEqualToString:currentObject.phone]) {
                    [_addscrollMess.allmenber removeObject:deleModel];
                }
            }
            //            [_addscrollMess.allmenber removeObject:currentObject];
            [_addscrollMess removeSubViewWithPhone:key FromScrollView:_addscrollMess.scrollView];
        }else{
            if (NO == [self canAddMenberToConf])
            {
                return;
            }
            [_addscrollMess addSubViewWithPhone:key withImageName:default_headImage ToScrollView:_addscrollMess.scrollView withUrl:[NSURL URLWithString:currentObject.avatarimgurl]];
            [_addscrollMess.allmenber addObject:currentObject];
            
        }
        //checkBox设置
        NSString  *imageName=@"people_not-select.png";
        if ([_addscrollMess.array_addcontact containsObject:key]) {
            imageName=@"people_select.png";
        }
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
        
        
    }
    else{
        EmployeeModel *employeeModel=_contact_MutDic[sectionTitleArray[indexPath.section]][indexPath.row];
        if (employeeModel.type==2) {
            addFromGroupVC * add = [[addFromGroupVC alloc]init];
            add.rootName = employeeModel.name;
            add.grou_ID = [employeeModel.orgId integerValue];
            [self.navigationController pushViewController:add animated:YES];
            
            return;
        }
        if ([nav.phoneArray containsObject:employeeModel.phone]) {
            return;
        }
        if ([employeeModel.phone isEqualToString:[ConstantObject sharedConstant].userInfo.phone]) {
            //选中了自己,什么也不做
            return;
        }
        NSString *key=[NSString stringWithFormat:@"%@",employeeModel.phone];
        if ([_addscrollMess.array_addcontact containsObject:key]) {
            [_addscrollMess.allmenber removeObject:employeeModel];
            [_addscrollMess removeSubViewWithPhone:key FromScrollView:_addscrollMess.scrollView];
        }else{
            if (NO == [self canAddMenberToConf])
            {
                return;
            }
            [_addscrollMess addSubViewWithPhone:key withImageName:@"public_default_avatar_80.png" ToScrollView:_addscrollMess.scrollView withUrl:[NSURL URLWithString:employeeModel.avatarimgurl]];
            [_addscrollMess.allmenber addObject:employeeModel];
        }
        //checkBox设置
        NSString  *imageName=@"people_not-select.png";
        if ([_addscrollMess.array_addcontact containsObject:key]) {
            imageName=@"people_select.png";
        }
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
    }
    [tableView reloadData];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = nil;
    if (tableView == tableViewSearch)
    {
        return nil;
    }
    else{
        UIButton *titleButt=[UIButton buttonWithType:UIButtonTypeCustom];
        [titleButt setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:1.000]];
        titleButt.titleLabel.textAlignment=NSTextAlignmentLeft;
        
        titleButt.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);
        [titleButt addTarget:self action:@selector(titleButtClick:) forControlEvents:UIControlEventTouchUpInside];
        titleButt.tag=tag_title_butt_start+section;
        
        UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(10, 0, titleButt.frame.size.width-100, 30)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        titleLabel.text=sectionTitleArray[section];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        [titleButt addSubview:titleLabel];
        
        UIImageView * btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(293, 12, 11, 6)];
        if (select[section]==NO) {
            btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
        }else{
            btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
        }
        [titleButt addSubview:btn_img];
        //线
        UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, titleButt.frame.size.height-0.5, titleButt.frame.size.width, 0.5)];
        lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];            [titleButt addSubview:lineView];
        return titleButt;
        
    }
    
    return view;
}
-(void)titleButtClick:(UIButton *)butt{
    int index=butt.tag-tag_title_butt_start;
    NSString *str=sectionTitleArray[index];
    if (select[index]) {
        [_contact_MutDic removeObjectForKey:str];
        select[index]=NO;
    }else{
        
        if ([str isEqualToString:commanName]) {
            NSArray * commanArray=[self getCommanData];
            //  [_contact_MutDic setValue:commanArray forKey:str];
        }else{
            NSString *org_id=[SqlAddressData getOrganiztionsBySection:str];
            //      通过自己所在部门的id，找到这个部门下所有的人以及这个部门下的部门
            NSArray *memberArray=[SqlAddressData getNewOrgPeopleByOrgId:org_id];
            [_contact_MutDic setValue:memberArray forKey:str];
        }
        
        select[index]=YES;
    }
    
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat flt = 0;
    
    if (tableView == tableViewSearch)
    {
        return 0;
    }
    else
    {
        flt = 30.0;
    }
    return flt;
}

-(NSArray*)getCommanData
{
    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    NSArray* commanArray= [SqlAddressData selectCommanContact:uid];
    return commanArray;
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
        
        viewSearchBG = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
        viewSearchBG.backgroundColor = [UIColor whiteColor];
        
        tableViewSearch = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height - 44) style:UITableViewStylePlain];
        tableViewSearch.delegate = self;
        tableViewSearch.dataSource = self;
        [tableViewSearch setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
        [viewSearchBG addSubview:tableViewSearch];
        
        [self.view addSubview:viewSearchBG];
        [self ContentForSearchText:searchString];
        
        if (_search_array.count == 0)
        {
            viewSearchBG_1 = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
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
    [_search_array removeAllObjects];
    [_search_array addObjectsFromArray:[SqlAddressData getNewContactWithRequirement:searchText]];
    
}
#pragma mark - =======================

//#pragma mark - UISearchDisplayController Delegate Methods
//
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    if (searchString.length>0) {
//        [self ContentForSearchText:searchString];
//    }
//
//    return YES;
//}
//
//-(void)ContentForSearchText:(NSString*)searchText{
//
//    if (_search_array==nil) {
//        _search_array=[NSMutableArray array];
//    }
//    [_search_array removeAllObjects];
//    //    [_search_array addObjectsFromArray:[SqlAddressData getContactWithRequirement:searchText]];
//    [_search_array addObjectsFromArray:[SqlAddressData getNewContactWithRequirement:searchText]];
//}
////
//////Change the title of cancel button in UISearchBar IOS7
//-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
//    //    if (IS_IOS_7)
//    //    {
//
//
//    // 7.0 系统的适配处理。
//    controller.searchBar.showsCancelButton = YES;
//    UIButton *cancelButton;
//    UIView *topView = controller.searchBar.subviews[0];
//    for (UIView *subView in topView.subviews) {
//        if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
//            cancelButton = (UIButton*)subView;
//        }
//    }
//    if (cancelButton) {
//        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//        [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
//        cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
//        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
//
//    //    }else{
//    //        controller.searchBar.showsCancelButton = YES;
//    //        for(UIView *subView in controller.searchBar.subviews)
//    //        {
//    //            if([subView isKindOfClass:[UIButton class]])
//    //            {
//    //                [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
//    //            }
//    //        }
//    //    }
//}
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    isSearch=YES;
//    searchBar.showsCancelButton = YES;
//    for (UIView *subView in searchBar.subviews) {
//        if ([subView isKindOfClass:[UIButton class]]) {
//            UIButton *cancelButton = (UIButton*)subView;
//            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//            [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
//            cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
//            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
//    }
//    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//
//}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//    //isSearch=NO;
//
//
//    //[self.tableView reloadData];
//
//}
//-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
//    [self.tableView reloadData];
//}

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

#pragma mark 电话会议
- (BOOL)canAddMenberToConf
{
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if ((nav.addScrollType == AddScrollTypeCreateConf|| nav.addScrollType == AddScrollTypeCreateConfFromGroup) && _addscrollMess.allmenber.count >= 7)
    {
        [self.view.window makeToast:@"为保证通话质量，最多支持8人" duration:3 position:@"center"];
        return NO;
    }
    
    return YES;
}

@end
