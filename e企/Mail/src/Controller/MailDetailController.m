//
//  MailDetailController.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailDetailController.h"
#import "MailDetailHandler.h"
#import "Email.h"
#import "EmailAddress.h"
#import "LogicHelper.h"
#import "AttachmentsView.h"
#import "TOWebViewController.h"
#import "TWebView.h"
#import "EmailAccount.h"
#import "MailEditController.h"
#import "AppDelegate.h"

static const CGFloat kSpacingV = 4;
static const CGFloat kSpacingH = 16;
static const CGFloat kHeaderHeight = 100;
static const CGFloat kTipsViewHeight = 40;

#define HeaderLineViewTag  3333
#define HeaderLineHeight   0.5

static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

static NSString * mainStyle = @"\
body {\
font-family: Helvetica;\
font-size: 14px;\
word-wrap: break-word;\
-webkit-text-size-adjust:none;\
-webkit-nbsp-mode: space;\
}\
\
pre {\
white-space: pre-wrap;\
}\
";

@interface MailDetailController () <UIWebViewDelegate, UIScrollViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, AttachmentsViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *iHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *iTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *iTipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *iDetailButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *iLoadingProgress;
@property (strong, nonatomic) IBOutlet UIView *iTipsView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *iFavoriteButton;

//detail
@property (strong, nonatomic) IBOutlet UIView *iDetailView;
@property (strong, nonatomic) IBOutlet UILabel *iSenderLabel;
@property (strong, nonatomic) IBOutlet UILabel *iRecvLabel;
@property (strong, nonatomic) IBOutlet UILabel *iDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *iHideButton;
@property (strong, nonatomic) IBOutlet UILabel *iCCLabel;

@property (strong, nonatomic) IBOutlet UILabel *iSenderLabel2;
@property (strong, nonatomic) IBOutlet UILabel *iDateLabel2;
@property (strong, nonatomic) IBOutlet UILabel *iRecvLabel2;
@property (strong, nonatomic) IBOutlet UILabel *iCCLabel2;

@property (nonatomic) NSMutableArray *files;

//@property (weak, nonatomic) IBOutlet UIButton *iSenderButton;
//@property (weak, nonatomic) IBOutlet UILabel *iSubjectLabel;
//@property (weak, nonatomic) IBOutlet UILabel *iDateLabel;
//@property (weak, nonatomic) IBOutlet UILabel *iReceiverLabel;
@property (nonatomic, nonatomic) TWebView *iContentWeb;
//@property (nonatomic) CGFloat realHeight;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *iLoadingProgress;
//@property (strong, nonatomic) IBOutlet UIView *iHeaderView;


@property (nonatomic) Email *email;
@property (nonatomic) EmailAccount *account;
@property (nonatomic) AttachmentsView *attView;


@property (nonatomic) CGFloat detailViewHeight;

@end

@implementation MailDetailController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"详情";
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController setToolbarHidden:YES];
    [_handler initData];
    [self initUI];
    [self xiaxianHidden];
    //[self jiehshou];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_email.isFlag boolValue]) {
        _iFavoriteButton.image = [UIImage imageNamed:@""];
        _iFavoriteButton.title = @"取消星号";
    } else {
        _iFavoriteButton.image = [UIImage imageNamed:@""];
        _iFavoriteButton.title = @"标记星号";
    }
    for (UIView *view in self.view.subviews) {
        view.backgroundColor = [UIColor whiteColor];
    }
//    [[UIApplication sharedApplication] keyWindow].backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //[[[UIAlertView alloc] initWithTitle:@"系统警告" message:@"邮件大附件获取中，频繁操作可能导致出错。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}

- (void)initUI
{
#pragma mark - 初始化webview
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    
    CGFloat offset = 70.0;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.0 ) {
        offset = 120;
    }
    
