//
//  UIMyViewController.m
//  O了
//
//  Created by 化召鹏 on 14-8-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIMyViewController.h"

@interface UIMyViewController (){
    UIButton *_rightButton;
//    UIButton *_leftButt;
    UILabel *pull_down_label;///<下拉label
    UILabel *pull_up_label;///<上拉label
}

@end

@implementation UIMyViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - 是否允许取消网络请求
- (void)setCancelAFClient:(BOOL)cancelAFClient{
    _cancelAFClient=cancelAFClient;
}
#pragma mark - 是否允许添加afclient实例
- (void)setShouldAddAFClient:(BOOL)shouldAddAFClient{
    if (shouldAddAFClient) {
        if (!afClient) {
            afClient=[AFClient sharedClient];
        }
    }else{
        if (afClient) {
            afClient=nil;
        }
    }
    _shouldAddAFClient=shouldAddAFClient;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    float button_y=0;
    if (IS_IOS_7) {
        button_y=20;
    }else{
        button_y=0;
    }
    
    _hudDimBackground=YES;
    
//    self.navigationItem.hidesBackButton=YES;
    
    _tableViewStyle=UITableViewStylePlain;
    
    if (!requestUuid) {
        CFUUIDRef cfuuid =CFUUIDCreate(kCFAllocatorDefault);
        NSString *cfuuidString =(NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        requestUuid=cfuuidString;
    }
    
    _cancelAFClient=YES;
    self.shouldAddAFClient=YES;
    
    //系统默认的背景色,在用代码push进来的时候,会有上个页面的残影,需要设置为一个颜色
    self.view.backgroundColor=[UIColor whiteColor];
    /*
    if (!_leftButt) {
        _leftButt = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButt.backgroundColor = [UIColor clearColor];
        _leftButt.frame=CGRectMake(10, (44-29)/2, 53, 29);
        [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
        [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
        NSString *leftButtTitle=@"  返回";
        [_leftButt setTitle:leftButtTitle forState:UIControlStateNormal];
        _leftButt.titleLabel.font=[UIFont systemFontOfSize:14];
        _leftButt.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
        [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
    }
    */
    self.hidesBottomBarWhenPushed=YES;
    
}
- (void)viewWillAppear:(BOOL)animated{
    
//    if (_leftButt) {
//        [self.navigationController.navigationBar addSubview:_leftButt];
//    }
    if (_rightButton) {
        [self.navigationController.navigationBar addSubview:_rightButton];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated{
//    if (_leftButt) {
//        [_leftButt removeFromSuperview];
//    }
    if (_rightButton) {
        [_rightButton removeFromSuperview];
    }
}
#pragma mark - push的时候显示tabbar,默认为隐藏
-(void)showTabarWhenPush{
    self.hidesBottomBarWhenPushed=YES;
}
#pragma mark - 加载右侧按钮
-(void)loadRightButt{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.backgroundColor = [UIColor clearColor];
        
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"top_right.png"] forState:UIControlStateNormal];
        [_rightButton setBackgroundImage:[UIImage imageNamed:@"top_right_pre.png"] forState:UIControlStateHighlighted];
        _rightButton.frame=CGRectMake(320-50-10, (44-29)/2, 50, 29);
        _rightButton.titleLabel.font=[UIFont systemFontOfSize:13];
        
        [_rightButton addTarget:self action:@selector(rightButtClick) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:_rightButton];
    }
}
#pragma mark - nav上的按钮
-(void)leftButtItemClick{
    //左边按钮
    [self.navigationController popViewControllerAnimated:YES];
    if (_cancelAFClient && afClient) {
        [afClient cancelOperationWithRequestUuid:requestUuid];
    }
}
-(void)rightButtClick{
    //右边按钮
    
}
#pragma mark - 设置显示和隐藏按钮
-(void)hideButt:(int)index{
    if (index==0) {
        //隐藏左边按钮
//        if (_leftButt) {
//            [_leftButt removeFromSuperview];
//        }
        
    }else if (index==1){
        //隐藏右边按钮
        if (_rightButton) {
            [_rightButton removeFromSuperview];
        }
        
    }
}
#pragma mark - 设置标题
- (void)setLeftButtTitle:(NSString *)leftButtTitle{
//    [_leftButt setTitle:leftButtTitle forState:UIControlStateNormal];
}
-(void)setRightButtTitle:(NSString *)rightButtTitle{
    [_rightButton setTitle:rightButtTitle forState:UIControlStateNormal];
}
#pragma mark - 设置图片
- (void)setLeftButtBackImage:(UIImage *)leftButtBackImage{
    //左边按钮背景图片
//    [_leftButt setBackgroundImage:leftButtBackImage forState:UIControlStateNormal];
}
-(void)setLeftImage:(UIImage *)leftImage{
//    [_leftButt setImage:leftImage forState:UIControlStateNormal];
}
-(void)setRightButtBackImage:(UIImage *)rightButtBackImage{
    [_rightButton setBackgroundImage:rightButtBackImage forState:UIControlStateNormal];
}
- (void)setRightImage:(UIImage *)rightImage{
    [_rightButton setImage:rightImage forState:UIControlStateNormal];
}
#pragma mark - 内存警告
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - hud
- (void)hudWasHidden{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}

