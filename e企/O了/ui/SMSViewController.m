//
//  SMSViewController.m
//  e企
//
//  Created by THJ on 15/4/30.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "SMSViewController.h"
#import "MainViewController.h"
#import "WriteMeetingViewController.h"
#import "HuiyiTimeInputView.h"
#import "Download.h"
#import "NavigationVC_AddID.h"
#import "UIImageView+WebCache.h"
#import "MacroDefines.h"
@interface SMSViewController ()<UITextViewDelegate,DownloadDelegate,navigation_addIDDelegaet,UIGestureRecognizerDelegate>
@property (nonatomic, strong)UIView *Navigation;
@property (nonatomic, strong)UIView *UnderlyingView;
@property (nonatomic, strong)UIView *Select_columns;
@property (nonatomic, strong)UILabel *Select_personnel;
@property (nonatomic, strong)UILabel *Participate_personnel;
@property (nonatomic, strong)UIButton *AddButton;
@property (nonatomic, strong)UIView *Select_Add;
@property (nonatomic, strong)UIView *Line;
@property (nonatomic, strong)UIView *InputView;
@property (nonatomic, strong)UITextView *TextView;
@property (nonatomic, strong)UIButton *InputAddButton;
@property (nonatomic, strong)UIButton *SendButton;
@property (nonatomic, assign)CGFloat InputViewY;
@property (nonatomic, strong) NSMutableArray *uidArray;
@property (nonatomic, strong)UIImageView *Portrait;
@property (nonatomic, assign)float TABoffsetx;
@property (nonatomic, assign)float TABoffsety;
@property (nonatomic, strong)NSMutableArray *MyMutableArray;
@property (nonatomic, strong)NSArray *ary;
@property (nonatomic, strong)UILabel *Name_Label;
@property (nonatomic, strong)UIButton * imagebtn;
@property (nonatomic, strong)UIButton *back;
@property (nonatomic, strong)UIImageView *imagev;
@property (nonatomic, strong)UILabel *label;
@end

@implementation SMSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self Showui];
    self.view.backgroundColor = [UIColor colorWithRed:49.0/255.0 green:95.0/255.0 blue:155.0/255.0 alpha:1.0];
    _MyMutableArray = [[NSMutableArray alloc]init];
    _uidArray =[[NSMutableArray alloc]init];
}

-(void)Showui{
    //导航栏
    _Navigation = [[UIView alloc]init];
    _Navigation.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    _Navigation.backgroundColor = [UIColor colorWithRed:70.0/255.0 green:136.0/255.0 blue:241.0/255.0 alpha:1.0];
    [self.view addSubview:_Navigation];
    //标题
    UILabel*tite = [[UILabel alloc]init];
    tite.frame = CGRectMake(125, 28, 180, 30);
    tite.textColor = [UIColor whiteColor];
    //tite.text = @"短信群发";
    [tite setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [self.Navigation addSubview:tite];
    
    //返回按钮
    UIButton*back = [[UIButton alloc]init];
    back.frame = CGRectMake(0, 19, 80, 45);
    //[back setBackgroundImage:[UIImage imageNamed:@"nav-bar_back.png"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back_Methods) forControlEvents:UIControlEventTouchUpInside];
    [self.Navigation addSubview:back];
    //返回按钮图片
    _imagev = [[UIImageView alloc]init];
    _imagev.frame = CGRectMake(3, 30, 25, 25);
    [_imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.Navigation addSubview:_imagev];
    //返回按钮文字
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(25, 32, 90, 20);
    _label.text = @"短信群发";
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:18];
    [self.Navigation addSubview:_label];
    
    
    //取消按钮
    UIButton*cancel = [[UIButton alloc]init];
    cancel.frame = CGRectMake(230, 28, 100, 30);
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel_Methods) forControlEvents:UIControlEventTouchUpInside];
    //[self.Navigation addSubview:cancel];
    //底层
    _UnderlyingView = [[UIView alloc]init];
    _UnderlyingView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _UnderlyingView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0];
    [self.view addSubview:_UnderlyingView];
    //选择栏
    _Select_columns = [[UIView alloc]init];
    _Select_columns.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42);
    _Select_columns.backgroundColor = [UIColor whiteColor];
    [_UnderlyingView addSubview:_Select_columns];
    
    _Select_personnel = [[UILabel alloc]init];
    _Select_personnel.text = @"选择人员 ：";
    _Select_personnel.font = [UIFont systemFontOfSize:16];
    _Select_personnel.textColor = [UIColor colorWithRed:152.0/255.0 green:152.0/255.0 blue:152.0/255.0 alpha:1.0];
    _Select_personnel.frame = CGRectMake(15, 13, 100, 16);
    [_Select_columns addSubview:_Select_personnel];
    //选择几个人
    _Participate_personnel = [[UILabel alloc]init];
    _Participate_personnel.font = [UIFont systemFontOfSize:16];
    _Participate_personnel.textColor = [UIColor blackColor];
    _Participate_personnel.frame = CGRectMake(100, 13, 100, 16);
    [_Select_columns addSubview:_Participate_personnel];
    
    //添加接受消息人按钮
    _AddButton = [[UIButton alloc]init];
    _AddButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-32, 10, 22, 22);
    [_AddButton setBackgroundImage:[UIImage imageNamed:@"GroupChat_Set_Icon_Add.png"] forState:UIControlStateNormal];
    [_AddButton addTarget:self action:@selector(Add_Methods:) forControlEvents:UIControlEventTouchUpInside];
    [_Select_columns addSubview:_AddButton];
    //分割线
    _Line = [[UIView alloc]init];
    _Line.frame = CGRectMake(0, _Select_columns.frame.size.height+1.5, [UIScreen mainScreen].bounds.size.width, 0.5);
    _Line.backgroundColor = [UIColor colorWithRed:220.0/225.0 green:220.0/225.0 blue:220.0/225.0 alpha:1.0];
    [_UnderlyingView addSubview:_Line];
    //显示头像view
    _Select_Add = [[UIView alloc]init];