//    CGRect webFrame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH, ABDEVICE_SCREEN_HEIGHT-offset);
    CGRect webFrame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH, ABDEVICE_SCREEN_HEIGHT-offset+20);
    
    _iContentWeb = [[TWebView alloc] init];
    _iContentWeb.frame = webFrame;
    _iContentWeb.scalesPageToFit = YES;
    _iContentWeb.delegate = self;
    _iContentWeb.backgroundColor = [UIColor whiteColor];
    //_iContentWeb.hidden = YES;
//    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_iContentWeb];

    
    
#pragma mark- 添加邮件头部
    CGRect headerFrame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH, kHeaderHeight);
    _iHeaderView = [[UIView alloc] init];
    _iHeaderView.frame = headerFrame;
    _iHeaderView.backgroundColor = [UIColor redColor];
    _iContentWeb.headerView = _iHeaderView;
    
    UIView *headerLineView = [[UIView alloc] init];
    if (_email.subject.length>25){
    headerLineView.frame = CGRectMake(0, headerFrame.size.height-HeaderLineHeight+8, headerFrame.size.width, HeaderLineHeight);
    }else
    {
        headerLineView.frame = CGRectMake(0, headerFrame.size.height-HeaderLineHeight, headerFrame.size.width, HeaderLineHeight);
    }
    headerLineView.tag = HeaderLineViewTag;
    headerLineView.backgroundColor = [UIColor lightGrayColor];
    [_iHeaderView addSubview:headerLineView];
    
    CGFloat titleH = 44;
    CGRect titleFrame = CGRectMake(kSpacingH+5, kSpacingV, ABDEVICE_SCREEN_WIDTH - kSpacingH * 2, titleH);
    _iTitleLabel.frame = titleFrame;
//    _iTitleLabel.backgroundColor = [UIColor blueColor];
    
    
    if(!_email.subject)
    {
        _iTitleLabel.text = @"无主题";
    }
    else
    {
        _iTitleLabel.text = _email.subject;
//        _iTitleLabel.numberOfLines = 2;
//        [_iTitleLabel setAdjustsFontSizeToFitWidth:YES];
//        _iTitleLabel.adjustsFontSizeToFitWidth = YES;
        int count = [_email.subject length];
        NSLog(@"字符串的长度是%d",count);
        if (_email.subject.length>25)
        {
            //正文标题
            _iTitleLabel.frame = CGRectMake(kSpacingH+5, kSpacingV+8, ABDEVICE_SCREEN_WIDTH - kSpacingH * 2, titleH);
        }
    }
    
    [_iHeaderView addSubview:_iTitleLabel];
    
    CGRect tipsViewFrame = CGRectMake(0, titleH, ABDEVICE_SCREEN_WIDTH, kTipsViewHeight);
    _iTipsView.frame = tipsViewFrame;
    [_iHeaderView addSubview:_iTipsView];
    
    CGFloat buttonW = 64;
    CGFloat buttonH = 30;
    CGFloat buttonX = ABDEVICE_SCREEN_WIDTH - kSpacingH - buttonW;
//    CGRect buttonFrame = CGRectMake(buttonX, (kTipsViewHeight - buttonH) / 2, buttonW, buttonH);
//    _iDetailButton.frame = buttonFrame;
    if (_email.subject.length>25)
    {
    _iDetailButton.frame = CGRectMake(280, -2+16, 30, 30);
    }else
    {
        _iDetailButton.frame = CGRectMake(280, -2, 30, 30);
    }
    [_iTipsView addSubview:_iDetailButton];
    
    CGFloat tipsH = 22;
