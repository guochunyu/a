//
//  MWWebViewController.m
//  test
//
//  Created by 许学 on 14-8-8.
//  Copyright (c) 2014年 许学. All rights reserved.
//

#import "MWWebViewController.h"

#define MWFSystemVersion          ([[[UIDevice currentDevice] systemVersion] floatValue])
#define MWUIColorFromRGB(colorRed,colorGreen,colorBlue)  [UIColor colorWithRed:(colorRed)/255.0 green:(colorGreen)/255.0 blue:(colorBlue)/255.0 alpha:1.0]
#define MWPNGIMAGE(NAME)          [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(NAME) ofType:@"png"]]

#define MW_App_Frame_Height        [[UIScreen mainScreen] applicationFrame].size.height
#define MW_App_Frame_Width         [[UIScreen mainScreen] applicationFrame].size.width

#define kNavBarHeight                   44
#define kTooBarHeight                   44

@implementation MWToolBar
- (UIImage *)createImage:(UIColor *)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
- (void)drawRect:(CGRect)rect {
    if(MWFSystemVersion >= 7.0f)
    {
        [[self createImage:[UIColor whiteColor]] drawInRect:rect];
    }
    else
        [MWPNGIMAGE(@"pb_tabbar_background") drawInRect:rect];
}
@end


@interface MWWebViewController ()<UIPopoverControllerDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIBarButtonItem *stopLoadingButton;
@property (strong, nonatomic) UIBarButtonItem *reloadButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;

@property (strong, nonatomic) UIPopoverController *activitiyPopoverController;

@property (nonatomic,strong) UILabel *titleLb;
@property (nonatomic,strong) MWToolBar *toolBar;

@end

@implementation MWWebViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)load
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.URL];
    [self.webView loadRequest:request];
    
}

- (void)clear
{
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.titleLb.text = @"";
    self.title = @"";
}

#pragma mark - View controller lifecycle
- (void)dealloc
{
    
}
- (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result;
    
    // Try to find the root view controller programmically
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows)
        {
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        result = topWindow.rootViewController;
    else
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
	
    return result;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.userInteractionEnabled = YES;
    
    //webview
    self.webView = [[UIWebView alloc] init];
    self.webView.scalesPageToFit = YES;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    
    [self.view addSubview:self.webView];
    
    //[self setupToolBarItems];
    //PBWebBrowserModeModal 模式自定义nav   ios7 以下PBWebBrowserModeNavigation 也自定义nav
    if(self.mode == MWWebBrowserModeModal){
        CGRect webViewRect = self.view.frame;
        
        if(MWFSystemVersion >= 7.0){
            self.edgesForExtendedLayout = UIRectEdgeNone;
            webViewRect = CGRectMake(webViewRect.origin.x, 20, webViewRect.size.width, webViewRect.size.height-kTooBarHeight-20);
        }
        else{
            webViewRect = CGRectMake(webViewRect.origin.x, 0, webViewRect.size.width, webViewRect.size.height-kTooBarHeight);
        }
        self.webView.frame = webViewRect;
    }
    else if (self.mode == MWWebBrowserModeNavigation){
        CGRect webViewRect = self.view.frame;
        
        if(MWFSystemVersion >= 7.0)
            self.webView.frame = CGRectMake(webViewRect.origin.x, kNavBarHeight+20, webViewRect.size.width, webViewRect.size.height-kNavBarHeight-kTooBarHeight-20);
        else
            self.webView.frame = CGRectMake(webViewRect.origin.x, kNavBarHeight, webViewRect.size.width, webViewRect.size.height-kNavBarHeight-kTooBarHeight);
        [self setpNavBar];
        
    }
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //版本低于ios7 并且是PBWebBrowserModeNavigation 模式就隐藏系统的nav用自定义的
    if(self.mode == MWWebBrowserModeNavigation)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    self.webView.delegate = self;
    
    if (self.URL)
    {
        [self load];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clear];
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Helpers

- (void)setpNavBar
{
    CGRect navRect = CGRectMake(0, 0, self.view.bounds.size.width, kNavBarHeight);
    if(MWFSystemVersion >= 7.0f){
        navRect.origin.y = 20;
    }
    
    UIView *navView = [[UIView alloc] initWithFrame:navRect];
    navView.backgroundColor = MWUIColorFromRGB(246,246,246);
    UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = MWPNGIMAGE(@"navigationbar_back");
    
    [backBt setBackgroundImage:image forState:UIControlStateNormal];
    CGSize imageSize = image.size;
    backBt.frame = CGRectMake(10, 5, imageSize.width, imageSize.height);
    [backBt addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBt];
    //[self.view addSubview:navView];
    
    CGFloat offset = 15.0f;
    self.titleLb = [[UILabel alloc] initWithFrame:CGRectMake(offset, 0, navRect.size.width-(offset+10), kNavBarHeight)];
    self.titleLb.numberOfLines = 1;
    self.titleLb.textAlignment = NSTextAlignmentCenter;
    self.titleLb.backgroundColor = [UIColor clearColor];
    [navView addSubview:self.titleLb];
}



- (UIImage *)leftTriangleImage
{
    static UIImage *image;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CGSize size = CGSizeMake(14.0f, 16.0f);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0.0f, 8.0f)];
        [path addLineToPoint:CGPointMake(14.0f, 0.0f)];
        [path addLineToPoint:CGPointMake(14.0f, 16.0f)];
        [path closePath];
        [path fill];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return image;
}

