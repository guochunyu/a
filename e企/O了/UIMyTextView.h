//
//  UIMyTextView.h
//  O了
//
//  Created by 化召鹏 on 14-8-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMyTextView : UITextView
@property(nonatomic,copy)NSString *originalText;///<因为之前的表情标识为[01],现在替换为汉字后,发送出去的内容,到安卓上不能显示,所以需要把汉子替换为数字发送出去
@end
