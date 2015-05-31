//
//  CreateEnterPriseMemberCell.m
//  e企
//
//  Created by zw on 4/20/15.
//  Copyright (c) 2015 QYB. All rights reserved.
//

#import "CreateEnterPriseMemberCell.h"
#import "MacroDefines.h"

@implementation CreateEnterPriseMemberCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.nameTextfield = [[UITextField alloc] init];
        self.nameTextfield.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.nameTextfield];
        
        self.phoneNumLabel = [[UILabel alloc] init];
        self.phoneNumLabel.font = [UIFont systemFontOfSize:13];
        self.phoneNumLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.phoneNumLabel];
        
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.editButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.editButton];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.deleteButton];
        
        self.bottomLineView = [[UIView alloc] init];
        self.bottomLineView.backgroundColor = LineBgColor;
        [self.contentView addSubview:self.bottomLineView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
