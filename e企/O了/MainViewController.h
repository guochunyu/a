//
//  MainViewController.h
//  ConglomerateWeiChart
//
//  Created by 化召鹏 on 13-12-26.
//  Copyright (c) 2013年 化召鹏. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarButton.h"
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "MBProgressHUD.h"

//枚举 滑动的方向；
typedef enum
{
    SlideDirectionRight = 0,
    SlideDirectionLeft
	
} SlideDirection;

typedef void(^SiderClick)(int selectIndex,NSString *siderMenuName);
typedef void(^TabbarButtonClick)(int selectIndex);


static NSString *const ToWorkFromeMessage=@"ToWorkFromeMessage";///<在消息列表中点击工作圈消息,跳转到响应的工作圈

@interface MainViewController : UIViewController<UINavigationControllerDelegate,NoticeUnreadMessageDelegate,MBProgressHUDDelegate,UIAlertViewDelegate>{
    //正常状态下的图片数组
	NSArray  *_nomalImageArray;
    //高亮状态下的图片数组
	NSArray  *_hightlightedImageArray;
    
    int      _seletedIndex;
    MBProgressHUD  *_HUD;
    
}
@property (strong,nonatomic ) IBOutlet BarButton *tabbarButt1;///<消息

@property (strong,nonatomic ) IBOutlet BarButton *tabbarButt2;///<
@property (weak, nonatomic) IBOutlet BarButton *tabbarButtTask;
@property (strong,nonatomic ) IBOutlet BarButton *tabbarButt3;///<
@property (strong,nonatomic ) IBOutlet BarButton *tabbarButt4;///<
@property (weak, nonatomic) IBOutlet BarButton *tabbarButtAppstore;//应用中心

@property (strong, nonatomic) IBOutlet UIView    *tabbarView;//TabBar视图
@property(strong,nonatomic)UIWebView * webview;
@property(strong,nonatomic)UIView * navView;
@property (nonatomic,retain ) NSArray   *previousNavViewController;//导航控制器中的视图数组 就是第一个
@property (nonatomic,retain ) NSArray   *viewControllers;//TabBar视图数组
@property (nonatomic,assign) int       seletedIndex;//TabBar被选中的索引

@property (nonatomic,assign ) BOOL isToRootViewController;///<

@property (nonatomic,assign ) BOOL isToOnlineCustomerService;///<
//@property (nonatomic,strong)UIImageView * imageView;

//@property(nonatomic,assign)int i;
@property(nonatomic,assign)BOOL isFromLogin;///<是否从登录页面进来

@property(nonatomic,assign)BOOL isiOSInCall; //当前iOS系统是否正在通话

- (IBAction)selectTabbar:(id)sender;


//- (void)showTabBar:(SlideDirection)direction animated:(BOOL)isAnimated;
//- (void)hideTabBar:(SlideDirection)direction animated:(BOOL)isAnimated;

@property(nonatomic,copy)TabbarButtonClick tabbarButtonClick;///<tabar点击
@property(nonatomic,strong)UIButton*other;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)NSArray*dataArray;
@property(nonatomic,strong)UIView*grayView;
@property(nonatomic,assign)BOOL bools;

@property(nonatomic,strong)UIScrollView*scrllView;
@property(nonatomic,strong)UIPageControl*pagControl;
//@property(nonatomic,strong)NSString*imageName;
@property (nonatomic, strong)UILabel *Meeting_Remind;
@property (nonatomic, strong)NSString *Meeting_Remind_String;
@end
