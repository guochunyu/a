//
//  BTPhotoViewController.h
//  AppearanceChapter
//
//  Created by Adam Burkepile on 7/16/12.
//  Copyright (c) 2012 Adam Burkepile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollViewTouches.h"

@interface BTPhotoViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UIScrollViewTouchesDelegate>
@property (weak, nonatomic) IBOutlet UIScrollViewTouches *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *ibPhoto;
@property (strong, nonatomic) IBOutlet UIView *addView;
@property (weak, nonatomic) IBOutlet UITextField *text_name;
@property (strong, nonatomic) IBOutlet UIView *grayView;
@property (nonatomic, strong) NSString* photoData;
@property (nonatomic, assign)NSUInteger index;

@property(nonatomic,strong)NotesData *nd;
-(void)saveImage;
@end


@interface UIImage (Resizing)
- (UIImage *)resizeToFrame:(CGSize)newSize;
- (UIImage *)resizeToSize:(CGSize)newSize;

@end