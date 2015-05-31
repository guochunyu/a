//
//  MailEditController.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailEditController.h"
#import "MailEditHandler.h"
#import "LogicHelper.h"
#import "MNAlertPopup.h"
#import "Email.h"
#import "MailLogic.h"
#import "MintAnnotationChatView.h"
#import "NavigationVC_AddID.h"
#import "Email.h"
#import "AccountPopup.h"
#import "AttachmentsView.h"
#import "MainNavigationCT.h"
#import "CoreDataManager.h"
#import "AttachmentsController.h"
#import "MailDetailController.h"
#import "Reachability.h"
@import AssetsLibrary;


#define DefaultContent  @"--发自「和企录」客户端"
#define automatic_To_adapt_tohighly
#define AUTOMATIC_TO_ADAPT_TOHIGHLY 67
#define CC_AUTOMATIC_TO_ADAPT_TOHIGHLY 87
//static const CGFloat kAttItemHeight = 40;
//static const CGFloat kAttButtonHeight = 34;

static const CGFloat kViewHeight = 44;
//static const CGFloat kContentHeight = 200;
//static const CGFloat kSpacingV = 8;
static const CGFloat kSpacingH = 12;
static const CGFloat kDefaultContentHeight = 150;

@interface MailEditController () <UITextViewDelegate, UIAlertViewDelegate, AccountPopupDelegate,AttachmentsViewDelegate,navigation_addIDDelegaet,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AttachmentsControllerDelegate,UIDocumentInteractionControllerDelegate,
    UITextFieldDelegate>

{
    BOOL isEdited;
}

@property (nonatomic) Email *email;
@property (nonatomic) EmailSendType type;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *iCancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *iSendButton;

@property (weak, nonatomic) IBOutlet UIScrollView *iContentScroll;
// 收件人
@property (strong, nonatomic) IBOutlet UIView *iReceiverView;
@property (strong, nonatomic) IBOutlet UILabel *iReceiverLabel;
@property (strong, nonatomic) IBOutlet UIButton *iRecvAddButton;
@property (strong, nonatomic) IBOutlet MintAnnotationChatView *iRecvText;
// 抄送
@property (strong, nonatomic) IBOutlet MintAnnotationChatView *iCCText;
@property (strong, nonatomic) IBOutlet UILabel *iCCLabel;
@property (strong, nonatomic) IBOutlet UIView *iCCView;
@property (strong, nonatomic) IBOutlet UIButton *iCCButton;
// 主题
@property (strong, nonatomic) IBOutlet UIView *iTitleView;
@property (strong, nonatomic) IBOutlet UITextField *iTitleText;
@property (strong, nonatomic) IBOutlet UILabel *iTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *iTitleButton;

@property (strong, nonatomic) IBOutlet UITextView *iContentText;
@property (strong, nonatomic) IBOutlet UIWebView *iContentWeb;

@property (nonatomic) NSMutableArray *files;

@property (nonatomic) MNAlertPopup *popup;

@property (nonatomic) EmailAccount *account;
@property (nonatomic) AccountPopup *accountPopup;
@property (nonatomic) NSArray *accounts;
@property (nonatomic) UIButton *titleButton;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *hideKeyboardTap;
@property (nonatomic) AttachmentsView *attView;
@property (nonatomic) UIAlertView *titleAlert;
@property (nonatomic) UIAlertView *mediaAlert;
@property (nonatomic) UIView *recvLine;
@property (nonatomic) UIView *ccLine;
@property (nonatomic) CGFloat webHeight;
@property (nonatomic) CGFloat webWidth;
@property(nonatomic) NSString *transmit;
@property(nonatomic)UIToolbar * topView;
@property(nonatomic) UIAlertView *alert;
@end

@implementation MailEditController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;
    isEdited = NO;
    
    
    
    //我的
//    
//    UIView * vie= [[UIView alloc]initWithFrame:CGRectMake(0, 240, 320, 60)];
//    vie.backgroundColor=[UIColor lightGrayColor];
//    vie.alpha=0.5;
//    [_recvLine addSubview:vie];
 
    //bug2注册监听事件
    [self registerKeyBoardNotification];
    [_handler initData];
    _popup = [MNAlertPopup new];
    [self initUI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xiaxian) name:@"踢下线" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callIncoming:) name:@MtcCallIncomingNotification object:nil];

}

