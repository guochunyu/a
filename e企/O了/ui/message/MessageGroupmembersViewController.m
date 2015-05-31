//
//  MessageGroupmembersViewController.m
//  e企
//
//  Created by zxdDong on 15-3-4.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "MessageGroupmembersViewController.h"
#import "CellContact.h"
#import "PersonInfoViewController.h"
#import "UserDetailViewController.h"

#import "NSString+TransformPinyin.h"

#define ROW_CELLHEIGHT  54 //行高
#define TOP_Y 17
#define LABLE_WIDTH 20
#define TEXT_FONT 15

@interface MessageGroupmembersViewController (){
    MBProgressHUD *_HUD;
    BOOL isPushBottom;
    NSIndexPath * _patch;
}

@end
static NSString * cellIndentfier = @"cell";
@implementation MessageGroupmembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群成员";
    
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0, 320,rect.size.height- 44) style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    NSString *myTel1=[ConstantObject sharedConstant].userInfo.phone;
    EmployeeModel * model =[SqlAddressData queryMemberInfoWithPhone:myTel1];
    self.UserPhoto = model.avatarimgurl;
    DDLogInfo(@"%d",self.MembersArray.count);
    [self.tableView registerClass:[CellContact class] forCellReuseIdentifier:cellIndentfier];
    [self sortAllmembers:self.MembersArray];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)sortAllmembers:(NSMutableArray *)array{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < array.count; i++) {
        
        NSString * str = [((EmployeeModel *)[array objectAtIndex:i]).first_name uppercaseString];
        [dic setObject:[array objectAtIndex:i] forKey:str];
    }
    NSArray * a = [dic allKeys];
    
    self.sortarray4 = [a sortedArrayUsingSelector:@selector(compare:)];
    NSArray * MembersArray = [NSArray arrayWithArray:self.MembersArray];
    //  MembersArray = [self mycompare:MembersArray];
    NSMutableArray * temparray = [NSMutableArray arrayWithArray:MembersArray];
    self.sortAllMembersArray = [self sectionFromToPersons:temparray];
    
    /*
     for (int i = 0; i < array1.count; i++) {
     NSString * str = [[[[array1 objectAtIndex:i] transformMandarinToLatin] substringToIndex:1] uppercaseString];
     [dic setObject:[array objectAtIndex:i] forKey:str];
     [array3 addObject:str];
     [array2 addObject:dic];
     }
     NSArray * array4 = [array3 sortedArrayUsingSelector:@selector(compare:)];
     */
    
}

- (NSArray *)mycompare:(NSArray *)array
{
    NSMutableArray * mutableArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < array.count; i++) {
        EmployeeModel * model = (EmployeeModel *)[array objectAtIndex:i];
        NSString * firstName = model.pinyin_name;
        [mutableArray addObject:firstName];
    }
    mutableArray = [NSMutableArray arrayWithArray:[mutableArray sortedArrayUsingSelector:@selector(compare:)]];
    NSMutableArray * membersArray = [NSMutableArray arrayWithArray:array];
    NSMutableArray * array22 = [[NSMutableArray alloc]init];
    for (int i = 0; i < mutableArray.count; i++) {
        if(i >0)
        {
            if([mutableArray[i] isEqualToString:mutableArray[i-1]])
                continue;
        }
        for (int j = 0; j < membersArray.count; j++) {
            if ([((EmployeeModel *)[membersArray objectAtIndex:j]).pinyin_name isEqual:[mutableArray objectAtIndex:i]]) {
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
            //    userName = [userName transformMandarinToLatin];
            if (userName.length && userName.length>0) {
                if ([userName  caseInsensitiveCompare:str] == NSOrderedSame  ) {
                    [arrayTemp addObject:[array objectAtIndex:i]];
                    
                    // [array removeObjectAtIndex:i];
                }
            }
        }
        NSArray * tempArray = [self mycompare:arrayTemp];
        [allArray addObject:tempArray];
        
    }
    //  [allArray addObject:array];
    
    return allArray;
}
//懒加载
-(NSMutableArray *)keyArray{
    if (_keyArray == nil) {
        self.keyArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _keyArray;
}

//懒加载
-(NSMutableArray *)sortAllMembersArray{
    if (_sortAllMembersArray == nil) {
        self.sortAllMembersArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _sortAllMembersArray;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return ROW_CELLHEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int a  = self.sortarray4.count;
    return self.sortarray4.count;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [[self.sortarray4 objectAtIndex:section] uppercaseString];
//}

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
    NSString *str = [self.sortarray4 objectAtIndex:section];
    
    UIButton * button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0, 0, 320, 30);
    button.backgroundColor=UIColorFromRGB(0xf8f8f8);
    //            HEXCOLOR(0xEEEEEE);
    button.tag=section+100-1;
    UIMyLabel *butt_label=[[UIMyLabel alloc] initWithFrame:CGRectMake(14, 0, tableView.frame.size.width-20, button.frame.size.height - 0.5)];
    butt_label.text=[str uppercaseString];
    butt_label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    butt_label.textAlignment=NSTextAlignmentLeft;
    butt_label.font=[UIFont systemFontOfSize:15];
    [button addSubview:butt_label];
    //线
    
    [head.contentView addSubview:button];
    
    return head;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.sortAllMembersArray objectAtIndex:section] count];
}

