//
//  HuiyiViewController.m
//  e企
//
//  Created by a on 15/4/28.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "HuiyiViewController.h"
#import "Download.h"
#import "HuiyiTableViewCell.h"
#import "HuiyiData.h"
#import "MacroDefines.h"
#import "HuiyiDetailViewController.h"
#import "UIScrollView+AH3DPullRefresh.h"
//NSString*const noticecxd=@"test";
@interface HuiyiViewController ()<DownloadDelegate>
@property(nonatomic,strong)Download *download;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,assign) NSInteger page;
@property(nonatomic,assign) NSInteger totalCount;
@property (nonatomic, strong)UIButton *back;
@property (nonatomic, strong)UIImageView *imagev;
@property (nonatomic, strong)UILabel *label;
@end
BOOL isLoadMore=NO;
static NSInteger getCount=20;//每次获取数据个数

@implementation HuiyiViewController
NSString* getHost(int page,int count){
    return [NSString stringWithFormat:@"http://%@/eas/conf/user_timeline?gid=%@&uid=%@&page=%d&count=%d",HTTP_IP,ORG_ID,USER_ID,page,count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSArray *aa=[[SqliteDataDao sharedInstanse]queryBulletinDataWithlocation:0 length:10];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.navigationController.navigationBar.barTintColor=[UIColor colorWithRed:56/255.0 green:112/255.0 blue:237/255.0 alpha:1];
    _download=[[Download alloc]init];
    _download.delegate=self;
    _dataArray=[[NSMutableArray alloc]init];
    _page=1;
    [_tableView setPullToLoadMoreHandler:^{
        isLoadMore=YES;
        if (_page*getCount<_totalCount) {
            _page++;
            [_download downloadWithURLString:getHost(_page,getCount)];
        }else{
            [_tableView loadMoreFinished];
        }
    }];
    [_tableView setPullToRefreshHandler:^{
        isLoadMore=NO;
        _page=1;
        [_download downloadWithURLString:getHost(_page,getCount)];
    }];
    [self setPullText:_page*getCount<_totalCount];
    
    _imagev = [[UIImageView alloc]init];
    _imagev.frame = CGRectMake(3, 30, 25, 25);
    [_imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:_imagev];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(25, 32, 90, 20);
    _label.text = @"会议列表";
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:_label];
}

-(void)setPullText:(bool)IsMore
{
    [_tableView setPullToRefreshViewLoadedText:@"刷新完成"];
    [_tableView setPullToRefreshViewPullingText:@"下拉刷新"];
    [_tableView setPullToRefreshViewLoadingText:@"刷新中..."];
    [_tableView setPullToRefreshViewReleaseText:@"松开刷新"];
    if(IsMore){
        [_tableView setPullToLoadMoreViewPullingText:@"上拉加载更多"];
        [_tableView setPullToLoadMoreViewReleaseText:@"松开加载"];
        [_tableView setPullToLoadMoreViewLoadedText:@"加载完成"];
        [_tableView setPullToLoadMoreViewLoadingText:@"加载中"];
    }else{
        [_tableView setPullToLoadMoreViewReleaseText:@"没有更多内容"];
        [_tableView setPullToLoadMoreViewPullingText:@"没有更多内容"];
        [_tableView setPullToLoadMoreViewLoadedText:@"没有更多内容"];
        [_tableView setPullToLoadMoreViewLoadingText:@"没有更多内容"];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    isLoadMore=NO;
    _page=1;
    [_download downloadWithURLString:getHost(_page,getCount)];
    [_activity startAnimating];
    _imagev.hidden = NO;
    _label.hidden = NO;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HuiyiTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"HuiyiTableViewCell"];
    HuiyiData *data=_dataArray[indexPath.row];
    [cell initCellByHuiyidata:data];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pushHuiyiDetail"]) {
        NSLog(@"点击cell推出详情");
        HuiyiTableViewCell *cell=(HuiyiTableViewCell*)sender;
        HuiyiDetailViewController *huiyiDetail=segue.destinationViewController;
        //cell.huiyidata.isRead=YES;
        huiyiDetail.huiyidata=cell.huiyidata;
        if (!cell.redImageview.hidden) {
            NSString *http=[NSString stringWithFormat:@"http://%@/eas/conf/confirm",HTTP_IP];
            NSString *post=[NSString stringWithFormat:@"conf_id=%@&gid=%@&uid=%@",huiyiDetail.huiyidata.conf_id,ORG_ID,USER_ID];
            Download *down=[[Download alloc]initPostRequestWithURLString:http andHTTPBodyDictionaryString:post];
            down.finishDownload=^(Download* down){
                NSLog(@"%@    %@",down.downloadDictionary,down.downloadDictionary[@"msg"]);
                if ([down.downloadDictionary[@"status"] integerValue]) {
                    NSLog(@"会议确认成功");
                }else{
                    NSLog(@"会议确认失败");
                }
            };
        }
    }
    _imagev.hidden = YES;
    _label.hidden = YES;
}

-(void)downloadDidFinishLoading:(Download *)download
{
    NSLog(@"%@",_download.downloadDictionary);
    NSNumber *i=_download.downloadDictionary[@"unconfirm_count"];
    [[NSUserDefaults standardUserDefaults] setObject:i forKey:@"unconfirm_count"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //_Meeting_Unread  = [NSString stringWithFormat:@"%@",i];
    //DDLogCInfo(@"会议类里的数据：%@",_Meeting_Unread);
    //[self Transmission_Information];
    //NSArray *dataArray=[NSArray arrayWithArray:_dataArray];
    if (!isLoadMore) {
        [_dataArray removeAllObjects];
    }
    NSArray *dictArray=_download.downloadDictionary[@"confs"];
    self.totalCount=[_download.downloadDictionary[@"total"] integerValue];
    for (NSDictionary *dict in dictArray) {
        /*  NSString *confid= [NSString stringWithFormat:@"%@",dict[@"conf_id"]];
         HuiyiData *data=nil;
         for (HuiyiData *huiyi in dataArray) {
         if ([huiyi.conf_id isEqualToString:confid]) {
         data=[huiyi setDateWithDictionary:dict];
         break;
         }
         }
         if (data==nil) {
         data=[[HuiyiData alloc]initWithDictionary:dict];
         }
         */
        HuiyiData *data=[[HuiyiData alloc]initWithDictionary:dict];
        [_dataArray addObject:data];
    }
    [_tableView reloadData];
    [_tableView loadMoreFinished];
    [_tableView refreshFinished];
    [self setPullText:_page*getCount<_totalCount];
    [_activity stopAnimating];
}
/*
//未读消息通知
-(void)Transmission_Information {
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    NSDictionary*data=@{@"testq": _Meeting_Unread};
    NSNotification*notificationq=[NSNotification notificationWithName:noticecxd object:nil userInfo:data];
    DDLogCInfo(@"通知里的数据：%@",data);
    [center postNotification:notificationq];
}
*/


- (IBAction)back:(UIBarButtonItem *)sender {
    //[self Transmission_Information];
    //会议通知返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
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
