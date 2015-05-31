//
//  GroupAddress.m
//  O了
//
//  Created by macmini on 14-01-22.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "GroupAddress.h"
#import "enterprise_info.h"
#import "menber_info.h"
#import "CellFirstThree.h"
#import "MessageChatViewController.h"
#import "menber_enterprise.h"
#import "UserDetailViewController.h"

#import "AFClient.h"
#import "MainNavigationCT.h"
#import "MainViewController.h"

@interface GroupAddress (){
//    UIButton *_leftButt;
}

@end

@implementation GroupAddress


@synthesize arr_enterprise = _arr_enterprise;
@synthesize search_array_grou = _search_array_grou;
@synthesize search_array_menber = _search_array_menber;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - 返回
-(void)leftButtItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    //隐藏系统的item
//    [self.navigationItem setHidesBackButton:YES];
//    
//    _leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
//    _leftButt.frame=CGRectMake(10, (44-29)/2, 53, 29);
//    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
//    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
//    [_leftButt setTitle:[NSString stringWithFormat:@" %@",self.title] forState:UIControlStateNormal];
//    _leftButt.titleLabel.font=[UIFont systemFontOfSize:14];
//    _leftButt.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
//    [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self getData];
    
    if (IS_IOS_7) {
        self.automaticallyAdjustsScrollViewInsets = YES;
        [self setExtendedLayoutIncludesOpaqueBars:YES];
    }
    [self initBackButton];
}
- (void)viewWillDisappear:(BOOL)animated{
//    [_leftButt removeFromSuperview];
}
-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController.navigationBar addSubview:_leftButt];
}

