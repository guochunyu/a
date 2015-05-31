//
//  MWWebViewController.h
//  test
//
//  Created by 许学 on 14-8-8.
//  Copyright (c) 2014年 许学. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	MWWebBrowserModeNavigation,
	MWWebBrowserModeModal,
} MWWebBrowserMode;

@interface MWToolBar : UIToolbar {}@end


@interface MWWebViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) NSURL *URL;
@property (nonatomic, assign) MWWebBrowserMode mode;

- (void)load;
- (void)clear;
@end