//    _Select_Add.frame = CGRectMake(0, _Select_columns.frame.size.height+2, [UIScreen mainScreen].bounds.size.width, 132);
    _Select_Add.backgroundColor = [UIColor whiteColor];
    [_UnderlyingView addSubview:_Select_Add];
    _Select_Add.hidden = YES;

    
    
    
    //分割线
    _Line = [[UIView alloc]init];
    _Line.frame = CGRectMake(0, _Select_Add.frame.size.height+_Select_Add.frame.origin.y+1, [UIScreen mainScreen].bounds.size.width, 0.5);
    _Line.backgroundColor = [UIColor colorWithRed:200.0/225.0 green:200.0/225.0 blue:200.0/225.0 alpha:1.0];
    [_UnderlyingView addSubview:_Line];
    //发送栏
    _InputView = [[UIView alloc]init];
    _InputView.frame = CGRectMake(0, _UnderlyingView.frame.size.height-100, [UIScreen mainScreen].bounds.size.width, 50);
    _InputView.backgroundColor = [UIColor whiteColor];
    [_UnderlyingView addSubview:_InputView];
    //输入框
    _TextView = [[UITextView alloc]init];
    _TextView.frame = CGRectMake(45, 3, [UIScreen mainScreen].bounds.size.width-100, 30);
    [_TextView setBackgroundColor:[UIColor clearColor]];
    [[UITextView appearance] setTintColor:[UIColor blackColor]];
    [_TextView setDelegate:self];
    [_TextView setFont:[UIFont systemFontOfSize:15.0f]];
    [_InputView addSubview:_TextView];
    [self registerKeyBoardNotification];
    //更多按钮
//    _InputAddButton = [[UIButton alloc]init];
//    _InputAddButton.frame = CGRectMake(0, -5, 45, 45);
//    [_InputAddButton setBackgroundImage:[UIImage imageNamed:@"chat_add.png"] forState:UIControlStateNormal];
//    [_InputAddButton addTarget:self action:@selector(More_Methods:) forControlEvents:UIControlEventTouchUpInside];
    //[_InputView addSubview:_InputAddButton];
    
    _imagebtn = [[UIButton alloc]init];
    _imagebtn.frame = CGRectMake(8, 2, 30, 30);
    UIImage *bgImg1 = [UIImage imageNamed:@"Message"];
    UIImage *bgImg2 = [UIImage imageNamed:@"SMS"];
    [_imagebtn setImage:bgImg2 forState:UIControlStateNormal];
    [_imagebtn setImage:bgImg1 forState:UIControlStateSelected];
    [_imagebtn addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_InputView addSubview:_imagebtn];
    
    //发送按钮
    _SendButton = [[UIButton alloc]init];
    _SendButton.frame = CGRectMake(_InputView.frame.size.width-45, 2, 40, 30);
    [_SendButton.layer setCornerRadius:5.0];
    [_SendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_SendButton setBackgroundColor:[UIColor colorWithRed:135.0/255.0 green:192.0/255.0 blue:73.0/255.0 alpha:1.0]];
    [_SendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_SendButton addTarget:self action:@selector(Send_Methods:) forControlEvents:UIControlEventTouchUpInside];
    [_InputView addSubview:_SendButton];
}