//    CGRect tipsFrame = CGRectMake(kSpacingH, (kTipsViewHeight - tipsH) / 2, ABDEVICE_SCREEN_WIDTH - buttonW - kSpacingH * 2, tipsH);
    //发送至我View
    if (_email.subject.length>25)
    {
    CGRect tipsFrame = CGRectMake(kSpacingH+4, 0+16, ABDEVICE_SCREEN_WIDTH - buttonW - kSpacingH * 2, tipsH);
    _iTipsLabel.frame = tipsFrame;
    }else
    {
        CGRect tipsFrame = CGRectMake(kSpacingH+4, 0, ABDEVICE_SCREEN_WIDTH - buttonW - kSpacingH * 2, tipsH);
        _iTipsLabel.frame = tipsFrame;
    }
    _iTipsLabel.text = _email.subject;
   // _iTipsLabel.backgroundColor = [UIColor redColor];
    [_iTipsView addSubview:_iTipsLabel];
    
    NSMutableString *s = [NSMutableString new];
    for (EmailAddress *add in _email.receivers) {
        if ([add.address isEqualToString:_account.username]) {
            [s appendFormat:@"%@,",NSLocalizedString(@"MailDetail.tips.me", nil)];
        } else {
            NSString *name = add.displayName;
            if ([LogicHelper isBlankOrNil:name]) {
                name = add.address;
            }
            [s appendFormat:@"%@,",name];
        }
    }
    
    if ([s length] > 1 && [s characterAtIndex:[s length]-1] == ',')
    {
        s = [NSMutableString stringWithString:[s substringToIndex:[s length]-1]];
    }
    
