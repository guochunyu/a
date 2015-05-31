//
//  addFromGroupVC.m
//  O了
//
//  Created by macmini on 14-02-12.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "addFromGroupVC.h"
#import "CellAddMenb.h"
#import "CellFirstThree.h"

#import "enterprise_info.h"
#import "menber_info.h"
#import "AddgGroupCell.h"
#import "GroupCell.h"

//#import "SqliteContacts.h"

#define SEARCH_HEIGHT 40 //tableView头部高度
#define SCROLLVIEW_ICON_MARGIN 3    //scrollView的图标间距
#define SECTION_MAX_ROW 1000    //每组最大行数
#define ANIMATION_DURATION 0.2  //动画持续时间

@interface addFromGroupVC ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    UIButton *_rightButt;
    UIButton *_leftButt;
    
    NSArray *memberArray;///<通讯录
    NSMutableArray *titleButtArray;///<导航按钮
    
    UISearchBar *searchBarContacts;
    UISearchDisplayController *searchDisplayControllerContacts;
    UIView *viewTranslucentBG;
    UIButton *buttonTranslucent;
    UITableView *tableViewSearch;
    UIView *viewSearchBG;
    UIView *viewSearchBG_1;
    NSString * search_text;///<搜索的关键字
    BOOL isSearch;
}
@end

@implementation addFromGroupVC
@synthesize arr_enterprise = _arr_enterprise;
@synthesize search_array_grou = _search_array_grou;
@synthesize search_array_menber = _search_array_menber;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320,rect.size.height-44) style:UITableViewStylePlain];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.title=@"组织架构";
    self.navigationController.navigationItem.leftBarButtonItem.title = @"顶顶顶顶";
    isSearch = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //    self.navigationItem.hidesBackButton=YES;
    if (titleButtArray==nil) {
        titleButtArray=[[NSMutableArray alloc] init];
    }
//    
//    EmployeeModel *_empModel=[[EmployeeModel alloc] init];
//    _empModel.name=self.rootName;
//    
//    _empModel.orgId=[NSString stringWithFormat:@"%d",self.grou_ID];
//    
//    [titleButtArray addObject:_empModel];
    if ([self.rootName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USERCOMPANY]]) {
        NSDictionary * root=[SqlAddressData getRootOrganiztions];
        EmployeeModel * model=[[EmployeeModel alloc] init];
        model.name=root[@"organiztion_name"];
        model.orgId=root[@"organiztion_tag"];
        [titleButtArray addObject:model];
    }
    else{
            EmployeeModel *_empModel=[[EmployeeModel alloc] init];
            _empModel.name=self.rootName;
            _empModel.orgId=[NSString stringWithFormat:@"%d",self.grou_ID];
            [titleButtArray addObject:_empModel];
    }
    
    [self getData];
    _addscrollMess = [addScrollView_messege sharedInstanse];
    
    
    //    [self initBackButton];
    //右侧按钮
    
    //    _rightButt=[UIButton buttonWithType:UIButtonTypeCustom];
    //    [_rightButt setTitle:@"关闭" forState:UIControlStateNormal];
    //    [_rightButt setTintColor:[UIColor whiteColor]];
    //    _rightButt.titleLabel.font=[UIFont systemFontOfSize:16];
    //    [_rightButt setBackgroundColor:[UIColor clearColor]];
    //    _rightButt.frame=CGRectMake(320-50-10, (44-29)/2, 50, 29);
    //    [_rightButt addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    _leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
    //    _leftButt.backgroundColor = [UIColor whiteColor];
    _leftButt.frame=CGRectMake(10, (44-29)/2, 73, 29);
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    // [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    [_leftButt setTitle:@"  通讯录" forState:UIControlStateNormal];
    _leftButt.titleLabel.font=[UIFont systemFontOfSize:14];
    _leftButt.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
    [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    _addscrollMess = [addScrollView_messege sharedInstanse];
    if (IS_IOS_7) {
        
    }else{
        //        [self initBackButton];
        //  [self initbarButton];
    }
    
    UIBarButtonItem *barButtonItemRight = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"2_icon_search"]
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(iemcBarButtonItemAction:)];
    self.navigationItem.rightBarButtonItem = barButtonItemRight;
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

