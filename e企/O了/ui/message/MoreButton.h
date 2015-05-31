//
//  MoreButton.h
//  O了
//
//  Created by royasoft on 14-2-19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreView.h"
@interface MoreButton : UIButton

-(id)initWithFrame:(CGRect)frame isgroup:(BOOL)isgroup titleary:(NSArray *)ary;
@property(strong,nonatomic)UITextView *inputTextView;
@property(strong,nonatomic,readwrite) MoreView *inputView;
@end
