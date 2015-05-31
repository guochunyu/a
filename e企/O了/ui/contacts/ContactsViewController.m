//
//  ContactsViewController.h
//  e企
//
//  Created by zxdDong on 15-4-20.
//  Copyright (c) 2015年 QYB. All rights reserved.
//


#import "ContactsViewController.h"
#import "Contact.h"
#import "menber_info.h"
#import "enterprise_info.h"
#import "MessageChatViewController.h"
//#import "HtppEngine.h"
//#import "HttpRequestEngine.h"//请求通讯录的类
#import "UIViewAdditions.h"
#import "PersonInfoViewController.h"
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
#import "MyDepartmentViewController.h"


#define HEAD_CELLHEIGHT 30 //区的高度
#define ROW_CELLHEIGHT  54 //行高
#define SEARCH_CELLHEIGHT 44 //搜索框的高度
#define DAOHANG_HEIGHT 94
#define TEXT_FONT  15
#define TOP_Y 17
#define TOP_Y1 9
#define LABLE_WIDTH 20
#define LINE_HEIGHT 1
#define LINE_WIDTH 320
#define LABEL_WIDTH 20
//#define TOP_Y 20

@interface ContactsViewController ()
{
    UIImageView * btn_img;//区尾的小按钮
    NSDictionary * dataDic;
    NSMutableArray * sectionArray;
    NSMutableDictionary * sectionFlag;
    //    NSArray * commanArray;
    NSString * str1111;
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
    UIButton*back;
    UIImageView*imagev;
    UILabel*label;
    
    __weak IBOutlet UINavigationItem *back_btn;
}

@end

