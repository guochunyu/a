//
//  CustomImagePickerController.h
//  MeiJiaLove
//
//  Created by Wu.weibin on 13-7-9.
//  Copyright (c) 2013年 Wu.weibin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomImagePickerControllerDelegate <NSObject>

- (void)cameraPhoto:(UIImage *)image;
- (void)cancelCamera;
@end

@interface CustomImagePickerController : UIImagePickerController<UIImagePickerControllerDelegate>

@property(nonatomic)BOOL isSingle;
@property(nonatomic,assign)id<CustomImagePickerControllerDelegate> customDelegate;
@end

