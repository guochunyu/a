//
//  ServiceNumberAllListViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-3-3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#define SUCCESS @200    //成功状态码
#define EXIST @400      //已存在

#import "ServiceNumberAllListViewController.h"
#import "ServiceNumberDetailViewController.h"
#import "ServiceNumberAllListCell.h"
#import "MessageChatViewController.h"

#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ServiceNumberAllListViewController ()<ServiceNumberAllListCellDelegate>{
    MBProgressHUD *_progressHUD;
    NSArray *_arraySNInfo;
    NSMutableArray *publicArray;///<数据源
}

@end

@implementation ServiceNumberAllListViewController
#pragma mark - 生命周期
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    if(!publicArray){
        publicArray=[[NSMutableArray alloc] init];
    }
    
    if (self.serviceNumberListType==ServiceNumberListTypeSubscrib) {
        UIButton *rightButton=[UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.bounds=CGRectMake(0, 0, 15, 15);
        [rightButton setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(addServiceNumber:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBar=[[UIBarButtonItem alloc]initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem=rightBar;
    }
    //tableView设置
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self initialData];
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.tableView.backgroundColor=[UIColor whiteColor];
//    self.tableView.backgroundView=nil;
//    if (IS_IOS_7) {
//        //        if (self.view.bounds.size.height==480 || self.view.bounds.size.height==568) {
//        if ([UIScreen mainScreen].bounds.size.height==480||[UIScreen mainScreen].bounds.size.height==568) {
//            
//            self.tableView.frame=CGRectMake(0, 0, 320, self.view.bounds.size.height);
//        }
//    }

//    [self initialData];
}
#pragma mark 初始化数据
- (void)initialData
{
    if (self.serviceNumberListType==ServiceNumberListTypeSubscrib) {
        self.title=@"公众号";
        
        _arraySNInfo=[[SqliteDataDao sharedInstanse] queryPublicDataWithPa_uuid];
//        if (_arraySNInfo.count==0) {
//            PublicaccountModel *pm=[[PublicaccountModel alloc]init];
//            pm.name=@"无公众号，请关注";
//            NSArray * array=[[NSArray alloc]initWithObjects:pm, nil];
//            _arraySNInfo=array;
//        }
        [self.tableView reloadData];
        
        [[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"queryusersub" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlQueryusersubWithPagesize:pageSize withPageNum:@"1"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"s---%@",operation.responseString);
            [_progressHUD hide:YES];
            
            NSError *error=nil;
            NSXMLElement *content_message=[[DDXMLElement alloc] initWithXMLString:operation.responseString error:&error];
            if (error) {
                DDLogInfo(@"解析出错");
            }
            NSArray *publicaccounts=[content_message elementsForName:@"publicaccounts"];
            [publicArray removeAllObjects];
            if (publicaccounts.count!=0) {
                
                
                NSMutableArray *pa_uuidArray=[[NSMutableArray alloc] initWithArray:_arraySNInfo];
                //是否有删掉的服务号
                BOOL isDelete=NO;
                for (NSXMLElement *element in publicaccounts) {
                    PublicaccountModel *pm=[[PublicaccountModel alloc] init];
                    pm.logo=[[element elementForName:@"logo"] stringValue];
                    pm.name=[[element elementForName:@"name"] stringValue];
                    pm.pa_uuid=[[element elementForName:@"pa_uuid"] stringValue];
                    pm.sip_uri=[[element elementForName:@"sip_uri"] stringValue];
                    [publicArray addObject:pm];
                    for (int i=0;i<pa_uuidArray.count;) {
                        PublicaccountModel *publicModel = [pa_uuidArray objectAtIndex:i];
                        if ([publicModel.pa_uuid isEqualToString:pm.pa_uuid]) {
                            [pa_uuidArray removeObject:publicModel];
                        }else{
                            i++;
                        }
                    }
                }
                for (PublicaccountModel *publicModel in pa_uuidArray) {
                    isDelete=YES;
                    [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:publicModel.pa_uuid];
                    [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:publicModel.pa_uuid];
                    [[SqliteDataDao sharedInstanse] deletePublicDataWithPa_uuid:publicModel.pa_uuid];
                    
                }
                
                _arraySNInfo=publicArray;
                [[SqliteDataDao sharedInstanse] insertDataToPublicData:_arraySNInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
                [self.tableView reloadData];
            }else{
                //是否有删掉的服务号
                BOOL isDelete=NO;
                //清空
                for (PublicaccountModel *publicModel in _arraySNInfo) {
                    [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:publicModel.pa_uuid];
                    [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:publicModel.pa_uuid];
                    [[SqliteDataDao sharedInstanse] deletePublicDataWithPa_uuid:publicModel.pa_uuid];
                    isDelete=YES;
                }
                if (isDelete) {
                    //  取消关注公众号，刷新聊天列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
                }
                
                
                [self.tableView reloadData];
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_progressHUD hide:YES];
            [[ConstantObject app] showWithCustomView:nil detailText:@"无法连接到网络,请稍候重试!" isCue:1 delayTime:1 isKeyShow:NO];
        }];
    }else{
        self.title=@"公众号广场";
        _progressHUD=[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        _progressHUD.removeFromSuperViewOnHide=YES;
        _progressHUD.userInteractionEnabled=NO;
        _progressHUD.labelFont=[UIFont systemFontOfSize:12];
        _progressHUD.labelText=@"正在搜索";
        
        [[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"getpubliclist" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlGetpubliclistWithPagesize:@"100" withPageNum:@"1"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            DDLogInfo(@"s---%@",operation.responseString);
            [_progressHUD hide:YES];
            
            NSError *error=nil;
            NSXMLElement *content_message=[[DDXMLElement alloc] initWithXMLString:operation.responseString error:&error];
            if (error) {
                DDLogInfo(@"解析出错");
            }
            [publicArray removeAllObjects];
            NSArray *publicaccounts=[content_message elementsForName:@"publicaccounts"];
            for (NSXMLElement *element in publicaccounts) {
                PublicaccountModel *pm=[[PublicaccountModel alloc] init];
                pm.logo=[[element elementForName:@"logo"] stringValue];
                pm.name=[[element elementForName:@"name"] stringValue];
                pm.pa_uuid=[[element elementForName:@"pa_uuid"] stringValue];
                pm.sip_uri=[[element elementForName:@"sip_uri"] stringValue];
                [publicArray addObject:pm];
            }
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_progressHUD hide:YES];
            [[ConstantObject app] showWithCustomView:nil detailText:@"无法连接到网络,请稍候重试!" isCue:1 delayTime:1 isKeyShow:NO];
        }];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.serviceNumberListType==ServiceNumberListTypeUnsubscrib) {
        return publicArray.count;
    }
    int count=_arraySNInfo.count/ROW_COLUMN;
    int count1=_arraySNInfo.count%ROW_COLUMN>0?1:0;
    return count+count1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.serviceNumberListType==ServiceNumberListTypeSubscrib) {
        static NSString *CellIdentifier = @"PublicNumberCell";
        ServiceNumberAllListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil) {
            cell=[[ServiceNumberAllListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier useGesture:YES];
            
            cell.delegate=self;
        }
        // 截取的开始位置
        int location = indexPath.row * ROW_COLUMN;
        // 截取的长度
        int length = ROW_COLUMN;
        // 如果截取的范围越界
        if (location + length >= _arraySNInfo.count) {
            length = _arraySNInfo.count - location;
        }
        // 截取范围
        NSRange range = NSMakeRange(location, length);
        // 根据截取范围，获取这行所需的产品
        NSArray *arraySub = [_arraySNInfo subarrayWithRange:range];
        // 设置这个行Cell所需的产品数据
        cell.arraySub=arraySub;
        return cell;
    }else{
        static NSString *CellIdentifier = @"NoPublicNumberCell";
        NoPublicNumberCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"NoPublicNumberCell" owner:self options:nil] lastObject];
        }
        PublicaccountModel *pm=[publicArray objectAtIndex:indexPath.row];
        [cell.headImageView setImageWithURL:[NSURL URLWithString:pm.logo] placeholderImage:defaultHeadImage];
        cell.nameLabel.text=pm.name;
