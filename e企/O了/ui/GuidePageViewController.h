//
//  GuidePageViewController.h
//  O了
//
//  Created by 化召鹏 on 14-5-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuidePageViewController : UIViewController<UIScrollViewDelegate>{
    UIScrollView *_guideView;
    UIPageControl *_guidePageControl;
}
@property (nonatomic,copy) void (^guideFinish)(BOOL isFinish);
@end
