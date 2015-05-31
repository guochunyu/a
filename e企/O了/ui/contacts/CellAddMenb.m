//
//  CellAddMenb.m
//  O了
//
//  Created by macmini on 14-01-24.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "CellAddMenb.h"

#define CELL_MARGIN_LEFT 10 //左边距
#define CELL_ICON_SIZE 36 //头像大小
#define CELL_ACCESSORYVIEW_SIZE 14 //选中标记大小

@implementation CellAddMenb
@synthesize imageView = _imageView;
@synthesize label_name = _label_name;
//@synthesize addMenberBtn = _addMenberBtn;
@synthesize label_phonenumber = _label_phonenumber;
//bug4
@synthesize layer_hhh = _layer_hhh;
@synthesize layer_ttt = _layer_ttt;
@synthesize layer_mmm = _layer_mmm;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(50, 7, 36, 36)];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = _imageView.frame.size.width * 0.5;
        [_imageView setImage:[UIImage imageNamed:@"yezi_1.png"]];
        
        _label_name = [[UILabel alloc]initWithFrame:CGRectMake(95,15, 160, 20)];
        _label_name.font = [UIFont systemFontOfSize:15];
        _label_phonenumber = [[UILabel alloc]initWithFrame:CGRectMake(95, 30, 160, 15)];
        _label_phonenumber.textColor = [UIColor lightGrayColor];
        _label_phonenumber.font = [UIFont systemFontOfSize:12];
        //bug4设置显示位置
        _layer_hhh= [[UILabel alloc]initWithFrame:CGRectMake(180, 10, 125, 20)];
        _layer_hhh.font=[UIFont systemFontOfSize:16];
        _layer_hhh.backgroundColor = [UIColor clearColor];
        _layer_ttt=[[UILabel alloc]initWithFrame:CGRectMake(180, 10, 125, 20)];
        _layer_ttt.font =[UIFont systemFontOfSize:16];
        _layer_mmm = [[UILabel alloc]initWithFrame:CGRectMake(95, 10, 160, 20)];
        _layer_mmm.font = [UIFont systemFontOfSize:16];
        
//        _addMenberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_addMenberBtn setFrame:CGRectMake(10, 15, 25, 23)];
//        [_addMenberBtn setImage:[UIImage imageNamed:@"checkcontact.png"] forState:UIControlStateSelected];
//        [_addMenberBtn setImage:[UIImage imageNamed:@"nocheckcontact.png"] forState:UIControlStateNormal];
//        [_addMenberBtn addTarget:self action:@selector(addMenberBtnAction) forControlEvents:UIControlEventTouchUpInside];
//       
        [self addSubview:_imageView];
        [self addSubview:_label_name];
        [self addSubview:_label_phonenumber];
        //bug4加载label
        [self addSubview:_layer_hhh];
        [self addSubview:_layer_ttt];
        [self addSubview:_layer_mmm];
        //线
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(95, 49.5, 320, 0.5)];
        self.lineView.opaque             = YES;
        self.lineView.backgroundColor    = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        [self addSubview:self.lineView];
        
        self.accessoryView=[[UIImageView alloc]init];
        //分割线
    }
    return self;
}

//-(void)addMenberBtnAction{
//    self.addMenberBtn.selected = !self.addMenberBtn.selected;
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGPoint center=CGPointZero;
    //设置accessoryView的center
    self.accessoryView.bounds=CGRectMake(0, 0, CELL_ACCESSORYVIEW_SIZE, CELL_ACCESSORYVIEW_SIZE);
    center.x=CELL_MARGIN_LEFT+CELL_ACCESSORYVIEW_SIZE/2;
    center.y=self.frame.size.height/2;
    self.accessoryView.center=center;
    //设置imageView的center
    self.imageView.bounds=CGRectMake(0, 0, CELL_ICON_SIZE, CELL_ICON_SIZE);
    center.x+=CELL_ACCESSORYVIEW_SIZE/2+15+CELL_ICON_SIZE/2;
    self.imageView.center=center;
    //设置textLabel的center
    CGFloat detailX=center.x;
    center.x=center.x+CELL_ICON_SIZE/2+10+self.textLabel.frame.size.width/2;
    center.y=self.frame.size.height/2-2-self.textLabel.frame.size.height/2;
    self.textLabel.center=center;
    //设置detailTextLabel的frame
    center.x=detailX+CELL_ICON_SIZE/2+10+self.detailTextLabel.frame.size.width/2;
    center.y=self.frame.size.height/2+3+self.detailTextLabel.frame.size.height/2;
    self.detailTextLabel.center=center;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
