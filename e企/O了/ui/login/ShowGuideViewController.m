//
//  ShowGuideViewController.m
//  e企
//
//  Created by HC_hmc on 14/12/20.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ShowGuideViewController.h"

@interface ShowGuideViewController (){
    UIPageControl *facePageControl;
    UIScrollView *scrollview;
        UIButton *startbtn;
}

@end

@implementation ShowGuideViewController

-(id)init{
    self=[super init];
    if(self){
        
        NSLog(@"新建");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"###%f %f %f %f",self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.size.width,self.view.frame.size.height);
    self.view.backgroundColor=[UIColor whiteColor];
    scrollview=[[UIScrollView alloc]initWithFrame:self.view.frame];
    scrollview.delegate=self;
    scrollview.pagingEnabled=YES;//分页
    //    scrollview.userInteractionEnabled = YES;
    //    scrollview.pagingEnabled = YES;
    scrollview.bounces=NO;
    scrollview.scrollsToTop = NO;
    scrollview.contentSize=CGSizeMake(5*320, self.view.frame.size.height);
    scrollview.showsHorizontalScrollIndicator=NO;
    scrollview.showsVerticalScrollIndicator=NO;
    [self.view addSubview:scrollview];
    BOOL is4s=self.view.frame.size.height<500?YES:NO;
    
    
    for(int i=0;i<5;i++){
        UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(320*i, 0, 320, self.view.frame.size.height)];
        if(is4s){
            image.image=[UIImage imageNamed:[NSString stringWithFormat:@"newt%d",i+1]];
            
        }else{
            image.image=[UIImage imageNamed:[NSString stringWithFormat:@"new%d",i+1]];
        }
        
        if(i==4){
            UIButton *btn;
            if(is4s){
                btn=[[UIButton alloc]initWithFrame:CGRectMake(46.5, 410, 227, 41)];
            }else{
                btn=[[UIButton alloc]initWithFrame:CGRectMake(46.5, 481, 227, 41)];
            }
            btn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"enter_nm"]];
//            [btn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchDown];
            [image addSubview:btn];
        }
        [scrollview addSubview:image];
    }
    if(is4s){
        facePageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(110, 460, 100, 6)];
    }
    else{
        facePageControl=[[UIPageControl alloc] initWithFrame:CGRectMake(110, 545, 100, 6)];
    }
    [facePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    facePageControl.numberOfPages=5;
    facePageControl.currentPage=0;
    facePageControl.currentPageIndicatorTintColor=cor6;
//    facePageControl.pageIndicatorTintColor=[UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1];
    facePageControl.pageIndicatorTintColor=[UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1];
    [self.view addSubview:facePageControl];
    
    if(is4s){
        startbtn=[[UIButton alloc]initWithFrame:CGRectMake(46.5, 410, 227, 41)];
    }else{
        startbtn=[[UIButton alloc]initWithFrame:CGRectMake(46.5, 481, 227, 41)];
    }
    startbtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"enter_nm"]];
    [startbtn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchDown];
    [startbtn setHidden:YES];
    [self.view addSubview:startbtn];
    
}
-(void)start:(id)sender{
    NSLog(@"点击开始 ");
    self.blockEnterApp();
}
- (void)pageChange:(id)sender {
    facePageControl.currentPage=scrollview.contentOffset.x/320;
    [facePageControl updateCurrentPageDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    facePageControl.currentPage=scrollview.contentOffset.x/320;
    if(facePageControl.currentPage==4){
        [startbtn setHidden:NO];
    }else{
        [startbtn setHidden:YES];
    }
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
