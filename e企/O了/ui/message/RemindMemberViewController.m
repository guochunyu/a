//
//  RemindMemberViewController.m
//  O了
//
//  Created by 化召鹏 on 14-8-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "RemindMemberViewController.h"

@interface RemindMemberViewController (){
    NSMutableArray *memberListArray;
    NSMutableArray *searchResultArray;///<搜索结果
}

@end

@implementation RemindMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化
    self.leftButtTitle=@"取消";
//    [self.leftButt setBackgroundImage:nil forState:UIControlStateNormal];
//    [self.leftButt setBackgroundImage:nil forState:UIControlStateHighlighted];
    self.title=@"选择提醒的人";
    self.view.backgroundColor=[UIColor whiteColor];
    if (!memberListArray) {
        memberListArray=[[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!searchResultArray) {
        searchResultArray=[[NSMutableArray alloc] init];
    }
    
    
    _remindTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _remindTable.dataSource=self;
    _remindTable.delegate=self;
    _remindTable.rowHeight=50;
    [self.view addSubview:_remindTable];
    
    
    _searchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _searchBar.placeholder=@"姓名/手机号";//默认文字
    _searchBar.tintColor=[UIColor colorWithRed:0.271 green:0.789 blue:0.248 alpha:1.000];
    if (!IS_IOS_7) {
        //修改searchBar背景色
        _searchBar.backgroundColor=[UIColor colorWithRed:0.79 green:0.79 blue:0.81 alpha:1];
        [[_searchBar.subviews objectAtIndex:0] removeFromSuperview];
    }
    _searchBar.delegate=self;
    [_remindTable setTableHeaderView:_searchBar];
    
    _searchDisplayVC=[[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    [_searchDisplayVC setDelegate:self];
    _searchDisplayVC.searchResultsDelegate=self;
    _searchDisplayVC.searchResultsDataSource=self;
}
#pragma mark - 表格数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==_searchDisplayVC.searchResultsTableView) {
        return searchResultArray.count;
    }
    return memberListArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer=@"RemindMemberCell";
    RemindMemberCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!cell) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"RemindMemberCell" owner:self options:nil] lastObject];
    }
    menber_info *mi;
    if (tableView==_searchDisplayVC.searchResultsTableView) {
        mi=searchResultArray[indexPath.row];
    }else{
        mi=memberListArray[indexPath.row];
    }
    cell.nameLabel.text=mi.menberName;
    [cell.headImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/%@",HTTP_IP,HTTP_PORT,mi.avatar]] placeholderImage:[GetArcImageName arcImageNameStr:mi.telNum]];
    return cell;
}
#pragma mark - UITableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    menber_info *mi;
    if (tableView==_searchDisplayVC.searchResultsTableView) {
        mi=searchResultArray[indexPath.row];
    }else{
        mi=memberListArray[indexPath.row];
    }
    
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if (self.remindMember) {
        self.remindMember(NO,mi.menberName);
    }
}
#pragma mark - 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 导航条左右按钮
- (void)leftButtItemClick{
    
//    [self dismissModalViewControllerAnimated:YES];
    if (self.remindMember) {
        self.remindMember(YES,nil);
    }
}
- (void)rightButtClick{
    
}
#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //
    if (searchBar.text>0) {
        [self searchResult:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    DDLogInfo(@"%@",searchText);
    [self searchResult:searchText];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    
    return NO;
    
}

-(void)searchResult:(NSString *)searchText{
    [searchResultArray removeAllObjects];
    for(menber_info *mi in memberListArray){
        NSRange range_name=[mi.menberName.lowercaseString rangeOfString:searchText];

        NSRange range_tel=[mi.telNum rangeOfString:searchText];
        if(range_name.length>0 || range_tel.length>0){
            [searchResultArray addObject:mi];
            
        }
    }
    //刷新搜索结果表
    [_searchDisplayVC.searchResultsTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