-(void)viewDidUnload{
    //置为空
//    _leftButt=nil;
    
}
-(void)initBackButton{
    UIImage *buttonBack = [[UIImage imageNamed:@"nv_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    [self.navigationItem.backBarButtonItem setBackButtonBackgroundImage:buttonBack forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

-(void)getData{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return ([self.search_array_grou count] + [self.search_array_menber count]);
    }
    return ([self.arr_enterprise count] + [self.arr_menber count]);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return 50.0;
    }
    if (indexPath.row < [self.arr_enterprise count]) {
        return 50.0;
    }else{
        return 50.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierGrou = @"CellGrou";
    static NSString *CellIdentifierMenber = @"CellMenber";
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if (indexPath.row < [self.search_array_grou count]) {
            CellFirstThree *cell_firstThree = [tableView dequeueReusableCellWithIdentifier:CellIdentifierGrou];
            if (cell_firstThree == nil) {
                cell_firstThree = [[CellFirstThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierGrou];
            }
            enterprise_info *enterprise = [self.search_array_grou objectAtIndex:indexPath.row];
            cell_firstThree.label.text = enterprise.orgName;
            cell_firstThree.imageView.image = [UIImage imageNamed:@"集团通讯录.png"];
            
            return cell_firstThree;
        }else{
            CellContact *cell_contact = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMenber];
            if (cell_contact == nil) {
                cell_contact = [[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMenber];
                cell_contact.delegate = self;
            }
            
            menber_info *menber = [self.search_array_menber objectAtIndex:(indexPath.row - [self.search_array_grou count])];
            cell_contact.label_name.text = menber.menberName;
            cell_contact.label_position.text = menber.telNum;
//             cell_contact.phoneNumber = menber.telNum;
            if (menber.avatar) {
                NSString *fileURL = @"";
                NSURL *url = [NSURL URLWithString:fileURL];
                
                [cell_contact.imageView setImageWithURL:url placeholderImage:[GetArcImageName arcImageNameStr:menber.telNum]];
            }else{
                cell_contact.imageView.image = [GetArcImageName arcImageNameStr:menber.telNum];
            }
            if ([menber.telNum isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]]) {
                AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
                if (appDelegate.is_touxiang_cunzai) {
                    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                    NSString *filePath_01 = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"/avatar.png"];
                    [cell_contact.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath_01]]];
                }else{
                    
                }
            }
            
            NSString *selfNumber=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
            if ([menber.telNum isEqualToString:selfNumber]) {
                cell_contact.messageBtn.hidden = YES;
                cell_contact.calliphoneBtn.hidden = YES;
            }else{
                cell_contact.messageBtn.hidden = NO;
                cell_contact.calliphoneBtn.hidden = NO;
            }
            cell_contact.menssegeID = indexPath;
            cell_contact.isSearchTB = YES;
            return cell_contact;
        }
    }
    
    if (indexPath.row < [self.arr_menber count]) {
        
        
        
        CellContact *cell_contact = [tableView dequeueReusableCellWithIdentifier:CellIdentifierMenber];
        if (cell_contact == nil) {
            cell_contact = [[CellContact alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierMenber];
            cell_contact.delegate = self;
        }
        
        menber_info *menber = [self.arr_menber objectAtIndex:indexPath.row];
        cell_contact.label_name.text = menber.menberName;
        cell_contact.label_position.text = menber.telNum;
//        cell_contact.phoneNumber = menber.telNum;
        if (menber.avatar) {
            NSString *fileURL = @"";
            NSURL *url = [NSURL URLWithString:fileURL];
            [cell_contact.imageView setImageWithURL:url placeholderImage:[GetArcImageName arcImageNameStr:menber.telNum]];
        }else{
            cell_contact.imageView.image = [GetArcImageName arcImageNameStr:menber.telNum];
        }
        
        if ([menber.telNum isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE]]) {
            AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
            if (appDelegate.is_touxiang_cunzai) {
                NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                NSString *filePath_01 = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"/avatar.png"];
                [cell_contact.imageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:filePath_01]]];
            }else{
                
            }
        }
        
        NSString *selfNumber=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
        if ([menber.telNum isEqualToString:selfNumber]) {
            cell_contact.messageBtn.hidden = YES;
            cell_contact.calliphoneBtn.hidden = YES;
        }else{
            cell_contact.messageBtn.hidden = NO;
            cell_contact.calliphoneBtn.hidden = NO;
        }
        
        cell_contact.menssegeID = indexPath;
        cell_contact.isSearchTB = NO;
        
        return cell_contact;
        
        
        
    }else{
        CellFirstThree *cell_firstThree = [tableView dequeueReusableCellWithIdentifier:CellIdentifierGrou];
        if (cell_firstThree == nil) {
            cell_firstThree = [[CellFirstThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierGrou];
        }
        enterprise_info *enterprise = [self.arr_enterprise objectAtIndex:(indexPath.row - [self.arr_menber count])];
        cell_firstThree.label.text = enterprise.orgName;
        cell_firstThree.imageView.image = [UIImage imageNamed:@"集团通讯录.png"];
        
        return cell_firstThree;
    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
    
        if (indexPath.row < [self.search_array_grou count]) {
            GroupAddress *groupadd = [[GroupAddress alloc]init];
            enterprise_info *enterprise = [self.arr_enterprise objectAtIndex:indexPath.row];
            groupadd.grou_ID = enterprise.ID;
            groupadd.title = enterprise.orgName;
            groupadd.hidesBottomBarWhenPushed = YES;
            if (groupadd.grou_ID) {
                [self.navigationController pushViewController:groupadd animated:YES];
            }
            
        }else{
            
            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
            menber_info *menber = [self.search_array_menber objectAtIndex:(indexPath.row - [self.search_array_grou count])];
            userDetail.hidesBottomBarWhenPushed=YES;
            userDetail.userInfo=menber;
            [self.navigationController pushViewController:userDetail animated:YES];
        }

    }else{
        if (indexPath.row < [self.arr_menber count]) {
//            GroupAddress *groupadd = [[GroupAddress alloc]init];
//            enterprise_info *enterprise = [self.arr_enterprise objectAtIndex:indexPath.row];
//            groupadd.grou_ID = enterprise.ID;
//            groupadd.title = enterprise.orgName;
//            groupadd.hidesBottomBarWhenPushed = YES;
//            if (groupadd.grou_ID) {
//                [self.navigationController pushViewController:groupadd animated:YES];
//            }
            UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
            menber_info *menber = [self.arr_menber objectAtIndex:indexPath.row];
            userDetail.hidesBottomBarWhenPushed=YES;
            userDetail.userInfo=menber;
            [self.navigationController pushViewController:userDetail animated:YES];
            
        }else{
            
            
            [self performSegueWithIdentifier:@"IdentifierGroupAddresss" sender:indexPath];
        }

    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"IdentifierGroupAddresss"]) {
        NSIndexPath *indexpath = sender;
        GroupAddress *groupadd = segue.destinationViewController;
        enterprise_info *enterprise = [self.arr_enterprise objectAtIndex:(indexpath.row - [self.arr_menber count])];
        groupadd.grou_ID = enterprise.ID;
        groupadd.title = enterprise.orgName;
        groupadd.hidesBottomBarWhenPushed = YES;
    }
}

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
    _HUD.userInteractionEnabled=NO;
    [self.view addSubview:_HUD];
    [_HUD show:YES];
}

