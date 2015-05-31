//
//  ContactsViewController.m
//  O了
//
//  Created by macmini on 14-01-08.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "AddFromContact.h"
#import "Contact.h"
#import "menber_info.h"
#import "MessageChatViewController.h"
#import "AFClient.h"
#import "SqliteDataDao.h"
#import "CellFirstThree.h"
#import "CellAddMenb.h"
#import "addMydepartController.h"
#import "addGrouppCell.h"
#import "addGroupCell.h"
#import "NSString+TransformPinyin.h"    

#import "UIImageView+WebCache.h"

#import "addFromGroupVC.h"
#define SEARCH_HEIGHT 40 //tableView头部高度
#define SCROLLVIEW_ICON_MARGIN 3    //scrollView的图标间距
#define SECTION_MAX_ROW 1000    //每组最大行数
#define ANIMATION_DURATION 0.2  //动画持续时间

#define tag_title_butt_start 1000 //头部butt的开始tag值

@interface AddFromContact ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    UIButton *_rightButt;
    NSMutableArray *sectionTitleArray;
    
    BOOL isSearch;///<是否是搜索状态
    
    UISearchBar *searchBarContacts;
    UISearchDisplayController *searchDisplayControllerContacts;
    UIView *viewTranslucentBG;
    UIButton *buttonTranslucent;
    UITableView *tableViewSearch;
    UIView *viewSearchBG;
    UIView *viewSearchBG_1;
    NSMutableArray * _array;
    NSString * search_text;///<搜索的关键字
    

}

@end

