//
//  UIScrollViewTouchesDelegate.h
//  O了
//
//  Created by 化召鹏 on 14-2-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol UIScrollViewTouchesDelegate

-(void)scrollViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event whichView:(id)scrollView;

@end
@interface UIScrollViewTouches : UIScrollView

@property(nonatomic,assign) id<UIScrollViewTouchesDelegate> touchesdelegate;
@end