#pragma mark ==========cellcontact delegate
-(void)menssegeIDCell:(NSIndexPath *)row type:(BOOL)isSearchTB{
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (searchString.length>0) {
        [self ContentForSearchText:searchString];
    }
    
    return YES;
}

-(void)ContentForSearchText:(NSString*)searchText{
    
}

//搜索方法

-(void)getsearchArray:(NSArray *)array seachTest:(NSString *)searchText type:(NSString *)type{

    if ([type isEqualToString:@"allmenber"]) {
        NSArray *array_use = [NSArray arrayWithArray:array];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.reserve1 contains[c] %@",searchText];
        NSArray *filtArray = [array_use filteredArrayUsingPredicate:predicate];
        _search_array_menber = [NSMutableArray arrayWithArray:filtArray];
        
        NSPredicate *predicateShortNum = [NSPredicate predicateWithFormat:@"SELF.shortNum contains[c] %@",searchText];
        NSArray *filtArrayShortNum = [array_use filteredArrayUsingPredicate:predicateShortNum];
        for (menber_info *menber in filtArrayShortNum) {
            if (![_search_array_menber containsObject:menber]) {
                [_search_array_menber addObject:menber];
            }
        }
        NSPredicate *predicateTelNum = [NSPredicate predicateWithFormat:@"SELF.telNum contains[c] %@",searchText];
        NSArray *filtArrayTelNum = [array_use filteredArrayUsingPredicate:predicateTelNum];
        for (menber_info *menber in filtArrayTelNum) {
            if (![_search_array_menber containsObject:menber]) {
                [_search_array_menber addObject:menber];
            }
        }
        
        NSPredicate *predicateMenberName = [NSPredicate predicateWithFormat:@"SELF.menberName contains[c] %@",searchText];
        NSArray *filtArrayMenberName = [array filteredArrayUsingPredicate:predicateMenberName];
        for (menber_info *menber in filtArrayMenberName) {
            if (![_search_array_menber containsObject:menber]) {
                [_search_array_menber  addObject:menber];
            }
        }

    }else if ([type isEqualToString:@"allenterprise"]){
    
        NSArray *array_use = [NSArray arrayWithArray:array];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.pinyin contains[c] %@",searchText];
        NSArray *filtArray = [array_use filteredArrayUsingPredicate:predicate];
        _search_array_grou = [NSMutableArray arrayWithArray:filtArray];
        
        NSPredicate *predicateOrgname = [NSPredicate predicateWithFormat:@"SELF.orgName contains[c] %@",searchText];
        NSArray *filtArrayOrgname = [array_use filteredArrayUsingPredicate:predicateOrgname];
        for (enterprise_info *ent in filtArrayOrgname) {
            [_search_array_grou addObject:ent];
        }
    }
}

//Change the title of cancel button in UISearchBar IOS7
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
//    if (IS_IOS_7)
//    {
        // 7.0 系统的适配处理。
        controller.searchBar.showsCancelButton = YES;
        UIButton *cancelButton;
        UIView *topView = controller.searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
        if (cancelButton) {
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
            cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
//    }else{
//        controller.searchBar.showsCancelButton = YES;
//        for(UIView *subView in controller.searchBar.subviews)
//        {
//            if([subView isKindOfClass:[UIButton class]])
//            {
//                [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
//            }
//        }
//    }
}

//Change the title of cancel button in UISearchBar IOS6
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    if (IS_IOS_7){
        searchBar.showsCancelButton = YES;
        for (UIView *subView in searchBar.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                UIButton *cancelButton = (UIButton*)subView;
                [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
                [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
                cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
                [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//    }
}

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
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