@implementation AddFromContact
@synthesize search_array = _search_array;
@synthesize contact_MutDic = _contact_MutDic;

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    //    self.title = NSLocalizedString(@"通讯录", @"通讯录");
        //        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"通讯录pre.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"通讯录.png"]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320, rect.size.height-44) style:UITableViewStylePlain];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    //右侧按钮
     NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
        
        self.title = @"电话会议";
    }
    
    _rightButt=[UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButt setTitle:@"关闭" forState:UIControlStateNormal];
    [_rightButt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightButt.titleLabel.font=[UIFont systemFontOfSize:16];
    //    [_rightButt setBackgroundImage:[UIImage imageNamed:@"top_right.png"] forState:UIControlStateNormal];
    //    [_rightButt setBackgroundImage:[UIImage imageNamed:@"top_right_pre.png"] forState:UIControlStateHighlighted];
    _rightButt.frame=CGRectMake(/*320-50-10*/0, (44-29)/2, 50, 29);
    [_rightButt addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    _addscrollMess = [addScrollView_messege sharedInstanse];
    if (IS_IOS_7) {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexColor = [UIColor grayColor];
    }else{
        [self initBackButton];
        [self initbarButton];
    }
    [self hideMoreLine];
    
    ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
    contactsCheck.contactsCheckDelegate = self;
    if(contactsCheck.executeStatus == 0){
        [contactsCheck execute];
    }else if(contactsCheck.executeStatus == 1){
        [self beginUpdate];
    }else{
        [self endUpdate:YES];
    }
    
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    
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

-(void)hideMoreLine
{
    UIView *hide_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    hide_line.backgroundColor = [UIColor whiteColor];
  //  [self.tableView setTableFooterView:hide_line];
}
-(void)initbarButton{
    UIImage *buttonImage = [[UIImage imageNamed:@"top_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    [self.navigationItem.rightBarButtonItem setBackgroundImage:buttonImage forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor],UITextAttributeTextColor,
                                                                     [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0],
                                                                     UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                                     UITextAttributeTextShadowOffset,[UIFont fontWithName:@"AmericanTypewriter" size:0.0], UITextAttributeFont,nil]
                                                          forState:UIControlStateNormal];
}

-(void)initBackButton{
    UIImage *buttonBack = [[UIImage imageNamed:@"nv_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    [self.navigationItem.backBarButtonItem setBackButtonBackgroundImage:buttonBack forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

#pragma mark 取消
- (void)cancel:(id)sender
{
    [[addScrollView_messege sharedInstanse] releaseInstanse];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)viewWillDidDisappear:(BOOL)animated{
    
    [_rightButt removeFromSuperview];
    _rightButt = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
     [self initData];
    _rightButt.hidden = NO;
    [self.navigationController.navigationBar addSubview:_rightButt];
    if (_addscrollMess.isSmsInvitation) {
        [self performSegueWithIdentifier:@"pushGroupaddressbook" sender:nil];
    }else{
        
        [self.tableView reloadData];
    }
   

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"add_from_group_vc_title"];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect barFrame = self.searchBar.frame;
    barFrame.size.width = self.view.bounds.size.width;
    self.searchBar.frame = barFrame;
}

-(void)initData{
    
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    NSString * str = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
    switch (nav.addScrollType) {
            
        case AddScrollTypeCreatGroup:
        {
            
            _firstThree=@[@[@"选择已有的群",@"address_icon_organization_s"],@[str,@"icon_group.png"]];
            break;
        }
        case AddScrollTypeSendMessage:
        {
            _firstThree=@[@[str,@"address_icon_organization_s"]];
            break;
        }
        case AddScrollTypeInvite:
        case AddScrollTypeRecv:
        case AddScrollTypeTask:
        case AddScrollTypeCC:
        case AddScrollTypeNomal:
        {
            _firstThree=@[@[@"选择已有的群",@"address_icon_organization_s"],@[str,@"icon_group.png"]];
            break;
        }
        case AddScrollTypeCreatGroupFromOneChat:
        {
            _firstThree=@[@[str,@"address_icon_organization_s"],@[str,@"address_icon_group.png"]];
            break;
        }
        case AddScrollTypeTransmit:
       
        {
            _firstThree=@[@[str,@"address_icon_organization_s"],@[@"选择一个群",@"address_icon_group.png"]];
            break;
        }
        case AddScrollTypeCreateConf:
        {
            _firstThree=@[@[@"选择已有的群",@"address_icon_organization_s"],@[str,@"icon_group.png"]];
            break;
        }
        case AddScrollTypeCreateConfFromGroup:
        {
            _firstThree=nil;
            break;
        }
        default:
            break;
    }
    
    
    if (!sectionTitleArray) {
        sectionTitleArray=[[NSMutableArray alloc] init];
    }
    [sectionTitleArray removeAllObjects];
    
    if (!_contact_MutDic) {
        _contact_MutDic=[[NSMutableDictionary alloc] init];
    }
    
    
    if (nav.addScrollType == AddScrollTypeCreateConfFromGroup)
    {
        RoomInfoModel *roomModel = [[SqliteDataDao sharedInstanse]getRoomInfoModelWithroomJid:nav.roomIdOfCreateConf];
        [sectionTitleArray addObject:roomModel.roomName];
 //       [_contact_MutDic setValue:roomModel.roomMemberList forKey:roomModel.roomName];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        NSMutableArray * KeyArray = [NSMutableArray array];
        for (int i = 0; i < roomModel.roomMemberList.count; i++) {

           NSString * str = [((EmployeeModel *)[roomModel.roomMemberList objectAtIndex:i]).first_name  uppercaseString];
            [dic setObject:[roomModel.roomMemberList objectAtIndex:i] forKey:str];
        }
        NSArray * a = [dic allKeys];
        self.sortarray4 = [a sortedArrayUsingSelector:@selector(compare:)];
        
        _array = [NSMutableArray arrayWithArray:roomModel.roomMemberList];
        NSArray * MembersArray = [NSArray arrayWithArray:_array];
        MembersArray = [self mycompare:MembersArray];
        NSMutableArray * temparray = [NSMutableArray arrayWithArray:MembersArray];
        self.sortAllMembersArray = [self sectionFromToPersons:temparray];
        
        
        select[0]=YES;
        
        return;
    }
    
    [sectionTitleArray addObjectsFromArray:[SqlAddressData selectOrgName]];
    NSArray * commanArray=[self getCommanData];
    
    BOOL isOne=NO;
    
    if (sectionTitleArray.count==1) {
        isOne=YES;
        
    }
    
    if (commanArray.count>0) {
        [sectionTitleArray insertObject:commanName atIndex:0];
        
        NSArray * commanArray=[self getCommanData];
        [_contact_MutDic setValue:commanArray forKey:[sectionTitleArray objectAtIndex:0]];
        select[0]=YES;
        if (isOne) {
            NSString *org_id=[SqlAddressData getOrganiztionsBySection:[sectionTitleArray objectAtIndex:1]];
            //      通过自己所在部门的id，找到这个部门下所有的人以及这个部门下的部门
            //            NSArray *memberArray=[SqlAddressData getOrgPeopleByOrgId:org_id];
            
            NSArray *memberArray=[SqlAddressData getNewOrgPeopleByOrgId:org_id];
            
            [_contact_MutDic setValue:memberArray forKey:[sectionTitleArray objectAtIndex:1]];
            select[1]=YES;
            
        }
        
    }else{
        if (isOne) {
            NSString *org_id=[SqlAddressData getOrganiztionsBySection:[sectionTitleArray objectAtIndex:0]];
            //      通过自己所在部门的id，找到这个部门下所有的人以及这个部门下的部门
            //            NSArray *memberArray=[SqlAddressData getOrgPeopleByOrgId:org_id];
            NSArray *memberArray=[SqlAddressData getNewOrgPeopleByOrgId:org_id];
            
            [_contact_shoucang setValue:memberArray forKey:[sectionTitleArray objectAtIndex:0]];
            
            select[0]=YES;
        }
    }
    
}

- (NSArray *)mycompare:(NSArray *)array
{
    NSMutableArray * mutableArray = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        EmployeeModel * model = (EmployeeModel *)[array objectAtIndex:i];
        NSString * firstName = model.pinyin_name;
        [mutableArray addObject:firstName];
    }
    mutableArray = [NSMutableArray arrayWithArray:[mutableArray sortedArrayUsingSelector:@selector(compare:)]];
    NSMutableArray * membersArray = [NSMutableArray arrayWithArray:_array];
    NSMutableArray * array22 = [NSMutableArray array];
    for (int i = 0; i < mutableArray.count; i++) {
        for (int j = 0; j < membersArray.count; j++) {
            if ([((EmployeeModel *)[membersArray objectAtIndex:j]).pinyin_name isEqualToString:[mutableArray objectAtIndex:i]]) {
                [array22 addObject:[membersArray objectAtIndex:j]];
            }
        }
    }
    
    return array22 ;
    
}

- (NSMutableArray *) sectionFromToPersons:(NSMutableArray *)array {
    
    NSMutableArray * allArray = [NSMutableArray array];
    
    for (int j = 0; j < self.sortarray4.count; j++) {
        
        NSMutableArray * arrayTemp = [NSMutableArray array];
        
        NSString * str = [self.sortarray4 objectAtIndex:j];
        
        for (int i = 0;i < array.count; i++) {
            
            NSString * userName = ((EmployeeModel *)[array objectAtIndex:i]).first_name;
            if (userName.length && userName.length>0) {
                if ([userName  caseInsensitiveCompare:str] == NSOrderedSame  ) {
                    [arrayTemp addObject:[array objectAtIndex:i]];
                }
            }
        }
        [allArray addObject:arrayTemp];
        
    }
    //  [allArray addObject:array];
    
    return allArray;
}
-(NSArray*)getCommanData
{
    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    NSArray* commanArray= [SqlAddressData selectCommanContact:uid];
    return commanArray;
}
-(NSMutableArray *)sortAllMembersArray{
    if (_sortAllMembersArray == nil) {
        self.sortAllMembersArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _sortAllMembersArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    addFromGroupVC *addfrom = segue.destinationViewController;
    
    NSDictionary *dict=[SqlAddressData getRootOrganiztions];
    NSString *rootName=dict[@"organiztion_name"];
    addfrom.rootName=rootName;
    addfrom.grou_ID = [dict[@"organiztion_tag"] integerValue];
    
    if (sender && [sender isKindOfClass:[EmployeeModel class]]) {
        EmployeeModel *em=(EmployeeModel *)sender;
        addfrom.grou_ID=[em.orgId integerValue];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberofSection = 0;
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
        if (nav.addScrollType == AddScrollTypeCreatGroup) {
            if (tableView == tableViewSearch)
            {
                numberofSection = 1;
            }
            else{
            NSArray * array = [NSArray array];
            array = [self getCommanData];
            if (array.count > 0) {
                numberofSection = 3;
            }
            else {
                numberofSection = 2;
            }
                   }
        }
        else if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
                if (tableView == tableViewSearch)
                {
                    numberofSection = 1;
                }
                else{
                numberofSection = self.sortarray4.count;
                }
            }
        else{
            if (tableView == tableViewSearch)
            {
                numberofSection = 1;
            }
            else{
            NSArray * array = [NSArray array];
            array = [self getCommanData];
            if (array.count > 0) {
                numberofSection = 2;
            }
            else {
                numberofSection = 1;
            }
            }
        }


    return numberofSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberofRow = 0;
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (nav.addScrollType == AddScrollTypeCreatGroup) {
        if (tableView == tableViewSearch)
        {
            numberofRow = self.search_array.count;
        }
        else
        {
            if (section==0) {
                return 1;
            }
            else if (section == 1){
                return 2;
            }
            else if(section ==2){
                NSString *str=sectionTitleArray[section-2];
                NSArray *memberArray=[_contact_MutDic objectForKey:str];
                numberofRow=memberArray.count;
                DDLogInfo(@"%d",numberofRow);
                
            }
        }

    }
    if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
        if (tableView == tableViewSearch)
        {
            numberofRow = self.search_array.count;
        }
        else{
//        NSString *str=sectionTitleArray[section];
//        NSArray *memberArray=[_contact_MutDic objectForKey:str];
//        numberofRow=memberArray.count;
            numberofRow =[[self.sortAllMembersArray objectAtIndex:section] count];
        }
    }
    else{
        if (tableView == tableViewSearch)
        {
          numberofRow = self.search_array.count;
        }
        else
    {
       
        if (section == 0){
            return 2;
        }
        else if(section ==1){
            NSString *str=sectionTitleArray[section-1];
            NSArray *memberArray=[_contact_MutDic objectForKey:str];
            numberofRow=memberArray.count;
            DDLogInfo(@"%d",numberofRow);
            
        }
    }
    }
    return numberofRow;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
     NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (nav.addScrollType == AddScrollTypeCreatGroup) {
        if (tableView == tableViewSearch)
        {
            return nil;
        }
        else{
            if (section == 0) {
                UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
                titleLabel.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
                UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,9.5, 320, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleLabel addSubview:_lineView];
                UIView * _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 0.5)];
                _lineView1.opaque             = YES;
                _lineView1.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleLabel addSubview:_lineView1];
                titleLabel.textAlignment=NSTextAlignmentLeft;
                return titleLabel;
                
            }
            if (section == 1) {
                UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
                titleLabel.tag = 1000000;
                titleLabel.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
                UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,9.5, 320, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleLabel addSubview:_lineView];
                UIView * _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 0.5)];
                _lineView1.opaque             = YES;
                _lineView1.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleLabel addSubview:_lineView1];
                titleLabel.textAlignment=NSTextAlignmentLeft;
                return titleLabel;

            }
            
        }

    }
    if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
        if (tableView == tableViewSearch)
        {
            
        }
        return nil;
    }
    else {
        if (tableView == tableViewSearch)
        {
            return nil;
        }
        else {
            UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
            titleLabel.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
            UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,9.5, 320, 0.5)];
            _lineView.opaque             = YES;
            _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [titleLabel addSubview:_lineView];
            titleLabel.textAlignment=NSTextAlignmentLeft;
            return titleLabel;
            
        }

    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = nil;
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (nav.addScrollType == AddScrollTypeCreatGroup) {
        if (tableView == tableViewSearch)
        {
            return nil;
        }
        else
        {
            if (section==0) {
                UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
                titleLabel.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
                UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,9.5, 320, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleLabel addSubview:_lineView];
                titleLabel.textAlignment=NSTextAlignmentLeft;
                return titleLabel;
                
            }
            else{
                if(section == 1){
                    
                    
                    
                    UIButton *titleButt=[UIButton buttonWithType:UIButtonTypeCustom];
                    [titleButt setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:1.000]];
                    titleButt.titleLabel.textAlignment= NSTextAlignmentLeft;
                    titleButt.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
                    titleButt.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);
                    //  [titleButt addTarget:self action:@selector(titleButtClick:) forControlEvents:UIControlEventTouchUpInside];
                    //      titleButt.tag=tag_title_butt_start+section-1;
                    
                    UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(10, 0, titleButt.frame.size.width-100, 30)];
                    NSString * str = @"企业通讯录";
                    titleLabel.text= str;
                    titleLabel.font = [UIFont systemFontOfSize:12];
                    titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                    titleLabel.textAlignment=NSTextAlignmentLeft;
                    [titleButt addSubview:titleLabel];
                    
                    UIImageView * btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(293, 13, 11, 6)];
                    if (select[section-1]==NO) {
                        btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
                    }else{
                        btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
                    }
                    //      [titleButt addSubview:btn_img];
                    //线
                    UIView *footlineView=[[UIView alloc] initWithFrame:CGRectMake(0, titleButt.frame.size.height-0.5, titleButt.frame.size.width, 0.5)];
                    footlineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                    [titleButt addSubview:footlineView];
                    UIView *headline=[[UIView alloc] initWithFrame:CGRectMake(0,0, titleButt.frame.size.width, 0.5)];
                    headline.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                    [titleButt addSubview:headline];
                    return titleButt;
                }
                if(section == 2) {
                    UIButton *titleButt=[UIButton buttonWithType:UIButtonTypeCustom];
                    [titleButt setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]];
                    titleButt.titleLabel.textAlignment=NSTextAlignmentLeft;
                    
                    titleButt.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);
                    [titleButt addTarget:self action:@selector(titleButtClick:) forControlEvents:UIControlEventTouchUpInside];
                    titleButt.tag=tag_title_butt_start+section-2;
                    
                    UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(10, 0, titleButt.frame.size.width-100, 30)];
                    titleLabel.font = [UIFont systemFontOfSize:12];
                    titleLabel.text=@"我的收藏";
                    NSArray *memberArray=[_contact_MutDic objectForKey:titleLabel.text];
                    titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                    titleLabel.textAlignment=NSTextAlignmentLeft;
                    [titleButt addSubview:titleLabel];
                    
                    UIImageView * btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(293, 13, 11, 6)];
                    if (select[section-2]==NO) {
                        btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
                    }else{
                        btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
                    }
                    [titleButt addSubview:btn_img];
                    //线
                    UIView *footlineView=[[UIView alloc] initWithFrame:CGRectMake(0, titleButt.frame.size.height-0.5, titleButt.frame.size.width, 0.5)];
                    footlineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                    [titleButt addSubview:footlineView];
                    UIView *headline=[[UIView alloc] initWithFrame:CGRectMake(0,0, titleButt.frame.size.width, 0.5)];
                    headline.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                    [titleButt addSubview:headline];
                    return titleButt;
                    
                }
            }
        }

    }
    else if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
        if (tableView == tableViewSearch)
        {
            return nil;
        }
        {
            UIButton *titleButt=[UIButton buttonWithType:UIButtonTypeCustom];
            [titleButt setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]];
            titleButt.titleLabel.textAlignment=NSTextAlignmentLeft;
            
            titleButt.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);
          //  [titleButt addTarget:self action:@selector(titleButtClick:) forControlEvents:UIControlEventTouchUpInside];
            titleButt.tag=tag_title_butt_start+section;
            
            UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(10, 0, titleButt.frame.size.width-100, 30)];
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.text=[self.sortarray4[section] uppercaseString];
            titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            titleLabel.textAlignment=NSTextAlignmentLeft;
            [titleButt addSubview:titleLabel];
            
            UIImageView * btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(293, 13, 11, 6)];
            if (select[section]==NO) {
                btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
            }else{
                btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
            }
        //    [titleButt addSubview:btn_img];
            //线
            UIView *footlineView=[[UIView alloc] initWithFrame:CGRectMake(0, titleButt.frame.size.height-0.5, titleButt.frame.size.width, 0.5)];
            footlineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
         //   [titleButt addSubview:footlineView];
            UIView *headline=[[UIView alloc] initWithFrame:CGRectMake(0,0, titleButt.frame.size.width, 0.5)];
            headline.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
         //   [titleButt addSubview:headline];
            return titleButt;
            
        }

    }
    else {
        if (tableView == tableViewSearch)
        {
            return nil;
        }
    else
    {
       
            if(section == 0){
                UIButton *titleButt=[UIButton buttonWithType:UIButtonTypeCustom];
                [titleButt setBackgroundColor:[UIColor colorWithWhite:0.902 alpha:1.000]];
                titleButt.titleLabel.textAlignment= NSTextAlignmentLeft;
                titleButt.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
                titleButt.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);
                //  [titleButt addTarget:self action:@selector(titleButtClick:) forControlEvents:UIControlEventTouchUpInside];
                //      titleButt.tag=tag_title_butt_start+section-1;
                
                UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(10, 0, titleButt.frame.size.width-100, 30)];
                titleLabel.text=@"企业通讯录";
                titleLabel.font = [UIFont systemFontOfSize:12];
                titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                titleLabel.textAlignment=NSTextAlignmentLeft;
                [titleButt addSubview:titleLabel];
                
                UIImageView * btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(293, 13, 11, 6)];
                if (select[section]==NO) {
                    btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
                }else{
                    btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
                }
                //      [titleButt addSubview:btn_img];
                //线
                UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, titleButt.frame.size.height-0.5, titleButt.frame.size.width, 0.5)];
                lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleButt addSubview:lineView];
                return titleButt;
            }
            if(section == 1) {
                UIButton *titleButt=[UIButton buttonWithType:UIButtonTypeCustom];
                [titleButt setBackgroundColor:[UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0]];
                titleButt.titleLabel.textAlignment=NSTextAlignmentLeft;
                
                titleButt.frame=CGRectMake(0, 0, tableView.frame.size.width, 30);
                [titleButt addTarget:self action:@selector(titleButtClick:) forControlEvents:UIControlEventTouchUpInside];
                titleButt.tag=tag_title_butt_start+section-1;
                
                UIMyLabel *titleLabel=[[UIMyLabel alloc] initWithFrame:CGRectMake(10, 0, titleButt.frame.size.width-100, 30)];
                titleLabel.font = [UIFont systemFontOfSize:12];
                //               titleLabel.text=sectionTitleArray[section-1];
                titleLabel.text = @"我的收藏";
                titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                titleLabel.textAlignment=NSTextAlignmentLeft;
                [titleButt addSubview:titleLabel];
                
                UIImageView * btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(293, 13, 11, 6)];
                if (select[section-1]==NO) {
                    btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
                }else{
                    btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
                }
                [titleButt addSubview:btn_img];
                //线
                UIView *footlineView=[[UIView alloc] initWithFrame:CGRectMake(0, titleButt.frame.size.height-0.5, titleButt.frame.size.width, 0.5)];
                footlineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleButt addSubview:footlineView];
                UIView *headline=[[UIView alloc] initWithFrame:CGRectMake(0,0, titleButt.frame.size.width, 0.5)];
                headline.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [titleButt addSubview:headline];
                return titleButt;
                
            }
                    
    }
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat flt = 0;
     NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (nav.addScrollType == AddScrollTypeCreatGroup) {
        if (tableView == tableViewSearch)
        {
            return 0;
        }
    else
        {
            if (section == 0) {
                flt = 10.0;
            }else{
                flt = 30.0;
            }
        }

    }
    else {
        if (tableView == tableViewSearch)
        {
            return 0;
        }
        else
    {
        flt = 30;
    }
    }
    return flt;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    CGFloat flt = 0;
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;

    if(nav.addScrollType == AddScrollTypeCreatGroup){
        if (tableView == tableViewSearch)
        {
            return 0;
        }
    else
    {
        if (section == 0) {
            flt = 10;
        }
        else if (section == 1){
            flt = 10;
        }
    }
    }
   else if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
        if (tableView == tableViewSearch)
        {
            return 0;
        }
        else{
        flt = 0;
        }
    }
    else{
        if (tableView == tableViewSearch)
        {
            return 0;
        }
        else
        {
        if (section == 0) {
            flt = 10.0;
        }
            
        }
    }
    
    return flt;


}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    static NSString *CellIdentifier1 = @"Cell1";
    
    CellAddMenb *cell_addmenb = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    
    if (nav.addScrollType == AddScrollTypeCreatGroup){
        if (tableView == tableViewSearch)
        {
            [tableViewSearch setSeparatorColor:[UIColor clearColor]];
            if (cell_addmenb == nil) {
                cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            }
            
            EmployeeModel *employeeModel = [self.search_array objectAtIndex:indexPath.row];
            cell_addmenb.label_name.text = employeeModel.name;
            CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
            cell_addmenb.label_name.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
            if (employeeModel.leaderType==1) {
                cell_addmenb.label_phonenumber.text=employeeModel.comman_orgName;
            }else{
                cell_addmenb.label_phonenumber.text = employeeModel.comman_orgName;
            }
            cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
            [cell_addmenb.imageView setImageWithURL:[NSURL URLWithString:employeeModel.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
            
            //Cell的CheckBox
           
            
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
        else
        {
            if (indexPath.section == 0) {
                static NSString *cellIdentifier_1=@"AddgGroupCell";
                
                addGroupCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
                
                if (group_cell == nil) {
                    group_cell=[[[NSBundle mainBundle] loadNibNamed:@"addGroupCell" owner:self options:nil] lastObject];
                    
                }
                
                group_cell.label.text = _firstThree[indexPath.row][0];
                UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [group_cell.contentView addSubview:_lineView];
                
                UIView * _lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, 320, 0.5)];
                _lineView1.opaque             = YES;
                _lineView1.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [group_cell.contentView addSubview:_lineView1];
                return group_cell;
            }
            else if(indexPath.section == 1){
                if(indexPath.row == 0){
                    static NSString *cellIdentifier_2=@"AddgGroupCell1";
                    addGrouppCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
                    
                    if (group_cell == nil) {
                        NSArray * array =[[NSBundle mainBundle] loadNibNamed:@"addGrouppCell" owner:self options:nil];
                        group_cell = [array firstObject];
                        
                    }
                    group_cell.image1.layer.masksToBounds = YES;
                    group_cell.image1.layer.cornerRadius = group_cell.image1.frame.size.width * 0.5;
                    group_cell.image1.image=[UIImage imageNamed:@"icon_organization.png"];
                    group_cell.label.text = _firstThree[indexPath.row + 1][0];
                    UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(65, 49.5, 320, 0.5)];
                    _lineView.opaque             = YES;
                    _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                    [group_cell.contentView addSubview:_lineView];
                    
                    return group_cell;
                    
                }
                else if (indexPath.row == 1){
                    NSMutableArray * array =[NSMutableArray arrayWithArray:[SqlAddressData selectOrgName]];
                    NSString * str1111 = [array objectAtIndex:0];
                    str1111 = [str1111 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    DDLogInfo(@"%d",array.count);
                    if (array.count > 1) {
                        for (int i = 1; i < array.count;i++ ) {
                            str1111 = [str1111 stringByAppendingString:[NSString stringWithFormat:@"\\%@",[array objectAtIndex:i]]];
                        }

                    }
                    static NSString *cellIdentifier_2=@"AddgGroupCell1";
                    addGrouppCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
                    
                    if (group_cell == nil) {
                        group_cell=[[[NSBundle mainBundle] loadNibNamed:@"addGrouppCell" owner:self options:nil] lastObject];
                        
                    }
                    group_cell.image1.layer.masksToBounds = YES;
                    group_cell.image1.layer.cornerRadius = group_cell.image1.layer.cornerRadius = group_cell.image1.frame.size.width * 0.5;
                    group_cell.image1.image=[UIImage imageNamed:@"icon_department.png"];
                    group_cell.label.text = str1111;
                    group_cell.label1.text = @"我的部门";
                    UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, 320, 0.5)];
                    _lineView.opaque             = YES;
                    _lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                    [group_cell.contentView addSubview:_lineView];
                    return group_cell;
                    
                    
                }
            }
            else if (indexPath.section == 2){
                NSString *str=sectionTitleArray[indexPath.section-2];
                NSArray *memberArray=[_contact_MutDic objectForKey:str];
                EmployeeModel *employeeModel=[memberArray objectAtIndex:indexPath.row];
                
                if (employeeModel.type==2) {
                    static NSString *cellIdentifier_1=@"AddgGroupCell";
                    
                    AddgGroupCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
                    
                    if (group_cell == nil) {
                        group_cell=[[[NSBundle mainBundle] loadNibNamed:@"AddgGroupCell" owner:self options:nil] lastObject];
                        
                    }
                    group_cell.headImageView.layer.masksToBounds = YES;
                    group_cell.headImageView.layer.cornerRadius =  group_cell.headImageView.layer.cornerRadius = group_cell.headImageView.frame.size.width * 0.5;
                    group_cell.headImageView.image=[UIImage imageNamed:@"icon_group_50"];
                    group_cell.nameLabel.text = employeeModel.name;;
                    
                    cell = group_cell;
                }
                
                if (cell_addmenb == nil) {
                    cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
                }
                cell_addmenb.label_name.text = employeeModel.name;
                CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
                if (size.width > 80) {
                    size.width = 80;
                }
                cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
                if (employeeModel.leaderType==1) {
                    cell_addmenb.label_phonenumber.text=employeeModel.comman_orgName;
                }else{
                    cell_addmenb.label_phonenumber.text = employeeModel.comman_orgName;
                }
                
                cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
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
            
            
        }
        
    }
    if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
        if (tableView == tableViewSearch)
        {
            [tableViewSearch setSeparatorColor:[UIColor clearColor]];
            if (cell_addmenb == nil) {
                cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            }
            
            EmployeeModel *employeeModel = [self.search_array objectAtIndex:indexPath.row];
            cell_addmenb.label_name.text = employeeModel.name;
            CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
            cell_addmenb.label_name.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
            if (employeeModel.leaderType==1) {
                cell_addmenb.label_phonenumber.text=employeeModel.comman_orgName;
            }else{
                cell_addmenb.label_phonenumber.text = employeeModel.comman_orgName;
            }
            cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
            [cell_addmenb.imageView setImageWithURL:[NSURL URLWithString:employeeModel.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
            
            //Cell的CheckBox
            
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
        else {
            
//                NSString *str=sectionTitleArray[indexPath.section];
//                NSArray *memberArray=[_contact_MutDic objectForKey:str];
            //群成员排序不需要加线
            [cell_addmenb.lineView removeFromSuperview];
                EmployeeModel *employeeModel=[[self.sortAllMembersArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                
                if (employeeModel.type==2) {
                    static NSString *cellIdentifier_1=@"AddgGroupCell";
                    
                    AddgGroupCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
                    
                    if (group_cell == nil) {
                        group_cell=[[[NSBundle mainBundle] loadNibNamed:@"AddgGroupCell" owner:self options:nil] lastObject];
                        
                    }
                    group_cell.headImageView.layer.masksToBounds = YES;
                    group_cell.headImageView.layer.cornerRadius =  group_cell.headImageView.layer.cornerRadius = group_cell.headImageView.frame.size.width * 0.5;
                    group_cell.headImageView.image=[UIImage imageNamed:@"icon_group_50"];
                    group_cell.nameLabel.text = employeeModel.name;;
                    
                    return group_cell;
                }
                
                if (cell_addmenb == nil) {
                    cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
                }
                
                cell_addmenb.label_name.text = employeeModel.name;
                CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
                if (size.width > 80) {
                    size.width = 80;
                }
                cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
                if (employeeModel.leaderType==1) {
                    cell_addmenb.label_phonenumber.text=employeeModel.title;
                }else{
                    cell_addmenb.label_phonenumber.text = employeeModel.title;
                }
                
                cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
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
    }
    else{
        if (tableView == tableViewSearch)
        {
            [tableViewSearch setSeparatorColor:[UIColor clearColor]];
            if (cell_addmenb == nil) {
                cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            }
            
            EmployeeModel *employeeModel = [self.search_array objectAtIndex:indexPath.row];
            cell_addmenb.label_name.text = employeeModel.name;
            CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            if (size.width > 80) {
                size.width = 80;
            }
            cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
            cell_addmenb.label_name.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
            if (employeeModel.leaderType==1) {
                cell_addmenb.label_phonenumber.text=employeeModel.comman_orgName;
            }else{
                cell_addmenb.label_phonenumber.text = employeeModel.comman_orgName;
            }
            cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
            [cell_addmenb.imageView setImageWithURL:[NSURL URLWithString:employeeModel.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
            
            //Cell的CheckBox
            
            NSString  *imageName=@"people_not-select.png";
            NSString *selfNumber=[ConstantObject sharedConstant].userInfo.phone;
           
            if (nav.addScrollType == AddScrollTypeRecv || nav.addScrollType == AddScrollTypeCC) {
            if ([selfNumber isEqualToString:employeeModel.phone]) {
                imageName=@"people_not-select.png";
            }
                }
            else
            {
                if ([selfNumber isEqualToString:employeeModel.phone]) {
                    imageName=@"check_pre_contact.png";
                }
            }
            if ([_addscrollMess.array_addcontact containsObject:employeeModel.phone]) {
                imageName=@"people_select.png";
            }
            if ([nav.phoneArray containsObject:employeeModel.phone]) {
                imageName=@"check_pre_contact.png";
            }
   
            
            UIImageView *accessoryView=(UIImageView *)cell_addmenb.accessoryView;
            accessoryView.image=[UIImage imageNamed:imageName];
            
            cell = cell_addmenb;
        }
    else
    {     if(indexPath.section == 0){
            if(indexPath.row == 0){
                static NSString *cellIdentifier_2=@"AddgGroupCell1";
                addGrouppCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
                
                if (group_cell == nil) {
                    NSArray * array =[[NSBundle mainBundle] loadNibNamed:@"addGrouppCell" owner:self options:nil];
                    group_cell = [array firstObject];
                    
                }
                group_cell.image1.layer.masksToBounds = YES;
                group_cell.image1.layer.cornerRadius = group_cell.image1.frame.size.width * 0.5;
                group_cell.image1.image=[UIImage imageNamed:@"icon_organization.png"];
                group_cell.label.text = _firstThree[indexPath.row + 1][0];
                NSLog(@"-----------------------%@",group_cell.label.text);
                UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(65, 49.5, 320, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    =[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [group_cell.contentView addSubview:_lineView];
                
                return group_cell;
                
            }
            else if (indexPath.row == 1){
                NSMutableArray * array =[NSMutableArray arrayWithArray:[SqlAddressData selectOrgName]];
                NSString * str1111 = [array objectAtIndex:0];
                DDLogInfo(@"%d",array.count);
                if (array.count > 1) {
                    for (int i = 1; i < array.count;i++ ) {
                        str1111 = [str1111 stringByAppendingString:[NSString stringWithFormat:@"\\%@",[array objectAtIndex:i]]];
                    }
                }
                static NSString *cellIdentifier_2=@"AddgGroupCell1";
                addGrouppCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_2];
                
                if (group_cell == nil) {
                    group_cell=[[[NSBundle mainBundle] loadNibNamed:@"addGrouppCell" owner:self options:nil] lastObject];
                    
                }
                group_cell.image1.layer.masksToBounds = YES;
                group_cell.image1.layer.cornerRadius = group_cell.image1.layer.cornerRadius = group_cell.image1.frame.size.width * 0.5;
                group_cell.image1.image=[UIImage imageNamed:@"icon_department.png"];
                group_cell.label.text = str1111;
                group_cell.label1.text = @"我的部门";
                UIView * _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, 320, 0.5)];
                _lineView.opaque             = YES;
                _lineView.backgroundColor    =[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
                [group_cell.contentView addSubview:_lineView];
                return group_cell;
                
                
            }
        }
        else if (indexPath.section == 1){
            NSString *str=sectionTitleArray[indexPath.section-1];
            NSArray *memberArray=[_contact_MutDic objectForKey:str];
            
            EmployeeModel *employeeModel=[memberArray objectAtIndex:indexPath.row];
            
            if (employeeModel.type==2) {
                static NSString *cellIdentifier_1=@"AddgGroupCell";
                
                AddgGroupCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
                
                if (group_cell == nil) {
                    group_cell=[[[NSBundle mainBundle] loadNibNamed:@"AddgGroupCell" owner:self options:nil] lastObject];
                    
                }
                group_cell.headImageView.layer.masksToBounds = YES;
                group_cell.headImageView.layer.cornerRadius =  group_cell.headImageView.layer.cornerRadius = group_cell.headImageView.frame.size.width * 0.5;
                group_cell.headImageView.image=[UIImage imageNamed:@"icon_group_50"];
                group_cell.nameLabel.text = employeeModel.name;;
                
                return group_cell;
            }
            
            if (cell_addmenb == nil) {
                cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
            }
            
            cell_addmenb.label_name.text = employeeModel.name;
            CGSize size=[employeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            if (size.width > 80) {
                size.width = 80;
            }
            cell_addmenb.label_name.frame = CGRectMake(95,15, size.width, 20);
            if (employeeModel.leaderType==1) {
                cell_addmenb.label_phonenumber.text=employeeModel.comman_orgName;
            }else{
                cell_addmenb.label_phonenumber.text = employeeModel.comman_orgName;
            }
            
            cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 12, 15, 100, 20);
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
        
        
    }
    }
    return cell;
}

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (nav.addScrollType == AddScrollTypeCreatGroup) {
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
            if (indexPath.section == 0) {
                
                if (indexPath.row == 0) {
                    QunLiaoListViewController *qunVC=[[QunLiaoListViewController alloc] init];
                    qunVC.isFromMultiple=YES;
                    _rightButt.hidden = YES;
                    [self.navigationController pushViewController:qunVC animated:YES];
                    //                [self performSegueWithIdentifier:@"pushGroupaddressbook" sender:nil];
                }else if (indexPath.row==1){
                    QunLiaoListViewController *qunVC=[[QunLiaoListViewController alloc] init];
                    qunVC.isFromMultiple=YES;
                    [self.navigationController pushViewController:qunVC animated:YES];
                }
                
            }
            else if(indexPath.section == 1){
                EmployeeModel *employeeModel=_contact_shoucang[sectionTitleArray[indexPath.section -1 ]][indexPath.row];
                if (indexPath.row == 0) {
                    addFromGroupVC * add = [[addFromGroupVC alloc]init];
                    //把公司名称传进去,不然数据会错乱
                    add.rootName = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
                    [_rightButt removeFromSuperview];
                    [self.navigationController pushViewController:add animated:YES];
                    
                //    [self performSegueWithIdentifier:@"pushGroupaddressbook" sender:nil];
                    
                }
                else if (indexPath.row == 1){
                    addMydepartController * add = [[addMydepartController alloc]init];
                    [_rightButt removeFromSuperview];
                    [self.navigationController pushViewController:add animated:YES];
                }
            }
            else if (indexPath.section == 2){
                
                EmployeeModel *employeeModel=_contact_MutDic[sectionTitleArray[indexPath.section-2]][indexPath.row];
                if (employeeModel.type==2) {
                    [self performSegueWithIdentifier:@"pushGroupaddressbook" sender:employeeModel];
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
                    [_addscrollMess addSubViewWithPhone:key withImageName:@"public_default_avatar_80.png" ToScrollView:_addscrollMess.scrollView withUrl:[NSURL URLWithString:employeeModel.avatarimgurl]];
                    [_addscrollMess.allmenber addObject:employeeModel];
                }
                //checkBox设置
                NSString  *imageName=@"people_not-select.png";
                if ([_addscrollMess.array_addcontact containsObject:key]) {
                    imageName=@"people_select@2x.png";
                }
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
                accessoryView.image=[UIImage imageNamed:imageName];
            }
        }
        
}
   else if (nav.addScrollType == AddScrollTypeCreateConfFromGroup) {
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
        else {
            EmployeeModel *employeeModel=[[self.sortAllMembersArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if (employeeModel.type==2) {
                [self performSegueWithIdentifier:@"pushGroupaddressbook" sender:employeeModel];
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
       
   }
    else {
        if (tableView == tableViewSearch)
        {
            [searchBarContacts resignFirstResponder];
        EmployeeModel *currentObject=self.search_array[indexPath.row];
        //        (EmployeeModel *) currentObject = 0x030e323f
        //        (EmployeeModel *) currentObject = 0x030e323f
        NSString *selfNumber=[ConstantObject sharedConstant].userInfo.phone;
        NSString *str_phone = currentObject.phone;
            if (nav.addScrollType == AddScrollTypeTask || nav.addScrollType == AddScrollTypeInvite || nav.addScrollType == AddScrollTypeCreateConf ) {
                if ([selfNumber isEqualToString:str_phone]) {
                    return;
                }
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
       if(indexPath.section == 0){
            EmployeeModel *employeeModel=_contact_shoucang[sectionTitleArray[indexPath.section ]][indexPath.row];
            if (indexPath.row == 0) {
                addFromGroupVC * add = [[addFromGroupVC alloc]init];
                add.rootName = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
                _rightButt.hidden = YES;
                [self.navigationController pushViewController:add animated:YES];
             //   [self performSegueWithIdentifier:@"pushGroupaddressbook" sender:nil];
                
            }
            else if (indexPath.row == 1){
                addMydepartController * add = [[addMydepartController alloc]init];
                _rightButt.hidden = YES;
                [self.navigationController pushViewController:add animated:YES];
                
            }
            
        }
           else if (indexPath.section == 1){
            
            EmployeeModel *employeeModel=_contact_MutDic[sectionTitleArray[indexPath.section-1]][indexPath.row];
            if (employeeModel.type==2) {
                addFromGroupVC * add = [[addFromGroupVC alloc]init];
                _rightButt.hidden = YES;
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
    }
    }
    [tableView reloadData];
    
}

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
//    //[self.tableView reloadData];
//    
//}
//-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
//    [self.tableView reloadData];
//}

#pragma mark - =====搜索功能实现方法=====
- (void)iemcBarButtonItemAction:(id)sender
{
    searchBarContacts = [[UISearchBar alloc] init];
    if (IS_IOS_8)
    {
        UIMyLabel * label = [self.view viewWithTag:1000000];
        label.hidden = YES;
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
    
    viewTranslucentBG = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height )];
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

#pragma mark - 区头点击
-(void)titleButtClick:(UIButton *)butt{
    int index=butt.tag-tag_title_butt_start;
    NSString *str=sectionTitleArray[index];
    if (select[index]) {
        [_contact_MutDic removeObjectForKey:str];
        select[index]=NO;
    }else{
        
        if ([str isEqualToString:commanName]) {
            NSArray * commanArray=[self getCommanData];
            [_contact_MutDic setValue:commanArray forKey:str];
        }
        else
        {
            NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
            if (nav.addScrollType == AddScrollTypeCreateConfFromGroup)
            {
                RoomInfoModel *roomModel = [[SqliteDataDao sharedInstanse]getRoomInfoModelWithroomJid:nav.roomIdOfCreateConf];
                [_contact_MutDic setValue:roomModel.roomMemberList forKey:roomModel.roomName];
            }
        }
        //        else{
        //            NSString *org_id=[SqlAddressData getOrganiztionsBySection:str];
        //            //      通过自己所在部门的id，找到这个部门下所有的人以及这个部门下的部门
        //            NSArray *memberArray=[SqlAddressData getOrgPeopleByOrgId:org_id];
        //            [_contact_MutDic setValue:memberArray forKey:str];
        //        }
        
        select[index]=YES;
    }
    
    [self.tableView reloadData];
}

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