//    NSString *targer = _email.sender.displayName;
    NSString *targer = _email.sender.displayName;
    if ([LogicHelper isBlankOrNil:targer]) {
        targer = _email.sender.address;
    }
    //某人发送至某人Lable
    _iTipsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MailDetail.tips.format", nil),targer,s];
    NSString *name1=_account.username;
    
    if([name1 isEqualToString:_email.sender.address]){
        _iTipsLabel.text=[_iTipsLabel.text stringByReplacingOccurrencesOfString:targer withString:@"我"];
    }

    
    {
#pragma mark - 头部联系人详情
        //点击详情后，发件人收件人时间都在这个view里面
        _iDetailView.backgroundColor = [UIColor whiteColor];
        _detailViewHeight = kSpacingV;
        
        CGFloat buttonW = 64;
        CGFloat buttonH = 30;
        CGFloat buttonX = ABDEVICE_SCREEN_WIDTH - kSpacingH - buttonW;
        CGRect buttonFrame = CGRectMake(buttonX, _detailViewHeight, buttonW, buttonH);
        //_iHideButton.frame = buttonFrame;
        _iHideButton.frame = CGRectMake(280, 0, 30, 30);
        [_iDetailView addSubview:_iHideButton];
        
        CGFloat textH = 22;
        CGFloat textW = 60;
        CGFloat text2W = ABDEVICE_SCREEN_WIDTH - buttonW - kSpacingH * 2;
        CGRect senderFrame = CGRectMake(kSpacingH+5, _detailViewHeight-4, textW, textH);
        _iSenderLabel.frame = senderFrame;
        //呵呵4
        [_iDetailView addSubview:_iSenderLabel];
        
        CGRect sender2Frame = CGRectMake(kSpacingH + textW+5, _detailViewHeight-4, text2W-50, textH);
        _iSenderLabel2.frame = sender2Frame;
        //呵呵3
        [_iDetailView addSubview:_iSenderLabel2];
        _iSenderLabel2.text = _email.sender.displayName;
        if([name1 isEqualToString:_email.sender.address]){
            _iSenderLabel2.text=[_iSenderLabel2.text stringByReplacingOccurrencesOfString:targer withString:@"我"];
       
        }
        _detailViewHeight += kSpacingV + buttonH;
        CGRect dateFrame = CGRectMake(kSpacingH+6, kSpacingV + buttonH-4, textW, textH);
        _iDateLabel.frame = dateFrame;
        //呵呵
        [_iDetailView addSubview:_iDateLabel];
        
        CGRect date2Frame = CGRectMake(kSpacingH + textW+5, kSpacingV + buttonH-4, text2W, textH);
        _iDateLabel2.frame = date2Frame;
        //呵呵1
        [_iDetailView addSubview:_iDateLabel2];
        _iDateLabel2.text = [_email getstandardFormatDate];
        
        _detailViewHeight += kSpacingV + textH;
        
        CGRect recvFrame = CGRectMake(kSpacingH+5, _detailViewHeight-4, textW, textH);
        _iRecvLabel.frame = recvFrame;
        //呵呵2
        [_iDetailView addSubview:_iRecvLabel];
        
        
        NSMutableString *recvers = [NSMutableString new];
        for (EmailAddress *add in _email.receivers) {
            NSString *name = add.displayName;
            if ([name1 isEqualToString:add.address]) {
                name=@"我";
            }
            if ([LogicHelper isBlankOrNil:name]) {
                name = add.address;
            }
            [recvers appendFormat:@"%@,",name];
        }
        CGRect recvRect = [LogicHelper sizeWithWidth:recvers width:text2W font:_iRecvLabel2.font];
        CGRect recv2Frame = CGRectMake(kSpacingH + textW+5, _detailViewHeight-4, text2W, recvRect.size.height);
        //呵呵5
        _iRecvLabel2.frame = recv2Frame;
        [_iDetailView addSubview:_iRecvLabel2];
        if ([recvers length] > 1 && [recvers characterAtIndex:[recvers length]-1] == ',')
        {
            _iRecvLabel2.text = [recvers substringToIndex:[recvers length]-1];
           
        }else
        {
            _iRecvLabel2.text = recvers;
            
        }
    

      
        NSLog(@"%@",NSHomeDirectory());
        _iRecvLabel2.numberOfLines = 0;
        if (recvRect.size.height < textH) {
            _detailViewHeight += textH + kSpacingV;
        } else {
            _detailViewHeight += recvRect.size.height + kSpacingV;
        }
        
        
        if ([_email.cc count] > 0) {
            CGRect ccFrame = CGRectMake(kSpacingH+5, _detailViewHeight, textW, textH);
            _iCCLabel.frame = ccFrame;
            [_iDetailView addSubview:_iCCLabel];
            NSMutableString *ccs = [NSMutableString new];
            for (EmailAddress *add in _email.cc) {
                NSString *name = add.displayName;
                if ([name1 isEqualToString:add.address]) {
                    name=@"我";
                }
                if ([LogicHelper isBlankOrNil:name]) {
                    name = add.address;
                }
                
                [ccs appendFormat:@"%@,",name];
            }
            
            CGRect ccRect = [LogicHelper sizeWithWidth:ccs width:text2W font:_iCCLabel2.font];
            CGRect cc2Frame = CGRectMake(kSpacingH + textW, _detailViewHeight, text2W, ccRect.size.height);
            _iCCLabel2.frame = cc2Frame;
            _iCCLabel2.numberOfLines = 0;
            [_iDetailView addSubview:_iCCLabel2];
            if (ccRect.size.height < textH) {
                _detailViewHeight += textH + kSpacingH;
            } else {
                _detailViewHeight += ccRect.size.height + kSpacingH;
            }
            if ([ccs length] > 1 && [ccs characterAtIndex:[ccs length]-1] == ',')
            {
                _iCCLabel2.text = [ccs substringToIndex:[ccs length]-1];
            }
            else
            {
                _iCCLabel2.text = ccs;
            }
            
        }
        _iDetailView.hidden = YES;
    }
    if (_email.subject.length>25)
    {
    CGRect detailViewFrame = CGRectMake(0, titleH, ABDEVICE_SCREEN_WIDTH, _detailViewHeight-12);
    //详情界面view
    _iDetailView.frame = detailViewFrame;
    }else
    {
        CGRect detailViewFrame = CGRectMake(0, titleH, ABDEVICE_SCREEN_WIDTH, _detailViewHeight);
        //详情界面view
        _iDetailView.frame = detailViewFrame;
    }
    
    //_iDetailView.backgroundColor = [UIColor redColor];
    [_iHeaderView addSubview:_iDetailView];
    
    CGRect progressFrame = CGRectMake(ABDEVICE_SCREEN_WIDTH / 2 - 10, kHeaderHeight + 25, 20, 20);
    _iLoadingProgress.frame = progressFrame;
    [self.view addSubview:_iLoadingProgress];
    
    
    webFrame.origin.y = ABDEVICE_SCREEN_HEIGHT / 2;
    if (_email.htmlText != nil) {
        NSMutableString * html = [NSMutableString string];
        [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
         @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
         @"</iframe></html>", mainJavascript, mainStyle, _email.htmlText];
        [_iContentWeb loadHTMLString:html baseURL:nil];

    } else {
        [_iLoadingProgress startAnimating];
        _iContentWeb.scrollView.scrollEnabled = NO;
        [_handler loadEmailHtmlText];
    }
    
}
//暂时注释的附件
//-(void)jiehshou{
//    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(recrive:) name:notificationName object:nil];
//}
//-(void)recrive:(NSNotification*)sender{
//    if (sender.userInfo!=nil) {
//
//        NSString * str1 =[sender.userInfo objectForKey:@"key"];
//        NSString * b = [str1 substringFromIndex:4];
//        NSMutableString * str2 = [NSMutableString stringWithString:b];
//        [str2 deleteCharactersInRange:NSMakeRange(1, 1)];
//        
//        _fujian = [[UIView alloc]initWithFrame:CGRectMake(238, 30, 49, 23)];
//        _fujian.backgroundColor=[UIColor colorWithRed:49.0/255.0 green:101.0/255.0 blue:223.0/255.0 alpha:1];
//        _fujian.layer.cornerRadius = 7.0;
//        [self.view addSubview:_fujian];
//        
//        _imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"3_icon_accessory1@2x.png"]];
//        _imageV.frame=CGRectMake(13, 3, 10, 17);
//        [_fujian addSubview:_imageV];
//        
//        _jiezhi=[[UILabel alloc]init];
//        _jiezhi.text=str2;
//        _jiezhi.frame=CGRectMake(28, -3, 65, 30);
//        _jiezhi.font=[UIFont systemFontOfSize:16];
//        _jiezhi.textColor=[UIColor whiteColor];
//        
//        [_fujian addSubview:_jiezhi];
//        [_iHeaderView addSubview:_fujian];
//        
//        NSLog(@"jiezhi:%@",_jiezhi.text);
//    }else{
//        _fujian.hidden=YES;
//    }
//  
//    
//}
- (void)refreshViewFromEmailContent:(NSString *)content
{
    NSMutableString * html = [NSMutableString string];
    [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
     @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
     @"</iframe></html>", mainJavascript, mainStyle, content];
    [_iContentWeb loadHTMLString:html baseURL:nil];
}

