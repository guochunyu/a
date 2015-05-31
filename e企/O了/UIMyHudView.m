//
//  UIMyHudView.m
//  O了
//
//  Created by 化召鹏 on 14-8-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIMyHudView.h"



@implementation UIMyHudView{
    BOOL isStart;///<判断当前状态是否正在刷新,默认为NO
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithView:(UIView *)hudBgView fram:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        _hudBgView=hudBgView;
        if (!requestUuid) {
            CFUUIDRef cfuuid =CFUUIDCreate(kCFAllocatorDefault);
            NSString *cfuuidString =(NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
            requestUuid=cfuuidString;
        }
    }
    return self;
}
- (void)hudWasHidden{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}
-(void)addHUD:(NSString *)labelStr{
    
    
    UIWindow *keyWindow=[UIApplication sharedApplication].keyWindow;
    _HUD=[[MBProgressHUD alloc] initWithView:keyWindow];
    _HUD.dimBackground = YES;
    _HUD.labelText = labelStr;
    _HUD.userInteractionEnabled=YES;
    _HUD.removeFromSuperViewOnHide=YES;
    [_hudBgView addSubview:_HUD];
    [_HUD show:YES];
}
-(void)hudString:(NSString *)str{
    _HUD.detailsLabelText=str;
}

#pragma mark - 表格相关
- (void)setIsLoadTable:(BOOL)isLoadTable{
    if (isLoadTable) {
        //创建表格
        if (!self.myTable) {
            self.myTable=[[TouchTable alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
            self.myTable.dataSource=self;
            self.myTable.delegate=self;
            [self addSubview:self.myTable];
        }
        
    }
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
            if ([pull_down_label.text isEqualToString:@"下拉刷新"]) {

                pull_down_label.text=@"松开刷新";
            }
            
            
        }else if(scrollView.contentOffset.y > -50 && scrollView.contentOffset.y < 0){
            pull_down_label.text=@"下拉刷新";
            
        }else if (_myTable.contentSize.height<_myTable.frame.size.height){
            [self loadFootTableView];
            if (scrollView.contentOffset.y > 50){
                if ([pull_down_label.text isEqualToString:@"下拉刷新"]) {
                    
                    pull_down_label.text=@"松开刷新";
                }
            }else if (scrollView.contentOffset.y>0 && scrollView.contentOffset.y<50){
                pull_up_label.text=@"上拉刷新";
            }
        }else if (_myTable.contentSize.height>_myTable.frame.size.height){
            
            
            [self loadFootTableView];
            if (scrollView.contentOffset.y > (_myTable.contentSize.height - _myTable.frame.size.height)+50){
                if ([pull_down_label.text isEqualToString:@"下拉刷新"]) {
                    
                    pull_down_label.text=@"松开刷新";
                }
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
            if (!isStart) {
                isStart=YES;
                [self startPullDown];
            }
            pull_down_label.text=@"正在刷新";
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                _myTable.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
            } completion:^(BOOL finished) {
                //临时的气泡数组
                
            }];
        }else if (_myTable.contentSize.height<_myTable.frame.size.height){
            if (scrollView.contentOffset.y > 50 && _isPull_up){
                if (!isStart) {
                    isStart=YES;
                    [self startPullUp];
                }
                
                pull_up_label.text=@"正在刷新";
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                    _myTable.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 60.0f, 0.0f);
                } completion:^(BOOL finished) {
                    //临时的气泡数组
                    
                }];
            }
        }else if (_myTable.contentSize.height>_myTable.frame.size.height){
            if (scrollView.contentOffset.y > (_myTable.contentSize.height - _myTable.frame.size.height)+50 && _isPull_up){
                if (!isStart) {
                    isStart=YES;
                    [self startPullUp];
                }
                pull_up_label.text=@"正在刷新";
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
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
            [self hidePuTableView:PullTableHudViewTypeUp];
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
-(void)hidePuTableView:(PullTableHudViewType)pullType{
    [self recoverTableContentInset:pullType];
}
//恢复表格偏移量
-(void)recoverTableContentInset:(PullTableHudViewType)pullType{
    
    /**
     *  延迟一秒
     */
    isStart=NO;
    double delayInSeconds = 0.5;
    
    if (pullType==PullTableHudViewTypeUp) {
        delayInSeconds=0.0;
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            _myTable.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            
            switch (pullType) {
                case PullTableHudViewTypeDown:
                {
                    _pullDownLabelText=@"下拉刷新";
                    break;
                }
                case PullTableHudViewTypeUp:
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
    self.pullTableType=PullTableHudViewTypeDown;
}
-(void)startPullUp{
    self.pullTableType=PullTableHudViewTypeUp;
}

-(void)didStartPull{
    [_myTable scrollsToTop];
    _myTable.contentInset = UIEdgeInsetsMake(60, 0, 0, 0);
    [self scrollViewDidEndDragging:_myTable willDecelerate:YES];
}
#pragma mark -修改刷新view上的字
- (void)setPullDownLabelText:(NSString *)pullDownLabelText{
    if (pullDownLabelText) {
        pull_down_label.text=pullDownLabelText;
    }
}
- (void)setPullUpLabelText:(NSString *)pullUpLabelText{
    if (pullUpLabelText) {
        pull_up_label.text=pullUpLabelText;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
