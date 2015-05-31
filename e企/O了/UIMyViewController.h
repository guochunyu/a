//
//  UIMyViewController.h
//  O了
//
//  Created by 化召鹏 on 14-8-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchTable.h"


typedef enum {
    PullTableViewTypeDown,          ///<下拉
    PullTableViewTypeUp,            ///<上拉
}PullTableViewType;

@interface UIMyViewController : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate,TouchTableDelegate>{
    MBProgressHUD *_HUD;
    NSString *requestUuid;
    AFClient *afClient;
    
    UIView *_headTableView;///<下拉刷新view
    UIView *_footTableView;///<上拉刷新view
    
}

@property(nonatomic,copy)NSString *rightButtTitle;
@property(nonatomic,copy)NSString *leftButtTitle;

@property(nonatomic,strong)UIImage *rightButtBackImage;
@property(nonatomic,strong)UIImage *leftButtBackImage;
@property(nonatomic,strong)UIImage *rightImage;
@property(nonatomic,strong)UIImage *leftImage;

@property(nonatomic,strong)UIButton *rightButton;
//@property(nonatomic,strong)UIButton *leftButt;


@property(nonatomic,assign)BOOL shouldAddAFClient;///<是否创建afclient实例,默认为YES
@property(nonatomic,assign)BOOL cancelAFClient;///<是否允许取消afclient,默认为YES

@property(nonatomic,strong)TouchTable *myTable;///<创建表格
@property(nonatomic,assign)UITableViewStyle tableViewStyle;//表格类型,默认为UITableViewStylePlain
@property(nonatomic,assign)BOOL isLoadTable;///<是否创建表格,默认为NO,不创建,
@property(nonatomic,assign)BOOL isPull_Down;///<是否允许下拉刷新,默认为NO
@property(nonatomic,assign)BOOL isPull_up;///<是否允许上拉刷新,默认为NO

@property(nonatomic,assign)PullTableViewType pullTableType;///<标记当前为上拉或者下拉


/**
 hud
 */
-(void)addHUD:(NSString *)labelStr;
- (void)hudWasHidden;

@property(nonatomic,assign)BOOL hudDimBackground;///<hud的背景是否变暗,默认变暗

-(void)hudString:(NSString *)str;


-(void)hideButt:(int)index;//index,0为左边,1为右边

-(void)rightButtClick;
-(void)leftButtItemClick;

-(void)loadRightButt;
-(void)showTabarWhenPush;

/**
 *  隐藏刷新view
 */
-(void)hidePuTableView:(PullTableViewType)pullType;
-(void)startPullDown;///<开始刷新
-(void)startPullUp;///<上拉刷新
@end
