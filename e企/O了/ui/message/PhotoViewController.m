//
//  PhotoViewController.m
//  O了
//
//  Created by macmini on 14-01-15.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "PhotoViewController.h"
#import "BTPhotoViewController.h"

@interface PhotoViewController ()

@property (strong, nonatomic)BTPhotoViewController *potoVC;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation PhotoViewController
@synthesize photos;
@synthesize index= _index;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureView{

    // 设置UIPageViewController的配置项
    //第一个参数：滚动方式（书籍仿真滚动，scrollview的滚动方式）
    //第二个参数：换页滚动的方向：上下，左右
    //第三个参数：一个配置项,有两种配置：
    ////1.(ios 6.0 and later)若换页动画是UIPageViewControllerTransitionStyleScroll，
    ////表示的是上一页与下一页的间距(key为：UIPageViewControllerOptionInterPageSpacingKey);
    ////2.(ios 5.0 and later)若换页动画是UIPageViewControllerTransitionStylePageCurl,
    ////表示是书本的脊的位置（上，下，中间）(key为：UIPageViewControllerOptionSpineLocationKey)
    
    NSDictionary *options =[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                      forKey: UIPageViewControllerOptionSpineLocationKey];
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:options];
    
    _pageViewController.view.backgroundColor = [UIColor blackColor];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    self.pageViewController.view.frame = self.view.frame;
    
    BTPhotoViewController *dataViewController =[[BTPhotoViewController alloc] init];
    dataViewController.photoData =[self.photos objectAtIndex:self.index];
    BTPhotoViewController *initialViewController =[self viewControllerAtIndex:self.index];// // 得到当前页
    NSArray *viewControllers =[NSArray arrayWithObject:initialViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
    }];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

//    UIButton *saveButt=[UIButton buttonWithType:UIButtonTypeCustom];
//    saveButt.frame=CGRectMake(200, 200, 60, 40);
//    [saveButt setTitle:@"保存" forState:UIControlStateNormal];
//    [self.view addSubview:saveButt];
    
    self.title=[NSString stringWithFormat:@"%d/%d",self.index+1,[self.photos count]];
}

- (BTPhotoViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.photos count] == 0) || (index >= [self.photos count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    BTPhotoViewController *dataViewController =[[BTPhotoViewController alloc] init];
    dataViewController.photoData =[self.photos objectAtIndex:index];
    dataViewController.nd=self.nd;
    dataViewController.index = index;
    return dataViewController;
}

// 根据数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(BTPhotoViewController *)viewController {
    return viewController.index;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.navigationController.navigationBarHidden = YES;
    /*
    [self.navigationItem setHidesBackButton:YES];
    _leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
    _leftButt.frame=CGRectMake(10, (44-29)/2, 53, 29);
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    [_leftButt setTitle:@"  消息" forState:UIControlStateNormal];
    _leftButt.titleLabel.font=[UIFont systemFontOfSize:14];
    _leftButt.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
    [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
    */
    
    //右侧按钮
    
    _rightButt=[UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButt setTitle:@"保存" forState:UIControlStateNormal];
    _rightButt.titleLabel.font=[UIFont systemFontOfSize:14];
//    [_rightButt setBackgroundImage:[UIImage imageNamed:@"top_right.png"] forState:UIControlStateNormal];
//    [_rightButt setBackgroundImage:[UIImage imageNamed:@"top_right_pre.png"] forState:UIControlStateHighlighted];
    _rightButt.frame=CGRectMake(320-50, (44-29)/2, 50, 29);
    [_rightButt addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self configureView];
    
}
#pragma mark - 返回
-(void)leftButtItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 右边按钮
-(void)rightBarButtonClick{
//    BTPhotoViewController *initialViewController =[self viewControllerAtIndex:self.index];
//    [initialViewController saveImage];
    
//    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
//    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
//    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    BTPhotoViewController *btPhotoVC=(BTPhotoViewController *)[self viewControllerAtIndex:self.index];
    [btPhotoVC saveImage];
}
#pragma mark - viewLoad

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar addSubview:_leftButt];
    [self.navigationController.navigationBar addSubview:_rightButt];
}
-(void)viewWillDisappear:(BOOL)animated{
    [_leftButt removeFromSuperview];
    [_rightButt removeFromSuperview];
}

#pragma mark -
-(BTPhotoViewController *)viewControllerAtIndex:(NSUInteger)index viewController:(BTPhotoViewController *)photovc {
    
    if (([self.photos count] == 0) || (index >= [self.photos count])) {
        return nil;
    }

    [photovc setPhotoData:self.photos[index]];
    photovc.index = index;
    return photovc;
}


#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(BTPhotoViewController *)viewController];
    DDLogInfo(@"inde::%d",index);
    self.index=index;
    self.title=[NSString stringWithFormat:@"%d/%d",index+1,[self.photos count]];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法，自动来维护次序。
    // 不用我们去操心每个ViewController的顺序问题。
    
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(BTPhotoViewController *)viewController];
    self.title=[NSString stringWithFormat:@"%d/%d",index+1,[self.photos count]];
    self.index=index;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.photos count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}
#pragma mark - 显示下边的小圆点
//-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    return 10;
//}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return self.index;
}
#pragma mark - UIActionSheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        DDLogInfo(@"0");
        DDLogInfo(@"self.index===%d",self.index);
        BTPhotoViewController *btPhotoVC=(BTPhotoViewController *)[self viewControllerAtIndex:self.index];
        [btPhotoVC saveImage];
//        UITapGestureRecognizer *tapGes_grayView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGestureAction:)];
//        UITapGestureRecognizer *tapGes_addView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapGestureAction:)];
//        self.grayView.alpha = 0.3;
//        [self.grayView addGestureRecognizer:tapGes_grayView];
//        [self.addView addGestureRecognizer:tapGes_addView];
//        CGRect frame = self.navigationController.view.frame;
//        [self.addView setFrame:CGRectMake(35, frame.origin.y + 90, self.addView.frame.size.width, self.addView.frame.size.height)];
//        [self.navigationController.view addSubview:self.grayView];
//        [self.navigationController.view addSubview:self.addView];
    }else if(buttonIndex == 1){
        //        DDLogInfo(@"1");
        
    }
}
#pragma mark - receiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
