//
//  ServiceNumberMsgDetailViewController.m
//  O了
//
//  Created by 卢鹏达 on 14-3-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ServiceNumberMsgDetailViewController.h"

#import "NotesData.h"

@interface ServiceNumberMsgDetailViewController ()<UIWebViewDelegate,MBProgressHUDDelegate>{
    UIWebView *_webView;
    MBProgressHUD *_HUD;
}

@end

@implementation ServiceNumberMsgDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark-
#pragma mark HUD

- (void)hudWasHidden:(MBProgressHUD *)hud{
    [_HUD removeFromSuperview];
    _HUD = nil;
    _HUD.delegate=nil;
}
-(void)addHUD:(NSString *)labelStr{
    _HUD=[[MBProgressHUD alloc] initWithView:self.navigationController.view];
    _HUD.dimBackground = NO;
    _HUD.labelText = labelStr;
    _HUD.delegate=self;
    
    _HUD.userInteractionEnabled=YES;
    
    [self.view addSubview:_HUD];
    [_HUD show:YES];
}
#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    //leftBarButtonItem设置 返回GroupChat_Set_Icon_Add
//    UIButton *leftButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    leftButton.titleLabel.font=[UIFont systemFontOfSize:15];
//    leftButton.bounds=CGRectMake(0, 0, 50, 29);
//    [leftButton setTitle:@"  返回" forState:UIControlStateNormal];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
//    [leftButton setBackgroundImage:[UIImage imageNamed:@"nv_back_pre.png"] forState:UIControlStateHighlighted];
//    [leftButton addTarget:self action:@selector(backView:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftBar=[[UIBarButtonItem alloc]initWithCustomView:leftButton];
//    self.navigationItem.leftBarButtonItem=leftBar;
    self.view.backgroundColor=[UIColor whiteColor];
    
//    NSError *error=nil;
//    
//    NSXMLElement *x_parse=[[NSXMLElement alloc] initWithXMLString:self.notesData.sendContents error:&error];
//    
//    if (error) {
//        DDLogInfo(@"解析出错,error:%@",error);
//    }
//    
//    NSArray *articleArray=[[x_parse elementForName:@"article"] elementsForName:@"mediaarticle"];
    NSXMLElement *dan_x=self.x_element;
    
    NSString *title=[[dan_x elementForName:@"title"] stringValue];
    NSString *author=[[dan_x elementForName:@"author"] stringValue];
    self.title=title;
    [self addHUD:@"正在加载..."];
    NSString *source_linl=[[dan_x elementForName:@"source_link"] stringValue];
    NSString *iframeStr=[NSString stringWithFormat:@"<iframe width=\'100%%\' height=\'100%%\' frameborder=\'0\' scrolling=\'yes\' src=\'%@\'></iframe>",source_linl];
    NSMutableString *htmlHead=[NSMutableString stringWithFormat:@"<h2 style=\"margin:0;padding:0;\">%@</h2><p style=\"margin:0;padding:2;\"><font size=\"2\" color=\"gray\">%@ %@</font></p><br>%@",title,self.notesData.serverTime,author,iframeStr];
    
    [self loadWebView:htmlHead];
    
    /*
    AFHTTPRequestOperationManager *manager=[AFHTTPRequestOperationManager manager];
    [manager GET:[[dan_x elementForName:@"source_link"] stringValue] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"%@",operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(operation.response.statusCode==200){
            
            NSString *urlStr = [operation.responseString stringByReplacingOccurrencesOfString:@"<img " withString:@"<img width=\"100%\" "];
            
            NSMutableString *htmlHead=[NSMutableString stringWithFormat:@"<h2 style=\"margin:0;padding:0;\">%@</h2><p style=\"margin:0;padding:2;\"><font size=\"2\" color=\"gray\">%@ %@</font></p><br>%@",title,self.notesData.serverTime,author,urlStr];
            
            [self loadWebView:htmlHead];
        }else{
            [self hudWasHidden:nil];
        }
        
    }];
     */
    
    
    
    
    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
