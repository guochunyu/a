//
//  MNAlertPopup.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-9-15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface MNAlertPopup : UIView

- (void)show;
- (void)dismiss:(void(^)())completon;

@end
