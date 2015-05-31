//
//  AssetsViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-1-17.
//  Copyright (c) 2014年 roya. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import "RYAssetsPickerController.h"
#import "RYAssetsViewController.h"
#import "RYAssetsCell.h"
#import "RYAsset.h"
#import "MBProgressHUD.h"
#import "RYAssetsBrowerViewController.h"
#import "RYAssetsMediaPlayerViewController.h"

@interface RYAssetsViewController ()<RYAssetDelegate>{
    UIButton *_buttonSend;      ///<发送按钮
    UIButton *_buttonPreview;   ///<预览图片
    UIView *_toolBar;
    //    NSMutableArray *_arrayAsset;           ///<资源列表Group所包含的所有RYAsset
}

@end

@implementation RYAssetsViewController
#pragma mark - 生命周期
#pragma mark 初始化
- (id)init
{
    self = [super init];
    if (self) {
        self.selectCount=0;
    }
    return self;
}
#pragma mark 界面加载完成viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height-35-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource  = self;
    self.title=[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    [self initialBar];
    self.navigationController.toolbarHidden=YES;
    //tableView设置
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self initialAsset];
    
}
#pragma mark 界面将要显示viewWillAppear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
    self.navigationController.toolbarHidden=YES;
    [self addReturnButton];
    //    [self addCancleButton];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self removeReturnButton];
    //    [self removeCancleButton];
}

-(void)addReturnButton{
    UIButton *buttonLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonLeft.tag = 99;
    buttonLeft.frame=CGRectMake(0, 0, 44, 44);
    [buttonLeft setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"nav-bar_back.png"]]];
    [buttonLeft addTarget:self.parent action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:buttonLeft];
}

-(void)removeReturnButton{
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:99];
    if (btn) {
        [btn removeFromSuperview];
    }
}

-(void)addCancleButton{
    UIButton *buttonRight=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonRight.tag = 100;
    buttonRight.frame=CGRectMake(self.view.bounds.size.width-44-14, 0, 44, 44);
    //[buttonRight setTitle:@"取消" forState:UIControlStateNormal];
    buttonRight.titleLabel.font = [UIFont systemFontOfSize:16];
    buttonRight.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [buttonRight addTarget:self.parent action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:buttonRight];
}

-(void)removeCancleButton{
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:100];
    if (btn) {
        [btn removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark 初始化Bar
- (void)initialBar
{   //change
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica-Bold" size:19],NSFontAttributeName,nil]];
    //    //leftBarButtonItem设置 返回
    //    UIButton *buttonLeft=[UIButton buttonWithType:UIButtonTypeCustom];
    //    [buttonLeft setImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    //    [buttonLeft setImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateHighlighted];
    //
    //    buttonLeft.bounds=CGRectMake(0, 0, 44, 44);
    //    [buttonLeft addTarget:self.parent action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    //    UIBarButtonItem *barItemLeft=[[UIBarButtonItem alloc]initWithCustomView:buttonLeft];
    //    self.navigationItem.leftBarButtonItem=barItemLeft;
    
    //rightBarButtonItem设置 取消
    self.navigationItem.hidesBackButton = YES;
    [self setToolBar];
    
}

-(void)setToolBar
{
    _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-35, self.view.frame.size.width, 35)];
    _toolBar.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    [self.view addSubview:_toolBar];
    
    UIButton *buttonPreview=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonPreview.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonPreview.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    buttonPreview.frame=CGRectMake(14, 10, 50, 15);
    [buttonPreview setTitle:@"预览" forState:UIControlStateNormal];
    [buttonPreview setTitleColor:[UIColor colorWithRed:173/255.0 green:173/255.0 blue:173/255.0 alpha:1] forState:UIControlStateNormal];
    [buttonPreview setTitleColor:[UIColor colorWithRed:173/255.0 green:173/255.0 blue:173/255.0 alpha:1] forState:UIControlStateHighlighted];
    buttonPreview.titleLabel.textAlignment = NSTextAlignmentLeft;
    //[buttonPreview setTitleColor:[UIColor colorWithRed:29/255.0 green:106/255.0 blue:238/255.0 alpha:1] forState:UIControlStateHighlighted];
    [buttonPreview addTarget:self action:@selector(preview:) forControlEvents:UIControlEventTouchUpInside];
    buttonPreview.enabled = NO;
    _buttonPreview=buttonPreview;
    [_toolBar addSubview:buttonPreview];
    
    
    //toolbar设置 发送
    UIButton *buttonSend=[UIButton buttonWithType:UIButtonTypeCustom];
    buttonSend.titleLabel.font=[UIFont systemFontOfSize:12];
    buttonSend.frame=CGRectMake(self.view.bounds.size.width-55-7.5, 4.5, 55, 26);
    buttonSend.layer.masksToBounds = YES;
    buttonSend.layer.cornerRadius = 5;
    RYAssetsPickerController *picker=(RYAssetsPickerController *)self.parent;
    [buttonSend setTitle:picker.titleButtonSure forState:UIControlStateNormal];
    buttonSend.backgroundColor = [UIColor colorWithRed:50/255.0 green:115/255.0 blue:240/255.0 alpha:0.4];
    [buttonSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSend setTitleColor:[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1] forState:UIControlStateHighlighted];
    
    [buttonSend addTarget:self action:@selector(sendImage:) forControlEvents:UIControlEventTouchUpInside];
    _buttonSend=buttonSend;
    [_toolBar addSubview:buttonSend];
    
}


