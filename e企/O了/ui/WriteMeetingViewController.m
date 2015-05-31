//
//  WriteMeetingViewController.m
//  e企
//
//  Created by a on 15/4/28.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "WriteMeetingViewController.h"
#import "HuiyiTimeInputView.h"
#import "Download.h"
#import "NavigationVC_AddID.h"
#import "MacroDefines.h"
#import "UIImageView+WebCache.h"



@interface WriteMeetingViewController ()<DownloadDelegate,navigation_addIDDelegaet,UIScrollViewDelegate,UITextViewDelegate,UITextFieldDelegate>
@property(nonatomic,strong) Download *download;
@property(nonatomic,assign) long long timeLong;
@property(nonatomic,strong) NSMutableArray *userArray;
@property (nonatomic, strong)UIImageView *imagev;
@property (nonatomic, strong)UILabel *label;
@end
#define HUI_YI_HOST [NSString stringWithFormat:@"http://%@/eas/conf/create?gid=%@&uid=%@",HTTP_IP,ORG_ID,USER_ID]

@implementation WriteMeetingViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _download=[[Download alloc]init];
    _download.delegate=self;
    _userArray=[[NSMutableArray alloc]init];
    HuiyiTimeInputView *timeview=[[HuiyiTimeInputView alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 300)];
    _timeTf1.inputView=timeview;
    timeview.queding=^(HuiyiTimeInputView *tv){_timeTf1.text=tv.timeString;
        self.timeLong=tv.timeLong;
        [_timeTf1 resignFirstResponder];
    };
    timeview.quxiao=^(HuiyiTimeInputView *tv){[_timeTf1 resignFirstResponder];};
    //[self.view addSubview:timeview];
    NSLog(@"gid=%@&uid=%@",ORG_ID,USER_ID);
    _imageHeadView=[[UIView alloc]init];
    _imageHeadView.frame=CGRectMake(0, 200.5, [UIScreen mainScreen].bounds.size.width, 80);
    _imageHeadView.backgroundColor=[UIColor whiteColor];
    _imageHeadView.hidden=YES;
    [_scrollBackGround addSubview:_imageHeadView];
    _scrollBackGround.delegate=self;
     _scrollBackGround.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width,_meetDetailCentent.bottomY);
      _imageMutableArray=[[NSMutableArray alloc]init];
    
    _contentTV.backgroundColor=[UIColor whiteColor];
    _contentTV.delegate=self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Keyboard_Appear:) name:UIKeyboardDidShowNotification  object:nil];
    _titleTf.delegate=self;
    _addressTf.delegate=self;
    
    _imagev = [[UIImageView alloc]init];
    _imagev.frame = CGRectMake(3, 30, 25, 25);
    [_imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:_imagev];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(25, 32, 90, 20);
    _label.text = @"发起通知";
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:_label];
    _imagev.hidden = NO;
    _label.hidden = NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)Keyboard_Appear:(NSNotification*)noti{
    CGFloat keyboardHeight = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if(_contentTV.isFirstResponder){
        _scrollBackGround.contentSize=CGSizeMake(SCREEN_WIDTH,_meetDetailCentent.bottomY+keyboardHeight);
         _scrollBackGround.contentOffset=CGPointMake(0, keyboardHeight);
        //[_scrollBackGround setContentOffset:CGPointMake(0, keyboardHeight) animated:YES];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _scrollBackGround.contentSize=CGSizeMake(SCREEN_WIDTH, _meetDetailCentent.bottomY);
   
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView==_scrollBackGround) {
        [_contentTV resignFirstResponder];
        [_titleTf resignFirstResponder];
        [_timeTf1 resignFirstResponder];
        [_addressTf resignFirstResponder];
    }
}

- (IBAction)发送:(UIBarButtonItem *)sender {
    NSLog(@"发送会议");
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"发送失败" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    if([_titleTf.text isEqualToString:@""]){
        alert.message=@"必须写标题";
        [alert show];
        return;
    }else if (!(_wangLuo.selected||_duanXin.selected)){
        alert.message=@"至少选择网络或者短信";
        [alert show];
        return;
    }
    [_download downloadPostRequestWithURLString:HUI_YI_HOST andHTTPBodyDictionaryString:[self getPostString]];
}
-(void)downloadDidFinishLoading:(Download *)download
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    if ([download.downloadDictionary[@"status"] integerValue]) {
        NSLog(@"发送成功：%@",download.downloadDictionary);
        alert.message=@"发送成功";
        [self.navigationController popViewControllerAnimated:YES];
        [alert show];
    }else{
        alert.title=@"发送失败";
        alert.message=download.downloadDictionary[@"msg"];
        [alert show];
    }
}

