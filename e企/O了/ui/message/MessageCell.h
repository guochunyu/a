//
//  MessageCell.h
//  O了
//
//  Created by 化召鹏 on 14-1-9.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarButton.h"
#import "ChatListModel.h"
#import "MemberData.h"
#import "MLEmojiLabel.h"
extern NSString*const notificationMessage;
@interface MessageCell : UITableViewCell
@property(strong,nonatomic)UIImageView *headImage;
@property(strong,nonatomic)UIImageView *tipImage;
//@property(strong,nonatomic)UILabel *detailLabel;
@property(strong,nonatomic)MLEmojiLabel *detailLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)BarButton * barB;
@property(strong,nonatomic)ChatListModel *message;
@property(strong,nonatomic)NSDictionary *unRead;
@property(nonatomic,assign)NSInteger cell_row;
@property(strong,nonatomic)UIView *lineview;
@property(nonatomic,strong)NSArray *memberList;///<如果是群发消息,存放群发对象

@property (nonatomic, strong)NSString *Message_Unread;
-(void)Message_Unread_Methods;

-(void)addImageToHeadImage;
@end
