//
//  ChatCell.h
//  O了
//
//  Created by 化召鹏 on 14-8-8.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+myChat.h"
#import "ChatView.h"
#import "NotesData.h"

typedef void(^CellIndexPath)(NSIndexPath *indexPath);

@interface ChatCell : UITableViewCell{
    UIImageView *selectImageView;//多选
}
@property(nonatomic,assign)MyChatViewType cellChatViewType;
@property(nonatomic,assign)BOOL myChatSelect;//是否选择
@property(nonatomic,strong)ChatView  *chatView;
@property(nonatomic,copy)CellIndexPath indexPath;
- (void)changeMSelectedState;
-(NSIndexPath *)myIndexPath;
@end
