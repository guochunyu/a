//
//  GuidePageViewController.m
//  O了
//
//  Created by 化召鹏 on 14-5-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "GuidePageViewController.h"

#define self_view_height self.view.bounds.size.height
#define self_view_width self.view.bounds.size.width

@interface GuidePageViewController (){
    NSArray *imageArray;
}

@end

@implementation GuidePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //设置引导页，直接设置图片名称即可。
    imageArray=@[@"welcome1",@"1.4.3_2",@"1.4.3_3",@"1.4.3_4"];
    
    [[LogRecord sharedWriteLog] writeLog:@"进入引导页"];

    _guideView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self_view_width, self_view_height)];
    _guideView.pagingEnabled=YES;//分页
    _guideView.contentSize=CGSizeMake(self_view_width*imageArray.count, self_view_height);
    _guideView.showsHorizontalScrollIndicator=NO;
    _guideView.showsVerticalScrollIndicator=NO;
    _guideView.delegate=self;
    
    
    
    
    for(int i=0;i<imageArray.count;i++){
        UIImageView *guideImageView=[[UIImageView alloc] initWithFrame:CGRectMake(i*self_view_width, 0, self_view_width, self_view_height)];
        NSString *filePath=[[NSBundle mainBundle] pathForResource:imageArray[i] ofType:@"png"];
        NSData *imageData=[NSData dataWithContentsOfFile:filePath];
        filePath=nil;
//        guideImageView.image=[UIImage imageNamed:imageArray[i]];
        guideImageView.image=[UIImage imageWithData:imageData];
        imageData=nil;
        [_guideView addSubview:guideImageView];
    }
    
    _guidePageControl=[[UIPageControl alloc] initWithFrame:CGRectMake((self_view_width-100)/2, self_view_height-50, 100, 20)];
//    [_guidePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    _guidePageControl.numberOfPages=imageArray.count;
    _guidePageControl.currentPage=0;
    [self.view addSubview:_guideView];
    [self.view addSubview:_guidePageControl];
    
    
    NSString *now_version=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(0, IS_Height_4?210:170, 320, 100)];
    label.backgroundColor=[UIColor clearColor];
    label.text=now_version;
    label.textColor=[UIColor blackColor];
    label.font=[UIFont boldSystemFontOfSize:20];
    label.textAlignment=NSTextAlignmentCenter;
    [_guideView addSubview:label];
    
}
UIButton *butt;

//- (void)pageChange:(id)sender {
//    _guidePageControl.currentPage=_guideView.contentOffset.x/320;
//    [_guidePageControl updateCurrentPageDisplay];
//}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _guidePageControl.currentPage=_guideView.contentOffset.x/320;
    
    
    
    if(_guidePageControl.currentPage==imageArray.count-1){
        if (butt==nil){
            
            [[LogRecord sharedWriteLog] writeLog:@"创建“开启O了”按钮"];
            
            butt=[UIButton buttonWithType:UIButtonTypeCustom];
            butt.frame=CGRectMake((self_view_width-157)/2, self_view_height-67, 157, 40);
            
            [butt setTitle:@"开启0了" forState:UIControlStateNormal];
            butt.layer.cornerRadius=5;
            [butt.layer setMasksToBounds:YES];
            [butt setBackgroundImage:[UIImage imageNamed:@"ackButton_pre"] forState:UIControlStateNormal];
            [butt setBackgroundImage:[UIImage imageNamed:@"ackButton_pre"] forState:UIControlStateHighlighted];
            [butt addTarget:self action:@selector(buttClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:butt];
        }else{
            butt.hidden=NO;
        }
        
    }else{
        butt.hidden=YES;
    }
    
}
-(void)buttClick:(id)sender{
    self.guideFinish(YES);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
