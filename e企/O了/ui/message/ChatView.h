//
//  ChatView.h
//  O了
//
//  Created by 化召鹏 on 14-8-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesData.h"

///**
// *  view类型,默认不做处理,时间和群组不显示选择框
// */
typedef enum{
    MyChatViewTypeNormal,///<默认
    MyChatViewTypeL,///<头像在左边
    MyChatViewTypeLAndTime,///<头像在左边并且带有时间
    MyChatViewTypeR,///<头像在右边
    MyChatViewTypeRAndTime,///<头像在右边并且带有时间
    MyChatViewTypeTime,///<时间
    MyChatViewTypeGroup///<群组
    
}MyChatViewType;
@interface ChatView : UIView
@property(nonatomic,assign)MyChatViewType chatViewType;
@property(nonatomic,strong)UIView *timeView;
@property(nonatomic,strong)NotesData *nd;//view的唯一标识符,来区分重用


@end
