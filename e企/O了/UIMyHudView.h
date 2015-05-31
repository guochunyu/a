//
//  UIMyHudView.h
//  O了
//
//  Created by 化召鹏 on 14-8-27.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchTable.h"

typedef enum {
    PullTableHudViewTypeDown,          ///<下拉
    PullTableHudViewTypeUp,            ///<上拉
}PullTableHudViewType;

@interface UIMyHudView : UIView<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,TouchTableDelegate>{
    MBProgressHUD *_HUD;
    UIView *_hudBgView;
    NSString *requestUuid;
    
    UIView *_headTableView;///<下拉刷新view
    UIView *_footTableView;///<上拉刷新view
    
    UILabel *pull_down_label;///<下拉label
    UILabel *pull_up_label;///<上拉label
}

@property(nonatomic,strong)TouchTable *myTable;///<创建表格
@property(nonatomic,assign)BOOL isLoadTable;///<是否创建表格,默认为NO不创建,

@property(nonatomic,assign)BOOL isPull_Down;///<是否允许下拉刷新,默认为NO
@property(nonatomic,assign)BOOL isPull_up;///<是否允许上拉刷新,默认为NO

@property(nonatomic,copy)NSString *pullDownLabelText;///<下拉刷新的文字
@property(nonatomic,copy)NSString *pullUpLabelText;///<上拉刷新的文字

@property(nonatomic,assign)PullTableHudViewType pullTableType;///<标记当前为上拉或者下拉

- (id)initWithView:(UIView *)hudBgView fram:(CGRect)frame;

-(void)addHUD:(NSString *)labelStr;
- (void)hudWasHidden;

-(void)hudString:(NSString *)str;

//刷新相关
-(void)hidePuTableView:(PullTableHudViewType)pullType;
-(void)startPullDown;///<开始上拉刷新
-(void)startPullUp;///<上拉刷新

-(void)didStartPull;
@end