@implementation ContactsViewController
@synthesize search_array = _search_array,sortArray = _sortArray;
@synthesize search_array1 = _search_array1;
@synthesize contact_MutDic = _contact_MutDic;

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(id)init{
    self = [super init];
    if (self) {
        //        [self initData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"通讯录", @"通讯录");
        // [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"通讯录pre.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"通讯录.png"]];
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //修改返回按钮
    back = [[UIButton alloc]init];
    back.frame = CGRectMake(0, 19, 80, 45);
    back.backgroundColor = [UIColor clearColor];
    [back addTarget:self action:@selector(backff) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view addSubview:back];
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
     [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 70, 20);
    label.text = @"通讯录";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:label];
    
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320,rect.size.height- 28) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    //   [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:IS_IOS_7 ? @"top_ios7.png" : @"top.png"] forBarMetrics:UIBarMetricsCompact];
    
    self.dataArray=[[NSArray alloc]init];
    sectionArray=[[NSMutableArray alloc]init];
    cellDic=[[NSMutableDictionary alloc]init];
    sectionFlag = [[NSMutableDictionary alloc] init];
    isFirstIn=YES;
    isLoadFirst=YES;
    
    isSearch=NO;
    
    UIBarButtonItem *barButtonItemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2_icon_search"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(iemcBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItemRight;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectToGroupAddresss:) name:selectToGroupAddresss object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectToFuwuhao:) name:selectToFuwuhao object:nil];
    
    
    if (!IS_IOS_7) {
        self.tableView.backgroundColor=UIColorFromRGB(0xebebeb);
        self.tableView.backgroundView=nil;
        //修改searchBar背景色
        //        self.searchBar.backgroundColor=[UIColor colorWithRed:0.79 green:0.79 blue:0.81 alpha:1];
        //        [[self.searchBar.subviews objectAtIndex:0]removeFromSuperview];
    }
    
    
    if (IS_IOS_7) {
        self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        self.tableView.sectionIndexColor = [UIColor grayColor];
        self.automaticallyAdjustsScrollViewInsets = YES;
        [self setExtendedLayoutIncludesOpaqueBars:YES];
    }else{
        [self initBackButton];
        [self initbarButton];
    }
    //    [self getAddress];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView reloadData];
    [self hideMoreLine];
    
    back_btn.title = @"";
    
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]init];
    [btn setBackButtonBackgroundImage:[UIImage imageNamed:@"nav-bar_back"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = btn;
}

-(void)backff{
    //通讯录返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}



-(void)hideMoreLine
{
    UIView *hide_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    hide_line.backgroundColor = [UIColor whiteColor];
    //   [self.tableView setTableFooterView:hide_line];
}
-(NSArray*)getCommanData
{
    NSString *uid=[ConstantObject sharedConstant].userInfo.uid;
    NSArray* commanArray= [SqlAddressData selectCommanContact:uid];
    return commanArray;
}
#pragma mark----获取数据源
-(void)getAddress{
    //   得到区的名字数组
    //    sectionArray=[NSMutableArray arrayWithArray:[SqlAddressData selectOrgName]];
    sectionArray = [NSMutableArray array];
    for (NSString * str in sectionArray) {
        DDLogInfo(@"%@",str);
    }
    BOOL isOne=NO;
    
    if (sectionArray.count==1) {
        isOne=YES;
    }
    isLoadFirst=YES;
    NSArray * commanArray= [self getCommanData];
    
    if (commanArray.count>0) {
        [sectionArray insertObject:commanName atIndex:0];
        
        if (isLoadFirst) {
            
            
            [cellDic setValue:commanArray forKey:commanName];
            [sectionFlag setValue:[NSNumber numberWithInt:1] forKey:commanName];
            
        }
        
    }else{
        if (isLoadFirst) {
            if (isOne) {
                NSString * str = [sectionArray objectAtIndex:0];
                
                org_id= [[ConstantObject sharedConstant].userInfo.orgid objectAtIndex:0];
                self.dataArray=[SqlAddressData getOrgPeopleByOrgId:org_id];
                [cellDic setValue:self.dataArray forKey:str];
                [sectionFlag setValue:[NSNumber numberWithInt:1] forKey:str];
                
            }else{
                
            }
        }
    }
    if (isSearch) {
        return;
    }
    [self.tableView reloadData];
}
#pragma mark - 通知
-(void)selectToGroupAddresss:(NSNotification *)notification{
    [self performSegueWithIdentifier:@"IdentifierGroupAddresss" sender:nil];
    
}
-(void)selectToFuwuhao:(NSNotification *)notification{
    ServiceNumberAllListViewController *snSubscribeList=[[ServiceNumberAllListViewController alloc]initWithStyle:UITableViewStylePlain];
    snSubscribeList.serviceNumberListType=ServiceNumberListTypeSubscrib;
    snSubscribeList.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:snSubscribeList animated:YES];
}
#pragma mark - guan

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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    back.hidden = NO;
    imagev.hidden = NO;
    label.hidden = NO;
    
    self.navigationController.navigationBar.hidden = NO;
    
    NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
    EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
    self.UserPhoto = model.avatarimgurl;
    //  请求服务器数据
    ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
    contactsCheck.contactsCheckDelegate = self;
    if(contactsCheck.executeStatus == 0){
        NSMutableArray *orgArray=[NSMutableArray arrayWithArray:[SqlAddressData selectOrgName]];
        if(orgArray.count ==0){
            [[NSUserDefaults standardUserDefaults]setObject:0 forKey:LATESTUPDATETIME];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SqlAddressData deleTableData];
        }
        [contactsCheck execute];//调用本身的实例方法.从数据空中取
    }
    else if(contactsCheck.executeStatus == 1){
        [self beginUpdate];
    }
    isSearch=NO;
    //从数据库查找数据
    [self initData];
    
}

