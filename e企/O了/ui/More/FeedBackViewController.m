//
//  FeedBackViewController.m
//  e企
//
//  Created by xuxue on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "FeedBackViewController.h"
#import "CreateHttpHeader.h"

@interface FeedBackViewController ()
{
    NSString *headStr;
    NSInteger reqtimes;
    UIImageView*imagev;
    UILabel*label;
}

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //将意见反馈的标题隐藏
    //self.title = @"意见反馈";
    reqtimes = 0;
    _text_feedBack = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(0, 0, self.textView.frame.size.width, self.textView.frame.size.height - 30)];
    _text_feedBack.placeholder = @"欢迎你对「和企录」提出宝贵意见";
    _text_feedBack.font = [UIFont boldSystemFontOfSize:14.f];
   // _text_feedBack.layer.borderColor = [[UIColor grayColor]CGColor];
   // _text_feedBack.layer.borderWidth = 1.0;
    _text_feedBack.backgroundColor = [UIColor clearColor];
    _text_feedBack.delegate = self;
    _label_num = [[UILabel alloc]initWithFrame:CGRectMake(-5, CGRectGetMaxY(_text_feedBack.frame) + 5, self.textView.frame.size.width, 25)];
    _label_num.textColor = [UIColor grayColor];
    _label_num.textAlignment = 2;
    [_label_num setFont:[UIFont systemFontOfSize:18]];
    _label_num.text = @"(0/500)";
    _label_num.font = [UIFont boldSystemFontOfSize:14.f];
    
    [self.textView addSubview:_text_feedBack];
    [self.textView addSubview:_label_num];
    self.textView.layer.borderColor = [UIColorFromRGB(0xdcdcdc)CGColor];
    [self.textView.layer setCornerRadius:4.f];
    self.textView.layer.borderWidth = 1.0;
    
    [self.btn_Submit.layer setCornerRadius:4.f];
    
    //添加返回按钮
//    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"more_icon_back.@2x.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];
    UIBarButtonItem*leftBtn = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:self action:@selector(backView)];    leftBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    imagev = [[UIImageView alloc]init];
    imagev.frame = CGRectMake(3, 30, 25, 25);
    [imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:imagev];
    
    label = [[UILabel alloc]init];
    label.frame = CGRectMake(25, 32, 90, 20);
    label.text = @"意见反馈";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:label];
}

-(void)backView{
    //更多选项中意见反馈返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)submitFB:(id)sender
{
    [self.view endEditing:YES];
    
    if([_text_feedBack.text length] == 0)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"反馈信息不能为空！" isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }
    else if (_text_feedBack.text.length > 500)
    {
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"反馈信息不能大于500字！" isCue:1 delayTime:1 isKeyShow:NO];
        return;
    }
    reqtimes ++;

    NSDictionary *dict=@{@"feedback": _text_feedBack.text};
    AFClient *client = [AFClient sharedClient];
    NSString *gid = [[NSUserDefaults standardUserDefaults]objectForKey:myGID];
    NSString *cid = [[NSUserDefaults standardUserDefaults]objectForKey:myCID];

    [client postPath:[NSString stringWithFormat:@"eas/feedback?gid=%@&cid=%@",gid,cid] parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         DDLogInfo(@"userinforData===%@",operation.responseString);
         NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
         DDLogInfo(@"dic====%@",dic);
         
         if([[dic objectForKey:@"status"]integerValue] == 1)
         {
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:0 delayTime:1 isKeyShow:NO];
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:[dic objectForKey:@"msg"] isCue:1 delayTime:1 isKeyShow:NO];

         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSInteger stateCode = operation.response.statusCode;
         DDLogInfo(@"%d",stateCode);
         if(stateCode == 401  && reqtimes<=10)
         {
             NSDictionary *ddd=operation.response.allHeaderFields;
             if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
                 NSString *nonce=[ddd objectForKey:@"Www-Authenticate"];
                 headStr = [CreateHttpHeader createHttpHeaderWithNoce:nonce];
                 NSString *phoneNum = [[NSUserDefaults standardUserDefaults]objectForKey:MOBILEPHONE];
                 [client setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
                 
                 [self submitFB:sender];
                 
             }
         }else
         {
             reqtimes = 0;
             [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:nil detailText:@"提交失败!" isCue:1 delayTime:1 isKeyShow:NO];
             
         }
     }];

}

- (void)textViewDidChange:(UITextView *)textView
{
    int count = [textView.text length];
    //这里的count就是字符个数了
    NSString *textnum = [NSString stringWithFormat:@"(%d/500)",count];
    _label_num.text = textnum;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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
