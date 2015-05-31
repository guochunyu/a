//
//  PhotoViewController.h
//  O了
//
//  Created by macmini on 14-01-15.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoViewController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIActionSheetDelegate>{
    UIButton *_leftButt;
    UIButton *_rightButt;
}

@property(strong, nonatomic)NSArray *photos;
@property(assign, nonatomic)NSUInteger index;

@property(nonatomic,strong)NotesData *nd;
@end
