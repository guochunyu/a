//
//  AboutViewController.h
//  e企
//
//  Created by 许学 on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

@property (nonatomic, weak)IBOutlet UILabel *label_version;
@property (strong, nonatomic) NSString *plistUrl;

@end
