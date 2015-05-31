//
//  MainNavigationCT.m
//  O了
//
//  Created by macmini on 14-02-10.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "MainNavigationCT.h"

@interface MainNavigationCT ()

@end

@implementation MainNavigationCT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.tabBarController.tabBar setBarTintColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view from its nib.
    //将邮箱标题隐藏
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor clearColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica-Bold" size:19.0],NSFontAttributeName,nil]];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