#pragma mark 初始化Asset
- (void)initialAsset
{
    _arrayAsset=[[NSMutableArray alloc]init];
    [_arrayAsset removeAllObjects];
    //显示指示器
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    // 获取全局调度队列,后面的标记永远是0
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建调度群组
    dispatch_group_t group = dispatch_group_create();
    // 向调度群组添加异步任务，并指定执行的队列
    dispatch_group_async(group, queue, ^{
        //遍历AssetsGroup,并给赋值给_arrayAsset
        [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                RYAsset *asset=[[RYAsset alloc]initWithAsset:result];
                asset.parent=self;
                [_arrayAsset addObject:asset];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //隐藏指示器
                    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    //重新刷新数据
                    [_tableView reloadData];
                });
            }
        }];
    });
}
#pragma mark - BarButton事件
#pragma mark 跳到预览界面
- (void)preview:(id)sender
{
    [self toPreviewFromCurrentView:self showViewAtIndex:0];
}
#pragma mark 完成选择图片
- (void)sendImage:(id)sender
{
    NSMutableArray *arrayInfo=[[NSMutableArray alloc]init];
    for (RYAsset *asset in _arrayAsset) {
        if (asset.selected) {
            [arrayInfo addObject:asset.asset];
        }
    }
    [self.parent selectedAssets:arrayInfo original:NO];
}

