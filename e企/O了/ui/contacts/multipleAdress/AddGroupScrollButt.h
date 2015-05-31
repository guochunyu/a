//
//  AddGroupScrollButt.h
//  e企
//
//  Created by roya-7 on 14/11/18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddGroupScrollButt : UIButton
@property(nonatomic,copy)NSString *phone;///<手机号
@property(nonatomic,copy)NSString *orgId;///<手机号
//扩大button的点击范围
- (void) setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;
@end
