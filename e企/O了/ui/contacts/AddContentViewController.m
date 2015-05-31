//
//  MessageGroupChatAddUserViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-1-13.
//  Copyright (c) 2014年 roya. All rights reserved.
//

#define SEARCH_HEIGHT 40 //tableView头部高度
#define SCROLLVIEW_ICON_MARGIN 3    //scrollView的图标间距
#define ANIMATION_DURATION 0.2  //动画持续时间

#import "NSDictionary+Extra.h"

#import "AddContentViewController.h"
#import "AddContentCell.h"

//#import "AllEnterprise.h"
//#import "AllMenber.h"
//#import "FrequentContacts.h"
#import "menber_info.h"
#import "SqliteContacts.h"

#import "NSArray+FirstLetterArray.h"


@interface AddContentViewController (){
    UIButton *_btnSender;
    UIScrollView *_scrollView;
    NSMutableDictionary *_dictionarySelectUser;   ///<要添加的群聊用户
    NSArray *_arrayFrequent;                    ///<测试数据
    
    NSDictionary *_dictionaryContact;   //所有联系人字典
//    NSDictionary *_dictionarySort;  //排序后字段所对应的联系人ID
    NSMutableArray *_arraySort;            //排序的字段
}

@end

@implementation AddContentViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self=[super initWithStyle:style];
    if (self) {
        self.enterpriseID=1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dictionarySelectUser=[NSMutableDictionary dictionary];
//    _arrayFrequent=[FrequentContacts sharedInstanse].FreqmenberAraay;
    
    _dictionaryContact=[[NSMutableDictionary alloc]init];
//    for (menber_info *con in _arrayFrequent) {
//        [_dictionaryContact setObject:con forKey:[NSString stringWithFormat:@"%d",con.ID]];
//    }
//    _dictionarySort = [_arrayFrequent sortedArrayUsingFirstLetter];
//    _arraySort= [[[_dictionarySort allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
//    [_arraySort insertObject:@"#" atIndex:0];
//    NSLog(@"%@",_dictionarySort);
//    NSLog(@"%@",_arraySort);
    
//    _firstThree=[SqliteContacts getFixedInfo];
    _dictionaryContact=[SqliteContacts getFreq];
    _arraySort=[[_dictionaryContact.allKeys sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
//    [_arraySort insertObject:@"↑" atIndex:0];
//    [_arraySort insertObject:@"★" atIndex:1];
    [_arraySort insertObject:@"#" atIndex:0];
    
    [self initial];
}
-(void)getData{
    
//    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
//    AllEnterprise *allenterprise = [AllEnterprise sharedInstanse];
//    for (enterprise_info *enterprise in allenterprise.EnterpriseArray) {
//        if (enterprise.OrgNum == self.enterpriseID) {
//            [mutArray addObject:enterprise];
//        }
//    }
//    self.arrayEnterprise = mutArray;
//    
//    NSMutableArray *mutArraymenb = [[NSMutableArray alloc]init];
//    AllMenber *allmenber = [AllMenber sharedInstanse];
//    for (menber_info *menber in allmenber.menberAraay) {
//        if (menber.orgNum == self.enterpriseID) {
//            [mutArraymenb addObject:menber];
//        }
//    }
//    self.arrayMenber = mutArraymenb;
    
    NSDictionary *dic=[SqliteContacts getContactWithOrgNum:[NSString stringWithFormat:@"%d",self.enterpriseID]];
    self.arrayEnterprise=dic[SqliteContactsEnterprise];
    self.arrayMenber=dic[SqliteContactsMember];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - tableView数据源、代理设置
#pragma mark 返回tableView多少组数据
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arraySort.count;
}
#pragma mark 返回多少行数据
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int row=0;
    if (section==0) {
        row=self.arrayEnterprise.count;
    }else{
        NSArray *arrayLetter=_dictionaryContact[_arraySort[section]];
        row=arrayLetter.count;
    }
    return row;
}
#pragma mark tableViewCell的高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
#pragma mark tableView的分组标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle=@"";
    if (section!=0) {
        sectionTitle=_arraySort[section];
    }
    return sectionTitle;
}
#pragma mark tableView索引标题
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _arraySort;
}
#pragma mark 返回显示的Cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierEnterprise=@"enterpriseCell";
    static NSString *cellIdentifierMember=@"memberCell";
    if (indexPath.section==0) {
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierEnterprise];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifierEnterprise];
        }
        
        return cell;
    }else{
        AddContentCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifierMember];
        if (cell==nil) {
            cell=[[AddContentCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifierMember];
        }
        NSArray *arrayMember=_dictionaryContact[_arraySort[indexPath.section]];
        menber_info *menber=(menber_info*)arrayMember[indexPath.row];
        cell.imageView.image=[UIImage imageNamed:[NSString stringWithFormat:@"%ld.gif",(indexPath.row+1)]];
        cell.textLabel.text=menber.menberName;
        cell.detailTextLabel.text=menber.telNum;
        //Cell的CheckBox
        NSString  *imageName=@"nocheckcontact.png";
        NSString *key=[NSString stringWithFormat:@"%ld",menber.ID];
        if ([_dictionarySelectUser.allKeys containsObject:key]) {
            imageName=@"checkcontact.png";
        }
        UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
        accessoryView.image=[UIImage imageNamed:imageName];
        return cell;
    }
}
#pragma mark 选中某一行的处理事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    menber_info *currentObject=(menber_info *)_arrayFrequent[indexPath.row];
    NSString *key=[NSString stringWithFormat:@"%d",currentObject.ID];
    if ([_dictionarySelectUser.allKeys containsObject:key]) {//存在该用户－》移除
        //移除数据中存在的用户
        [_dictionarySelectUser removeObjectForKey:key];
        //从ScrollView中移除view
        [self removeSubViewWithTag:[key integerValue] FromScrollView:_scrollView];
    }else{  //用户没有添加－》添加用户
       //添加选中用户到数据
        [_dictionarySelectUser setValue:currentObject forKey:key];
        //在ScrollView中添加视图Button
        [self addSubViewkWithTag:[key integerValue] withImageName:[NSString stringWithFormat:@"%d.gif",(indexPath.row+1)] ToScrollView:_scrollView];
    }
    //checkBox设置
    NSString  *imageName=@"nocheckcontact.png";
    if ([_dictionarySelectUser.allKeys containsObject:key]) {
        imageName=@"checkcontact.png";
    }
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    UIImageView *accessoryView=(UIImageView *)cell.accessoryView;
    accessoryView.image=[UIImage imageNamed:imageName];
}
#pragma mark - 自定义的方法
#pragma mark 初始化
- (void)initial
{
    //toolbar设置
    CGFloat widthScreen=[UIScreen mainScreen].bounds.size.width;
    CGRect frameToolbar=self.navigationController.toolbar.frame;
    //scrollView设置
    _scrollView=[[UIScrollView alloc]init];
    _scrollView.frame=CGRectMake(0, 0, widthScreen-53-4, frameToolbar.size.height);
    //默认空白视图
    CGFloat iconHeight=frameToolbar.size.height-2*SCROLLVIEW_ICON_MARGIN;
    UIImageView *imageViewEmpty=[[UIImageView alloc]initWithFrame:CGRectMake(SCROLLVIEW_ICON_MARGIN, SCROLLVIEW_ICON_MARGIN, iconHeight, iconHeight)];
    imageViewEmpty.image=[UIImage imageNamed:@"tool_empty_member.png"];
    imageViewEmpty.tag=INT_MAX;
//    NSLog(@"%d",INT_MAX);
    [_scrollView addSubview:imageViewEmpty];
    //toolBar的确定按钮设置
    _btnSender=[UIButton buttonWithType:UIButtonTypeCustom];
    _btnSender.titleLabel.font=[UIFont systemFontOfSize:12];
    [_btnSender setTitle:@"确定" forState:UIControlStateNormal];
    _btnSender.frame=CGRectMake(_scrollView.frame.size.width+2, (_scrollView.frame.size.height-25)/2, 53, 25);
    [_btnSender setBackgroundImage:[UIImage imageNamed:@"tool_button_disable.png"] forState:UIControlStateDisabled];
    [_btnSender setBackgroundImage:[UIImage imageNamed:@"tool_button_enable.png"] forState:UIControlStateNormal];
    [_btnSender setBackgroundImage:[UIImage imageNamed:@"tool_button_enable_highlighted.png"] forState:UIControlStateHighlighted];
    _btnSender.enabled=NO;
    
    [self.navigationController.toolbar addSubview:_scrollView];
    [self.navigationController.toolbar addSubview:_btnSender];
    self.navigationController.toolbarHidden=NO;
    //navigation设置
    self.title=@"发起群聊";
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tabbar_3.png"] forBarMetrics:UIBarMetricsDefault];
    //tableView HeaderView添加SearchBar
    CGRect mainFrame=[[UIScreen mainScreen]bounds];
    UISearchBar *searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, mainFrame.size.width, SEARCH_HEIGHT)];
    searchBar.placeholder=@"搜索";
    self.tableView.tableHeaderView=searchBar;
}