-(void)rortUserName:(EmployeeModel *)roomInfo{
    NSString * nameKey = [[[roomInfo.name transformMandarinToLatin]substringToIndex:1] uppercaseString];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CellContact *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentfier];
    self.roonInfoModel = [[self.sortAllMembersArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSLog(@"%@",self.roonInfoModel.name);
    cell.label_name.text = _roonInfoModel.name;
    CGSize size=[_roonInfoModel.name sizeWithFont:[UIFont systemFontOfSize:TEXT_FONT] constrainedToSize:CGSizeMake(MAXFLOAT, 20) lineBreakMode:NSLineBreakByCharWrapping];
    if (size.width > 80) {
        size.width = 80;
    }
    cell.label_name.frame=CGRectMake(cell.imageView.frame.size.width+cell.imageView.frame.origin.x+15, TOP_Y,size.width, LABLE_WIDTH);
    cell.label_position.text = _roonInfoModel.comman_orgName;
    CGSize size1=[_roonInfoModel.comman_orgName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,20) lineBreakMode:NSLineBreakByCharWrapping];
    if (size1.width > 150) {
        size1.width = 150;
    }
    cell.label_position.frame=CGRectMake(cell.label_name.frame.size.width+cell.label_name.frame.origin.x+10, TOP_Y,size1.width, LABLE_WIDTH);
    if (_roonInfoModel.avatarimgurl) {
        self.imacct = [ConstantObject sharedConstant].userInfo.imacct;
        if ([_roonInfoModel.imacct isEqual:_imacct]) {
            NSString *fileURL = self.UserPhoto;
            NSURL *url = [NSURL URLWithString:fileURL];
            [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
        }else{
            NSString *fileURL = _roonInfoModel.avatarimgurl;
            NSURL *url = [NSURL URLWithString:fileURL];
            DDLogInfo(@"%@",url);
            [cell.imageView setImageWithURL:url placeholderImage:[UIImage imageNamed:@"address_icon_person"]];
        }
    }
    if (indexPath.row == [[self.sortAllMembersArray objectAtIndex:indexPath.section] count] - 1) {
        cell.lineView.hidden = YES;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}


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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.roonInfoModel = [[self.sortAllMembersArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    UserDetailViewController *userDetail=[[UserDetailViewController alloc]initWithNibName:@"UserDetailViewController" bundle:nil];
    userDetail.organizationName = self.roonInfoModel.comman_orgName;
    userDetail.userInfo =self.roonInfoModel;
    userDetail.hidesBottomBarWhenPushed=YES;
    
    
    [self.navigationController pushViewController:userDetail animated:YES];
    
    [self.tableView reloadData];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
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
