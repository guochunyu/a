//
//  AppListTableViewController.m
//  e企
//
//  Created by shawn on 14/11/11.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "AppListTableViewController.h"
#import "JsonManager.h"
#import "AppListTableViewCell.h"
#import "AppInstalledTableViewCell.h"
#import "AppDetailViewController.h"
#import "ConstantObject.h"
#import "AFClient.h"

#define BOOL_INSTALL_APP @"boolInstallApps"
#define BOOL_UNINSTALL_APP @"boolUninstallApps"

@interface AppListTableViewController (){
    NSMutableArray *sectionTiltles;
    NSMutableArray *installApps;
    NSMutableArray *uninstallApps;
    id currentPlugin;
    UIImageView *imageViewHeaderSection;
    NSMutableDictionary *mutableDictHeaderSection;
    BOOL boolimageHeaderSection;
}

@end

@implementation AppListTableViewController

- (void)viewDidLoad {
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
     sectionTiltles = [NSMutableArray arrayWithCapacity:2];
    [super viewDidLoad];
    
//    sectionTiltles = [NSMutableArray arrayWithObjects:@"已安装应用",@"未安装应用", nil];
//    installApps = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"", nil];
//    uninstallApps = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"", nil];
    
    sectionTiltles = [[NSMutableArray alloc] init];
    installApps = [[NSMutableArray alloc] init];
    uninstallApps = [[NSMutableArray alloc] init];
    
    mutableDictHeaderSection = [[NSMutableDictionary alloc] init];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOL_INSTALL_APP];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOL_UNINSTALL_APP];
}
- (void)viewWillAppear:(BOOL)animated{
   [self loadAppData];
}
-(void) loadAppData{
    NowLoginUserInfo *userInfo = [ConstantObject sharedConstant].userInfo;
     NSString *gid=[[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    [client.requestSerializer setValue:@"50000" forHTTPHeaderField:@"PluginCode"];
    [client.requestSerializer setValue:gid forHTTPHeaderField:@"coid"];
    [client.requestSerializer setValue:@"-1" forHTTPHeaderField:@"serverversion"];
    [client.requestSerializer setValue:userInfo.uid forHTTPHeaderField:@"userId" ];
    [client.requestSerializer setValue:@"ios" forHTTPHeaderField:@"ostype" ];
    [client.requestSerializer setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[[NSArray alloc] init] forKey:@"plugins"];
    [parameters setValue:@"23423" forKey:@"cellid"];
    [parameters setValue:@"-1" forKey:@"serverversion"];
    [parameters setValue:@"4.0"forKey:@"osversion"];
    [parameters setValue:@"ios" forKey:@"ostype"];
    [parameters setValue:@"000000000000000" forKey:@"imei"];
    
    NSString *stringURL = [NSString stringWithFormat:@"http://%@/adc/terminalGetAppList",HTTP_ADCIP];
    NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:@"POST" URLString:stringURL parameters:nil error:nil];
    request.HTTPBody = [[JsonManager jsonFromDict:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.refreshControl endRefreshing];
        /*responseObject = @"{\"plugins\":[{\"sort\":\"999\",\"desc\":\"中国移动和包是一款手机钱包功能应用，支持各大银行的储蓄卡和信用卡，支持远程支付功能，支持话费自助以及日常生活缴费功能。\",\"ostype\":\"ios\",\"minos\":\"19\",\"descpic3\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/3.png\",\"descpic2\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/2.png\",\"digest\":\"\",\"descpic1\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/1.png\",\"type\":\"ipa\",\"osversion\":\"19\",\"version\":\"1\",\"name\":\"和包\",\"action\":\"com.test.fragmenttest13.RCSEntryAction\",\"option\":\"1\",\"app_bill_std\":\"13\",\"versionname\":\"1.0\",\"app_bill_model_id\":\"1\",\"pkg\":\"com.cmcc.MobileWallet\",\"manageUrl\":\"无\",\"iconurl\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/58x58.png\",\"code\":\"901\",\"url\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/MobileWallet.ipa\",\"iosinfo\":{\"plisturl\":\"https:\/\/api.touchsoft.com.cn\/cmcchy.plist\",\"manageurl\":\"管理平台网址\",\"appstoreurl\":\"苹果应用商店应用下载地址\",\"logo\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/58x58.png\",\"descpics\":[\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/1.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/2.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/3.png\"],\"desc\":\"中国移动和包是一款手机钱包功能应用，支持各大银行的储蓄卡和信用卡，支持远程支付功能，支持话费自助以及日常生活缴费功能。\",\"bundleversion\":\"1.0\",\"bundleidentifier\":\"com.cmcc.MobileWallet\",\"urlschema\":\"cmcchy:\/\/mobilewallet\",\"url\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/MobileWallet.ipa\",\"version\":\"1.0\"},\"size\":\"1495\",\"categoryid\":\"2\",\"descpics\":[\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/1.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/2.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/3.png\"],\"price\":\"收费的\",\"md5\":\"\"},{\"sort\":\"999\",\"desc\":\"1.新增大冒险模式\",\"ostype\":\"ios\",\"minos\":\"19\",\"descpic3\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/3.png\",\"descpic2\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/2.png\",\"digest\":\"\",\"descpic1\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/1.png\",\"type\":\"ipa\",\"osversion\":\"19\",\"version\":\"1\",\"name\":\"天天酷跑\",\"action\":\"com.test.fragmenttest13.RCSEntryAction\",\"option\":\"1\",\"app_bill_std\":\"13\",\"versionname\":\"1.0\",\"app_bill_model_id\":\"1\",\"pkg\":\"com.cmcc.MobileWallet\",\"manageUrl\":\"无\",\"iconurl\":\"http:\/\/a1.mzstatic.com\/us\/r30/Purple3\/v4\/55\/cb\/3a/55cb3a1c-b2a6-6f96-81b2-b190af2f81e8\/icon175x175.png\",\"code\":\"901\",\"url\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/MobileWallet.ipa\",\"iosinfo\":{\"plisturl\":\"\",\"manageurl\":\"管理平台网址\",\"appstoreurl\":\"https://itunes.apple.com/cn/app/tian-tian-ku-pao/id653350791?mt=8\",\"logo\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/58x58.png\",\"descpics\":[\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/1.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/2.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/3.png\"],\"desc\":\"中国移动和包是一款手机钱包功能应用，支持各大银行的储蓄卡和信用卡，支持远程支付功能，支持话费自助以及日常生活缴费功能。\",\"bundleversion\":\"1.0\",\"bundleidentifier\":\"com.cmcc.MobileWallet\",\"urlschema\":\"tencent100692648:\/\/\",\"url\":\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/MobileWallet.ipa\",\"version\":\"1.0\"},\"size\":\"1495\",\"categoryid\":\"2\",\"descpics\":[\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/1.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/2.png\",\"https:\/\/app.apec-china.org.cn\/confs\/dl\/ios\/3.png\"],\"price\":\"收费的\",\"md5\":\"\"}],\"serverversion\":309,\"version\":1}";*/

        //id jsonObject = [JsonManager dictFromJson:responseObject];
          DDLogInfo(@"应用中心列表获取成功：%@",operation.responseString);
        id jsonObject = responseObject;
        NSArray *plugins = jsonObject[@"plugins"];
        installApps = [NSMutableArray arrayWithCapacity:0];
        uninstallApps = [NSMutableArray arrayWithCapacity:0];
        for (int i=0; i<[plugins count]; i++) {
            id plugin = [plugins objectAtIndex:i];
            NSString *urlschema = plugin[@"iosInfo"][@"urlschema"];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://eqi/",urlschema]];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [installApps addObject:plugin];
            }else{
                [uninstallApps addObject:plugin];
            }
        }
        
        sectionTiltles = [NSMutableArray arrayWithCapacity:2];
        if ([installApps count] > 0) {
            [sectionTiltles addObject:@"已安装应用"];
            /*测试代码开始*
            if (installApps.count < 12) {
                 for (int i =0 ; [installApps count] < 12; i++){
                    id app = [[installApps objectAtIndex:0] copy];
                    NSString *appInfo = [JsonManager jsonFromDict:app];
                    appInfo = [appInfo stringByReplacingOccurrencesOfString:@"\"name\" : \"" withString:[NSString stringWithFormat:@"\"name\":\"测试(%d)",i]];
                    app = [JsonManager dictFromJson:appInfo];
                    [installApps addObject:app];
                }
            }
            
            *测试代码结束*/

        }
        if ([uninstallApps count] > 0) {
            [sectionTiltles addObject:@"未安装应用"];
            /*测试代码开始*
            if (uninstallApps.count < 12) {
                for (int i =0 ; [uninstallApps count] < 12; i++) {
                    id app = [[uninstallApps objectAtIndex:0] copy];
                    NSString *appInfo = [JsonManager jsonFromDict:app];
                    appInfo = [appInfo stringByReplacingOccurrencesOfString:@"\"name\" : \"" withString:[NSString stringWithFormat:@"\"name\":\"测试(%d)",i]];
                    app = [JsonManager dictFromJson:appInfo];
                    [uninstallApps addObject:app];
                }
            }
            
             *测试代码结束*/
        }
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"应用中心列表获取失败：%@",operation.responseString);
       [self.refreshControl endRefreshing];
    }];
    [client.operationQueue addOperation:operation];
    
}