#pragma mark - TableView数据源及委托事件
#pragma mark 返回tableView的组数:section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
#pragma mark 返回组数所对应的行数:row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count=_arrayAsset.count/ROW_COLUMN;
    int count1=_arrayAsset.count%ROW_COLUMN>0?1:0;
    return count+count1;
}
#pragma mark 返回tableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RYAssetsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[RYAssetsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // 截取的开始位置
    int location = indexPath.row * ROW_COLUMN;
    // 截取的长度
    int length = ROW_COLUMN;
    // 如果截取的范围越界
    if (location + length >= _arrayAsset.count) {
        length = _arrayAsset.count - location;
    }
    // 截取范围
    NSRange range = NSMakeRange(location, length);
    // 根据截取范围，获取这行所需的产品
    NSArray *arrayRowAssets = [_arrayAsset subarrayWithRange:range];
    // 设置这个行Cell所需的产品数据
    cell.arrayRowAssets=arrayRowAssets;
    
    __unsafe_unretained RYAssetsViewController *assetView=self;
    cell.blockPreview=^(RYAsset *asset){
        int index=[assetView.arrayAsset indexOfObject:asset];
        [assetView toPreviewFromCurrentView:assetView showViewAtIndex:index+1];
    };
    return cell;
}
#pragma mark 返回UITableViwCell的高度//change
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return 80;
    return (IPHONE_WIDTH-IMAGE_SPACE_DISTANCE*(ROW_COLUMN+1))/ROW_COLUMN+IMAGE_SPACE_DISTANCE;
}
#pragma mark - 自定义方法
#pragma mark 跳转到预览界面具体方法
- (void)toPreviewFromCurrentView:(RYAssetsViewController *)assetsView showViewAtIndex:(NSInteger)index
{
    RYAssetsPickerController *assetsPicker=(RYAssetsPickerController *)assetsView.parent;
    [UIView  beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.75];
    if (assetsPicker.AssetType==RYAssetsPickerAssetPhoto) {
        RYAssetsBrowerViewController *browerViewController=[[RYAssetsBrowerViewController alloc]initWithNibName:nil bundle:nil];
        RYAssetsPickerController *picker=(RYAssetsPickerController *)self.parent;
        browerViewController.titleButtonSure=picker.titleButtonSure;
        browerViewController.parent=assetsView.parent;
        browerViewController.selectCount=assetsView.selectCount;
        NSMutableArray *arraySelect=[[NSMutableArray alloc]init];
        if (index==0) {
            browerViewController.intSelectIndex=index;
            for (RYAsset *ryAsset in assetsView.arrayAsset) {
                if (ryAsset.selected) {
                    [arraySelect addObject:ryAsset];
                }
            }
        }else{
            browerViewController.intSelectIndex=index-1;
            arraySelect=assetsView.arrayAsset;
        }
        browerViewController.arrayAsset=arraySelect;
        NSLog(@"browerViewController.intSelectIndex = %d",browerViewController.intSelectIndex);
        [assetsView.navigationController pushViewController:browerViewController animated:NO];
    }
    if (assetsPicker.AssetType==RYAssetsPickerAssetVideo) {
        RYAssetsMediaPlayerViewController *mediaPlayer=[[RYAssetsMediaPlayerViewController alloc]initWithNibName:nil bundle:nil];
        RYAssetsPickerController *picker=(RYAssetsPickerController *)self.parent;
        mediaPlayer.titleButtonSure=picker.titleButtonSure;
        mediaPlayer.parent=assetsView.parent;
        if (index==0) {
            for (RYAsset *ryAsset in assetsView.arrayAsset) {
                if (ryAsset.selected) {
                    mediaPlayer.ryAsset=ryAsset;
                    break;
                }
            }
        }else{
            mediaPlayer.ryAsset=assetsView.arrayAsset[index-1];
        }
        
        [assetsView.navigationController pushViewController:mediaPlayer animated:NO];
    }
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:assetsView.navigationController.view cache:NO];
    [UIView commitAnimations];
}
#pragma mark - 委托事件
#pragma mark 确定该资源是否可以选择
- (BOOL)assetShouldSelect:(RYAsset *)asset
{
    BOOL shouldSelect=YES;
    if (asset.selected) {
        self.selectCount--;
    }else{
        if((shouldSelect=[self.parent shouldSelectAsset:asset previousCount:self.selectCount])){
            self.selectCount++;
        }
    }
    RYAssetsPickerController *picker=(RYAssetsPickerController *)self.parent;
    NSString *titleSend=@"";
    NSString *titlePreview=@"";
    _buttonSend.backgroundColor = [UIColor colorWithRed:50/255.0 green:115/255.0 blue:240/255.0 alpha:1];
    
    if (self.selectCount==0) {
        _buttonSend.enabled=NO;
        _buttonSend.alpha = 0.4;
        _buttonPreview.enabled=NO;
        [_buttonPreview setTitleColor:[UIColor colorWithRed:173/255.0 green:173/255.0 blue:173/255.0 alpha:1] forState:UIControlStateNormal];
        
        titleSend=picker.titleButtonSure;
        titlePreview=@"预览";
    }else{
        _buttonSend.enabled=YES;
        _buttonSend.alpha = 1;
        _buttonPreview.enabled=YES;
        [_buttonPreview setTitleColor:[UIColor colorWithRed:29/255.0 green:106/255.0 blue:238/255.0 alpha:1] forState:UIControlStateNormal];
        titleSend=[NSString stringWithFormat:@"%@(%d)",picker.titleButtonSure,self.selectCount];
        titlePreview=[NSString stringWithFormat:@"预览(%d)",self.selectCount];
    }
    [_buttonSend setTitle:titleSend forState:UIControlStateNormal];
    [_buttonPreview setTitle:titlePreview forState:UIControlStateNormal];
    return shouldSelect;
}

@end