- (UIImage *)rightTriangleImage
{
    
    static UIImage *rightTriangleImage;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UIImage *leftTriangleImage = [self leftTriangleImage];
        
        CGSize size = leftTriangleImage.size;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGFloat x_mid = size.width / 2.0f;
        CGFloat y_mid = size.height / 2.0f;
        
        CGContextTranslateCTM(context, x_mid, y_mid);
        
        CGContextRotateCTM(context, M_PI);
        [leftTriangleImage drawAtPoint:CGPointMake((x_mid * -1), (y_mid * -1))];
        
        rightTriangleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    return rightTriangleImage;
    
    
}

- (void)setupToolBarItems
{
    
    self.toolBar = [[MWToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kTooBarHeight, self.view.frame.size.width, kTooBarHeight)];
    self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.toolBar setBarStyle:UIBarStyleBlackTranslucent];
    //self.toolBar.backgroundColor = [UIColor clearColor];
    //[self.view addSubview:self.toolBar];
    
    /*
    self.stopLoadingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                           target:self
                                                                           action:@selector(reloadStopButtonTapped:)];
    
    self.reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                      target:self
                                                                      action:@selector(reloadStopButtonTapped:)];
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[self leftTriangleImage]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(backButtonTapped:)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[self rightTriangleImage]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(forwardButtonTapped:)];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:MWPNGIMAGE(@"navigationbar_back") style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(action:)];
    
    UIBarButtonItem *space_ = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                            target:nil
                                                                            action:nil];
    space_.width = 35.0f;
    
    self.toolbarItems = @[closeButton,space_,self.stopLoadingButton, space_, self.backButton, space_, self.forwardButton, space_, actionButton];
    [self.toolBar setItems:self.toolbarItems animated:YES];
     */
}

- (void)toggleState
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    NSMutableArray *toolbarItems = [self.toolbarItems mutableCopy];
    if (self.webView.loading) {
        toolbarItems[2] = self.stopLoadingButton;
    } else {
        toolbarItems[2] = self.reloadButton;
    }
    self.toolbarItems = [toolbarItems copy];
    
    [self.toolBar setItems:self.toolbarItems animated:YES];
}

- (void)finishLoad
{
    [self toggleState];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - Button actions

- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
    [self refreshButtonsState];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
    [self refreshButtonsState];
}

- (void)reloadStopButtonTapped:(id)sender
{
    if (self.webView.isLoading)
        [self.webView stopLoading];
    else
        [self.webView reload];
    
    [self refreshButtonsState];
}

- (void)back:(id)sender
{
    if(self.mode == MWWebBrowserModeNavigation)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)action:(id)sender
{
    UIActionSheet *moreSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"用Safari打开",@"复制链接", nil];
    [moreSheet showInView:self.view];
}

#pragma mark Button State Handling
- (void)refreshButtonsState
{
    //update the state for the back button
    if (self.webView.canGoBack)
        [self.backButton setEnabled:YES];
    else
        [self.backButton setEnabled:NO];
    
    if (self.webView.canGoForward)
        [self.forwardButton setEnabled:YES];
    else
        [self.forwardButton setEnabled:NO];
}


#pragma mark - Web view delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL absoluteString] hasPrefix:@"sms:"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    if ([[request.URL absoluteString] hasPrefix:@"http://www.youtube.com/v/"] ||
        [[request.URL absoluteString] hasPrefix:@"http://itunes.apple.com/"] ||
        [[request.URL absoluteString] hasPrefix:@"https://itunes.apple.com/"] ||
        [[request.URL absoluteString] hasPrefix:@"http://phobos.apple.com/"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self toggleState];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self finishLoad];
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleLb.text = self.title;
    self.URL = self.webView.request.URL;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self finishLoad];
}

#pragma mark - Popover controller delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.activitiyPopoverController = nil;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:self.URL];
            break;
        case 1:{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.URL.absoluteString;
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