-(void)refreshView :(UIRefreshControl *) refresh{
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"正在刷新数据..."];
    [self loadAppData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sectionTiltles.count >0 ? [sectionTiltles count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (sectionTiltles.count == 0) {
        return 1;
    }
    NSString *sectionTiltle = [sectionTiltles objectAtIndex:section];
    if ([sectionTiltle isEqualToString:@"已安装应用"]) {
        BOOL boolInstallApps = [[NSUserDefaults standardUserDefaults] boolForKey:BOOL_INSTALL_APP];
        int count;
        if (boolInstallApps)
        {
            count = [installApps count];
        }
        else
        {
            count = 0;
        }
        return count %4 ==0 ? count /4 : count / 4 + 1;
    }else {
        BOOL boolUninstallApps = [[NSUserDefaults standardUserDefaults] boolForKey:BOOL_UNINSTALL_APP];
        if (boolUninstallApps)
        {
            return [uninstallApps count];
        }
        else
        {
            return 0;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    static int height=30;
    return sectionTiltles.count>0 ? height:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *viewHeaderSection = [[UIView alloc] init];

    UIButton *buttonHeaderSection = [[UIButton alloc] init];
    buttonHeaderSection.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    buttonHeaderSection.backgroundColor = UIColorFromRGB(0xf8f8f8);
    buttonHeaderSection.tag = section-1;
    [buttonHeaderSection addTarget:self action:@selector(buttonHeaderSectionAction:) forControlEvents:UIControlEventTouchUpInside];
    [viewHeaderSection addSubview:buttonHeaderSection];
    
    UILabel *labelHeaderSection = [[UILabel alloc] init];
    labelHeaderSection.frame = CGRectMake(14, 5, 100, 20);
    //    labelHeaderSection.backgroundColor = [UIColor blackColor];
    labelHeaderSection.text = [sectionTiltles objectAtIndex:section];
    labelHeaderSection.textColor = UIColorFromRGB(0x999999);
    labelHeaderSection.font = [UIFont boldSystemFontOfSize:12];
    [viewHeaderSection addSubview:labelHeaderSection];
    
    UIView *viewLine = [[UIView alloc] init];
    viewLine.frame = CGRectMake(0, 29.5, self.view.frame.size.width, 0.5);
    viewLine.backgroundColor = UIColorFromRGB(0xEFEFF4);
    [viewHeaderSection addSubview:viewLine];
    
    imageViewHeaderSection = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-27, 11, 11, 6)];
    if ([[mutableDictHeaderSection objectForKey:[sectionTiltles objectAtIndex:section]] integerValue] == 0)
    {
        imageViewHeaderSection.image = [UIImage imageNamed:@"public_lager_all_arrow3.png"];
    }
    else
    {
        imageViewHeaderSection.image = [UIImage imageNamed:@"public_lager_all_arrow1.png"];
    }
    [viewHeaderSection addSubview:imageViewHeaderSection];
    
    return viewHeaderSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return sectionTiltles.count >0 ? [sectionTiltles objectAtIndex:section] : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (sectionTiltles.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nodata" forIndexPath:indexPath];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60, (tableView.frame.size.height - 340), 200, 20)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"无数据，下拉刷新！";
        label.font = size14;
        label.textColor = UIColorFromRGB(0x333333);
        [cell addSubview:label];
        return cell;
    }
    NSInteger section =  indexPath.section;
    NSString *sectionTiltle = [sectionTiltles objectAtIndex:section];
    NSMutableArray *apps = nil;
    if ([sectionTiltle isEqualToString:@"已安装应用"]) {
        apps =  installApps;
        NSInteger row = indexPath.row;
        AppInstalledTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appInstallItem" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        for (int i =1; i<= 4; i++) {
            int index = row * 4 + i -1;
            UIView *rowView =  nil;
            switch (i) {
                case 1:
                    rowView = cell.item1;
                    break;
                case 2:
                    rowView = cell.item2;
                    break;
                case 3:
                    rowView = cell.item3;
                    break;
                case 4:
                    rowView = cell.item4;
                    break;
                    
                default:
                    break;
            }
            if (index >= apps.count) {
                rowView.hidden = YES;
                continue;
            }else{
                rowView.hidden = NO;
            }
            
            id plugin = [apps objectAtIndex:index];
            
            UIImageView *iconImageView  = (UIImageView*)[rowView viewWithTag:101];
            UILabel *appNameLabel = (UILabel*)[rowView viewWithTag:102];
            
            if (index == 11) {
                [iconImageView setImage:[UIImage imageNamed:@"plugincenter_more.png"]];
                //iconImageView.frame = CGRectMake(20, 20, 20, 7);
                appNameLabel.text = @"更多";
            }else{
                [iconImageView setImageWithURL:[NSURL URLWithString:plugin[@"iosInfo"][@"logo"]]
                              placeholderImage:[UIImage imageNamed:@"public_icon_tabbar_apply_nm.png"]];
                appNameLabel.text = plugin[@"name"];
                rowView.tag = index + 10000;
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openApp:)];
                [rowView addGestureRecognizer:tapGesture];
                
//                iconImageView.image = [UIImage imageNamed:@"public_icon_tabbar_apply_nm.png"];
//                appNameLabel.text = @"和企录小分队";
            }
            
        }
        return cell;

    }else{// 未安装应用
        apps = uninstallApps;
        NSInteger row = indexPath.row;
        id plugin = [apps objectAtIndex:row];
        AppListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appNotInstallItem" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Configure the cell...
        [cell.iconImageView setImageWithURL:[NSURL URLWithString:plugin[@"iosInfo"][@"logo"]]
                           placeholderImage:[UIImage imageNamed:@"public_icon_tabbar_apply_nm.png"]];
        
        cell.appNameLable.text = plugin[@"name"];
        NSString *stringLabelContent  = plugin[@"iosInfo"][@"desc"];
//        if ([stringLabelContent isEqualToString:@"(null)"])
//        {
            cell.labelContent.text = [NSString stringWithFormat:@"%@", stringLabelContent];
//        }
    
        NSString *stringLabelVerMb = plugin[@"iosInfo"][@"size"];
        cell.labelVerMb.text = [NSString stringWithFormat:@"V%.1f | %@", 1.5, [self getSizeString:stringLabelVerMb.integerValue]];
        
//        cell.iconImageView.image = [UIImage imageNamed:@"public_icon_tabbar_apply_nm.png"];
//        cell.appNameLable.text = @"和企录项目";
////        cell.appNameLable.backgroundColor = [UIColor blackColor];
//        cell.labelContent.text = @"快速的科考队的肯定";
//        cell.labelVerMb.text = @"V1.2 | 2M";
////        cell.labelVerMb.backgroundColor = [UIColor redColor];
        
        return cell;

    }
    
}