- (void)resetUIFrame
{
    CGFloat attY = 0;
    if (_iDetailView.hidden) {
        attY = _iTitleLabel.frame.size.height + kTipsViewHeight;
        [_iContentWeb headerViewHeightChange:attY animated:YES];
    } else {
        attY = _iTitleLabel.frame.size.height + _detailViewHeight;
        [_iContentWeb headerViewHeightChange:attY animated:YES];
    }
    
    //bug6解决隐藏详情下移问题
    _iDetailView.frame = CGRectMake(0, _iHeaderView.frame.size.height-_iDetailView.frame.size.height-HeaderLineHeight, _iHeaderView.frame.size.width, _iDetailView.frame.size.height);
     if (_email.subject.length>25)
     {
         [_iHeaderView viewWithTag:HeaderLineViewTag].frame = CGRectMake(0, _iHeaderView.frame.size.height-HeaderLineHeight+12, _iHeaderView.frame.size.width, HeaderLineHeight);
     }else
     {
         [_iHeaderView viewWithTag:HeaderLineViewTag].frame = CGRectMake(0, _iHeaderView.frame.size.height-HeaderLineHeight, _iHeaderView.frame.size.width, HeaderLineHeight);
     }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([Reachability getCurrentNetWorkStatus]) {
        [_iLoadingProgress startAnimating];
    }else{
        UIAlertView *a=[[UIAlertView alloc]initWithTitle:@"提示" message:@"网络断开了，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [a show];
        //[self.navigationController popViewControllerAnimated:YES];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = request.URL;
        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
        return NO;
    }
    
    NSURLRequest *responseRequest = [self webView:webView resource:nil willSendRequest:request redirectResponse:nil fromDataSource:nil];
    
    if(responseRequest == request) {
        return YES;
    } else {
        [webView loadRequest:responseRequest];
        return NO;
    }
}

- (NSURLRequest *)webView:(UIWebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource
{
    if ([[[request URL] scheme] isEqualToString:@"x-mailcore-msgviewloaded"]) {
        [self _loadImages];
    }
    
    return request;
}

- (void) _loadImages
{
    NSString * result = [_iContentWeb stringByEvaluatingJavaScriptFromString:@"findCIDImageURL()"];
    NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray * imagesURLStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    for(NSString * urlString in imagesURLStrings) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *theScheme = [url scheme];
        if ([theScheme caseInsensitiveCompare:@"cid"] == NSOrderedSame){
            NSURL * cacheURL = [self _cacheJPEGImageData:nil withFilename:url.resourceSpecifier];
            
            NSDictionary * args = @{ @"URLKey": urlString, @"LocalPathKey": cacheURL.absoluteString };
            NSString * jsonString = [self _jsonEscapedStringFromDictionary:args];
            
            NSString * replaceScript = [NSString stringWithFormat:@"replaceImageSrc(%@)", jsonString];
            [_iContentWeb stringByEvaluatingJavaScriptFromString:replaceScript];

        }
        
    }
}
- (NSString *) _jsonEscapedStringFromDictionary:(NSDictionary *)dictionary
{
    NSData * json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
}
- (NSURL *) _cacheJPEGImageData:(NSData *)imageData withFilename:(NSString *)filename
{
//    NSString * path = [[NSTemporaryDirectory() stringByAppendingPathComponent:filename] stringByAppendingPathExtension:@"jpg"];
//    [imageData writeToFile:path atomically:YES];
      return [NSURL fileURLWithPath:[LogicHelper sandboxHtmlFilePath:filename]];
}

-(void)dealloc{
    //找到通知中心
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:@"WWDC" object:nil];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_iLoadingProgress stopAnimating];
    _iContentWeb.scrollView.scrollEnabled = YES;
    DDLogInfo(@"webview contentsize=%@",NSStringFromCGSize(_iContentWeb.scrollView.contentSize));
    
    if (_iContentWeb.scrollView.contentSize.height < 400)
    {
        NSString *str = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '300%'";
        [_iContentWeb stringByEvaluatingJavaScriptFromString:str];
    }
    
    [self addAttachmentsView];
}