//    doubleTap.numberOfTouchesRequired = 2;
//    [_webView addGestureRecognizer:doubleTap];
}


-(void)loadWebView:(NSString *)htmlHead{
    
    //webView
    CGSize sizeScreen=[UIScreen mainScreen].bounds.size;
    CGSize sizeStatus=[UIApplication sharedApplication].statusBarFrame.size;
    CGSize sizeNVBar=self.navigationController.navigationBar.bounds.size;
    CGFloat heightWV=sizeScreen.height-sizeStatus.height-sizeNVBar.height;
    
    self.view.backgroundColor=[UIColor colorWithRed:0.136 green:0.144 blue:0.147 alpha:1.000];
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 20)];
    label.text=@"由和企录提供";
    label.textAlignment=NSTextAlignmentCenter;
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor colorWithRed:0.386 green:0.407 blue:0.414 alpha:1.000];
    [self.view addSubview:label];
    
    
    _webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, sizeScreen.width, heightWV)];
    _webView.delegate=self;
    _webView.backgroundColor=[UIColor clearColor];
    _webView.scrollView.showsHorizontalScrollIndicator=NO;
    _webView.scrollView.showsVerticalScrollIndicator=YES;
    //    webView.scrollView.bounces=NO;
//    _webView.scalesPageToFit=YES;
    
    [_webView loadHTMLString:htmlHead baseURL:nil];
    _webView.userInteractionEnabled=YES;
    [self.view addSubview:_webView];
    
    [self hudWasHidden:nil];
}

-(void) doubleTap :(UITapGestureRecognizer*) sender
{
    //  <Find HTML tag which was clicked by user>
    //  <If tag is IMG, then get image URL and start saving>
//    int scrollPositionY = [[webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
//    int scrollPositionX = [[webView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
//    
//    int displayWidth = [[webView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
//    CGFloat scale = webView.frame.size.width / displayWidth;
//    
//    CGPoint pt = [sender locationInView:webView];
//    pt.x *= scale;
//    pt.y *= scale;
//    pt.x += scrollPositionX;
//    pt.y += scrollPositionY;
//    
//    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
//    NSString * tagName = [webView stringByEvaluatingJavaScriptFromString:js];
//    tagName=[tagName lowercaseString];
//    if ([tagName isEqualToString:@"img"]) {
//        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
//        NSString *urlToSave = [webView stringByEvaluatingJavaScriptFromString:imgURL];
//        DDLogInfo(@"image url=%@", urlToSave);
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark navigation的返回事件
- (void)backView:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
//    NSString *JsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
//    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:JsToGetHTMLSource];
//    DDLogInfo(@"%@",HTMLSource);
    
    CGFloat maxwidth=[UIScreen mainScreen].bounds.size.width-20;
    NSString *scriptString=[NSString stringWithFormat:
                            @"var script = document.createElement('script');"
                            "script.type = 'text/javascript';"
                            "script.text = \"function ResizeImages() { "
                            "var myimg,oldwidth;"
                            "var maxwidth=%lf;" //缩放系数
                            "for(i=0;i <document.images.length;i++){"
                            "myimg = document.images[i];"
                            "if(myimg.width > maxwidth){"
                            "oldwidth = myimg.width;"
                            "myimg.width = maxwidth;"
                            "myimg.height = myimg.height * (maxwidth/oldwidth);"
                            "}"
                            "}"
                            "}\";"
                            "document.getElementsByTagName('head')[0].appendChild(script);",maxwidth];
    //拦截网页图片  并修改图片大小
    [webView stringByEvaluatingJavaScriptFromString:scriptString];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    
//    NSString *jsToGetHTMLSource =@"document.getElementsByTagName_r('html')[0].innerHTML";
//    
//    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
//    
//    DDLogInfo(@"%@",HTMLSource);
    
}
@end