-(void)xiaxian{
    if (_alert.hidden==NO) {
         [_alert dismissWithClickedButtonIndex:0 animated:YES];
    }
    if (_mediaAlert.hidden==NO) {
        [_mediaAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    NSLog(@"踢下线");
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    
    _iContentScroll.delegate = self;
    
}

//bug2
-(void)registerKeyBoardNotification
{
    //增加监听，当键盘出现或改变时收出消息    ［核心代码］
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

////当键盘出现或改变时调用
//- (void)keyboardWillShow:(NSNotification *)aNotification
//{
//    DDLogInfo(@"键盘键盘出现了！！！！");
//    //    _iContentText.frame = CGRectMake(0, 130, 320, 121);_textField = new TextField();
//    _iContentText.scrollEnabled=YES;
//    _iContentText.userInteractionEnabled = YES;
//
//    
//}
//
////当键退出时调用
//- (void)keyboardWillHide:(NSNotification *)aNotification
//{
//    DDLogInfo(@"键盘键盘消失了！！！！");
//   // _iContentText.frame = CGRectMake(0, 130, 320, [UIScreen mainScreen].bounds.size.height-320);
//    
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[_iContentText becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _iContentScroll.delegate = nil;
    
    _accountPopup.hidden = YES;
}

#pragma mark - UI
- (void)initUI
{
    _accountPopup = [[AccountPopup alloc] initWithMiddleAccount:_accounts delegate:self];
    [_accountPopup createAccountsPopupMiddle];
    _accountPopup.hidden = YES;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_accountPopup];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.navigationItem.titleView = view;

    _titleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    _titleButton.frame = CGRectMake(0, 0, 200, 40);
    //修改写邮件位置标题
    /*
    _titleButton.frame = CGRectMake(-45, -2, 230, 40);
    [_titleButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    _titleButton.backgroundColor = [UIColor redColor];
    [_titleButton setTitle:_account.username forState:UIControlStateNormal];
    
    [_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [_titleButton addTarget:self action:@selector(didTitleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_titleButton];
    */
    UILabel*titlelabel = [[UILabel alloc]initWithFrame:CGRectMake(-35, -2, 230, 40)];
    titlelabel.font = [UIFont systemFontOfSize:18];
    titlelabel.text = _account.username;
    titlelabel.textColor = [UIColor whiteColor];
    titlelabel.textAlignment = UITextAlignmentCenter;
    [view addSubview:titlelabel];
    
    
    
    /*
    UIImageView *imge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
    imge.frame = CGRectMake(175, 17, 12, 6);
    [view addSubview:imge];
     */
    
//    UIImageView *imge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
//    imge.frame = CGRectMake(170, 17, 12, 6);
//    [view addSubview:imge];
    
    _files = [NSMutableArray new];
    if (_type == EmailSendTypeNew ||
        _type == EmailSendTypeTransmit)
    {
        for (Attachment *att in _email.attachments) {
            [_files addObject:att];
        }
    }
    _iRecvText.delegate = self;
    _iRecvText.nameTagImage=[UIImage imageNamed:@"btn_set_on"];
    _iCCText.delegate = self;
    _iCCText.nameTagImage=[UIImage imageNamed:@"btn_set_on"];
    [self addRecvView];
    [self addCCView];
    [self addTitleView];
    [self addContentText];
    [self resetFrame];
    [self addAttachmentsView:nil];
}

- (void)didTitleButtonClick:(id)sender
{
    if (_accountPopup.hidden) {
        _accountPopup.hidden = NO;
        //[_titleButton setImage:[UIImage imageNamed:@"arrow_up"] forState:UIControlStateNormal];
    } else {
        _accountPopup.hidden = YES;
        //[_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    }
}

- (void)didAccountChanged:(EmailAccount *)account
{
    _account = account;
    [_handler changeAccount:account];
    [_titleButton setTitle:_account.username forState:UIControlStateNormal];
    //[_titleButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
}

- (void)addRecvView
{
    CGRect viewFrame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH, kViewHeight);
    _iReceiverView.frame = viewFrame;
    [_iContentScroll addSubview:_iReceiverView];
    
    CGFloat labelW = 60;
    
    CGFloat labelH = 21;
    CGRect labelFrame = CGRectMake(kSpacingH, (kViewHeight - labelH) / 2, labelW, labelH);
    _iReceiverLabel.frame = labelFrame;
    [_iReceiverView addSubview:_iReceiverLabel];
    
    
    CGFloat buttonW = 40;
    CGFloat buttonH = kViewHeight;
    CGFloat buttonX = ABDEVICE_SCREEN_WIDTH - buttonW;
    CGRect buttonFrame = CGRectMake(buttonX, (kViewHeight - buttonH) / 2, buttonW, buttonH);
    _iRecvAddButton.frame = buttonFrame;
    [_iReceiverView addSubview:_iRecvAddButton];
    _recvLine = [self createLine:60];
    [_iReceiverView addSubview:_recvLine];
    CGFloat textH = 30;
    CGFloat textX = labelFrame.origin.x + labelW;
    CGFloat textW = ABDEVICE_SCREEN_WIDTH - textX - buttonW - kSpacingH * 2;
    CGRect textFrame = CGRectMake(textX, 0, textW, textH);
    _iRecvText.frame = textFrame;
    _iRecvText.delegate = self;
    [_iReceiverView addSubview:_iRecvText];
    [_iReceiverView bringSubviewToFront:_recvLine];
    if (_type == EmailSendTypeNew && _email != nil) {
        for (EmailAddress *act in _email.receivers) {
          /* 
           if ([act.address isEqualToString:_account.username]) {
                continue;
            }
           */
            MintAnnotation *annotation = [MintAnnotation new];
            annotation.usr_id = act.address;
            annotation.usr_name = [act displayNameOrAddress];
            [_iRecvText addAnnotation:annotation];
        }
    }
    if (_type == EmailSendTypeReply) {
        MintAnnotation *annotation = [MintAnnotation new];
        annotation.usr_id = _email.sender.address;
        annotation.usr_name = [_email.sender displayNameOrAddress];
        [_iRecvText addAnnotation:annotation];
    }
    if (_type == EmailSendTypeReplyAll) {
      /*  BOOL isCC = false;
        for (EmailAddress *add in _email.cc) {
            if ([add.address isEqualToString:_account.username]) {
                isCC = true;
                break;
            }
        }
        if (isCC) { // 自己是抄送人 原始邮件发件人 收件人作为新邮件收件人
       */
            MintAnnotation *sender = [MintAnnotation new];
            sender.usr_id = _email.sender.address;
            sender.usr_name = [_email.sender displayNameOrAddress];
            [_iRecvText addAnnotation:sender];

            for (EmailAddress *act in _email.receivers) {
                if ([act.address isEqualToString:_account.username]) {
                    continue;
                }
                MintAnnotation *annotation = [MintAnnotation new];
                annotation.usr_id = act.address;
                annotation.usr_name = [act displayNameOrAddress];
                [_iRecvText addAnnotation:annotation];
            }
        /*} else { // 自己是收件人 原始邮件发件人作为收件人 其他人作为抄送人
            MintAnnotation *sender = [MintAnnotation new];
            sender.usr_id = _email.sender.address;
            sender.usr_name = [_email.sender displayNameOrAddress];
            [_iRecvText addAnnotation:sender];
        }*/

    }
}

- (void)addCCView
{
    
    
    CGRect viewFrame = CGRectMake(0, kViewHeight, ABDEVICE_SCREEN_WIDTH, kViewHeight);
    _iCCView.frame = viewFrame;
    [_iContentScroll addSubview:_iCCView];
   
    
//    UIView*uiviewe = [[UIView alloc] init];
//    uiviewe.backgroundColor = [UIColor redColor];
//    uiviewe.frame = CGRectMake(0, 25, 300, 0.5);
//    [_iRecvText addSubview:uiviewe];
//    
//    UIView*uivewq = [[UIView alloc] init];
//    uivewq.backgroundColor = [UIColor blueColor];
//    uivewq.frame = CGRectMake(0, 25, 300, 0.5);
//    [_iCCText addSubview:uivewq];

    CGFloat labelW = 60;
    CGFloat labelH = 21;
    CGRect labelFrame = CGRectMake(kSpacingH, (kViewHeight - labelH) / 2, labelW, labelH);
    _iCCLabel.frame = labelFrame;
    [_iCCView addSubview:_iCCLabel];
    
    
    
    CGFloat buttonW = 40;
    CGFloat buttonH = kViewHeight;
    CGFloat buttonX = ABDEVICE_SCREEN_WIDTH - buttonW;
    CGRect buttonFrame = CGRectMake(buttonX, (kViewHeight - buttonH) / 2, buttonW, buttonH);
    _iCCButton.frame = buttonFrame;
    [_iCCView addSubview:_iCCButton];
    _ccLine = [self createLine:60];
    [_iCCView addSubview:_ccLine];
    
    CGFloat textH = 30;
    CGFloat textX = labelFrame.origin.x + labelW;
    CGFloat textW = ABDEVICE_SCREEN_WIDTH - textX - buttonW - kSpacingH * 2;
    CGRect textFrame = CGRectMake(textX, 0, textW, textH);
    _iCCText.frame = textFrame;
    _iCCText.delegate = self;
    //_iCCView.backgroundColor=[UIColor greenColor];
    [_iCCView addSubview:_iCCText];
    [_iCCView bringSubviewToFront:_ccLine];
    
    if (_type == EmailSendTypeNew && _email != nil) {
        for (EmailAddress *act in _email.cc) {
            MintAnnotation *annotation = [MintAnnotation new];
            annotation.usr_id = act.address;
            annotation.usr_name = [act displayNameOrAddress];
            [_iCCText addAnnotation:annotation];
        }
    }
    
    if (_type == EmailSendTypeReplyAll) {
       /* BOOL isCC = false;
        for (EmailAddress *add in _email.cc) {
            if ([add.address isEqualToString:_account.username]) {
                isCC = true;
                break;
            }
        }
        if (isCC) { // 自己是抄送人 原始邮件发件人 收件人作为新邮件收件人
        */
            for (EmailAddress *act in _email.cc) {
                if ([act.address isEqualToString:_account.username]) {
                    continue;
                }
                MintAnnotation *annotation = [MintAnnotation new];
                annotation.usr_id = act.address;
                annotation.usr_name = [act displayNameOrAddress];
                [_iCCText addAnnotation:annotation];
            }
    /*    } else { // 自己是收件人 原始邮件发件人作为收件人 其他人作为抄送人
            for (EmailAddress *act in _email.cc) {
                if ([act.address isEqualToString:_account.username]) {
                    continue;
                }
                MintAnnotation *annotation = [MintAnnotation new];
                annotation.usr_id = act.address;
                annotation.usr_name = [act displayNameOrAddress];
                [_iCCText addAnnotation:annotation];
            }
            for (EmailAddress *act in _email.receivers) {
                if ([act.address isEqualToString:_account.username]) {
                    continue;
                }
                MintAnnotation *annotation = [MintAnnotation new];
                annotation.usr_id = act.address;
                annotation.usr_name = [act displayNameOrAddress];
                [_iCCText addAnnotation:annotation];
            }
        }*/
    }
    
}

- (void)addTitleView
{
    CGRect viewFrame = CGRectMake(0, kViewHeight * 2, ABDEVICE_SCREEN_WIDTH, kViewHeight);
    _iTitleView.frame = viewFrame;
    //_iTitleView.backgroundColor = [UIColor blueColor];
    [_iContentScroll addSubview:_iTitleView];
    
    CGFloat labelW = 60;
    CGFloat labelH = 21;
    CGRect labelFrame = CGRectMake(kSpacingH, (kViewHeight - labelH) / 2, labelW, labelH);
    _iTitleLabel.frame = labelFrame;
    [_iTitleView addSubview:_iTitleLabel];
    
    CGFloat buttonW = 22;
    CGFloat buttonH = 22;
    CGFloat buttonX = ABDEVICE_SCREEN_WIDTH - buttonW - kSpacingH;
    CGRect buttonFrame = CGRectMake(buttonX+3.5, (kViewHeight - buttonH) / 2, buttonW, buttonH);
    _iTitleButton.frame = buttonFrame;
    [_iTitleButton setBackgroundImage:[UIImage imageNamed:@"3_icon_not-accessory.png"] forState:UIControlStateNormal];
    [_iTitleView addSubview:_iTitleButton];
    [_iTitleView addSubview:[self createLine:0]];
    
    CGFloat textH = 30;
    CGFloat textX = labelFrame.origin.x + labelW;
    CGFloat textW = ABDEVICE_SCREEN_WIDTH - textX - buttonW - kSpacingH * 2;
    CGRect textFrame = CGRectMake(textX, (kViewHeight - textH) / 2, textW, textH);
    _iTitleText.frame = textFrame;
    _iTitleText.delegate = self;
    //_iTitleText.backgroundColor = [UIColor redColor];
    [_iTitleView addSubview:_iTitleText];
    if (_type == EmailSendTypeNew && _email != nil) {
        NSString *title = _email.subject;
        if (![title isEqualToString:@"无主题"]) {
            _iTitleText.text = title;
        }
    }
    if (_type == EmailSendTypeReply || _type == EmailSendTypeReplyAll) {
        NSString *title = [NSString stringWithFormat:@"Re:%@",_email.subject?(_email.subject):(@"无主题")];
        _iTitleText.text = title;
    }
    if (_type == EmailSendTypeTransmit) {
        NSString *title = [NSString stringWithFormat:@"Fwd:%@",_email.subject?(_email.subject):(@"无主题")];
        _iTitleText.text = title;
    }
}

- (void)addContentText
{
    NSString *t = [NSString stringWithFormat:DefaultContent];
    if (_email != nil && _email.plainText != nil && _type == EmailSendTypeNew) {
        _iContentText.text = _email.plainText;
    } else {
        //写邮件正文内容
        _iContentText.text = [NSString stringWithFormat:@"\n\n\n\n%@",DefaultContent];
    }
    
    CGRect textFrame = CGRectMake(0, kViewHeight * 3, ABDEVICE_SCREEN_WIDTH, kDefaultContentHeight);
    _iContentText.frame = textFrame;
    //写邮件内容位置
//    _iContentText.frame = CGRectMake(0, 130, 320, [UIScreen mainScreen].bounds.size.height-650);
    //_iContentText.frame = CGRectMake(0, 130, 320, [UIScreen mainScreen].bounds.size.height-450);
   // _iContentText.textColor = [UIColor redColor];
    //写邮件内容收键盘
    _topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [_topView setBarStyle:UIBarStyleDefault];
    UIBarButtonItem * helloButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:helloButton,btnSpace,doneButton,nil];
    [_topView setItems:buttonsArray];
    [_iContentText setInputAccessoryView:_topView];
    [_iRecvText setInputAccessoryView:_topView];
    [_iCCText setInputAccessoryView:_topView];
    [_iTitleText setInputAccessoryView:_topView];
    
    [_iContentScroll addSubview:_iContentText];
   
    _iContentScroll.delegate = self;
    
    if (_email != nil &&
        ((_type == EmailSendTypeReply ||
          _type == EmailSendTypeReplyAll ||
          _type == EmailSendTypeTransmit)||
         _email.sendType.integerValue == EmailSendTypeReply||
         _email.sendType.integerValue == EmailSendTypeReplyAll||
         _email.sendType.integerValue == EmailSendTypeTransmit )){
        CGRect webFrame = CGRectMake(0, kViewHeight * 3 + kDefaultContentHeight+0.5, ABDEVICE_SCREEN_WIDTH, 1);
        _iContentWeb.frame = webFrame;
        [_iContentScroll addSubview:_iContentWeb];
        if (_email.htmlText != nil) {
            if (_type == EmailSendTypeTransmit || _type == EmailSendTypeReply || _type == EmailSendTypeReplyAll) {
                [_iContentWeb loadHTMLString:[self getTransmitContent:_email] baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
            }else{
                [_iContentWeb loadHTMLString:_email.htmlText baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
            }
        }
    }else {
        
        if (_type == EmailSendTypeNew && _email && _email.plainText){
            t = _email.plainText;
        }
        //scroll大小
        _iContentScroll.contentSize = CGSizeMake(ABDEVICE_SCREEN_WIDTH,  kViewHeight * 3 + _iContentText.frame.size.height + _iContentWeb.frame.size.height+_attView.frame.size.height);
        if ([_email.archiveType integerValue] == EmailArchiveTypeDraft)
        {
            _iContentText.text = _email.plainText;
        }
    }
    _iContentText.selectedRange = NSMakeRange(0,0);
    
}
//写邮件内容收键盘
-(IBAction)dismissKeyBoard
{
    [_iContentText resignFirstResponder];
    [_iRecvText resignFirstResponder];
    [_iCCText resignFirstResponder];
    [_iTitleText resignFirstResponder];
}

-(NSString*)getTransmitContent:(Email*)email{
    NSMutableString *receivers = [NSMutableString new];
    for (EmailAddress *add in _email.receivers) {
        _name = add.displayName;
        if ([LogicHelper isBlankOrNil:_name]) {
            _name = add.address;
        }
        _str11=[NSString stringWithFormat:@"%@,",_name];
            [receivers appendString:_str11];
    
    }
    if ([_str11 hasSuffix:@","]) {
        receivers = [receivers substringToIndex:[receivers length]-1].mutableCopy;
    }
  
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
   
    NSMutableString * cc = [NSMutableString new];
    for (EmailAddress * add1 in _email.cc) {
        _name1 =add1.displayName;
        if ([LogicHelper isBlankOrNil:_name1]) {
            _name1 = add1.address;
        }
        _str = [NSString stringWithFormat:@"%@,",_name1];
        [cc appendString:_str];
  
    }
    if ([_str hasSuffix:@","]) {
        cc = [cc substringToIndex:[cc length]-1].mutableCopy;
        
    }
    email.subject = email.subject?email.subject:@"无主题";
//    return [NSString stringWithFormat:@"<html xmlns='http://www.w3.org/1999/xhtml'><head><title></title></head><body><div style='font-size: 12px;background:#efefef;padding:8px;'><div><b>发件人:</b>&nbsp;%@</div><div><b>发送时间:</b>&nbsp;%@</div><div><b>收件人:</b>&nbsp;%@ <wbr></div><div></div><div><b>主题:</b>&nbsp;%@</div></div>%@</body></html></div>",email.sender.displayName,[formatter stringFromDate:email.date],receivers,email.subject,email.htmlText];
    if ([cc isEqualToString:@""]||cc==nil) {
        return [NSString stringWithFormat:@"<html xmlns='http://www.w3.org/1999/xhtml'><head><title></title></head><body><div style='font-size: 12px;background:#efefef;padding:8px;'><div><b>发件人:</b>&nbsp;%@</div><div><b>发送时间:</b>&nbsp;%@</div><div><b>收件人:</b>&nbsp;%@ <wbr></div><div></div><div><b>主题:</b>&nbsp;%@</div></div>%@</body></html></div>",email.sender.displayName,[formatter stringFromDate:email.date],receivers,email.subject,email.htmlText];
    }else{
        return [NSString stringWithFormat:@"<html xmlns='http://www.w3.org/1999/xhtml'><head><title></title></head><body><div style='font-size: 12px;background:#efefef;padding:8px;'><div><b>发件人:</b>&nbsp;%@</div><div><b>发送时间:</b>&nbsp;%@</div><div><b>收件人:</b>&nbsp;%@ <wbr></div><div></div><div><b>抄送人:</b>&nbsp;%@ <wbr></div><div></div><div><b>主题:</b>&nbsp;%@</div></div>%@</body></html></div>",email.sender.displayName,[formatter stringFromDate:email.date],receivers,cc,email.subject,email.htmlText];
    }
    
    
    
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = _iContentWeb.frame;
    CGSize fittingSize = [_iContentWeb sizeThatFits:CGSizeZero];
    CGFloat width = fittingSize.width > ABDEVICE_SCREEN_WIDTH ? fittingSize.width : ABDEVICE_SCREEN_WIDTH;
    frame.size.width = width;
    frame.size.height = fittingSize.height +100 > 5000 ? 5000 : fittingSize.height +100;
    //转发时发送时间位置
    _iContentWeb.frame = frame;

    
    _iContentWeb.scrollView.contentInset = UIEdgeInsetsMake(0.5, 0, 0, 0);

    UILabel *line = [[UILabel alloc] init];
    line.frame = CGRectMake(0, -0.5, width, 0.5);
    line.backgroundColor = [UIColor lightGrayColor];
    [_iContentWeb addSubview:line];
    
    if (width <= ABDEVICE_SCREEN_WIDTH) {
        _iContentWeb.scrollView.scrollEnabled = NO;
    }
    _webHeight = fittingSize.height;
    DDLogInfo(@"fitting width %.1f",fittingSize.width);
    [self resetFrame];
    [self addAttachmentsView:nil];
}

- (void)addAttachmentsView:(NSArray *)assets
{
    if (assets != nil) {
        [_files addObjectsFromArray:assets];
    }
//    if (_type == EmailSendTypeNew && _email == nil) {
//        return;
//    }
    NSUInteger count = [_files count];
    if (count == 0 ) {
        return;
    }
    if (_attView != nil) {
        [_attView removeFromSuperview];
    }
    CGFloat y = 0;
    if (_email != nil) {
        y = kViewHeight * 3 + _iContentText.frame.size.height + _iContentWeb.frame.size.height;
    } else {
        y = kViewHeight * 3 + _iContentText.frame.size.height;
    }
    //附件位置
    _attView = [[AttachmentsView alloc] initWithSendAttachments:_files];
    _attView.delegate = self;
    _attView.frame = CGRectMake(0, y+_hg, ABDEVICE_SCREEN_WIDTH, [_attView viewHeight]);
   _attView.frame = CGRectMake(0, _iContentText.frame.size.height+_hg, ABDEVICE_SCREEN_WIDTH, [_attView viewHeight]);
    
    [_iContentScroll addSubview:_attView];
    //_attView.backgroundColor=[UIColor redColor];
    [self resetFrame];
    
    return;
}

- (void)didAttachmentClick:(NSObject *)attachment
{
    isEdited = YES;
    DDLogCInfo(@"点击删除附件时调用1");
    [_files removeObject:attachment];
    [_attView removeFromSuperview];
    [self addAttachmentsView:nil];
    //_iContentScroll.contentSize = CGSizeMake(_iContentScroll.contentSize.width, _iContentScroll.contentSize.height -60);
    [self resetFrame];
}

- (void)didAttachmentItemClick:(NSURL *)url
{
    if (url != nil) {
        //UIDocumentInteractionController *fileInteractionController = [UIDocumentInteractionController new];
        UIDocumentInteractionController *fileInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        fileInteractionController.delegate = self;
        //fileInteractionController.UTI = [LogicHelper fileSuffix:a.filename];
        if (![fileInteractionController presentPreviewAnimated:YES]) {
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
    [self.view removeFromSuperview];
    return 0;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    DDLogInfo(@"documentInteractionControllerDidDismissOpenInMenu");
    return self.view.frame;
}

- (void)viewDidLayoutSubviews
{
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 7.0 && version <= 9.0) {
        //_iContentScroll.contentSize = CGSizeMake(_iContentScroll.contentSize.width, ABDEVICE_SCREEN_HEIGHT + (_files.count -1) * 60);//转发附件拉升
        
        //_iContentScroll.contentSize = CGSizeMake(_iContentScroll.contentSize.width, _iContentWeb.frame.origin.y+_attView.frame.origin.y+ _attView.frame.size.height);//转发附件拉升
        
        
        DDLogInfo(@"%f",_iContentScroll.contentSize.height);
    }
    
}


#pragma mark - Action
- (IBAction)didCancelButtonClick:(id)sender
{
    DDLogCInfo(@"保存到草稿箱时调用");
    if (_email != nil && [_email.archiveType integerValue] == EmailArchiveTypeDraft) {
        if (![_email.plainText isEqualToString:_iContentText.text] || isEdited)
        {
//           _alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"MailDetail.save", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"app.cancel", nil) otherButtonTitles:NSLocalizedString(@"app.save", nil),NSLocalizedString(@"app.unsave", nil), nil];
             _alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否保存到草稿箱" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存",@"不保存", nil];
            [_alert show];
            return;
        }
        [_handler cancel:NO];
        return;
    }
    
    BOOL recvNil = [LogicHelper isBlankOrNil:_iRecvText.text];
    BOOL ccNil = [LogicHelper isBlankOrNil:_iCCText.text];
    BOOL titleNil = [LogicHelper isBlankOrNil:_iTitleText.text];
    BOOL contentNil = [_iContentText.text isEqualToString:[NSString stringWithFormat:@"\n\n\n\n%@",DefaultContent]];
    if (recvNil && ccNil && titleNil && contentNil && _attView == nil) {
        [_handler cancel:NO];
        return;
    }
    _alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否保存到草稿箱" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"保存",@"不保存", nil];
    [_alert show];
    //[_handler cancel:NO];
}

- (IBAction)didSendButtonClick:(id)sender
{

    DDLogInfo(@"点击发送的时候调用");
    [self resignKeyBoard];
    NSMutableArray *to = [NSMutableArray new];
    for (MintAnnotation *a in _iRecvText.annotationList) {
        NSString *email = a.usr_id;
        [to addObject:email];
    }
    NSString *reciver = [_iRecvText makeStringWithoutTagString];
    reciver = [[NSString alloc] initWithString:[reciver stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (![LogicHelper isBlankOrNil:reciver]) {
        [to addObject:reciver];
    }
    if (to.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入收件人" delegate:nil cancelButtonTitle:NSLocalizedString(@"app.confirm", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
 
    
    
    
    NSMutableArray *cc = [NSMutableArray new];
    for (MintAnnotation *a in _iCCText.annotationList) {
        NSString *email = a.usr_id;
        [cc addObject:email];
    }
    NSString *ccer = [_iCCText makeStringWithoutTagString];
    ccer = [[NSString alloc] initWithString:[ccer stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (![LogicHelper isBlankOrNil:ccer]) {
        [cc addObject:ccer];
    }
    NSString *subject = _iTitleText.text;
    subject = [[NSString alloc] initWithString:[subject stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if(sender)
    {
        //右上角发送
        if (subject == nil || subject.length == 0) {
            _titleAlert = [[UIAlertView alloc] initWithTitle:nil message:@"主题为空，是否进行发送？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
            [_titleAlert show];
            return;
        }
    }
    //alterview 发送
    NSMutableString *body = [NSMutableString stringWithString:_iContentText.text];
    while ([body rangeOfString:@"\n"].length > 0)
    {
        [body replaceCharactersInRange:[body rangeOfString:@"\n"] withString:@"<br>"];
    }
    [body stringByReplacingOccurrencesOfString:DefaultContent withString:[NSString stringWithFormat:@"<br><br>%@",DefaultContent]];
    if (_type == EmailSendTypeReply || _type == EmailSendTypeReplyAll || _type == EmailSendTypeTransmit) {
    
//        if (_type == EmailSendTypeTransmit) {
        
            [body appendFormat:@"%@",[self getTransmitContent:_email]];
            self.transmit=body;
    }else{
        //（null）的地方
        //[body appendFormat:@"%@",_email.htmlText];
    }

    [_popup show];
    if (subject == nil)
    {
        subject = @"";
    }
    [_handler sendWithSubject:subject body:body to:to cc:cc files:_files];
//       [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 进入通讯录选择收件人
- (IBAction)didRecvButtonAddClick:(id)sender
{
   

    if([Reachability isNetWorkReachable]){
    isEdited = YES;
    DDLogInfo(@"didRecvButtonAddClick");
    [self chooseContact:AddScrollTypeRecv];
    
    }else{
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
            return;
    }


}

#pragma mark - 进入通讯录选择抄送
- (IBAction)didCCButtonClick:(id)sender
{
    

    if ([Reachability isNetWorkReachable]) {
        isEdited = YES;
        DDLogInfo(@"didRecvButtonAddClick");
        [self chooseContact:AddScrollTypeCC];
     
    }else{
        [(AppDelegate *)[UIApplication sharedApplication].delegate showWithCustomView:@"当前网络不可用" detailText:@"请检查网络设置" isCue:1.5 delayTime:1 isKeyShow:NO];
        return;
    }
   
}

#pragma mark - 添加附件
- (IBAction)didAttachmentButtonClick:(id)sender
{
   
    _mediaAlert = [[UIAlertView alloc] initWithTitle:@"选择附件来源" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拍照",@"手机相册选取",@"选择附件",nil];
    [_mediaAlert show];
    isEdited = YES;
}

- (void)onSendCompleted:(BOOL)success desc:(NSString *)desc
{
    [_popup dismiss:^{
        if (success) {
            [self saveToBox:EmailArchiveTypeSendbox];
            if (_type == EmailSendTypeReply || _type == EmailSendTypeReplyAll) {
                        _email.hasReply = @(YES);
                        _email.hasTransmit = @(NO);
                            }
            if (_type == EmailSendTypeTransmit) {
                        _email.hasTransmit = @(YES);
                        _email.hasReply = @(NO);
                           }
            [self.navigationController popViewControllerAnimated:YES];
            //[_handler cancel:YES];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:desc == nil ? @"" : desc delegate:nil cancelButtonTitle:NSLocalizedString(@"app.confirm", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

#pragma mark scorllview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect ccFrame = _iCCView.frame;
    CGRect recvFrame = _iReceiverView.frame;
    CGRect titleFrame = _iTitleView.frame;
    CGRect textFrame = _iContentText.frame;
    ccFrame.origin.x = scrollView.contentOffset.x;
    recvFrame.origin.x = scrollView.contentOffset.x;
    titleFrame.origin.x = scrollView.contentOffset.x;
    textFrame.origin.x = scrollView.contentOffset.x;
    _iCCView.frame = ccFrame;
    _iReceiverView.frame = recvFrame;
    _iTitleView.frame = titleFrame;
    _iContentText.frame = textFrame;
    
    [self resignKeyBoard];
}

-(void)resignKeyBoard
{
   // [_iRecvText resignFirstResponder];
   // [_iCCText resignFirstResponder];
   // [_iTitleText resignFirstResponder];
    //bug2
   // [_iContentText resignFirstResponder];
}

#pragma mark - textviewdelegate

- (void)textViewDidChange:(UITextView *)textView
{
    

    //收件人
    if (textView == _iRecvText) {
        [_iRecvText textViewDidChange:textView];
    }
    //抄送
    if (textView == _iCCText) {
        [_iCCText textViewDidChange:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    MintAnnotationChatView *t;
    if (textView == _iRecvText) {
        t = _iRecvText;
    }
    if (textView == _iCCText) {
        t = _iCCText;
    }
    isEdited = YES;
    if ([text isEqualToString:@" "]) {
        NSString *plainText = [t makeStringWithoutTagString];
        NSString *text = [plainText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (![LogicHelper isBlankOrNil:text]) {
            MintAnnotation *annotation = [MintAnnotation new];
            annotation.usr_id = text;
            annotation.usr_name = text;
            NSMutableArray *anns = [NSMutableArray arrayWithArray:t.annotationList];
            [anns addObject:annotation];
            [t clearAll];
            for (MintAnnotation *a in anns) {
                [t addAnnotation:a];
            }
        }
        return YES;
    }
    BOOL result = [t shouldChangeTextInRange:range replacementText:text];
    [self resetFrame];
    return result;
}

#pragma mark - textFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _iTitleText)
    {
        isEdited = YES;
        return YES;
    }
    return NO;
}

- (void)openCamera
{
    [self.view endEditing:YES];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"正在处理照片..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    Attachment *att = [Attachment create];
    NSString *fileName = [NSString stringWithFormat:@"%f.jpg",[[NSDate date] timeIntervalSince1970]];
    NSString *filePath = [LogicHelper sandboxFilePath:fileName];
    att.filepath = filePath;
    att.filename = fileName;

    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [data writeToFile:filePath atomically:YES];
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    [self addAttachmentsView:@[att]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView == _titleAlert) {
        switch (buttonIndex) {
            case 1: {
                _iTitleText.text = @" ";
                [self didSendButtonClick:nil];
            }
        }
    } else if (alertView == _mediaAlert) {
      
        switch (buttonIndex) {
            case 1: {
      
//                if (![AppHelper hardwareCameraAvailable]) {//没有摄像头
//                    [AppHelper showAlertWithTitle:nil message:NSLocalizedString(@"user.permissio.camera.none", nil)];
//                    return ;
//                }
//                if (![AppHelper permissionCaptureEnable]) {//没有权限
//                    [AppHelper showAlertWithTitle:nil message:NSLocalizedString(@"user.permission.camera.tips", nil)];
//                    return ;
//                }
                [self openCamera];
            }
                break;
            case 2:
 
                [_handler selectPhotos];
                break;
            case 3:
    
                [self performSegueWithIdentifier:@"Attachments" sender:self];
                break;
        }
    } else {
 
        switch (buttonIndex) {
            case 1: {
             
                if (_email != nil && [_email.archiveType integerValue] == EmailArchiveTypeDraft){
                    [self saveDraft];
                    [_handler cancel:NO];
                }else{
                    [self saveToBox:EmailArchiveTypeDraft];
                    [_handler cancel:NO];
                }
                
            }
                break;
            case 2:
     
                [_handler cancel:NO];
                break;
        }
    }
}

- (void)addFiles:(NSArray *)files
{
    [self addAttachmentsView:files];
}

- (void)saveToBox:(EmailArchiveType)type
{
    if (_email != nil && [_email.archiveType integerValue] == EmailArchiveTypeDraft) {
        [_email decreate];
    }
    
    Email *email = [Email create:_account];
    
    NSMutableArray *to = [NSMutableArray new];
    for (MintAnnotation *a in _iRecvText.annotationList) {
        NSString *email = a.usr_id;
        EmailAddress *addr = [EmailAddress create];
        addr.address = email;
        addr.displayName = a.usr_name;
        [to addObject:addr];
    }
    
    NSString *reciver = [_iRecvText makeStringWithoutTagString];
    reciver = [[NSString alloc] initWithString:[reciver stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (![LogicHelper isBlankOrNil:reciver]) {
        EmailAddress *addr = [EmailAddress create];
        addr.address = reciver;
        addr.displayName = reciver;
        NSString *name = [SqlAddressData queryMemberInfoWithEmail:reciver].name;
        DDLogCInfo(@"id获取到的：%@",reciver);
        if (name) {
            addr.displayName = name;
        }
        [to addObject:addr];
    }
    email.receivers = [NSSet setWithArray:to];
     DDLogCInfo(@"啊啊啊啊啊啊啊啊：%@",email.receivers);
    
    NSMutableArray *cc = [NSMutableArray new];
    for (MintAnnotation *a in _iCCText.annotationList) {
        NSString *email = a.usr_id;
        EmailAddress *addr = [EmailAddress create];
        addr.address = email;
        addr.displayName = a.usr_name;
        [cc addObject:addr];
    }
    
    NSString *ccer = [_iCCText makeStringWithoutTagString];
    ccer = [[NSString alloc] initWithString:[ccer stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (![LogicHelper isBlankOrNil:ccer]) {
        EmailAddress *addr = [EmailAddress create];
        addr.address = ccer;
        addr.displayName = ccer;
        NSString *name = [SqlAddressData queryMemberInfoWithEmail:ccer].name;
        if (name) {
            addr.displayName = name;
        }
        [cc addObject:addr];
    }
    email.cc = [NSSet setWithArray:cc];
    
    NSString *subject = _iTitleText.text;
    subject = [[NSString alloc] initWithString:[subject stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if ([LogicHelper isBlankOrNil:subject]) {
        subject = NSLocalizedString(@"MailDetail.nosubject", nil);
    }
    email.subject = subject;
    NSMutableString *body;
    NSMutableString *html;
    if (type == EmailArchiveTypeDraft) {
        if (_type == EmailSendTypeNew) {
            body = [NSMutableString stringWithString:_iContentText.text];
        } else {
            body = [NSMutableString stringWithString:@""];
        }
        html = [NSMutableString stringWithString:@""];
    } else {
        html = [NSMutableString stringWithString:_iContentText.text];
        while ([html rangeOfString:@"\n"].length > 0) {
            [html replaceCharactersInRange:[html rangeOfString:@"\n"] withString:@"<br>"];
        }
        //搜索不到一直搜索
        //        [html replaceCharactersInRange:[html rangeOfString:DefaultContent] withString:[NSString stringWithFormat:@"<br><br>%@",DefaultContent]];
        //搜索不到直接结束
        [html stringByReplacingOccurrencesOfString:DefaultContent withString:[NSString stringWithFormat:@"<br><br>%@",DefaultContent]];
    }
    
    if (_type == EmailSendTypeReply || _type == EmailSendTypeReplyAll || _type == EmailSendTypeTransmit) {
        [body appendFormat:@"\n%@",_email.plainText];
        [html appendFormat:@"\n%@",_email.htmlText];
        email.sendType = @(_type);
    }
    EmailAddress *addr = [EmailAddress create];
    addr.displayName = @"我";
    addr.address = _account.username;
    email.sender = addr;
    
    
    if (type == EmailArchiveTypeDraft) {
        email.plainText = _iContentText.text;
    } else {
        email.plainText = body;
    }
    email.htmlText = html;
    
    
    email.isRead = @(true);
    email.attachments = [NSSet new];
    email.date = [NSDate date];
    email.hasDeleted = @(NO);
    email.archiveType = @(type);
    email.isFlag = @(NO);
#warning 附件
    NSMutableArray *arr = [NSMutableArray new];
    for (NSObject *obj in _files) {
        Attachment *att = [Attachment create];
        if ([obj isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)obj;
            att.filename = asset.defaultRepresentation.filename;
            DDLogCInfo(@"1000000000：%@",att.filename);
            //att.data = [self assetData:asset];
            NSString *filePath = [LogicHelper sandboxFilePath:asset.defaultRepresentation.filename];
            [[self assetData:asset] writeToFile:filePath atomically:YES];
            att.filepath = filePath;
            [arr addObject:att];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            NSString *name = [[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] stringByAppendingString:@".jpg"];
            att.filename = name;
            NSString *filePath = [LogicHelper sandboxFilePath:name];
            [UIImageJPEGRepresentation((UIImage *)obj, 0.5) writeToFile:filePath atomically:YES];
            att.filepath = filePath;
            [arr addObject:att];
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *path = (NSString *)obj;
            att.filename = [path lastPathComponent];
            att.filepath = path;
            [arr addObject:att];
        } else {
            Attachment *attObj = (Attachment *)obj;
            att.filename = attObj.filename;
            att.filepath = attObj.filepath;
            [arr addObject:att];
        }
        att.email = email;
    }
    email.attachments = [NSSet setWithArray:arr];
    if (_type!=EmailSendTypeNew) {
        email.htmlText = [self getTransmitContent:email];
    }
    [[CoreDataManager sharedInstance] save];
}

- (void)saveDraft
{
   
    NSMutableArray *to = [NSMutableArray new];
    for (MintAnnotation *a in _iRecvText.annotationList) {
        NSString *email = a.usr_id;
        EmailAddress *addr = [EmailAddress create];
        addr.address = email;
        addr.displayName = a.usr_name;
        [to addObject:addr];
    }
    NSString *reciver = [_iRecvText makeStringWithoutTagString];
    reciver = [[NSString alloc] initWithString:[reciver stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (![LogicHelper isBlankOrNil:reciver]) {
        EmailAddress *addr = [EmailAddress create];
        addr.address = reciver;
        addr.displayName = reciver;
        NSString *name = [SqlAddressData queryMemberInfoWithEmail:reciver].name;
        if (name) {
            addr.displayName = name;
        }
        [to addObject:addr];
    }
    _email.receivers = [NSSet setWithArray:to];
    
    NSMutableArray *cc = [NSMutableArray new];
    for (MintAnnotation *a in _iCCText.annotationList) {
        NSString *email = a.usr_id;
        EmailAddress *addr = [EmailAddress create];
        addr.address = email;
        addr.displayName = a.usr_name;
        [cc addObject:addr];
    }
    NSString *ccer = [_iCCText makeStringWithoutTagString];
    ccer = [[NSString alloc] initWithString:[ccer stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if (![LogicHelper isBlankOrNil:ccer]) {
        EmailAddress *addr = [EmailAddress create];
        addr.address = ccer;
        addr.displayName = ccer;
        NSString *name = [SqlAddressData queryMemberInfoWithEmail:ccer].name;
        if (name) {
            addr.displayName = name;
        }
        [cc addObject:addr];
    }
    _email.cc = [NSSet setWithArray:cc];
    
    NSString *subject = _iTitleText.text;
    subject = [[NSString alloc] initWithString:[subject stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if ([LogicHelper isBlankOrNil:subject]) {
        subject = NSLocalizedString(@"MailDetail.nosubject", nil);
    }
    _email.subject = subject;
    
    NSMutableString *body = [NSMutableString stringWithString:@""];
    NSMutableString *html = [NSMutableString stringWithString:@""];
    
    
    [body appendFormat:@"\n%@",_email.plainText];
    [html appendFormat:@"%@",_email.htmlText];
    
    EmailAddress *addr = [EmailAddress create];
    addr.displayName = @"我";
    addr.address = _account.username;
    _email.sender = addr;
    _email.htmlText = html;
    _email.plainText = _iContentText.text;
    
    _email.isRead = @(true);
    _email.attachments = [NSSet new];
    _email.date = [NSDate date];
    _email.hasDeleted = @(NO);
    _email.archiveType = @(EmailArchiveTypeDraft);
    _email.isFlag = @(NO);
#warning 附件
    NSMutableArray *arr = [NSMutableArray new];
    for (NSObject *obj in _files) {
        Attachment *att = [Attachment create];
        if ([obj isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)obj;
            att.filename = asset.defaultRepresentation.filename;
            //att.data = [self assetData:asset];
            NSString *filePath = [LogicHelper sandboxFilePath:asset.defaultRepresentation.filename];
            [[self assetData:asset] writeToFile:filePath atomically:YES];
            att.filepath = filePath;
            [arr addObject:att];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            NSString *name = [[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]] stringByAppendingString:@".jpg"];
            att.filename = name;
            
            NSString *filePath = [LogicHelper sandboxFilePath:name];
            [UIImageJPEGRepresentation((UIImage *)obj, 0.5) writeToFile:filePath atomically:YES];
            att.filepath = filePath;
            [arr addObject:att];
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *path = (NSString *)obj;
            att.filename = [path lastPathComponent];
            att.filepath = path;
            [arr addObject:att];
        } else {
            Attachment *attObj = (Attachment *)obj;
            att.filename = attObj.filename;
            att.filepath = attObj.filepath;
            [arr addObject:att];
        }
        att.email = _email;
    }
    _email.attachments = [NSSet setWithArray:arr];
    [[CoreDataManager sharedInstance] save];
}

- (NSData *)assetData:(ALAsset *)asset
{
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    long long size = representation.size;
    NSUInteger usize = (unsigned int)size;
    NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:usize];
    void *buffer = [rawData mutableBytes];
    [representation getBytes:buffer fromOffset:0 length:usize error:nil];
    NSData *assetData = [[NSData alloc] initWithBytes:buffer length:usize];
    return assetData;
}

// 添加收件人和抄送
- (void)chooseContact:(AddScrollType)type
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    nav_add.addScrollType=type;
    nav_add.delegate_addID = self;
//    MainNavigationCT *mainct = (MainNavigationCT *)self.navigationController;
//    MainViewController *maivc = (MainViewController *)mainct.mainVC;
    [self presentViewController:nav_add animated:YES completion:^{
        
    }];
}

- (void)contactSelected:(AddScrollType)type member:(NSArray *)memberArray
{
    MintAnnotationChatView *t;
    if (type == AddScrollTypeRecv) {
        t = _iRecvText;
    }
    if (type == AddScrollTypeCC) {
        t = _iCCText;
    }
    for (EmployeeModel *e in memberArray) {
        if (![LogicHelper isBlankOrNil:e.email]) {
            MintAnnotation *annotation = [MintAnnotation new];
            annotation.usr_id = e.email;
            annotation.usr_name = e.name;
            DDLogInfo(@"selected name %@",e.name);
            /*NSMutableArray *anns = [NSMutableArray arrayWithArray:t.annotationList];
            [anns addObject:annotation];
            [t clearAll];
            for (MintAnnotation *a in anns) {
                [t addAnnotation:a];
            }*/
            [t addAnnotation:annotation];
        }
    }
    [self resetFrame];
}

- (UIView *)createLine:(CGFloat)space
{
    UIView *line = [UIView new];
    CGFloat lineW = ABDEVICE_SCREEN_WIDTH-space*2;
    CGFloat lineH = 0.5;
    CGRect lineFrame = CGRectMake(space, kViewHeight -1 , lineW, lineH);
    line.frame = lineFrame;
    line.backgroundColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:0.2];
    return line;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AttachmentsController *ctl = segue.destinationViewController;
    ctl.delegate = self;
}

- (void)didFileSelected:(NSString *)filePath
{
    [self addAttachmentsView:@[filePath]];
}

- (void)resetFrame
{
    CGFloat startY = 0;
    // recv
    //CGFloat width = _iRecvText.frame.size.width;
    NSString *text = [_iRecvText makeString];
    UITextRange *textRange = [_iRecvText textRangeFromPosition:_iRecvText.beginningOfDocument toPosition:_iRecvText.endOfDocument];
    startY=text.length?[_iRecvText firstRectForRange:textRange].size.height+30:kViewHeight;
    
    //startY =[LogicHelper hightWith:text width:width attributesDict:_iRecvText.defaultAttributedString];
   
    CGRect recvframe = _iReceiverView.frame;
    recvframe.size.height = startY;
    
    _iReceiverView.frame = recvframe;
    CGRect recvTextFrame = _iRecvText.frame;
    recvTextFrame.size.height = startY;
    /*
    if (startY == kViewHeight) {
        recvTextFrame.origin.y = (kViewHeight - 30) / 2;
        recvTextFrame.size.height = 30;
    } else {
        recvTextFrame.origin.y = -8;
        recvTextFrame.size.height = startY+20;
    }*/
    _iRecvText.frame = recvTextFrame;

    CGRect recvLineFrame = _recvLine.frame;
    recvLineFrame.origin.y = startY - 1;
    _recvLine.frame = recvLineFrame;

    
    text = [_iCCText makeString];
    textRange =[_iCCText textRangeFromPosition:_iCCText.beginningOfDocument toPosition:_iCCText.endOfDocument];
    //CGFloat ccHeight = [LogicHelper hightWith:text width:width attributesDict:_iCCText.defaultAttributedString];
    CGFloat ccHeight=text.length?[_iCCText firstRectForRange:textRange].size.height+30:kViewHeight;
    CGRect ccframe = _iCCView.frame;
    ccframe.origin.y = startY;
    ccframe.size.height = ccHeight;
    _iCCView.frame = ccframe;
    CGRect ccTextFrame = _iCCText.frame;
    ccTextFrame.size.height = ccHeight;
    /*
    if (ccHeight == kViewHeight) {
        ccTextFrame.origin.y = (kViewHeight - 30) / 2;
        ccTextFrame.size.height = 30;
    } else {
        ccTextFrame.origin.y = -8;
        ccTextFrame.size.height = ccHeight +20 ;
    }*/
    _iCCText.frame = ccTextFrame;
    startY += ccHeight;
    
    CGRect ccLineFrame = _ccLine.frame;
    ccLineFrame.origin.y = ccHeight - 1;
    _ccLine.frame = ccLineFrame;
    
    // title
    CGRect titleframe = _iTitleView.frame;
    titleframe.origin.y = startY;
    _iTitleView.frame = titleframe;

    startY += kViewHeight;
    
    CGRect contentFrame = _iContentText.frame;
    contentFrame.origin.y = startY;contentFrame.size.height=_iContentText.contentSize.height;
    _iContentText.frame = contentFrame;
    //_iContentText.backgroundColor=[UIColor redColor];
    startY += _iContentText.contentSize.height;
    
    CGRect webFrame = _iContentWeb.frame;
    webFrame.origin.y = startY;
    _iContentWeb.frame = webFrame;
   
    startY += _webHeight > 0 ? _iContentWeb.frame.size.height : 0;
    
//    startY -= 170;
    CGRect attFrame = _attView.frame;
    
    attFrame.origin.y = startY;
    
    _attView.frame = attFrame;
    
    startY += _attView.frame.size.height;
    
    if (startY < ABDEVICE_SCREEN_HEIGHT)
    {
//        startY = ABDEVICE_SCREEN_HEIGHT + 200;
        startY = ABDEVICE_SCREEN_HEIGHT + startY;
    }
    _iContentScroll.contentSize = CGSizeMake(ABDEVICE_SCREEN_WIDTH, startY+150);
    //_iContentScroll.contentSize = CGSizeMake(ABDEVICE_SCREEN_WIDTH,  kViewHeight * 3 + _iContentText.frame.size.height + _iContentWeb.frame.size.height+_attView.frame.size.height);
}




//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    
    _topView.hidden = NO;
//    _attView.frame = CGRectMake(0, _hg, 320, [UIScreen mainScreen].bounds.size.height);
    //_attView.frame = CGRectMake(0, _hg+300, 320, [UIScreen mainScreen].bounds.size.height);
    
    CGRect rect=_iContentText.frame;
    rect.size.height=90;
    DDLogInfo(@"键盘键盘出现了！！！！");
    _iContentText.frame =rect;
    //上移scroll不显示空白
    //邮件正文
    if ([_iContentText isFirstResponder])
    {
        [_iContentScroll setContentOffset:CGPointMake(0, _iContentText.frame.origin.y-130) animated:NO];
    }else if ([_iRecvText isFirstResponder])//收件人
    {
       
        [_iContentScroll setContentOffset:CGPointMake(0, _iRecvText.frame.origin.y) animated:NO];
        
    }else if ([_iCCText isFirstResponder])//抄送人
    {
     
        [_iContentScroll setContentOffset:CGPointMake(0, _iCCText.frame.origin.y) animated:NO];
    }
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    DDLogInfo(@"键盘键盘消失了！！！！");
    CGRect rect=_iContentText.frame;
    rect.size.height=_iContentText.contentSize.height;
    _iContentText.frame =rect;
    [self resetFrame];
    _topView.hidden = YES;
    //CGFloat q = _iTitleView.frame.origin.y;
    //_iContentText.frame = CGRectMake(0, q+kViewHeight, 320, [UIScreen mainScreen].bounds.size.height);
    //_hg = (q+kViewHeight+_iContentText.frame.size.height);

    //_attView.frame = CGRectMake(0, _hg+_iContentWeb.frame.size.height, 320, [UIScreen mainScreen].bounds.size.height);
}

- (void)callIncoming:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end