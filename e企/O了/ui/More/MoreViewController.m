//
//  MoreViewController.m
//  e企
//
//  Created by roya-7 on 14/11/3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"更多";
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchDragInside];
    [self.view addSubview:btn];
}
-(void)clear
{
    [self clearLocalDataWithPath:[self clearLocalData]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//清理本地缓存
- (BOOL)clearLocalDataWithPath:(NSString *)path
{
    //删除此文件夹
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:path error:nil];
}
- (NSString *)clearLocalData
{
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cacheesSource"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