-(void)addHUD:(NSString *)labelStr{
    
    
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    _HUD=[[MBProgressHUD alloc] initWithView:keyWindow];
    _HUD.dimBackground = _hudDimBackground;
    _HUD.labelText = labelStr;
    _HUD.userInteractionEnabled=YES;
    _HUD.removeFromSuperViewOnHide=YES;
    [self.view addSubview:_HUD];
    [_HUD show:YES];
}
-(void)hudString:(NSString *)str{
    _HUD.detailsLabelText=str;
}

#pragma mark - 表格相关
- (void)setTableViewStyle:(UITableViewStyle)tableViewStyle{
    _tableViewStyle=tableViewStyle;
}

- (void)setIsLoadTable:(BOOL)isLoadTable{
    if (isLoadTable) {
        //创建表格
        if (!self.myTable) {
            self.myTable=[[TouchTable alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:_tableViewStyle];
            self.myTable.dataSource=self;
            self.myTable.delegate=self;
            [self.view addSubview:self.myTable];
            
            [self setExtraCellLineHidden:self.myTable];
        }
        
    }
}
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
#pragma mark - 表格数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifer=@"MyCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!cell) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
    }
    return cell;
}

#pragma mark - 表格代理

#pragma mark - 拖动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (_headTableView.superview) {
        if (scrollView.contentOffset.y < -50) {
            
            if (!_isPull_Down) {
                _isPull_Down=YES;
            }
            
            //下拉
            if (![pull_down_label.text isEqualToString:@"正在刷新"]) {
                pull_down_label.text=@"松开刷新";
            }
            
        }else if(scrollView.contentOffset.y > -50 && scrollView.contentOffset.y < 0){
            pull_down_label.text=@"下拉刷新";
            
        }else if (_myTable.contentSize.height<_myTable.frame.size.height){
            [self loadFootTableView];
            if (scrollView.contentOffset.y > 50){
                pull_up_label.text=@"松开刷新";
            }else if (scrollView.contentOffset.y>0 && scrollView.contentOffset.y<50){
                pull_up_label.text=@"上拉刷新";
            }
        }else if (_myTable.contentSize.height>_myTable.frame.size.height){
            
            
            [self loadFootTableView];
            if (scrollView.contentOffset.y > (_myTable.contentSize.height - _myTable.frame.size.height)+50){
                pull_up_label.text=@"松开刷新";
            }else if (scrollView.contentOffset.y>(_myTable.contentSize.height - _myTable.frame.size.height) && scrollView.contentOffset.y<(_myTable.contentSize.height - _myTable.frame.size.height)+50){
                pull_up_label.text=@"上拉刷新";
            }
        }
    }
    
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (_headTableView.superview) {
        if (scrollView.contentOffset.y < -50) {
            //下拉
            [self startPullDown];
            pull_down_label.text=@"正在刷新";
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                _myTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
            } completion:^(BOOL finished) {
                //临时的气泡数组
                
            }];
        }else if (_myTable.contentSize.height<_myTable.frame.size.height){
            if (scrollView.contentOffset.y > 50 && _isPull_up){
                [self startPullUp];
                pull_up_label.text=@"正在刷新";
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                    _myTable.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
                } completion:^(BOOL finished) {
                    //临时的气泡数组
                    
                }];
            }
        }else if (_myTable.contentSize.height>_myTable.frame.size.height){
            if (scrollView.contentOffset.y > (_myTable.contentSize.height - _myTable.frame.size.height)+50 && _isPull_up){
                [self startPullUp];
                pull_up_label.text=@"正在刷新";
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
//                    UIEdgeInsets insets = {top, left, bottom, right};
                    _myTable.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
                } completion:^(BOOL finished) {
                    //临时的气泡数组
                    
                }];
            }
        }
    }
    
    
}
#pragma mark - 上拉下拉相关
- (void)setIsPull_Down:(BOOL)isPull_Down{
    //下拉

    if (isPull_Down) {
        /**
         *允许下拉
         */
        if (!_headTableView) {
            if (!_myTable) {
                self.isLoadTable=YES;
            }
            _headTableView=[[UIView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
            _headTableView.backgroundColor=[UIColor clearColor];
            
            UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 20, 20, 20)];
            activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
            [activityView startAnimating];
            [_headTableView addSubview:activityView];
            
            pull_down_label = [[UILabel alloc] initWithFrame:CGRectMake(60, 45, 200, 15)];
            pull_down_label.textAlignment=NSTextAlignmentCenter;
            pull_down_label.backgroundColor = [UIColor clearColor];
            pull_down_label.font=[UIFont systemFontOfSize:12];
            pull_down_label.text = @"下拉刷新";
            [_headTableView addSubview:pull_down_label];
            
            if (_headTableView.superview != _myTable) {
                [_myTable addSubview:_headTableView];
            }
            
        }
    }
}
- (void)setIsPull_up:(BOOL)isPull_up{
    //上拉
    if (isPull_up) {
        /**
         *  允许上拉
         */
        _isPull_up=YES;
    }else{
        _isPull_up=NO;
        if (_footTableView) {
            [self hidePuTableView:PullTableViewTypeUp];
        }
    }
}
-(void)loadFootTableView{
    
    if (!_isPull_up) {
        return;
    }
    
    if (!_footTableView) {
        if (!_myTable) {
            self.isLoadTable=YES;
        }
        _footTableView=[[UIView alloc] initWithFrame:CGRectMake(0, _myTable.contentSize.height, 320, 60)];
        _footTableView.backgroundColor=[UIColor clearColor];
        
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 10, 20, 20)];
        activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleGray;
        [activityView startAnimating];
        [_footTableView addSubview:activityView];
        
        pull_up_label = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 200, 15)];
        pull_up_label.textAlignment=NSTextAlignmentCenter;
        pull_up_label.backgroundColor = [UIColor clearColor];
        pull_up_label.font=[UIFont systemFontOfSize:12];
        pull_up_label.text = @"上拉刷新";
        [_footTableView addSubview:pull_up_label];
        
        if (_footTableView.superview != _myTable) {
            [_myTable addSubview:_footTableView];
//            _myTable.tableFooterView=_footTableView;
        }
        
    }else{
        _footTableView.frame=CGRectMake(0, _myTable.contentSize.height, 320, 60);
    }
}
/**
 *  隐藏刷新view
 */
-(void)hidePuTableView:(PullTableViewType)pullType{
    [self recoverTableContentInset:pullType];
}
//恢复表格偏移量
-(void)recoverTableContentInset:(PullTableViewType)pullType{
    
    /**
     *  延迟一秒
     */
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            _myTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            switch (pullType) {
                case PullTableViewTypeDown:
                {
                    
                    break;
                }
                case PullTableViewTypeUp:
                {
                    if (_footTableView) {
                        [_footTableView removeFromSuperview];
                        _footTableView=nil;
                    }
                    break;
                }
                default:
                    break;
            }
        }];
        
    });
    
}
-(void)startPullDown{
    self.pullTableType=PullTableViewTypeDown;
}
-(void)startPullUp{
    self.pullTableType=PullTableViewTypeUp;
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
