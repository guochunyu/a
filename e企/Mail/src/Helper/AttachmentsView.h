//
//  AttachmentsView.h
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/21.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Attachment.h"
extern NSString*const notificationName;
@protocol AttachmentsViewDelegate <NSObject>

- (void)didAttachmentClick:(NSObject *)attachment;

@optional
- (void)didAttachmentItemClick:(NSURL *)url;

@end

@interface AttachmentsView : UIView

@property(nonatomic,strong)UILabel * title;







@property (nonatomic) id<AttachmentsViewDelegate> delegate;

- (instancetype)initWithAttachments:(NSArray *)attachments;
- (instancetype)initWithSendAttachments:(NSArray *)attachments;

- (CGFloat)viewHeight;

@end
