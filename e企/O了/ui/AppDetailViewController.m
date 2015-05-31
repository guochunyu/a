//
//  AppDetailViewController.m
//  e企
//
//  Created by shawn on 14/11/12.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "AppDetailViewController.h"


@interface AppDetailViewController (){
   }

@end

@implementation AppDetailViewController
@synthesize plugin;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.title = plugin[@"name"];
    
    [self.iconImageView setImageWithURL:[NSURL URLWithString:plugin[@"iosInfo"][@"logo"]]
                       placeholderImage:[UIImage imageNamed:@"public_icon_tabbar_apply_nm.png"]];
    
    NSArray *descpics = plugin[@"iosInfo"][@"descpics"];
    CGFloat imgWidth = 144;
    CGFloat imgHeight = 240;
    int padding = 10;
    int x = padding;
    int y = (self.descpics.frame.size.height - imgHeight)/2;
    NSString *defaultPic = @"public_icon_tabbar_apply_nm.png";
    for (int i=0; i < descpics.count; i++) {
        NSString *picUrl = [descpics objectAtIndex:i];
        if ((picUrl == nil || picUrl.length ==0 ) && x == padding && i !=  descpics.count -1 ) {
            continue;
        }
        if ((picUrl == nil || picUrl.length ==0 ) && x == padding && i ==  descpics.count -1 ) {
            defaultPic = @"app_default_descpic.png";
            x = (self.descpics.frame.size.width - imgWidth)/2;
        }
        UIImageView *view  = [[UIImageView alloc] init];
        view.backgroundColor = [UIColor blackColor];
        [view setImageWithURL:[NSURL URLWithString:picUrl]
              placeholderImage:[UIImage imageNamed:defaultPic]];
        // add the controller's view to the scroll view
        if (nil == view.superview) {
            CGRect frame =  CGRectMake(x, y, imgWidth, imgHeight);
            view.frame = frame;
            [self.descpics addSubview:view];
            x = x + imgWidth + padding;
        }
    }
    self.descpics.contentSize = CGSizeMake(x,  self.descpics.frame.size.height);

    
    NSString *desc = plugin[@"iosInfo"][@"desc"];
    self.descLabel.text =desc;
    NSString *size = plugin[@"iosInfo"][@"size"];
    self.sizeLabel.text = [self getSizeString:size.floatValue] ;
    self.nameLabel.text = plugin[@"name"];
    
    
}

-(void)viewDidLayoutSubviews{
    self.appContentView.contentSize = CGSizeMake(self.appContentView.frame.size.width, 450);
}

-(NSString*) getSizeString:(CGFloat) size{
    size = size / 1024.0f;
    NSString *suffix = @"M";
    if (size > 1024) {
        size = size / 1024.0f;
        suffix = @"G";
    }
    return  [NSString stringWithFormat:@"%.02f%@",size,suffix];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)installApp:(id)sender {
     NSString *urlString = @"";
    NSString *plistUrl = plugin[@"iosInfo"][@"plisturl"];
    if (plistUrl.length > 0) {
        urlString = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",plistUrl];
    }else{
         urlString = plugin[@"iosInfo"][@"appstoreurl"];
    }
    BOOL b = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    DDLogInfo(@"%@",urlString);
    DDLogInfo(@"%@",b ? @"YES":@"NO");
}
@end