-(void) openApp:(id)sender{
    UITapGestureRecognizer*tapGesture  = (UITapGestureRecognizer*)sender;
    id plugin = [installApps objectAtIndex:tapGesture.view.tag - 10000];
    NSString *urlschema = plugin[@"iosInfo"][@"urlschema"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://eqi/",urlschema]];
    if (![[UIApplication sharedApplication] openURL:url]) {
        /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示信息" message:[NSString stringWithFormat:@"打开应用失败(%@)!",urlschema]  delegate:self cancelButtonTitle:@"确定"  otherButtonTitles:nil, nil];
        [alertView show];*/
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (sectionTiltles.count == 0) {
        return  self.view.frame.size.height;
    }
    NSInteger section =  indexPath.section;
    NSString *sectionTiltle = [sectionTiltles objectAtIndex:section];
    if ([sectionTiltle isEqualToString:@"已安装应用"]) {
        return 80;
    }else{
        return 66;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (sectionTiltles.count == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self loadAppData];
        return;
    }
    NSInteger section =  indexPath.section;
    NSString *sectionTiltle = [sectionTiltles objectAtIndex:section];
    NSMutableArray *apps = nil;
    if ([sectionTiltle isEqualToString:@"已安装应用"]) {
        apps =  installApps;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }else{
        apps = uninstallApps;
    }
    currentPlugin = [apps objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"appDetail" sender:self];
}

- (void)buttonHeaderSectionAction:(id)sender
{
    UIButton *buttonSender = (UIButton *)sender;
    NSLog(@"=======> : 点中了%d", buttonSender.tag+1);
    NSString *stringSender = sectionTiltles[buttonSender.tag+1];
    if ([[mutableDictHeaderSection objectForKey:stringSender] integerValue] == 1)
    {
        if (buttonSender.tag)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOL_INSTALL_APP];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOL_UNINSTALL_APP];
        }
        if (buttonSender.tag && buttonSender.tag < 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BOOL_UNINSTALL_APP];
        }
        [mutableDictHeaderSection setObject:[NSNumber numberWithInteger:0] forKey:stringSender];
    }
    else
    {
        if (buttonSender.tag)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BOOL_INSTALL_APP];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BOOL_UNINSTALL_APP];
        }
        if (buttonSender.tag && buttonSender.tag < 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BOOL_UNINSTALL_APP];
        }
        [mutableDictHeaderSection setObject:[NSNumber numberWithInteger:1] forKey:stringSender];
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"appDetail"]) {
        AppDetailViewController *appDetailViewController = segue.destinationViewController;
        appDetailViewController.hidesBottomBarWhenPushed=YES;
        appDetailViewController.plugin = currentPlugin;
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] init];
        backButtonItem.title = @"详情";
        self.navigationItem.backBarButtonItem = backButtonItem;
    }
}

-(NSString*) getSizeString:(CGFloat) size{
    size = size / 1024.0f;
    NSString *suffix = @"M";
    if (size > 1024) {
        size = size / 1024.0f;
        suffix = @"G";
    }
    return  [NSString stringWithFormat:@"%.02f%@",size,suffix];
}


@end



