//
//  MNAlertPopup.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-9-15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MNAlertPopup.h"
#import "LogicHelper.h"

static const CGFloat kContentSize = 80;

@interface MNAlertPopup ()

@property (nonatomic) UIView *contentView;

@end

@implementation MNAlertPopup

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIView *contentView = [[UIView alloc] init];
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        contentView.backgroundColor = [UIColor blackColor];
        contentView.alpha = 0.8;
        contentView.layer.cornerRadius = 12.0;
        
        UIActivityIndicatorView *progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [progress setColor:[UIColor whiteColor]];
        [progress startAnimating];
        progress.frame = CGRectMake((kContentSize - 37) / 2, (kContentSize - 37) / 2, 37, 37);
        
        [contentView addSubview:progress];
        
        contentView.frame = CGRectMake((ABDEVICE_SCREEN_WIDTH - kContentSize) / 2, (ABDEVICE_SCREEN_HEIGHT - kContentSize) / 2, kContentSize, kContentSize);
        [self addSubview:contentView];
        self.frame = CGRectMake(0, 0, ABDEVICE_SCREEN_WIDTH, ABDEVICE_SCREEN_HEIGHT);
        self.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:0.5];
        _contentView = contentView;
    }
    return self;
}


- (void)show
{
    dispatch_async( dispatch_get_main_queue(), ^{
        if(!self.superview){
            NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
            
            for (UIWindow *window in frontToBackWindows) {
                if (window.windowLevel == UIWindowLevelNormal) {
                    [window addSubview:self];
                    break;
                }
            }
        }
        _contentView.alpha = 0.0;
        // set frame before transform here...
        _contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [UIView animateWithDuration:0.6
                              delay:0.0
             usingSpringWithDamping:0.8
              initialSpringVelocity:15.0
                            options:0
                         animations:^{
                             _contentView.alpha = 1.0;
                             _contentView.transform = CGAffineTransformIdentity;
                         }
                         completion:nil];
        
    });
}

- (void)dismiss:(void(^)())completon
{
    
    dispatch_async( dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.13
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void){
                             _contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }
                         completion:^(BOOL finished){
                             
                             [UIView animateWithDuration:0.26
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^(void){
                                                  _contentView.alpha = 0.0;
                                                  _contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                              }
                                              completion:^(BOOL finished) {
                                                  [self removeFromSuperview];
                                                  completon();
                                              }];
                         }];
    });
    
}



@end