- (void)addAttachmentsView
{
    NSUInteger count = [_email.attachments count];
    if (count == 0) {
        return;
    }
    NSMutableArray *atts = [NSMutableArray new];
    for (NSObject *obj in _email.attachments) {
        [atts addObject:obj];
    }
    
    AttachmentsView *attView = [[AttachmentsView alloc] initWithAttachments:atts];
    attView.delegate = self;
    attView.frame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH, [attView viewHeight]);
    _iContentWeb.footerView = attView;
     attView.backgroundColor = [UIColor whiteColor];
    
    //_iContentWeb.hidden = NO;
}

#pragma mark - 查看附件
- (void)didAttachmentClick:(NSObject *)attachment
{

    Attachment *att = (Attachment *)attachment;
    NSString *filePath = [LogicHelper getLocalFilePath:att.filename];
    if ([[filePath pathExtension] isEqualToString:@"txt"]) {
        NSString *str= [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        if (!str) {
            str= [NSString stringWithContentsOfFile:filePath encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000) error:nil];
        }
        //解决txt文件中文乱码问题，转码成NSUTF16StringEncoding类型
        [str writeToFile:filePath atomically:YES encoding:NSUTF16StringEncoding error:nil];
        NSLog(@"%@ ",str);
    }
   NSURL *file_URL = [NSURL fileURLWithPath:filePath];
    if (file_URL != nil) {
        //UIDocumentInteractionController *fileInteractionController = [UIDocumentInteractionController new];
        UIDocumentInteractionController *fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:file_URL];
        fileInteractionController.delegate = self;
        //fileInteractionController.UTI = [LogicHelper fileSuffix:a.filename];
        if (![fileInteractionController presentPreviewAnimated:YES]) {
            DDLogInfo(@"=========");
            UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此文件手机无法打开，请到电脑网页打开" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alertV show];
        }
        //[fileInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    }
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
    //显示时间条
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self;
}