-(NSString*)getPostString{
    int notify_type=-1;
    if (_wangLuo.selected) {
        notify_type=_duanXin.selected?2:0;
    }else{
        notify_type=_duanXin.selected?1:-1;
    }
    if (_userArray.count) {
        NSMutableString *mutableString=[NSMutableString stringWithString:[_userArray.firstObject phone]];
        for (int i=1; i<_userArray.count; i++) {
            EmployeeModel *e=_userArray[i];
            [mutableString appendFormat:@",%@",e.phone];
        }
        NSString *uidString= [NSString stringWithFormat:@"members=%@",mutableString];
        return [NSString stringWithFormat:@"conf_name=%@&content=%@&conf_time=%lld&notify_type=%d&%@&address=%@",_titleTf.text,_contentTV.text,_timeLong,notify_type,uidString,_addressTf.text];
    }
    return  [NSString stringWithFormat:@"conf_name=%@&content=%@&conf_time=%lld&notify_type=%d&address=%@",_titleTf.text,_contentTV.text,_timeLong,notify_type,_addressTf.text];
    
}
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    _imagev.hidden = YES;
    _label.hidden = YES;
}
-(void)contactSelected:(AddScrollType)type member:(NSArray *)memberArray
{
    NSLog(@"选择成员%@",memberArray);
    for (Myimageview * remove in _imageMutableArray) {
        [remove removeFromSuperview];
    }
    [_imageMutableArray removeAllObjects];
    [_userArray removeAllObjects];
    _membersLabel.text=[NSString stringWithFormat:@"已经选择%d人",memberArray.count];
    for (int i = 0; i<memberArray.count; i++) {
        EmployeeModel * e = memberArray[i];
        [_userArray addObject:e];
        Myimageview *imagview=[[Myimageview alloc]initWithFrame:CGRectMake(30+i%4*70, i/4*70+8, 50, 50) buttonwidth:15 buttonImageName:@"shanchu"];
        imagview.delegate=self;
        //imagview.imageView.backgroundColor=[UIColor greenColor];
        [imagview.imageView setImageWithURL:[NSURL URLWithString:e.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
        imagview.label.text=e.name;
        [_imageMutableArray addObject:imagview];
        [_imageHeadView addSubview:imagview];
        imagview.tag=i;
    }
    CGRect rect=_imageHeadView.frame;
    rect.size.height=8+70*(memberArray.count/4+(memberArray.count%4!=0));
    _imageHeadView.frame=rect;
}
- (IBAction)toumingbutton:(id)sender {
    NSLog(@"点击下移出现下移");
    if (_imageHeadView.hidden&&_userArray.count) {
        _imageHeadView.hidden=NO;
        _meetDetailCentent.frame=CGRectMake(0, 201+_imageHeadView.frame.size.height, [UIScreen mainScreen].bounds.size.width, 300);
    }else{
        _imageHeadView.hidden=YES;
        _meetDetailCentent.frame=CGRectMake(0, 201, [UIScreen mainScreen].bounds.size.width, 300);
    }
    _scrollBackGround.contentSize=CGSizeMake(SCREEN_WIDTH,_meetDetailCentent.bottomY);
}

-(void)MyimageviewBottonClink:(Myimageview*)imageview{
    NSLog(@"点击删除头像图片");
    [imageview removeFromSuperview];
    [UIView animateWithDuration:0.8 animations:^{
        for (int i=_imageMutableArray.count-1; i>imageview.tag; i--) {
            Myimageview *imageview=_imageMutableArray[i];
            imageview.frame=[_imageMutableArray[i-1] frame];
            imageview.tag=i-1;
        }
    } completion:^(BOOL finished) {
        CGRect rect=_imageHeadView.frame;
        rect.size.height=8+70*(_imageMutableArray.count/4+(_imageMutableArray.count%4!=0));
        _imageHeadView.frame=rect;
    }];
    [_imageMutableArray removeObjectAtIndex:imageview.tag];
    [_userArray removeObjectAtIndex:imageview.tag];
    _membersLabel.text=[NSString stringWithFormat:@"已经选择%d人",_userArray.count];
}

- (IBAction)wangluo:(UIButton *)sender {
    sender.selected=!sender.selected;
}
- (IBAction)duanxin:(UIButton *)sender {
    sender.selected=!sender.selected;
}
- (IBAction)addMembers:(UIButton *)sender {
    NSLog(@"增加会议成员");
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    nav_add.addScrollType=AddScrollTypeNomal;
    nav_add.delegate_addID = self;
    [self presentViewController:nav_add animated:YES completion:^{
        
    }];
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