-(void)leftButtItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{//
    
    if (_leftButt) {
        [_leftButt removeFromSuperview];
    }
    if (_rightButt) {
        [_rightButt removeFromSuperview];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    if (_addscrollMess.isSmsInvitation) {
        self.navigationItem.hidesBackButton=YES;
        _addscrollMess.isSmsInvitation=NO;
    }
    [self.navigationController.navigationBar addSubview:_rightButt];
    //    [self.navigationController.navigationBar addSubview:_leftButt];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect barFrame = self.searchBar.frame;
    barFrame.size.width = self.view.bounds.size.width;
    self.searchBar.frame = barFrame;
}

-(void)getData{
    //    NSDictionary *dic=[SqliteContacts getContactWithOrgNum:[NSString stringWithFormat:@"%d",self.grou_ID]];
    //    _arr_enterprise=dic[SqliteContactsEnterprise];
    //    _arr_menber=dic[SqliteContactsMember];
    
    //    memberArray=[SqlAddressData getOrgPeopleByOrgId:[NSString stringWithFormat:@"%d",self.grou_ID]];
    //   memberArray=[SqlAddressData getNewOrgPeopleByOrgId:[NSString stringWithFormat:@"%d",self.grou_ID]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        memberArray=[SqlAddressData getOrgName];
        if (memberArray.count>0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self.rootName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:USERCOMPANY]]) {
                    memberArray=[SqlAddressData getOrgPeopleByOrgId:[NSString stringWithFormat:@"%d",self.grou_ID]];
                }
                [self.tableView reloadData];
            });
        } else {
             memberArray=[SqlAddressData getOrgPeopleByOrgId:[NSString stringWithFormat:@"%d",self.grou_ID]];
        }
    });
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 导航
-(void)checkOutSql:(AddGroupScrollButt *)butt{
    
    int index=butt.tag - 100;
    while (titleButtArray.count-1>index) {
        [titleButtArray removeLastObject];
    }
    NSString * org_id=butt.orgId;
    memberArray=[SqlAddressData getOfContactPeople:org_id];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tableViewSearch)
    {
        return self.search_array_menber.count;
        
    }
    else{
        return memberArray.count;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == tableViewSearch)
    {
        return nil;
    }
 //   NSString * companyStr = [[NSUserDefaults standardUserDefaults]objectForKey:USERCOMPANY];
    UIScrollView * scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    scrollView.backgroundColor=[UIColor colorWithWhite:0.917 alpha:1.000];
    scrollView.showsHorizontalScrollIndicator=NO;
    scrollView.showsVerticalScrollIndicator=NO;
    float butt_x=0;
    for (int i=0; i<titleButtArray.count; i++) {
        EmployeeModel * model=[titleButtArray objectAtIndex:i];
        AddGroupScrollButt *butt=[[AddGroupScrollButt alloc] init];
        butt.orgId=model.orgId;
        [butt setBackgroundColor:[UIColor colorWithWhite:0.917 alpha:1.000]];
        
        if (i == 0) {
            [butt setTitle:self.rootName  forState:UIControlStateNormal];
            CGSize titleSize=[self.rootName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            butt.frame=CGRectMake(butt_x, -2, titleSize.width+20+14, 32);
            butt.tag=i+100;
            NSLog(@"%d",butt.tag);
            [butt setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        }else{
            UIButton * button =((AddGroupScrollButt *)[scrollView viewWithTag:100]);
            //   NSLog(@"%@",button);
            NSString * str =self.rootName;
            [button setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
            CGSize Size=[str sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            if (Size.width > 110) {
                button.frame=CGRectMake(0, -2,100, 32);
                [button setTitle:self.rootName  forState:UIControlStateNormal];
            }else{
                [button  setTitle:self.rootName  forState:UIControlStateNormal];
            }
            [butt setTitleColor:[UIColor colorWithRed:64/255.0 green:138/255.0 blue:244/255.0 alpha:1.0] forState:UIControlStateNormal];
            if (i == titleButtArray.count - 1) {
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
            CGSize Size=[self.rootName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 30) lineBreakMode:NSLineBreakByCharWrapping];
            if (Size.width > 110) {
                butt_x = 100;
            }else{
                butt_x= Size.width + 20 + 14;}
        }else{
            butt_x+=butt.frame.size.width;
            
        }
        [butt addTarget:self action:@selector(checkOutSql:) forControlEvents:UIControlEventTouchUpInside];
        
        [butt setEnlargeEdgeWithTop:20 right:0 bottom:0 left:0];
        [scrollView addSubview:butt];
        
    }
    scrollView.contentSize=CGSizeMake(butt_x, 30);
    if (butt_x>tableView.frame.size.width) {
        [scrollView setContentOffset:CGPointMake(butt_x, 0)];
    }
    return scrollView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == tableViewSearch)
    {
        return 0;
    }
    return 30.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierMenber = @"CellMenber";
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (tableView == tableViewSearch)
    {
        [tableViewSearch setSeparatorColor:[UIColor clearColor]];
        CellAddMenb *cell_contact = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMenber];
        if (cell_contact == nil) {
            cell_contact = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMenber];
        }
        EmployeeModel *member=[self.search_array_menber objectAtIndex:indexPath.row];
        
        [cell_contact.imageView setImageWithURL:[NSURL URLWithString:member.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
        
        cell_contact.label_name.text = member.name;
        CGSize size=[member.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
        cell_contact.label_name.frame = CGRectMake(95, 15, size.width, 20);
        if (member.leaderType==1) {
            cell_contact.label_phonenumber.text =member.comman_orgName;
        }else{
            cell_contact.label_phonenumber.text=member.comman_orgName;
        }
        cell_contact.label_phonenumber.frame = CGRectMake(cell_contact.label_name.frame.size.width + 95 + 10, 15, 100, 20);
        //Cell的CheckBox
        NSString  *imageName=@"people_not-select.png";
        if ([_addscrollMess.array_addcontact containsObject:member.phone]) {
            imageName=@"people_select.png";
        }
        //        NSArray *memberArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"add_group_member"];
        if ([nav.phoneArray containsObject:member.phone]) {
            imageName=@"check_pre_contact.png";
        }
        if ([member.phone isEqualToString:[ConstantObject sharedConstant].userInfo.phone]) {
            imageName=@"check_pre_contact.png";
        }
        
        UIImageView *accessoryView=(UIImageView *)cell_contact.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
        
        return cell_contact;
        
    }
    else {
    EmployeeModel *emplyeeModel=[memberArray objectAtIndex:indexPath.row];
    switch (emplyeeModel.type) {
        case 1:
        {
            //联系人
            CellAddMenb *cell_addmenb = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (cell_addmenb == nil) {
                cell_addmenb = [[CellAddMenb alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMenber];
            }
            [cell_addmenb.imageView setImageWithURL:[NSURL URLWithString:emplyeeModel.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
            
            cell_addmenb.label_name.text = emplyeeModel.name;
            CGSize size=[emplyeeModel.name sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
            cell_addmenb.label_name.frame = CGRectMake(95, 15, size.width, 20);
            if (emplyeeModel.leaderType==1) {
                cell_addmenb.label_phonenumber.text =@"公司领导";
            }else{
                cell_addmenb.label_phonenumber.text=emplyeeModel.title;
            }
            cell_addmenb.label_phonenumber.frame = CGRectMake(95 + cell_addmenb.label_name.frame.size.width + 10, 15, 100, 20);
            //Cell的CheckBox
            NSString *str = emplyeeModel.phone;
            NSString  *imageName=@"people_not-select.png";
            if ([_addscrollMess.array_addcontact containsObject:str]) {
                imageName=@"people_select.png";
            }
            if ([nav.phoneArray containsObject:str]) {
                imageName=@"check_pre_contact.png";
            }
            
            if ([emplyeeModel.phone isEqualToString:[ConstantObject sharedConstant].userInfo.phone]) {
                imageName=@"check_pre_contact.png";
            }
            
            UIImageView *accessoryView=(UIImageView *)cell_addmenb.accessoryView;
            accessoryView.image=[UIImage imageNamed:imageName];
            return cell_addmenb;
            
            break;
        }
        case 2:
        {
            //部门
            static NSString *cellIdentifier_1=@"AddgGroupCell";
            
            GroupCell *group_cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier_1];
            
            if (group_cell == nil) {
                group_cell=[[[NSBundle mainBundle] loadNibNamed:@"GroupCell" owner:self options:nil] lastObject];
                
            }
            //            group_cell.headImageView.image=[UIImage imageNamed:@"icon_group_50"];
            //            group_cell.headImageView.layer.masksToBounds = YES;
            //            group_cell.headImageView.layer.cornerRadius = 19.0;
            group_cell.label.text = emplyeeModel.name;
            UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, 320, 0.5)];
            lineView.opaque             = YES;
            lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
            [group_cell.contentView addSubview:lineView];
            
            return group_cell;
            //            CellFirstThree *cell_firstThree = [tableView dequeueReusableCellWithIdentifier:CellIdentifierGrou];
            //            if (cell_firstThree == nil) {
            //                cell_firstThree = [[CellFirstThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierGrou];
            //            }
            //            cell_firstThree.label.text = emplyeeModel.name;
            //            cell_firstThree.imageView.image = [UIImage imageNamed:@"icon_group_50"];
            //
            //            return cell_firstThree;
            
            break;
        }
        default:
            break;
    }
    
    }
    if (indexPath.row < [self.arr_menber count]) {
        
        
        
    }else{
        
        
        
        
        
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NavigationVC_AddID *nav=(NavigationVC_AddID *)self.navigationController;
    if (tableView == tableViewSearch)
    {
        [searchBarContacts resignFirstResponder];
        EmployeeModel *employeeModel=[self.search_array_menber objectAtIndex:indexPath.row];
        if ([employeeModel.phone isEqualToString:[ConstantObject sharedConstant].userInfo.phone]) {
            return;
        }
        if ([nav.phoneArray containsObject:employeeModel.phone]) {
            return;
        }
        NSString  *imageName=@"people_not-select.png";
        if ([_addscrollMess.array_addcontact containsObject:employeeModel.phone]) {
            for (int i=0; i<_addscrollMess.allmenber.count; i++) {
                EmployeeModel *deleModel=[_addscrollMess.allmenber objectAtIndex:i];
                if ([deleModel.phone isEqualToString:employeeModel.phone]) {
                    [_addscrollMess.allmenber removeObject:deleModel];
                }
            }
            //            [_addscrollMess.allmenber removeObject:employeeModel];
            [_addscrollMess removeSubViewWithPhone:employeeModel.phone FromScrollView:_addscrollMess.scrollView];
        }else{
            if (NO == [self canAddMenberToConf])
            {
                return;
            }
            imageName=@"people_select.png";
            [_addscrollMess addSubViewWithPhone:employeeModel.phone withImageName:default_headImage ToScrollView:_addscrollMess.scrollView withUrl:[NSURL URLWithString:employeeModel.avatarimgurl]];
            [_addscrollMess.allmenber addObject:employeeModel];
        }
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
    }
    else{
        
        EmployeeModel *employeeModel=[memberArray objectAtIndex:indexPath.row];
        switch (employeeModel.type) {
            case 1:
            {
                //人
                if ([employeeModel.phone isEqualToString:[ConstantObject sharedConstant].userInfo.phone]) {
                    //点击自己不做任何操作
                    return;
                }
                if ([nav.phoneArray containsObject:employeeModel.phone]) {
                    return;
                }
                NSString  *imageName=@"people_not-select.png";
                if ([_addscrollMess.array_addcontact containsObject:employeeModel.phone]) {
                    
                    [_addscrollMess removeSubViewWithPhone:employeeModel.phone FromScrollView:_addscrollMess.scrollView];
                    [_addscrollMess.allmenber removeObject:employeeModel];
                }else{
                    if (NO == [self canAddMenberToConf])
                    {
                        return;
                    }
                    imageName=@"people_select.png";
                    [_addscrollMess addSubViewWithPhone:employeeModel.phone withImageName:default_headImage ToScrollView:_addscrollMess.scrollView withUrl:[NSURL URLWithString:employeeModel.avatarimgurl]];
                    if ((nav.addScrollType==AddScrollTypeRecv||nav.addScrollType==
                         AddScrollTypeCC)&&(!employeeModel.email||[employeeModel.email isEqualToString:@""])) {
                        UIAlertView *alertview=[[UIAlertView alloc]initWithTitle:@"提示" message:@"该联系人无邮箱账号" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                        [_addscrollMess removeSubViewWithPhone:employeeModel.phone FromScrollView:_addscrollMess.scrollView];
                        [alertview show];
                    }else{
                        [_addscrollMess.allmenber addObject:employeeModel];
                    }
                }
                
                //checkBox设置
                UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
                UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
                accessoryView.image=[UIImage imageNamed:imageName];
                break;
            }
            case 2:
            {
                //组
                //                self.grou_ID=[employeeModel.orgId integerValue];
                //                [self getData];
                //                [titleButtArray addObject:employeeModel];
                
                memberArray = [SqlAddressData getOfContactPeople:employeeModel.orgId];
                [titleButtArray addObject:employeeModel];
                [self.tableView reloadData];
                break;
            }
            default:
                break;
        }
        
    }
    [tableView reloadData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //    NSInteger row = [sender integerValue];
    NSIndexPath *indexpath = sender;
    addFromGroupVC *addmenber = segue.destinationViewController;
    enterprise_info *enterprise = [self.arr_enterprise objectAtIndex:(indexpath.row - [self.arr_menber count])];
    addmenber.grou_ID = enterprise.ID;
    addmenber.title = enterprise.orgName;
    
}

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
//    if (_search_array_menber==nil) {
//        _search_array_menber=[NSMutableArray array];
//    }
//    [_search_array_menber removeAllObjects];
////    [_search_array_menber addObjectsFromArray:[SqlAddressData getContactWithRequirement:searchText]];
//    [_search_array_menber addObjectsFromArray:[SqlAddressData getNewContactWithRequirement:searchText]];
//}
//
//
////Change the title of cancel button in UISearchBar IOS7
//-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
////    if (IS_IOS_7)
////    {
//        // 7.0 系统的适配处理。
//        controller.searchBar.showsCancelButton = YES;
//        UIButton *cancelButton;
//        UIView *topView = controller.searchBar.subviews[0];
//        for (UIView *subView in topView.subviews) {
//            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
//                cancelButton = (UIButton*)subView;
//            }
//        }
//        if (cancelButton) {
//            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//            [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
//            cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
//            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        }
//
////    }else{
////        controller.searchBar.showsCancelButton = YES;
////        for(UIView *subView in controller.searchBar.subviews)
////        {
////            if([subView isKindOfClass:[UIButton class]])
////            {
////                [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
////            }
////        }
////    }
//}
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    //    if (IS_IOS_7){
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
//-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller{
//    [self.tableView reloadData];
//}

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
        
        if (_search_array_menber.count == 0)
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
    if (_search_array_menber==nil) {
        _search_array_menber=[NSMutableArray array];
    }
    [_search_array_menber removeAllObjects];
    [_search_array_menber addObjectsFromArray:[SqlAddressData getNewContactWithRequirement:searchText]];
    
}

#pragma mark - =======================

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
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
