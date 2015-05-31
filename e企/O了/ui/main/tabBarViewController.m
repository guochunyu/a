//
//  tabBarViewController.m
//  O了
//
//  Created by macmini on 14-01-08.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import "tabBarViewController.h"
#import "ContactsViewController.h"
#import "MessageViewController.h"

@interface tabBarViewController ()

@end

@implementation tabBarViewController

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
	// Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
//    UIViewController *messageVC = [[MessageViewController alloc]initWithNibName:@"MessageViewController" bundle:nil];
//    UIStoryboard *messageVC=[UIStoryboard   storyboardWithName:@"Chat" bundle:nil];
//    UINavigationController *navi_1 = [[UINavigationController alloc]initWithRootViewController:[messageVC instantiateInitialViewController]];
//    
//    UIViewController *contactVC = [[ContactsViewController alloc]initWithNibName:@"ContactsViewController" bundle:nil];
//    UINavigationController *navi_2 = [[UINavigationController alloc]initWithRootViewController:contactVC];
//    
//    UIStoryboard * meVC = [UIStoryboard storyboardWithName:@"MeViewController" bundle:nil];
//    UINavigationController *navi_4 = [[UINavigationController alloc]initWithRootViewController:[meVC instantiateInitialViewController]];
//    navi_4.title = @"我";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