-(void)beginUpdate{
    if (_HUD != nil) {
        [_HUD removeFromSuperview];
    }
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view bringSubviewToFront:_HUD];
    [self.view.superview addSubview:_HUD];
    _HUD.labelText = @"检查联系人更新...";
    [_HUD show:YES];
}
-(void)endUpdate:(bool)hasUpdate{
    if (_HUD != nil) {
        [_HUD removeFromSuperview];
    }
    [self initData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOWTABBAR object:nil userInfo:nil];
    
    //tableview set
    self.tableView.backgroundColor=UIColorFromRGB(0xebebeb);
    self.tableView.backgroundView=nil;
    if (IS_IOS_7) {
        if (self.view.bounds.size.height==480 || self.view.bounds.size.height==568) {
            
            self.tableView.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height-50);
        }
        
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    back.hidden = YES;
    imagev.hidden = YES;
    label.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_HIDETABBAR object:nil userInfo:nil];
}
-(IBAction)rightBtnAction:(id)sender{
    //    AddContactsViewController *addContactsVC = [[AddContactsViewController alloc]initWithStyle:UITableViewStyleGrouped];
    //    addContactsVC.hidesBottomBarWhenPushed = YES;
    //    [self.navigationController pushViewController:addContactsVC animated:YES];
    [self performSegueWithIdentifier:@"IdentifierAddContact" sender:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //    CGRect barFrame = self.searchBar.frame;
    //    if (barFrame.size.width != self.view.bounds.size.width) {
    //        barFrame.size.width = self.view.bounds.size.width;
    //        self.searchBar.frame = barFrame;
    //    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberofSection = 0;
    if (tableView == tableViewSearch)
    {
        
        numberofSection = 1;
        
    }
    //    if (tableView == self.searchDisplayController.searchResultsTableView)
    //    {
    //        numberofSection = [self.search_array count];
    //    }
    else
    {
        
        numberofSection=sectionArray.count+2;
        
    }
    return numberofSection;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberofRow = 0;
    if (tableView == tableViewSearch)
    {
        
        numberofRow = self.search_array.count;
    }
    else
    {
        if (section == 0) {
            /**
             *  返回第一个区的row数量
             */
            numberofRow =2;
        } else if(section == 1){
            //            根据区头找到每个部门的人员
            numberofRow = 1;
            
        }
        else if(section == 2){
            //            根据区头找到每个部门的人员
            NSArray * cellArray=cellDic[[sectionArray objectAtIndex:section-2]];
            numberofRow=cellArray.count;
            
        }
        
    }
    return numberofRow;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//
//    NSString *str = nil;
//    if (tableView ==tableViewSearch)
//    {
//    }
//    if(section==0){
//
//    }
//    if (section == 2)
//    {
//        str = [sectionArray objectAtIndex:section-2];
//    }
//    return nil;
//}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UITableViewHeaderFooterView *foot = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"footer"];
    if (!foot) {
        foot = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"footer"];
    }
    else{
        //      防止重用
        while ([foot.contentView.subviews lastObject] != nil)
        {
            [(UIView*)[foot.contentView.subviews lastObject] removeFromSuperview];
        }
        
    }
    if (tableView == tableViewSearch)
    {
        foot=nil;
    }
    else {
        if (section == 0) {
            foot =nil;
        }
        else if (section == 1){
            foot.contentView.backgroundColor = UIColorFromRGB(0xebebeb);
        }
        else if (section == 2){
            foot = nil;
        }
        
    }
    
    return foot;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
        /*
         if (section == 0) {
         NSString *str =[[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
         
         UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
         button.frame=CGRectMake(0, 0, 320, 30);
         button.backgroundColor=UIColorFromRGB(0xf8f8f8);
         //            HEXCOLOR(0xEEEEEE);
         button.tag=section+100-1;
         
         
         UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
         butt_label.text=str;
         butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
         butt_label.textAlignment=NSTextAlignmentLeft;
         butt_label.font=[UIFont systemFontOfSize:12];
         [button addSubview:butt_label];
         //线
         UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, button.frame.size.width, 0.5)];
         lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
         [button addSubview:lineView];
         
         [head.contentView addSubview:button];
         }
         else{
         NSString *str =@"我的部门";
         UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
         button.frame=CGRectMake(0, 0, 320, 30);
         button.backgroundColor=UIColorFromRGB(0xf8f8f8);
         //            HEXCOLOR(0xEEEEEE);
         button.tag=section+100-1;
         
         
         UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
         butt_label.text=str;
         butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
         butt_label.textAlignment=NSTextAlignmentLeft;
         butt_label.font=[UIFont systemFontOfSize:12];
         [button addSubview:butt_label];
         //线
         UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, button.frame.size.width, 0.5)];
         lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
         [button addSubview:lineView];
         
         [head.contentView addSubview:button];
         
         }
         */
        
    }
    else
    {
        if (section == 0) {
            
            NSString *str = @"企业通讯录";
            
            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(0, 0, 320, 30);
            button.backgroundColor=UIColorFromRGB(0xf8f8f8);
            //            HEXCOLOR(0xEEEEEE);
            button.tag=section+100-1;
            
            
            UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
            butt_label.text=str;
            butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            butt_label.textAlignment=NSTextAlignmentLeft;
            butt_label.font=[UIFont systemFontOfSize:12];
            [button addSubview:butt_label];
            //线
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, button.frame.size.width, 0.5)];
            lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [button addSubview:lineView];
            
            [head.contentView addSubview:button];
            
        }
        else if (section == 1){
            head.contentView.backgroundColor = UIColorFromRGB(0xebebeb);
        }
        else if (section == 2){
            
            NSString *str = [sectionArray objectAtIndex:section-2];
            
            UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
            button.frame=CGRectMake(0, 0, 320, 31);
            [button addTarget:self action:@selector(openOrClosed:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor=[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0];
            button.tag=section+100-2;
            
            UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
            butt_label.text=str;
            butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
            butt_label.textAlignment=NSTextAlignmentLeft;
            butt_label.font=[UIFont systemFontOfSize:12];
            [button addSubview:butt_label];
            UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height-0.5, button.frame.size.width, 0.5)];
            lineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            UIView *lineView1=[[UIView alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width, 0.5)];
            lineView1.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];            [button addSubview:lineView1];
            
            [button addSubview:lineView];
            
            
            [head.contentView addSubview:button];
            
            
            btn_img=[[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 27, 13, 11, 6)];
            if ([(NSNumber*)[sectionFlag valueForKey:str] intValue]== 0) {
                btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow1.png"];
            }else{
                btn_img.image=[UIImage imageNamed:@"public_lager_all_arrow3.png"];
            }
            [head.contentView addSubview:btn_img];
            
            //            UIView* lineView               = [[UIView alloc] init];
            //            lineView.frame=CGRectMake(0, head.frame.size.height-LINE_HEIGHT, head.frame.size.width,LINE_HEIGHT);
            //            lineView.opaque             = YES;
            //            lineView.backgroundColor    = HEXCOLOR(0x999999);
            //         [head.contentView addSubview:lineView];
            
            if([sectionArray count] == 1)
            {
                oneOrgBtn = button;
            }
        }
    }
    return head;
}
#pragma mark------部门的折叠
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
        }
        //        else{
        //
        //            //NSString *orgID= [SqlAddressData getOrganiztionsBySection:str];
        //            //int orgIndex = index + ([self getCommanData].count ==0 ? 0 : 1);
        //
        //            NSString *orgID= [SqlAddressData getOrganiztionsBySection:sectionArray[index]];
        //            //NSString *orgID= [[ConstantObject sharedConstant].userInfo.orgid objectAtIndex:index];
        //            //NSString *orgID= [[ConstantObject sharedConstant].userInfo.orgid objectAtIndex:orgIndex];
        //            //      通过自己所在部门的id，找到这个部门下所有的人以及这个部门下的部门
        //            NSArray *memberArray=[SqlAddressData getOrgPeopleByOrgId:orgID];
        //            [cellDic setValue:memberArray forKey:str];
        //        }
        [sectionFlag setValue:[NSNumber numberWithInt:1] forKey:str];
    }
    if (isSearch) {
        return;
    }
    [self.tableView reloadData];
    // [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:index + 2] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark----返回区头的高度


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{    CGFloat flt = 0;
    
    if (tableView == tableViewSearch)
    {
        flt=0;
    }
    else
    {
        if (section == 0) {
            flt=HEAD_CELLHEIGHT;
        }else if(section == 1) {
            flt=10;
        }
        else if (section == 2){
            flt=HEAD_CELLHEIGHT;
        }
    }
    return flt;
}

