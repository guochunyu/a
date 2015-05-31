//
//  CellContact.m
//  O了
//
//  Created by macmini on 14-01-10.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "CellContact.h"
#import "MessageChatViewController.h"

#define TEXT_FONT 12
#define LABEL_WIDTH 20
#define TOP_Y 20
#define LINE_WIDTH 308
#define LINE_HEIGHT 0.5
#define LINE_TOPY 53.5
@implementation CellContact
@synthesize imageView = _imageView;
@synthesize label_name = _label_name;
@synthesize label_position = _label_position;
@synthesize messageBtn = _messageBtn;
@synthesize calliphoneBtn = _calliphoneBtn;
@synthesize lineView = _lineView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(14, 7, 40, 40)];
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = _imageView.frame.size.width * 0.5;
        [_imageView setImage:[UIImage imageNamed:@"address_icon_person.png"]];
        int ios6with = 0;
        if (IS_IOS_7) {
            ios6with = 0;
        }else{
            ios6with = 10;
        }
        _label_name = [[UILabel alloc]init];
        _label_name.font = [UIFont systemFontOfSize:15];
        _label_name.frame=CGRectMake(_imageView.frame.size.width+_imageView.frame.origin.x+5, TOP_Y,100, LABEL_WIDTH);
        _label_name.textAlignment=NSTextAlignmentCenter;
        
        _label_position = [[UILabel alloc]initWithFrame:CGRectMake(_label_name.frame.size.width+_label_name.frame.origin.x+5, TOP_Y,70, LABEL_WIDTH)];
        _label_position.textColor = [UIColor lightGrayColor];
        _label_position.textAlignment=NSTextAlignmentLeft;
        _label_position.font = [UIFont systemFontOfSize:TEXT_FONT];
        
//        _label_position1 = [[AttributedLabel alloc]initWithFrame:CGRectMake(_label_name.frame.size.width+_label_name.frame.origin.x+5, TOP_Y,70, LABEL_WIDTH)];
//        _label_position1.textColor = [UIColor lightGrayColor];
//        _label_position1.textAlignment=NSTextAlignmentLeft;
//        _label_position1.font = [UIFont systemFontOfSize:TEXT_FONT];
        //线
        self.lineView               = [[UIView alloc] initWithFrame:CGRectMake(69, LINE_TOPY, LINE_WIDTH, LINE_HEIGHT)];
        _lineView.opaque             = YES;
        _lineView.backgroundColor    =[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];
        [self.contentView addSubview:self.lineView];
        [self.contentView addSubview:_label_name];
        [self.contentView addSubview:_label_position];
//        [self.contentView addSubview:_label_position1];
        [self.contentView addSubview:_imageView];
      }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