#pragma mark 从ScrollView中移除view
- (void)removeSubViewWithTag:(NSInteger)tag FromScrollView:(UIScrollView *)scrollView
{
    //移除ScrollView中存在的Button
    NSArray *buttons=[scrollView subviews];
    CGRect removeViewRect=CGRectZero;
    //动画效果
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    //button变幻
    for (UIView *view in buttons) {
        if (view.tag==tag) {
            [view removeFromSuperview];
            removeViewRect=view.frame;
            continue;
        }
        if(!CGRectEqualToRect(removeViewRect, CGRectZero)&&[view isKindOfClass:[UIButton class]]){
            view.transform=CGAffineTransformTranslate(view.transform,-(removeViewRect.size.width+SCROLLVIEW_ICON_MARGIN), 0);
        }
    }
    //空白头像变幻
    UIView *emptyView=[scrollView viewWithTag:INT_MAX];
    emptyView.transform=CGAffineTransformTranslate(emptyView.transform, -emptyView.frame.size.width-SCROLLVIEW_ICON_MARGIN, 0);
    //contentSize重设
    scrollView.contentSize=CGSizeMake(scrollView.contentSize.width-removeViewRect.size.width-SCROLLVIEW_ICON_MARGIN,scrollView.contentSize.height);
    //结束动画
    [UIView commitAnimations];
    //确定按钮数量变换
    if ([_dictionarySelectUser count]==0) {
        _btnSender.enabled=NO;
        [_btnSender setTitle:@"确定" forState:UIControlStateDisabled];
    }else{
        [_btnSender setTitle:[NSString stringWithFormat:@"确定(%d)",[_dictionarySelectUser count]] forState:UIControlStateNormal];
    }
}
#pragma mark 在ScrollView中添加视图Button
- (void)addSubViewkWithTag:(NSInteger)tag withImageName:(NSString *)imageName ToScrollView:(UIScrollView *)scrollView
{
    //移除scrollview中不是button类的视图
    NSMutableArray *subViews=[NSMutableArray array];
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [subViews addObject:view];
        }
    }
    CGRect scrollFrame=scrollView.frame;
    CGFloat iconHeight=scrollFrame.size.height-2*SCROLLVIEW_ICON_MARGIN;
    //添加button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dropSelectUser:) forControlEvents:UIControlEventTouchUpInside];
    button.tag=tag;
    if (subViews.count<=0) {
        button.frame=CGRectMake(SCROLLVIEW_ICON_MARGIN, SCROLLVIEW_ICON_MARGIN, iconHeight, iconHeight);
    }else{
        CGRect frame=[subViews.lastObject frame];
        button.frame=CGRectMake(frame.origin.x+frame.size.width+SCROLLVIEW_ICON_MARGIN, SCROLLVIEW_ICON_MARGIN, iconHeight, iconHeight);
    }
    //[scrollView addSubview:button];
    UIImageView *emptyView=(UIImageView *)[scrollView viewWithTag:INT_MAX];
    [scrollView insertSubview:button atIndex:[subViews indexOfObject:emptyView]];
    scrollView.contentSize=CGSizeMake(button.frame.origin.x+button.frame.size.width+SCROLLVIEW_ICON_MARGIN+iconHeight, scrollView.bounds.size.height);
    //动画设置
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    //偏移量设置
    CGFloat exceptEmptySize=scrollView.contentSize.width-SCROLLVIEW_ICON_MARGIN-iconHeight;
    if (exceptEmptySize>scrollView.bounds.size.width) {
        scrollView.contentOffset=CGPointMake(exceptEmptySize-scrollView.bounds.size.width, 0);
    }
    emptyView.transform=CGAffineTransformTranslate(emptyView.transform, SCROLLVIEW_ICON_MARGIN+iconHeight, 0);
    //结束动画
    [UIView commitAnimations];
    //确定按钮数量变换
    _btnSender.enabled=YES;
    [_btnSender setTitle:[NSString stringWithFormat:@"确定(%d)",[_dictionarySelectUser count]] forState:UIControlStateNormal];
    for (UIView *view in scrollView.subviews) {
//        NSLog(@"%s,%d",object_getClassName(view),view.tag);
    }
}
#pragma mark 取消
- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark 删除选择用户，Button事件
- (void)dropSelectUser:(UIButton *)sender
{
    NSObject *selectObject=[_dictionarySelectUser objectForKey:[NSString stringWithFormat:@"%d",sender.tag]];
    //改变TableViewCell的状态视图
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[_arrayFrequent indexOfObject:selectObject] inSection:0];
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView=(UIImageView *)cell.accessoryView;
    imageView.image=[UIImage imageNamed:@"nocheckcontact.png"];
    //移除数据中存在的用户
    [_dictionarySelectUser removeObjectForKey:[NSString stringWithFormat:@"%d",sender.tag]];
    //移除ScrollView中的视图
    [self removeSubViewWithTag:sender.tag FromScrollView:_scrollView];
}
@end
