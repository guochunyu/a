//
//  ServiceNumberWebViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-3-11.
//  Copyright (c) 2014年 QYB. All rights reserved.
//


#import "ServiceNumberWebViewController.h"

#import "MBProgressHUD.h"

@interface ServiceNumberWebViewController ()<UIWebViewDelegate>{
    MBProgressHUD *_progressHUD;
    UIWebView *webView;
}

@end

@implementation ServiceNumberWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //leftBarButtonItem设置 返回GroupChat_Set_Icon_Add
    UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.titleLabel.font=[UIFont systemFontOfSize:15];
    leftButton.bounds=CGRectMake(0, 0, 50, 29);
    [leftButton setTitle:@"  返回" forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back_pre.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem=leftBar;
    //标题
    self.title=self.snName;
    //webView
    CGSize sizeScreen=[UIScreen mainScreen].bounds.size;
    CGSize sizeStatus=[UIApplication sharedApplication].statusBarFrame.size;
    CGSize sizeNVBar=self.navigationController.navigationBar.bounds.size;
    CGFloat heightWV=sizeScreen.height-sizeStatus.height-sizeNVBar.height;
    
    
//    NSString *labelUrl=[self.snUrl];
    
//    self.view.backgroundColor=[UIColor colorWithRed:0.136 green:0.144 blue:0.147 alpha:1.000];
//    
//    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 20)];
//    label.text=[NSString stringWithFormat:@"由%@提供",self.snUrl];
//    label.textAlignment=UITextAlignmentCenter;
//    label.backgroundColor=[UIColor clearColor];
//    label.textColor=[UIColor colorWithRed:0.386 green:0.407 blue:0.414 alpha:1.000];
//    [self.view addSubview:label];
    
    
//    self.snUrl=@"http://www.baidu.com/";
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, sizeScreen.width, heightWV)];
    webView.delegate=self;
    webView.scalesPageToFit=YES;
//    [webView setBackgroundColor:[UIColor clearColor]];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:self.snUrl]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressHUD hide:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    //化
    [webView stopLoading];

    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - 委托
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (_progressHUD==nil) {
        _progressHUD=[MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    }
    _progressHUD.userInteractionEnabled=NO;
    _progressHUD.removeFromSuperViewOnHide=YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    /**
     *  获取标题
     */
//    NSString *ttttt = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    
    [_progressHUD hide:YES];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
    _progressHUD.mode=MBProgressHUDModeText;
    _progressHUD.margin=10;
    _progressHUD.opacity=0.7;
    _progressHUD.yOffset=150.f;
    _progressHUD.labelFont=[UIFont systemFontOfSize:12];
    _progressHUD.userInteractionEnabled=NO;
    _progressHUD.labelText=@"网络异常，加载失败";
    [_progressHUD hide:YES afterDelay:1];
}
@end