-(UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
    DDLogInfo(@"documentInteractionControllerDidEndPreview");
    //导航栏背景颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:111.0/255.0 blue:245.0/255.0 alpha:1.0]];
    //导航栏按钮颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //导航栏字体颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
     [self.view removeFromSuperview];
    return 0;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    DDLogInfo(@"documentInteractionControllerDidDismissOpenInMenu");
    return self.view.frame;
}

- (IBAction)didDetailButtonClick:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _iDetailView.hidden = NO;
        _iTipsView.hidden = YES;
        _iDetailView.alpha = 1;
        _iTipsView.alpha = 0;
    }];
    [self resetUIFrame];
}

- (IBAction)didHideButtonClick:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _iDetailView.hidden = YES;
        _iTipsView.hidden = NO;
        _iDetailView.alpha = 0;
        _iTipsView.alpha = 1;
    }];
    
    [self resetUIFrame];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect headerFrame = _iHeaderView.frame;
    CGRect detailFrame = _iDetailView.frame;
    CGRect tipsFrame = _iTipsView.frame;
    headerFrame.origin.x = scrollView.contentOffset.x;
    detailFrame.origin.x = scrollView.contentOffset.x;
    tipsFrame.origin.x = scrollView.contentOffset.x;
    _iHeaderView.frame = headerFrame;
    _iDetailView.frame = detailFrame;
    _iTipsView.frame = tipsFrame;
    
}

#pragma mark - 邮件标星
- (IBAction)didFavoriteButtonClick:(id)sender
{
    if ([_email.isFlag boolValue]) {
        _iFavoriteButton.image = [UIImage imageNamed:@""];
        _iFavoriteButton.title = @"标记星号";
    } else {
        _iFavoriteButton.image = [UIImage imageNamed:@""];
        _iFavoriteButton.title = @"取消星号";
    }
    [_handler saveFavorite];
}



- (IBAction)didTrashButtonClick:(id)sender
{
    _alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"MailDetail.delete", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"app.cancel", nil) otherButtonTitles:NSLocalizedString(@"app.delete", nil), nil];
    [_alert show];
}

- (IBAction)didReplyButtonClick:(id)sender
{
    _actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"app.cancel", nil)
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedString(@"MailDetail.reply", nil), NSLocalizedString(@"MailDetail.replyAll",nil), NSLocalizedString(@"MailDetail.transmit", nil),nil];
    _actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [_actionSheet showInView:self.view];
}
-(void)xiaxianHidden{
    NSNotificationCenter*centerHI=[NSNotificationCenter defaultCenter];
    //找到通知中心,注册收听某主题的广播
    [centerHI addObserver:self selector:@selector(recriveHidden:) name:@"踢下线" object:nil];
}
-(void)recriveHidden:(NSNotification*)xiaxianH{
   
    if (_actionSheet.hidden == NO) {
          [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (_alert.hidden == NO) {
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

-(void)deallocXiaXian{
    //找到通知中心
    NSNotificationCenter*centerHidden=[NSNotificationCenter defaultCenter];
    
    [centerHidden removeObserver:self name:@"踢下线" object:nil];
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    switch (buttonIndex) {
        case 0:
            [_handler reply];
            break;
        case 1:
            [_handler replyAll];
            break;
        case 2:
            [_handler transmit];
        
            
            //转发
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [_handler deleteMail];
    }
}

- (void)viewDidLayoutSubviews
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.0 && version <= 8.0) {
        //        _iContentScroll.contentSize = CGSizeMake(_iContentScroll.contentSize.width, ABDEVICE_SCREEN_HEIGHT + (_files.count -1) * 60 + _iContentWeb.frame.size.height);
        //        DDLogInfo(@"%f",_iContentScroll.contentSize.height);
        [self resetUIFrame];
    }
    
}

@end
