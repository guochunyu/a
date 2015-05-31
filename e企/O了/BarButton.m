//
//  BarButton.m
//  O了
//
//  Created by 化召鹏 on 14-1-23.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "BarButton.h"

@implementation BarButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}
- (void)setRemindImage:(UIImageView *)remindImage{
    
    
    [self bringSubviewToFront:remindImage];
}
-(void)addTheRemindImage{
    _remindImage=[[UIImageView alloc] initWithFrame:CGRectMake(27 , -13, 15, 15)];
    _remindImage.image=[UIImage imageNamed:@"public_Remindnumber.png"];
    _remindImage.backgroundColor=[UIColor clearColor];
    [self addSubview:_remindImage];
    
    [self bringSubviewToFront:_remindImage];
}
-(void)setRemindNum:(NSInteger)remindNum{
    _remindNum=remindNum;
    if (_remindImage!=nil) {
        [_remindImage removeFromSuperview];
    }
    [self addTheRemindImage];
//    [self setRemindImage:nil];
    if (_remindNum==0) {
        _remindImage.alpha = 0;
    }else{
        _remindImage.alpha = 1;
        //获取未读消息
        if(remindNum < 0 ){
            _remindImage.frame = CGRectMake(55, 5, 8, 8);
        }else{
            UILabel *numberLabel=[[UILabel alloc] initWithFrame:CGRectMake(3, 2, 10, 10)];
            numberLabel.backgroundColor=[UIColor clearColor];
            numberLabel.textAlignment=NSTextAlignmentCenter;
            numberLabel.font=[UIFont systemFontOfSize:8];
            numberLabel.textColor=[UIColor whiteColor];
            numberLabel.text=[NSString stringWithFormat:@"%d",remindNum];
            if (remindNum>99) {
                
                NSString *imageName= @"public_Remindnumber.png";
                UIImage *img=[UIImage imageNamed:imageName];
                
                //对图片进行边帽设置，可以把图片分为4个部分，取大约值即可，将来放大的话 四个角不变，其余部分会自动有规则的填充
                UIImage *newImage=[img stretchableImageWithLeftCapWidth:7.5 topCapHeight:7.5];
                _remindImage.image=newImage;
                _remindImage.frame=CGRectMake(40, 5, 20, 15);
                numberLabel.frame=CGRectMake(3, 2, 15, 10);
                numberLabel.text=[NSString stringWithFormat:@"99+"];
            }
            
            [_remindImage addSubview:numberLabel];
        }
    }
    
}

-(void)setTabbarTitleLabel:(NSString *)tabbarTitleLabel{
    tabbarLabel=[[UILabel alloc] initWithFrame:CGRectMake(-10, 33, self.frame.size.width+20, 15)];
    tabbarLabel.backgroundColor=[UIColor clearColor];
    tabbarLabel.textAlignment=NSTextAlignmentCenter;
    tabbarLabel.font=[UIFont systemFontOfSize:11];
    
    tabbarLabel.text=tabbarTitleLabel;
    tabbarLabel.textColor=[UIColor colorWithRed:0.44 green:0.44 blue:0.45 alpha:1];

    [self addSubview:tabbarLabel];

}
-(void)setBarButtonTitleColor:(NSInteger)isSelect{
    if (isSelect==1) {
        tabbarLabel.textColor=[UIColor colorWithRed:64/255.0  green:138/255.0 blue:244/255.0 alpha:1];

        
    }else{
        tabbarLabel.textColor=[UIColor colorWithRed:0.44 green:0.44 blue:0.45 alpha:1];
        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)setIsRemind:(BOOL)isRemind{
    if (isRemind && _remindNum == 0) {
        if (_remindImage==nil) {
            _remindImage=[[UIImageView alloc] initWithFrame:CGRectMake(47, 5, 8, 8)];
        }
        
        _remindImage.image=[UIImage imageNamed:@"public_Remindnumber.png"];
        _remindImage.backgroundColor=[UIColor clearColor];
        _remindImage.alpha = 1;
        [self addSubview:_remindImage];
        [self bringSubviewToFront:_remindImage];
    }
    else
    {
        if (_remindImage)
        {
            [_remindImage removeFromSuperview];
        }
    }
}

@end
