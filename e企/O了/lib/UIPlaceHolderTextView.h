//
//  UIPlaceHolderTextView.h
//  HYAppInstall
//
//  Created by 许学 on 14/11/20.
//  Copyright (c) 2014年 cmcc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView
{
    NSString *placeholder;
    
    UIColor *placeholderColor;
    
@private
    
    UILabel *placeHolderLabel;
    UILabel *numLable;
}

@property(nonatomic, retain) UILabel *placeHolderLabel;

@property(nonatomic, retain) UILabel *numLable;

@property(nonatomic, retain) NSString *placeholder;

@property(nonatomic, retain) UIColor *placeholderColor;


-(void)textChanged:(NSNotification*)notification;


@end
