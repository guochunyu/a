//
//  MWInsetsTextField.m
//  MobileWallet
//
//  Created by louzhenhua on 14-9-3.
//  Copyright (c) 2014年 CMCC. All rights reserved.
//

#import "MWInsetsTextField.h"

@implementation MWInsetsTextField


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.textEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.leftViewEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        UIImage *backgroundImage = [UIImage imageNamed:@"inputbox.png"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
        [self setBackground:backgroundImage];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.textEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        self.leftViewEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        UIImage *backgroundImage = [UIImage imageNamed:@"inputbox.png"];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
        [self setBackground:backgroundImage];
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.textEdgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.textEdgeInsets)];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
//    return [super leftViewRectForBounds:UIEdgeInsetsInsetRect(bounds, leftViewEdgeInsets)];
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += self.leftViewEdgeInsets.left;// 右偏10	return iconRect;
    return iconRect;
}

@end
