//
//  ShowGuideViewController.h
//  e企
//
//  Created by HC_hmc on 14/12/20.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowGuideViewController : UIViewController<UIScrollViewDelegate>
@property (nonatomic,copy) void (^blockEnterApp)();
@end