-(void)back_Methods{
    //短信群发返回去除动画效果
    [self dismissViewControllerAnimated:NO completion:nil];
}

//选择人物
-(void)Add_Methods:(UIButton*)button{
    DDLogCInfo(@"选择人物");
    _Participate_personnel.text = @"";
    _Select_Add.hidden = NO;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"NavigationVC_AddID" bundle:nil];
    NavigationVC_AddID *nav_add = story.instantiateInitialViewController;
    nav_add.addScrollType=AddScrollTypeNomal;
    nav_add.delegate_addID = self;
    [self presentViewController:nav_add animated:YES completion:^{
        
    }];
    //第二次点击时清空之前头像
    for (int i = 0; i<_MyMutableArray.count; i++) {
        UIButton*delete = _MyMutableArray[i];
        [delete removeFromSuperview];
        
    }
    [_MyMutableArray removeAllObjects];
}

-(void)contactSelected:(AddScrollType)type member:(NSArray *)memberArray
{
    _ary = memberArray;
    _Participate_personnel.text=[NSString stringWithFormat:@"已选择%d人",memberArray.count];
    [_uidArray removeAllObjects];
    for (EmployeeModel *e in memberArray) {
        //手机号
        [_uidArray addObject:e.phone];
    }
    //显示图片
    for (int i = 0; i<memberArray.count; i++) {
        //建立资料源
        EmployeeModel *p = memberArray[i];
        //删除按钮
        UIButton*delete = [[UIButton alloc]init];
        //每行4个
        delete.frame = CGRectMake(50+i%4*70,i/4*80+10,13,13);
        delete.layer.masksToBounds = YES;
        delete.layer.cornerRadius =6.5;
        //子类超出父类也可以显示
        delete.userInteractionEnabled = YES;
        //超出范围也显示
        delete.clipsToBounds = NO;
        //delete.backgroundColor = [UIColor redColor];
        //将循环i赋给删除按钮的tag，以便于删除单个操作
        delete.tag = i;
        [delete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [delete setBackgroundImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
        [_Select_Add addSubview:delete];
        //头像图片
        UIImageView *PortraitView = [[UIImageView alloc]init];
        PortraitView.frame = CGRectMake(-40, 0, 50, 50);
     //   PortraitView.frame = CGRectMake(-42, 0, 50, 50);
        PortraitView.layer.masksToBounds = YES;
        PortraitView.layer.cornerRadius =25.0;
  //      PortraitView.alpha = 0.95;
        //通过url获取头像
        [PortraitView setImageWithURL:[NSURL URLWithString:p.avatarimgurl]placeholderImage:[UIImage imageNamed:@"public_default_avatar_80"]];
        //将删除按钮作为图像的父视图
        [delete addSubview:PortraitView];
        
        UIImageView *imgev = [[UIImageView alloc]init];
        imgev.frame = CGRectMake(40, -2, 15, 15);
        imgev.backgroundColor = [UIColor redColor];
        imgev.layer.masksToBounds = YES;
        imgev.layer.cornerRadius =6.5;
        [PortraitView addSubview:imgev];
        
        //名字
        _Name_Label = [[UILabel alloc]init];
        _Name_Label.frame = CGRectMake(-30, 50, 90, 30);
        _Name_Label.text = p.name;
        [delete addSubview:_Name_Label];
        
        
        _Select_Add.frame = CGRectMake(0, _Select_columns.frame.size.height+2, [UIScreen mainScreen].bounds.size.width, 500);
        [_MyMutableArray addObject:delete];
    }
    
}

-(void)delete:(UIButton*)button{
    DDLogCInfo(@"出现吧");
    //刷新文字
    _Participate_personnel.text=[NSString stringWithFormat:@"已选择%d人",_MyMutableArray.count-1];
    //倒序
    for (int i = _MyMutableArray.count-1; i>button.tag; i--) {
        //获取被点击的button
        UIButton*btn1 = _MyMutableArray[i];
        //获取被点击button后面一个需要往前移动的button
        UIButton*btn2 = _MyMutableArray[i-1];
        //移动
        btn1.frame = btn2.frame;
        //将tag赋值
        btn1.tag = btn2.tag;
    }
    //将要删除的元素取出来
    UIButton*btn = _MyMutableArray[button.tag];
    //删除元素
    [btn removeFromSuperview];
    //更新某一个元素
    [_MyMutableArray removeObject:btn];
    [_uidArray removeObjectAtIndex:button.tag];
    
    
}

-(void)cancel_Methods{
    NSLog(@"取消取消取消");
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    _TextView.text = @"";
    _Participate_personnel.text = @"";
    _Select_Add.hidden = YES;
    
    for (int i = 0; i<_MyMutableArray.count; i++) {
        UIButton*delete = _MyMutableArray[i];
        [delete removeFromSuperview];
    }
    [_MyMutableArray removeAllObjects];
    [_uidArray removeAllObjects];
}





//更多内容
//-(void)More_Methods:(UIButton*)button{
//    DDLogCInfo(@"更多内容");
//    
//}

- (IBAction) buttonTouch:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    
    button.selected = !button.selected;
}

//发送短信
-(void)Send_Methods:(UIButton*)button{
    DDLogCInfo(@"发送短信");
    
    NSString *uidStr=[NSString stringWithFormat:@"to=%@",[_uidArray componentsJoinedByString:@","]];
    NSString *postStr=[NSString stringWithFormat:@"%@&content=%@&from=%@&type=%d&gid=%@",uidStr,_TextView.text,USER_ID,!_imagebtn.selected,ORG_ID];
    NSString *urlStr=[NSString stringWithFormat:@"http://%@/eas/sendmsg",HTTP_IP];
    Download *down=[[Download alloc]initPostRequestWithURLString:urlStr andHTTPBodyDictionaryString:postStr];
    NSLog(@"%@",postStr);
    down.delegate=self;
}


-(void)downloadDidFinishLoading:(Download *)download
{
    NSString *message=[download.downloadDictionary objectForKey:@"msg"];
    NSLog(@"%@",download.downloadDictionary);
    
    UIAlertView *aler=[[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    if ([[download.downloadDictionary objectForKey:@"status"] integerValue]) {
        NSLog(@"成功");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"失败");
        aler.title=@"发送失败";
    }
    [aler show];
}

-(void)registerKeyBoardNotification
{
    //增加监听，当键盘出现或改变时收出消息    ［核心代码］
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
//当键盘出现时调用
- (void)keyboardWillShow:(NSNotification *)aNotification
{
   // CGFloat keyboardHeight = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    _InputView.frame = CGRectMake(0, keyboardHeight-35, [UIScreen mainScreen].bounds.size.width, 50);
    if ([UIScreen mainScreen].bounds.size.width == 320&&[UIScreen mainScreen].bounds.size.height == 480){
        NSLog(@"4s&&4");
        _InputView.frame = CGRectMake(0, 90, [UIScreen mainScreen].bounds.size.width, 100);
    }else{
        _InputView.frame = CGRectMake(0, 170, [UIScreen mainScreen].bounds.size.width, 100);
    }
    
}

//当键盘退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _InputView.frame = CGRectMake(0, _UnderlyingView.frame.size.height-100, [UIScreen mainScreen].bounds.size.width, 50);
}

//自动匹配输入高度
- (void)textViewDidChange:(UITextView *)textView{
    //获取输入内容
    //DDLogCInfo(@"%@",textView.text);
    //判断行数
//    CGSize size = [textView.text sizeWithFont:[textView font]];
//    int length = size.height;
//    int colomNumber = textView.contentSize.height/length;
    
    //自动换行增加textview高度,这里的判断是如果大于73的高度就不在增加textview的高度
    if (textView.frame.size.height<73) {
        CGRect frame = textView.frame;
        CGSize size = [textView.text sizeWithFont:textView.font constrainedToSize:CGSizeMake(280, 1000)lineBreakMode:UILineBreakModeTailTruncation];
        frame.size.height = size.height > 1 ? size.height + 20 : 64;
        textView.frame = frame;
    }else{
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
