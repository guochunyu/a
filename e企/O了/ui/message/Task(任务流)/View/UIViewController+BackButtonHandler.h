//
//  UIViewController+BackButtonHandler.h
//  e企
//
//  Created by Capricorns on 15/4/3.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>

@optional

// Override this method in UIViewController derived class to handle 'Back' button click

-(BOOL)navigationShouldPopOnBackButton;

@end

@interface UIViewController (BackButtonHandler)<BackButtonHandlerProtocol>

@end
