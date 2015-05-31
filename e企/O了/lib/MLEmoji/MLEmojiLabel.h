//
//  MLEmojiLabel.h
//  MLEmojiLabel
//
//  Created by molon on 5/19/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "TTTAttributedLabel.h"


typedef NS_OPTIONS(NSUInteger, MLEmojiLabelLinkType) {
    MLEmojiLabelLinkTypeURL = 0,                ///<连接
    MLEmojiLabelLinkTypeEmail,                  ///<邮箱
    MLEmojiLabelLinkTypePhoneNumber,            ///<手机号码
    MLEmojiLabelLinkTypeAt,                     ///<@人员
    MLEmojiLabelLinkTypePoundSign,              ///<标记,如"这是提醒项"
};


@class MLEmojiLabel;
@protocol MLEmojiLabelDelegate <NSObject>

@optional
- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type;


@end

@interface MLEmojiLabel : TTTAttributedLabel

@property (nonatomic, assign) BOOL disableEmoji; ///<禁用表情
@property (nonatomic, assign) BOOL disableThreeCommon; ///<禁用电话，邮箱，连接三者
//NSString * const kURLActions[] = {@"url->",@"email->",@"phoneNumber->",@"at->",@"poundSign->"};
@property(nonatomic,assign)BOOL disableEmail;///<禁用邮箱
@property(nonatomic,assign)BOOL disablePhoneNumber;///<禁用电话
@property(nonatomic,assign)BOOL disableAt;///<禁用@功能
@property(nonatomic,assign)BOOL disablePoundSign;///<禁用话题


@property(nonatomic,assign)NSRange highlightedStrRange;///<高亮文字的range,根据这个属性设置高亮位置.(这个位置之前必须不能出现表情)


@property (nonatomic, assign) BOOL isNeedAtAndPoundSign; ///<是否需要话题和@功能，默认为不需要

@property (nonatomic, copy) NSString *customEmojiRegex; ///<自定义表情正则
@property (nonatomic, copy) NSString *customEmojiPlistName; ///<xxxxx.plist 格式

@property (nonatomic, weak) id<MLEmojiLabelDelegate> emojiDelegate; //点击连接的代理方法

@property (nonatomic, copy) NSString *emojiText; ///<设置处理文字

@end
