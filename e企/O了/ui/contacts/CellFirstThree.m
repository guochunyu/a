//
//  CellFirstThree.m
//  O了
//
//  Created by macmini on 14-01-10.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "CellFirstThree.h"
#define TEXT_FONT 14
#define LABEL_WIDTH 20
#define TOP_Y 20
#define LINE_WIDTH 308
#define LINE_HEIGHT 0.5
#define LINE_TOPY 53.5


@implementation CellFirstThree
@synthesize imageView = _imageView;
@synthesize label = _label;
@synthesize lineView = _lineView;
@synthesize unitBtn = _unitBtn;

@synthesize imageView1 = _imageView1;
@synthesize label1 = _label1;
@synthesize qunBtn = _qunBtn;

@synthesize imageView2 = _imageView2;
@synthesize label2 = _label2;
@synthesize publicBtn = _publicBtn;

@synthesize messageBtn = _messageBtn;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(14, 7, 40, 40)];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 20.0;
        _label = [[UILabel alloc]initWithFrame:CGRectMake(59, 20, 50, 20)];
        _label.font = [UIFont systemFontOfSize:14];
        _label.textAlignment=NSTextAlignmentLeft;
        _unitBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _unitBtn.frame=CGRectMake(31, 16, 44, 44);
        _unitBtn.tag=100;
          
        _imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(137, 16, 44, 44)];
        _imageView1.layer.masksToBounds = YES;
        _imageView1.layer.cornerRadius = 22.0;
        _label1 = [[UILabel alloc]initWithFrame:CGRectMake(137, 65, 50, 20)];
        _label1.font = [UIFont systemFontOfSize:14];
        _label1.textAlignment=NSTextAlignmentLeft;
        _qunBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _qunBtn.frame=CGRectMake(137, 16, 44, 44);
        _qunBtn.tag=200;

        
        _imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(244, 16, 44, 44)];
        _imageView2.layer.masksToBounds = YES;
        _imageView2.layer.cornerRadius = 22.0;
        _label2 = [[UILabel alloc]initWithFrame:CGRectMake(244, 64, 50, 20)];
        _label2.font = [UIFont systemFontOfSize:14];
        _label2.textAlignment=NSTextAlignmentLeft;
        _publicBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        _publicBtn.frame=CGRectMake(244, 16, 44, 44);
        _publicBtn.tag=300;

        
        //线
        self.lineView               = [[UIView alloc] initWithFrame:CGRectMake(69, 53.5, 308, 0.5)];
        _lineView.opaque             = YES;
        _lineView.backgroundColor    =[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];          
        
        [self.contentView addSubview:_lineView];
        [self.contentView addSubview:_imageView];
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_unitBtn];
        [self.contentView bringSubviewToFront:_unitBtn];
        
        [self.contentView addSubview:_imageView1];
        [self.contentView addSubview:_label1];
        [self.contentView addSubview:_qunBtn];
        [self.contentView bringSubviewToFront:_qunBtn];
        
//        [self.contentView addSubview:_imageView2];
//        [self.contentView addSubview:_label2];
//        [self.contentView addSubview:_publicBtn];
//        [self.contentView bringSubviewToFront:_publicBtn];
    }
    return self;
}
-(void)addChatImage{
    int ios6with = 0;
    if (IS_IOS_7) {
        ios6with = 0;
    }else{
        ios6with = 10;
    }
//    _sendMessageImage=[[UIImageView alloc] initWithFrame:CGRectMake(245, 15, 25, 23)];
    _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageBtn setFrame:CGRectMake(245 - ios6with, 15, 25, 23)];
    [_messageBtn setImage:[UIImage imageNamed:@"adress_chat.png"] forState:UIControlStateNormal];
    [_messageBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_messageBtn];
}
-(void)chat:(id)sender{
    [self.delegate cellFirstThreeCell:nil];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
