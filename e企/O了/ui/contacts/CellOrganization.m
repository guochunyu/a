//
//  CellOrganization.m
//  e企
//
//  Created by royaMAC on 14-11-10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CellOrganization.h"

@implementation CellOrganization

@synthesize headImg=_headImg ,nameLabel=_nameLabel, positionLabel=_positionLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _headImg=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius=20.0;
        _headImg.image=[UIImage imageNamed:@"icon_group_50.png"];
        
        _nameLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 12,200, 30)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font=[UIFont systemFontOfSize:15];
        
        _positionLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 10, 80, 30)];
        _positionLabel.font=[UIFont systemFontOfSize:15];
        _positionLabel.textColor=[UIColor lightGrayColor];
        
        self.lineView=[[UIView alloc] initWithFrame:CGRectMake(0, 53.5, 320, 0.5)];
        _lineView.opaque             = YES;
        _lineView.backgroundColor    =[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0];        [self.contentView addSubview:self.lineView];
//        [self.contentView addSubview:_headImg];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_positionLabel];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