#pragma mark----返回区尾的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    CGFloat flt = 0;
    
    if (tableView == tableViewSearch)
    {
        return 0;
    }
    
    else
    {
        if (section == 0) {
            flt=0;
        }else if(section == 1) {
            flt=10;
        }
        else if (section == 2){
            flt=0;
        }
    }
    return flt;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier0 = @"Cell0";
    static NSString *CellIdentifier1 = @"Cell1";
    
    CellFirstThree *cell_firstThree = nil;
    CellContact *cell_contact = nil;
    //在这个位置处理搜索结果展示
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
        NSLog(@"contact.name%@contact.name",contact.name);
        
        CGSize size=[contact.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        if (size.width > 80) {
            size.width = 80;
        }
        cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
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
        
        
        /*
         else{
         EmployeeModel *contact = [self.search_array1 objectAtIndex:indexPath.row];
         cell_contact.label_name.text = contact.name;
         NSLog(@"contact.name%@contact.name",contact.name);
         
         CGSize size=[contact.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
         if (size.width > 80) {
         size.width = 80;
         }
         cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
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
         if (indexPath.row == _search_array1.count - 1) {
         cell_contact.lineView.frame = CGRectMake(0, 53.5, 320, 0.5);
         }
         
         cell = cell_contact;
         }
         */
        return cell;
    }
    else
    {
        if (indexPath.section == 0) {
            if (cell_firstThree == nil) {
                cell_firstThree = [[CellFirstThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier0];
                cell_firstThree.delegate=self;
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            if (indexPath.row == 0) {
                DDLogInfo(@"%@",self.firstThree);
                Contact *contact = [self.firstThree objectAtIndex:0];
                DDLogInfo(@"%@",contact.name);
                cell_firstThree.label.text = contact.name;
                CGSize size=[contact.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
                
                cell_firstThree.label.frame=CGRectMake(69, TOP_Y1,self.tableView.frame.size.width - 100, LABLE_WIDTH);
                cell_firstThree.label.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
                cell_firstThree.label1.frame =
                CGRectMake(cell_firstThree.imageView.frame.size.width + cell_firstThree.imageView.frame.origin.x + 15,cell_firstThree.label.bottom + 6, 40, 10);
                cell_firstThree.label1.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                cell_firstThree.label1.font = [UIFont systemFontOfSize:10];
                cell_firstThree.label1.textAlignment = NSTextAlignmentLeft;
                cell_firstThree.label1.text = @"组织架构";
                
                // DDLogInfo(@"%@",contact.name);r
                cell_firstThree.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",contact.image]];
                //    [cell_firstThree.unitBtn addTarget:self action:@selector(gotoPhone:) forControlEvents:UIControlEventTouchUpInside];
            }
            //self.firstThree 存放的是 单位  群 公共号
            else{
                cell_firstThree.lineView.frame = CGRectMake(0, 53.5,self.tableView.frame.size.width, 0.5);
                Contact *contact = [self.firstThree objectAtIndex:1];
                cell_firstThree.label.text = contact.name;
                CGSize size=[contact.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
                cell_firstThree.label.frame=CGRectMake(69, TOP_Y1,self.tableView.frame.size.width - 100, LABLE_WIDTH);
                cell_firstThree.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",contact.image]];
                cell_firstThree.label.textColor = [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
                cell_firstThree.label1.frame =
                CGRectMake(cell_firstThree.imageView.frame.size.width + cell_firstThree.imageView.frame.origin.x + 15,cell_firstThree.label.bottom + 6, 40, 10);
                cell_firstThree.label1.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
                cell_firstThree.label1.font = [UIFont systemFontOfSize:10];
                cell_firstThree.label1.textAlignment = NSTextAlignmentLeft;
                cell_firstThree.label1.text = @"我的部门";
                cell_firstThree.unitBtn.tag = 200;
                
            }
            
            cell = cell_firstThree;
            cell_firstThree.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
            
        }
        else if (indexPath.section == 1){
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier0];
            }
            
            UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(14, 7, 40, 40)];
            imageView.layer.masksToBounds = YES;
            imageView.layer.cornerRadius = imageView.frame.size.width * 0.5;
            [imageView setImage:[UIImage imageNamed:@"icon_group.png"]];
            [cell.contentView addSubview:imageView];
            int ios6with = 0;
            if (IS_IOS_7) {
                ios6with = 0;
            }else{
                ios6with = 10;
            }
            UILabel * label_name = [[UILabel alloc]init];
            label_name.font = [UIFont systemFontOfSize:TEXT_FONT];
            label_name.frame=CGRectMake(50,15,100, LABEL_WIDTH);
            label_name.textAlignment=NSTextAlignmentCenter;
            [cell.contentView addSubview:label_name];
            
            label_name.text = @"我的群组";
            label_name.textColor =[UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
            UIView *footlineView=[[UIView alloc] initWithFrame:CGRectMake(0,ROW_CELLHEIGHT
                                                                          -0.5, self.tableView.frame.size.width, 0.5)];
            footlineView.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [cell.contentView addSubview:footlineView];
            UIView *headline=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableView.frame.size.width, 0.5)];
            headline.backgroundColor=[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [cell.contentView addSubview:headline];
            
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if(indexPath.section == 2){
            //          cell显示表中的内容
            if (cell_contact == nil) {
                cell_contact = [[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
                cell_contact.delegate = self;
            }else{
                //删除cell的所有子视图
                while ([cell.contentView.subviews lastObject] != nil)
                {
                    [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
                }
            }
            NSString * sectionStr = [sectionArray objectAtIndex:indexPath.section - 2];
            NSArray * array=[cellDic objectForKey:[sectionArray objectAtIndex:indexPath.section-2]];
            EmployeeModel *model = [array objectAtIndex:indexPath.row];
            if ([sectionStr isEqualToString:commanName]) {
                cell_contact.label_name.text = model.name;
                cell_contact.label_name.textColor =  [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1.0];
                DDLogInfo(@"+++++++++++++%@=======",model.name);
                CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
                if (size.width > 80) {
                    size.width = 80;
                }
                cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, 17,size.width, LABLE_WIDTH);
                cell_contact.label_position.text = model.comman_orgName;
                NSLog(@"%@",model.title);
                //根据str获取宽高
                CGSize size1=[ model.comman_orgName sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
                if (size1.width > 150) {
                    size1.width = 150;
                }
                cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
                
                if (model.avatarimgurl) {
                    NSString *fileURL = model.avatarimgurl;
                    NSURL *url = [NSURL URLWithString:fileURL];
                    [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
                    
                }
                if(indexPath.row==array.count-1){
                    [cell_contact.lineView setFrame:CGRectMake(0, 54, 320, 0.5)];
                }
                
            }
            
            //            else{
            //                if (model.type==1) {
            //
            //                    cell_contact.label_name.text = model.name;
            //                    DDLogInfo(@"+++++++++++++%@=======",model.name);
            //                    CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            //                    cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
            //                    cell_contact.label_position.text = model.title;
            //                    CGSize size1=[model.title sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
            //                    cell_contact.label_position.frame=CGRectMake(cell_contact.label_name.frame.size.width+cell_contact.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
            //
            //                    if (model.avatarimgurl) {
            //                        NSString * imacct = [ConstantObject sharedConstant].userInfo.imacct;
            //                        if ([model.imacct isEqual:imacct]) {
            //                            NSString *fileURL = self.UserPhoto;
            //                            NSURL *url = [NSURL URLWithString:fileURL];
            //                            [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
            //                        }else{
            //                            NSString *fileURL = model.avatarimgurl;
            //                            NSURL *url = [NSURL URLWithString:fileURL];
            //                            DDLogInfo(@"%@",url);
            //                            [cell_contact.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
            //                        }
            //                    }else{
            //                    }
            //                }if (model.type==2) {
            //                    cell_contact.label_name.text=model.name;
            //                    CGSize size=[model.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            //                    cell_contact.label_name.frame=CGRectMake(cell_contact.imageView.frame.size.width+cell_contact.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
            //                    cell_contact.label_position.text = @"";
            //                    [cell_contact.imageView setImage:[UIImage imageNamed:@"icon_group_50.png"]];
            //                }
            //            }
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
            cell = cell_contact;
        }
    }
    return cell;
}
#pragma mark-----搜素展示
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
#pragma mark-----公共功能
-(void)gotoPhone:(UIButton*)sender
{
    if (sender.tag==100) {
        OrganizationViewController * controller=[[OrganizationViewController alloc]initWithNibName:@"OrganizationViewController" bundle:nil];
        controller.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:controller animated:YES];
        //       更新父节点的属性
    }if (sender.tag==200) {
        QunLiaoListViewController *qunListVC=[[QunLiaoListViewController alloc] init];
        qunListVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:qunListVC animated:YES];
    }if (sender.tag==300) {
        ServiceNumberAllListViewController *snSubscribeList=[[ServiceNumberAllListViewController alloc]initWithStyle:UITableViewStylePlain];
        snSubscribeList.serviceNumberListType=ServiceNumberListTypeSubscrib;
        snSubscribeList.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:snSubscribeList animated:YES];
    }
}
#pragma mark - Table view delegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if (tableView == tableViewSearch){
        return nil;
    }else{
        DDLogInfo(@"-----%@-----",self.sortArray);
        return self.sortArray;
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == tableViewSearch){
        return ROW_CELLHEIGHT;
    }else{
        if (indexPath.section==0) {
            return ROW_CELLHEIGHT;
        }else{
            return ROW_CELLHEIGHT;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == tableViewSearch)
    {
        
        EmployeeModel *contact = [self.search_array objectAtIndex:indexPath.row];
        UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
        userDetail.userInfo=contact;
        userDetail.searchBarContacts = searchBarContacts;
        //        searchBarContacts.hidden = YES;
        [searchBarContacts resignFirstResponder];
        userDetail.organizationName=contact.comman_orgName;
        [self.navigationController pushViewController:userDetail animated:YES];
        
        //        else{
        //
        //            EmployeeModel *contact = [self.search_array1 objectAtIndex:indexPath.row];
        //            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
        //            userDetail.userInfo=contact;
        //            userDetail.searchBarContacts = searchBarContacts;
        ////            searchBarContacts.hidden = YES;
        //            [searchBarContacts resignFirstResponder];
        //            userDetail.organizationName=contact.comman_orgName;
        //            [self.navigationController pushViewController:userDetail animated:YES];
        //
        //
        //        }
        
    }
    else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                OrganizationViewController * controller=[[OrganizationViewController alloc]initWithNibName:@"OrganizationViewController" bundle:nil];
                controller.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:controller animated:YES];
                
            }
            else {
                MyDepartmentViewController * MyDepartment = [[MyDepartmentViewController alloc]init];
                MyDepartment.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:MyDepartment animated:YES];
                
            }
        }
        else if (indexPath.section == 1){
            QunLiaoListViewController *qunListVC=[[QunLiaoListViewController alloc] init];
            qunListVC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:qunListVC animated:YES];
            
        }
        else if(indexPath.section == 2){
            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
            NewOrgViewController *viewController=[[NewOrgViewController alloc]initWithNibName:@"NewOrgViewController" bundle:nil];
            //           有问题需要改
            NSArray * array=[cellDic objectForKey:[sectionArray objectAtIndex:indexPath.section-2]];
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
                    if (indexPath.section-2==0) {
                        userDetail.organizationName=model.comman_orgName;
                        DDLogInfo(@"%@",model.comman_orgName);
                    }else{
                        userDetail.organizationName=[sectionArray objectAtIndex:indexPath.section-2];
                        
                    }
                }else{
                    userDetail.organizationName=[sectionArray objectAtIndex:indexPath.section-2];
                }
                userDetail.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:userDetail animated:YES];
                
            }if (model.type==2) {
                NSArray * newArray=[[NSArray alloc]init];
                newArray=[SqlAddressData getOfContactPeople:model.orgId];
                viewController.dataArray=newArray;
                viewController.organizationName=model.name;
                viewController.orgId=model.orgId;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"IdentifierGroupAddresss"]) {
        
    }else if ([segue.identifier isEqualToString:@"IdentifierAddContact"]){
        
    }
}
#pragma mark - cell_firstThree delegate
-(void)cellFirstThreeCell:(NSIndexPath *)row{
    DDLogInfo(@"代理方法 啥也不写 为了增加阅读难度吗");
    
}