//        CGSize size=
        
        return cell;
       
    }
    
    
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.serviceNumberListType==ServiceNumberListTypeUnsubscrib) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PublicaccountModel *pm=[publicArray objectAtIndex:indexPath.row];
        ServiceNumberDetailViewController *detailVC=[[ServiceNumberDetailViewController alloc] init];
        detailVC.publicaccontModel=pm;
        detailVC.hidesBottomBarWhenPushed=YES;
        detailVC.subscribestatusType=0;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}
#pragma mark - target
#pragma mark 返回
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 添加服务号
- (void)addServiceNumber:(UIButton *)sendr
{
    ServiceNumberAllListViewController *snAll=[[ServiceNumberAllListViewController alloc]initWithStyle:UITableViewStylePlain];
    snAll.serviceNumberListType=ServiceNumberListTypeUnsubscrib;
    snAll.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:snAll animated:YES];
}
#pragma mark - 委托事件
- (void)serviceNumberAllListCell:(ServiceNumberAllListCell *)cell clickServiceNumberInfo:(PublicaccountModel *)snInfo
{
    PublicaccountModel *pm=snInfo;
//    ServiceNumberDetailViewController *detailVC=[[ServiceNumberDetailViewController alloc] init];
//    detailVC.publicaccontModel=pm;
//    detailVC.hidesBottomBarWhenPushed=YES;
//    detailVC.subscribestatusType=1;
//    [self.navigationController pushViewController:detailVC animated:YES];
    MessageChatViewController *messageVC=[[MessageChatViewController alloc] init];
    messageVC.chatType=2;
    messageVC.hidesBottomBarWhenPushed=YES;
    messageVC.publicModel=pm;
    [self.navigationController pushViewController:messageVC animated:YES];
}
- (void)serviceNumberAllListCell:(ServiceNumberAllListCell *)cell deleteServiceNumberInfo:(PublicaccountModel *)snInfo
{
    
}
#pragma mark - CustomMethod
#pragma mark 隐藏指示器
- (void)hideProgressHud:(MBProgressHUD *)progressHUD withText:(NSString *)msg
{
    progressHUD.mode=MBProgressHUDModeText;
    progressHUD.margin=10;
    progressHUD.opacity=0.7;
    progressHUD.yOffset=150.f;
    progressHUD.labelFont=[UIFont systemFontOfSize:12];
    progressHUD.labelText=msg;
    progressHUD.userInteractionEnabled=NO;
    [progressHUD hide:YES afterDelay:1];
}
@end
