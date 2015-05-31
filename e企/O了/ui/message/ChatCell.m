//
//  ChatCell.m
//  O了
//
//  Created by 化召鹏 on 14-8-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell
@synthesize myChatSelect=_myChatSelect;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _myChatSelect=NO;
        CGRect indicatorFrame = CGRectMake(-30, abs(self.frame.size.height - 30)/ 2, 30, 30);
        selectImageView = [[UIImageView alloc] initWithFrame:indicatorFrame];
        selectImageView.layer.masksToBounds = YES;
        selectImageView.layer.cornerRadius = 22;
        [self.contentView addSubview:selectImageView];

    }
    return self;
}

- (void)layoutSubviews
{
    // Initialization code
    [super layoutSubviews];


    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    if (_myChatSelect)
    {

        self.textLabel.textColor = [UIColor darkTextColor];
        [selectImageView setImage:[UIImage imageNamed:@"CellBlueSelected"]];
    }
    else
    {
        self.backgroundView.backgroundColor = [UIColor clearColor];
        [selectImageView setImage:[UIImage imageNamed:@"CellNotSelected"]];
    }
    [UIView commitAnimations];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
//    if (self.cellChatViewType==MyChatViewTypeGroup || self.cellChatViewType==MyChatViewTypeTime) {
//        [super setEditing:NO animated:animated];
//    }else{
//        [super setEditing:editing animated:animated];
//    }

    

    if (self.cellChatViewType!=MyChatViewTypeGroup && self.cellChatViewType!=MyChatViewTypeTime) {
        [super setEditing:editing animated:animated];
        
        float view3_y=20;
        switch (self.cellChatViewType) {
            case MyChatViewTypeLAndTime:
            {
                view3_y=70;
                break;
            }
            case MyChatViewTypeRAndTime:
            {
                view3_y=50;
                break;
            }
            case MyChatViewTypeTime:
            {
                view3_y=40;
                break;
            }
            case MyChatViewTypeL:
            {
                view3_y=40;
                break;
            }
            case MyChatViewTypeR:
            {
                view3_y=20;
                break;
            }
            default:
                break;
        }
        selectImageView.frame=CGRectMake(-30, view3_y, 30, 30);
        
        /*
         ** 只有ios7需要多做一层循环,8和7之前的处理方式一样.
         */
        if (iosSystemVersion==7) {
            for (UIView *view1 in self.subviews) {
                for (UIView *view2 in view1.subviews) {
                    
                    if ([view2 isMemberOfClass: NSClassFromString(@"UITableViewCellEditControl")]) {
                        for (UIView *view3 in view2.subviews) {
                            
                            [view3 removeFromSuperview];
                            
                        }
                    }
                };
            }
        }else{
            for (UIControl *control in self.subviews){
                if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
                    [control removeFromSuperview];
                }
            }
        }
        /*
        if (IS_IOS_7) {
            
            if (IS_IOS_8) {
                for (UIControl *control in self.subviews){
                    if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
                        [control removeFromSuperview];
                    }
                }
            }else{
                
            }
            
            
        }else{
            //ios7以下要这样处理
            
        }
         */
        
    }


}

- (void)changeMSelectedState
{
    _myChatSelect= !_myChatSelect;
    [self setNeedsLayout];
}
-(NSIndexPath *)myIndexPath{
    UITableView *selfSuperView=nil;
    if (IS_IOS_7) {
        selfSuperView=(UITableView *)[[self superview] superview];
    }else{
        selfSuperView=(UITableView *)[self superview];
    }
    NSIndexPath *index=[selfSuperView indexPathForCell:self];
    return index;
}
@end
