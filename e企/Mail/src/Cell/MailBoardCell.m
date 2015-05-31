//
//  MailBoardCell.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/12.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailBoardCell.h"
#import "Email.h"

@interface MailBoardCell ()

@property (weak, nonatomic) IBOutlet UILabel *iSenderLabel;
@property (weak, nonatomic) IBOutlet UILabel *iSubjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *iContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *iDateLabel;
@property (weak, nonatomic) IBOutlet UIView *iReadTag;
@property (weak, nonatomic) IBOutlet UIImageView *iAttachmentIcon;
@property (weak, nonatomic) IBOutlet UIImageView *iTagIcon; //star
@property (weak, nonatomic) IBOutlet UIImageView *iBatchTag; //green
@property (weak, nonatomic) IBOutlet UIImageView *iResendImage;
@property (weak, nonatomic) IBOutlet UIImageView *iReplyImage;


@end


@implementation MailBoardCell

- (void)configureWithEmail:(Email *)email batch:(BOOL)btach andType:(EmailArchiveType)type;
{
    //DDLogInfo(@"是否进入保存等方法");
    _email = email;
    _iSenderLabel.text = [email.sender displayNameOrAddress];
    EmailAccount *account= [EmailAccount listAccounts].firstObject;
    if([account.username isEqualToString:_email.sender.address]){
        _iSenderLabel.text=@"我";
    }
    //邮箱首页正文内容
    if ([email.plainText hasPrefix:@" "])
    {
        NSString*str = [email.plainText substringFromIndex:1];
        DDLogCInfo(@"邮箱首页正文内容:%@",email.plainText);
        _iContentLabel.text = str;
    }else{
        _iContentLabel.text = email.plainText;
    }
    //邮箱首页标题内容
    _iSubjectLabel.text = !email.subject||[email.subject isEqualToString:@""]?@"无主题":email.subject;

    //邮箱首页时间内容
    _iDateLabel.text = [email getFormatDate];
    if (email.attachments != nil && [email.attachments count] > 0) {
        _iAttachmentIcon.hidden = NO;
       [_iTagIcon setCenter:CGPointMake(226, 27)];
    } else {
        _iAttachmentIcon.hidden = YES;
       [_iTagIcon setCenter:CGPointMake(247, 27)];

    }
    //标记红点
    _iReadTag.hidden = [email.isRead boolValue];
    _iReadTag.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:59.0/255.0 blue:48.0/255.0 alpha:1.0];
    _iReadTag.layer.cornerRadius = 5;
    _iReadTag.layer.masksToBounds = YES;
    //标记星星
    _iTagIcon.hidden = ![email.isFlag boolValue];
    if (btach) {
        _iTagIcon.hidden = YES;
        _iReadTag.hidden = YES;
    } else {
        _iBatchTag.hidden = YES;
        
    }
    
    if (type == EmailArchiveTypeInbox)
    {
        _iReplyImage.hidden = ![email.hasReply boolValue];
        _iResendImage.hidden = ![email.hasTransmit boolValue];
    }
    else
    {
        _iReplyImage.hidden = YES;
        _iResendImage.hidden = YES;
    }
    if (type != EmailArchiveTypeDraft) {
       
        //可以加不等于显示
        _iReplyImage.hidden = ![email.hasReply boolValue];
        _iResendImage.hidden = ![email.hasTransmit boolValue];
    }else{
        
        _iReplyImage.hidden = YES;
        _iResendImage.hidden = YES;
    }
    
}

- (void)batchTag:(BOOL)tag
{
    _iBatchTag.hidden = !tag;
}

- (void)configureWithEmailContent:(NSString *)content
{
    _iContentLabel.text = content;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end