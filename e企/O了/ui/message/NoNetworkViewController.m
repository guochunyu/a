//
//  NoNetworkViewController.m
//  O了
//
//  Created by 化召鹏 on 14-7-29.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NoNetworkViewController.h"

@interface NoNetworkViewController ()

@end

@implementation NoNetworkViewController

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
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor=[UIColor grayColor];
    self.title=@"网络无法连接";
    
    UIScrollView *scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height)];
    scrollView.backgroundColor = [UIColor colorWithWhite:0.878 alpha:1.000];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(320, self.view.frame.size.height+1);
    [self.view addSubview:scrollView];
    
    UILabel *label1=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 40)];
    label1.text=@"建议按照以下方法检查网络连接";
    label1.textColor=[UIColor blackColor];
    label1.font=[UIFont systemFontOfSize:18];
    label1.backgroundColor=[UIColor clearColor];
    [scrollView addSubview:label1];
    
    UIView *lineView=[[UIView alloc] initWithFrame:CGRectMake(10, label1.frame.origin.y+40+3, 300, 2)];
    lineView.backgroundColor=[UIColor colorWithWhite:0.756 alpha:1.000];
    [scrollView addSubview:lineView];
    
    UITextView *textView=[[UITextView alloc] initWithFrame:CGRectMake(10, lineView.frame.origin.y+5, 310, 300)];
    textView.editable=NO;
    textView.backgroundColor=[UIColor colorWithWhite:0.878 alpha:1.000];
    textView.text=@"\n\n1.打开手机“设置”并把“Wi-Fi”开关保持开启状态\n\n\n2.打开手机“设置”-“通用”-“蜂窝移动网络”并把“蜂窝移动数据”开关保持开启状态";
    textView.font=[UIFont systemFontOfSize:16];
    [scrollView addSubview:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