#pragma mark - UISearchDisplayController Delegate Methods

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    if (searchString.length>0) {
//        [self ContentForSearchText:searchString];
//    }
//    return YES;
//}

#pragma mark - 修改取消按钮

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    //    if (IS_IOS_7){
//
//    isSearch=YES;
//
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
//    //    }
//}
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
//
//
//}
//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
//    isSearch=NO;
//    [self initData];
//}
//-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
//    //    if (IS_IOS_7)
//    //    {
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
//        [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
//        cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
//        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    }
//}
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
    /*
     int a = _search_array.count;
     
     //NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
     
     NSArray * array =[SqlAddressData selectOrgName];
     for (int i = 0; i< array.count; i++) {
     for (int j = 0; j < _search_array.count; j++) {
     if ([((EmployeeModel *)[_search_array objectAtIndex:j]).comman_orgName isEqualToString:[array objectAtIndex:i]])
     {
     NSString * str = ((EmployeeModel *)[_search_array objectAtIndex:j]).comman_orgName;
     [_search_array1 addObject:[_search_array objectAtIndex:j]];
     }
     }
     [_search_array removeObjectsInArray:_search_array1];
     }
     */
    [tableViewSearch reloadData];
    
}
#pragma mark-----去掉区头的滑动效果
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//
//    if (scrollView==self.tableView) {
//        CGFloat sectionHeaderHeight = HEAD_CELLHEIGHT;
//
//        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//
//            scrollView.contentInset = UIEdgeInsetsMake(ROW_CELLHEIGHT +8.0, 0, 0, 0);
//
//        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//
//        }
//
//    }
//
//}


