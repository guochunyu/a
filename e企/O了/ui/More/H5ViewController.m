//
//  H5ViewController.m
//  e企
//
//  Created by 独孤剑道(张洋) on 15/3/31.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "H5ViewController.h"

@interface H5ViewController ()
{
    __weak IBOutlet UIWebView *webViewH5;
    NSURLRequest *_request;
    UIImageView*imagev;
    UILabel*label;
}

@end

@implementation H5ViewController
@synthesize currentH5Types;

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withRequest:(NSURLRequest *)request{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _request = request;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView * vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64)];
    vi.backgroundColor=[UIColor colorWithRed:56/255.0 green:112/255.0 blue:237/255.0 alpha:1];
    [self.view addSubview:vi];

    UILabel * lab =[[UILabel alloc]initWithFrame:CGRectMake(135, 20, 100, 50)];
    //lab.text=@"应用中心";
    lab.font=[UIFont systemFontOfSize:16];
    lab.textColor=[UIColor whiteColor];
    [vi addSubview:lab];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=CGRectMake(0, 19, 80, 45);
    //[btn setTitle:@"返回" forState:UIControlStateNormal];
    //btn.font=[UIFont systemFontOfSize:16];
    //[btn setBackgroundImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    //btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:btn];
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [vi addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 90, 20);
    label.text = @"应用中心";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [vi addSubview:label];
   
    
    if (currentH5Types == AppRecommendationTypes)
    {
        //@"应用推荐";
        
        [webViewH5 loadRequest:_request];
        
    }
    else if (currentH5Types == TrafficManagements)
    {
        //@"流量管理";
        
        
        [webViewH5 loadRequest:_request];
    }
}
-(void)btn{
    //应用中心返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    if (currentH5Types == AppRecommendationTypes){
        
        NSString *url = [request.URL absoluteString];
        NSRange range = [url rangeOfString:@"itms-services:"];
        
        if ([_request.URL.absoluteString isEqualToString:[request.URL absoluteString]]
            || [_request.HTTPMethod isEqualToString:@"POST"]){
            return YES;
            
        }else if(range.length){
            
            return YES;
            
        }else{
            H5ViewController *webViewController = [[H5ViewController alloc] initWithNibName:@"H5ViewController" bundle:nil withRequest:request];
            webViewController.hidesBottomBarWhenPushed = YES;
            webViewController.title = @"";
            [self.navigationController pushViewController:webViewController animated:YES];
        }
        
        return NO;
        
    }else if (currentH5Types == TrafficManagements){
        
        if ([_request.URL.absoluteString isEqualToString:[request.URL absoluteString]]
            || [_request.HTTPMethod isEqualToString:@"POST"]){
            return YES;
            
        }else{
            
            H5ViewController *webViewController = [[H5ViewController alloc] initWithNibName:@"H5ViewController" bundle:nil withRequest:request];
            webViewController.hidesBottomBarWhenPushed = YES;
            webViewController.title = @"";
            [self.navigationController pushViewController:webViewController animated:YES];
            
        }
        
        return NO;
    }
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

@end
