//
//  TransmitViewController.h
//  O了
//
//  Created by 化召鹏 on 14-7-22.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectChat)(id sender);

@interface TransmitViewController : UIViewController<UIAlertViewDelegate>{
    NSMutableArray *_imageViewArray;
}

@property(nonatomic,copy)NSString *nowTaskId;
@property(nonatomic,strong)SelectChat selectChat;//选择某个回话
@end