#pragma mark-
#pragma mark HUD

- (void)hudWasHidden:(MBProgressHUD *)hud{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}
-(void)addHUD:(NSString *)labelStr{
    _HUD=[[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    _HUD.dimBackground = YES;
    _HUD.labelText = labelStr;
    _HUD.delegate=self;
    
    _HUD.userInteractionEnabled=YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
    [_HUD show:YES];
}

#pragma mark ==========cellcontact delegate
-(void)menssegeIDCell:(NSIndexPath *)row type:(BOOL)isSearchTB{
    
}

#pragma mark ----- 一区获取数据
-(void)initData{
    _firstThree=[self getDatainfo];
    //获得数据源
    //    getAddress
    
    ContactsCheck *contactsCheck = [ContactsCheck sharedInstance];
    if (contactsCheck.executeStatus !=1 && [SqlAddressData queryContactIsNull]) {
        [self getAddress];
    }
    if (isSearch) {
        return;
    }
    [self.tableView reloadData];
}
#pragma mark---二区的数据源

#pragma mark---一区的数据源
-(NSArray*)getDatainfo
{
    NSMutableArray * arrayData=[NSMutableArray arrayWithCapacity:0];
    NSString * str = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
    DDLogInfo(@"%@",str);
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (str == nil || str.length == 0) {
        str = [NSString stringWithFormat:@"企业通讯录"];
    }
    NSCharacterSet *nameCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    //判断字符串是否在指定的字符集范围内
    
    NSRange userNameRange = [str rangeOfCharacterFromSet:nameCharacters];
    
    if (userNameRange.location != NSNotFound) {
        
        NSLog(@"包含特殊字符");
        
    }
    Contact * contact1 = [[Contact alloc]initWithCategory:@"0" name:str image:@"icon_organization.png" phoneNumber:nil];
    [arrayData addObject:contact1];
    NSMutableArray * array =[NSMutableArray arrayWithArray:[SqlAddressData selectOrgName]];
    str1111 = [NSString stringWithFormat:@"%@",[array objectAtIndex:0]];
    str1111 = [str1111 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (array.count > 1) {
        for (int i = 1; i < array.count;i++ ) {
            str1111 = [str1111 stringByAppendingString:[NSString stringWithFormat:@"\\%@",[array objectAtIndex:i]]];
        }
        
    }
    
    Contact * contact2 = [[Contact alloc]initWithCategory:@"1" name:str1111 image:@"icon_department.png" phoneNumber:nil];
    [arrayData addObject:contact2];
    // [arrayData addObject:[Contact contactOfCategory:@"0" name:str image:@"address_icon_organization_s.png" phoneNumber:nil]];
    // [arrayData addObject:[Contact contactOfCategory:@"1" name:@"我的群组" image:@"address_icon_group.png" phoneNumber:nil]];
    // [arrayData addObject:[Contact contactOfCategory:@"2" name:@"公众号" image:@"address_icon_rss.png" phoneNumber:nil]];
    return [NSArray arrayWithArray:arrayData];
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
    //buttonTranslucent.backgroundColor = [UIColor redColor];
    [buttonTranslucent addTarget:self action:@selector(buttonTranslucent) forControlEvents:UIControlEventTouchUpInside];
    [viewTranslucentBG addSubview:buttonTranslucent];
    isSearch = YES;
    
    back.hidden = YES;
    imagev.hidden = YES;
    label.hidden = YES;
    
}

#pragma mark - 按钮响应
- (void)buttonTranslucent
{
    back.hidden = NO;
    imagev.hidden = NO;
    label.hidden = NO;
    
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
    back.hidden = NO;
    imagev.hidden = NO;
    label.hidden = NO;
    
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
        
        viewSearchBG = [[UIView alloc] initWithFrame:CGRectMake(0,64, self.view.bounds.size.width, self.view.bounds.size.height - 68)];
        viewSearchBG.backgroundColor = [UIColor whiteColor];
        
        tableViewSearch = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height - 68) style:UITableViewStylePlain];
        tableViewSearch.delegate = self;
        tableViewSearch.dataSource = self;
        [tableViewSearch setSeparatorInset:UIEdgeInsetsMake(0, 70, 0, 0)];
        [viewSearchBG addSubview:tableViewSearch];
        
        [self.view addSubview:viewSearchBG];
        
        [self ContentForSearchText:searchString];
        
        if (_search_array.count == 0)
        {
            viewSearchBG_1 = [[UIView alloc] initWithFrame:CGRectMake(0,64, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
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
#pragma mark - =======================

@end




