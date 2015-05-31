//
//  CustomServiceCell.m
//  O了
//
//  Created by roya-7 on 14-9-19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "CustomServiceCell.h"

@implementation CustomServiceFirstCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setTitleText:(NSString *)titleText{
    if (titleText) {
        _titleText=titleText;
    }
    UIFont *font=[UIFont systemFontOfSize:17];
    CGSize titleSize=[_titleText sizeWithFont:font constrainedToSize:CGSizeMake(self.bitTitleLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    
    if (titleSize.height>self.titleBgView.frame.size.height) {
        //两行
//        self.bigImageView
        
        if (titleSize.height>40) {
            titleSize.height=40;
        }
        
        CGRect bigTitleBgFrame=self.titleBgView.frame;
        bigTitleBgFrame.origin.y=bigTitleBgFrame.origin.y-(titleSize.height+10-bigTitleBgFrame.size.height);
        bigTitleBgFrame.size.height=titleSize.height+10;
        self.titleBgView.frame=bigTitleBgFrame;
        bigTitleBgFrame.origin.x=0;
        bigTitleBgFrame.origin.y=0;
        self.bitTitleLabel.frame=bigTitleBgFrame;
        self.bigTitleBgImageView.frame=bigTitleBgFrame;
        
        
    }
    self.bitTitleLabel.text=_titleText;
    
    
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
@end


@implementation CustomServiceOtherCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(BOOL)canBecomeFirstResponder{
    return YES;
}
@end
