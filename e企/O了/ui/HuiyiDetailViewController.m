//
//  HuiyiDetailViewController.m
//  e企
//
//  Created by a on 15/5/6.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "HuiyiDetailViewController.h"
#import "HuiyiData.h"
#import "HuiyiTableViewCell.h"
#import "SqlAddressData.h"
#import "LogicHelper.h"
#import "e企-Swift.h"

#define HIGHT 5  //每个label间隔为5
 
@interface HuiyiDetailViewController ()
//@property(nonatomic,strong) NSMutableArray *weiquerenArray;
@property (nonatomic, strong)UIImageView *imagev;
@property (nonatomic, strong)UILabel *label;
@end

@implementation HuiyiDetailViewController
static CGFloat labelHight=30;//未确定或确定人数label标题高度
static CGFloat imageStarX=30;//头像图片距离父视图左边距离
static CGFloat imageStarY=5;//头像图片距离父视图上边距离
static CGFloat imageWidth=50;//头像图片宽度高度
static CGFloat imageGapY=20;//每个头像图片宽度垂直间隔
static CGFloat imageGapX=20;//每个头像图片宽度水平间隔
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"未确认%@",self.huiyidata.noconfirm_members);
    _titlelabel.text=[NSString stringWithFormat:@"会议主题：%@",_huiyidata.conf_name];
    [self restLabeframe:_titlelabel aboveLabel:nil];
    NSString *time=[HuiyiTableViewCell getTimeStringFromTimeNumberstring:_huiyidata.conf_time];
    _timelabel.text=[NSString stringWithFormat:@"会议时间：%@",time];
    [self restLabeframe:_timelabel aboveLabel:_titlelabel];
    _didianlabel.text=[NSString stringWithFormat:@"会议地点：%@",_huiyidata.address];
    [self restLabeframe:_didianlabel aboveLabel:_timelabel];
    _contentlabel.text=[NSString stringWithFormat:@"会议内容：%@",_huiyidata.content];
    [self restLabeframe:_contentlabel aboveLabel:_didianlabel];
     EmployeeModel *e=  [SqlAddressData  queryMemberInfoWithPhone:_huiyidata.creator_uid];//根据手机号uid获取联系人；
    NSString *faqitime=[HuiyiTableViewCell getTimeStringFromTimeNumberstring:_huiyidata.create_time];
    _faqiLabel.text=[NSString stringWithFormat:@"发起:%@  %@",e.name,faqitime];
    CGRect rect= _faqiView.frame;
    rect.origin.y=[Myimageview getbotton:_contentlabel]+HIGHT;
    _faqiView.frame=rect;
    UIView *weiqueding=[[UIView alloc]initWithFrame:CGRectMake(0, [Myimageview getbotton:_faqiView]+HIGHT, [UIScreen mainScreen].bounds.size.width,0)];//未确定视图
    //weiqueding.backgroundColor=[UIColor whiteColor];
    weiqueding.hidden=!_huiyidata.noconfirm_members.count;
    UILabel *weiquedinglaibel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, weiqueding.frame.size.width, labelHight)];//weiquedinglaibel.backgroundColor=[UIColor lightGrayColor];
    weiquedinglaibel.text=[NSString stringWithFormat:@"未确定(%d人)",_huiyidata.noconfirm_members.count];
    [weiqueding addSubview:weiquedinglaibel];
    [_scrollview addSubview:weiqueding];
    for (int i = 0; i<_huiyidata.noconfirm_members.count; i++) {
        NSString *uidstr = _huiyidata.noconfirm_members[i];
        EmployeeModel *model=  [SqlAddressData  queryMemberInfoWithPhone:uidstr];
        Myimageview *imagview=[[Myimageview alloc]initWithFrame:CGRectMake(imageStarX+i%4*(imageWidth+imageGapX), i/4*(imageGapY+imageWidth)+weiquedinglaibel.frame.size.height+imageStarY, imageWidth, imageWidth) buttonwidth:15 buttonImageName:@"message_faild_message"];
        //imagview.delegate=self;
        //imagview.backgroundColor=[UIColor greenColor];
        [imagview.imageView setImageWithURL:[NSURL URLWithString:model.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
        imagview.label.text=model.name;
        [weiqueding addSubview:imagview];
    }
    rect=weiqueding.frame;
    rect.size.height=weiquedinglaibel.frame.size.height+imageStarY+(imageGapY+imageWidth)*(_huiyidata.noconfirm_members.count/4+(_huiyidata.noconfirm_members.count%4!=0));
    weiqueding.frame=rect;
    rect.size.height=1;
    rect.origin.y=weiqueding.frame.size.height;
    UILabel *lielabel=[[UILabel alloc]initWithFrame:rect];
    lielabel.backgroundColor=[UIColor blackColor];
    [weiqueding addSubview:lielabel];
    
    UIView *queding=[[UIView alloc]initWithFrame:CGRectMake(0, [Myimageview getbotton:weiqueding]+HIGHT, [UIScreen mainScreen].bounds.size.width,0)];//已确定视图
    //queding.backgroundColor=[UIColor whiteColor];
    queding.hidden=!_huiyidata.confirmed_members.count;
    UILabel *quedinglaibel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0,queding.frame.size.width, labelHight)];//quedinglaibel.backgroundColor=[UIColor lightGrayColor];
    quedinglaibel.text=[NSString stringWithFormat:@"已确定(%d人)",_huiyidata.confirmed_members.count];
    [queding addSubview:quedinglaibel];
    [_scrollview addSubview:queding];
    for (int i = 0; i<_huiyidata.confirmed_members.count; i++) {
        NSString *uidstr = _huiyidata.confirmed_members[i];
        EmployeeModel *model=  [SqlAddressData  queryMemberInfoWithPhone:uidstr];
        Myimageview *imagview=[[Myimageview alloc]initWithFrame:CGRectMake(imageStarX+i%4*(imageWidth+imageGapX), i/4*(imageWidth+imageGapY)+imageStarY+quedinglaibel.frame.size.height, imageWidth, imageWidth) buttonwidth:15 buttonImageName:@"checkcontact"];
        //imagview.delegate=self;
        //imagview.backgroundColor=[UIColor greenColor];
        [imagview.imageView setImageWithURL:[NSURL URLWithString:model.avatarimgurl] placeholderImage:[UIImage imageNamed:default_headImage]];
        imagview.label.text=model.name;
        //[_weiquerenArray addObject:imagview];
        [queding addSubview:imagview];
    }
    rect=queding.frame;
    rect.size.height=quedinglaibel.frame.size.height+imageStarY+(imageGapY+imageWidth)*(_huiyidata.confirmed_members.count/4+(_huiyidata.confirmed_members.count%4!=0));
    queding.frame=rect;
    rect.size.height=1;
    rect.origin.y=queding.frame.size.height;
    UILabel *lielabel1=[[UILabel alloc]initWithFrame:rect];
    lielabel1.backgroundColor=[UIColor blackColor];
    [queding addSubview:lielabel1];

    _scrollview.contentSize=CGSizeMake([UIScreen mainScreen].bounds.size.width, [Myimageview getbotton:queding]+10);
    
    
    _imagev = [[UIImageView alloc]init];
    _imagev.frame = CGRectMake(3, 30, 25, 25);
    [_imagev setImage:[UIImage imageNamed:@"nav-bar_back.png"]];
    [self.navigationController.view addSubview:_imagev];
    
    _label = [[UILabel alloc]init];
    _label.frame = CGRectMake(25, 32, 90, 20);
    _label.text = @"会议通知";
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:18];
    [self.navigationController.view addSubview:_label];
    _imagev.hidden = NO;
    _label.hidden = NO;
    
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}




-(void)restLabeframe:(UILabel*)label aboveLabel:(UILabel *)aboveLabel
{//通过上面的label自动调整当前label。
    CGFloat h= [LogicHelper hightWith:label.text width:label.frame.size.width attributesDict:@{NSFontAttributeName : _titlelabel.font}];
    CGRect rect=label.frame;
    rect.size.height=h;
    if (aboveLabel) {
        rect.origin.y=aboveLabel.frame.origin.y+aboveLabel.frame.size.height+HIGHT;
    }
    label.frame=rect;
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    _imagev.hidden = YES;
    _label.hidden = YES;
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
