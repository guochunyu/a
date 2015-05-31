//
//  MessageCell.m
//  O了
//
//  Created by 化召鹏 on 14-1-9.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MessageCell.h"
#import "NSDate+string.h"
NSString*const notificationMessage=@"WWDC";

@interface MessageCell (){
    UIView *bgView;
    UIImageView *starimageview;
}

@property(nonatomic,strong)NSMutableDictionary *memberDataDict;
@end

@implementation MessageCell
@synthesize  message,unRead;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        if (!self.memberDataDict) {
            self.memberDataDict=[[NSMutableDictionary alloc] init];
        }

        bgView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 67)];
        bgView.backgroundColor=[UIColor whiteColor];
        [self addSubview:bgView];
        
        _headImage=[[UIImageView alloc] initWithFrame:CGRectMake(14,10.5,44,44)];
        _headImage.backgroundColor=[UIColor clearColor];
        [_headImage.layer setMasksToBounds:YES];
        [_headImage.layer setCornerRadius:_headImage.frame.size.height/2];
        
        [bgView addSubview:_headImage];
        //未读消息红点
//        CGRect barFrame = CGRectMake(0,5,15,15);
        CGRect barFrame = CGRectMake(18,18,15,15);
        self.barB = [[BarButton alloc]initWithFrame:barFrame];
        self.barB.remindImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.barB.remindImage.image=[UIImage imageNamed:@"public_Remindnumber.png"];
        self.barB.remindImage.backgroundColor=[UIColor clearColor];
        self.barB.remindNum = 0;
        [bgView addSubview:self.barB];
        
        _nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(72, 12, 150, 20)];
        _nameLabel.backgroundColor=[UIColor clearColor];
        _nameLabel.font=[UIFont systemFontOfSize:16];
        _nameLabel.text=@"_nameLabel";
        _nameLabel.textColor=[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [bgView addSubview:_nameLabel];
        
        
        starimageview=[[UIImageView alloc]initWithFrame:CGRectMake(72+35, 14.5, 15, 15)];
        starimageview.image=[UIImage imageNamed:@"msg_icon_system-notice"];
        [starimageview setHidden:YES];
        [bgView addSubview:starimageview];
        _timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(210, 11, 95, 20)];
        _timeLabel.backgroundColor=[UIColor clearColor];
        _timeLabel.textAlignment=NSTextAlignmentRight;
        _timeLabel.text=@"_timeLabel";
        _timeLabel.textColor=[UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1];
        _timeLabel.font=[UIFont systemFontOfSize:11];
        [bgView addSubview:_timeLabel];
        
        
        _detailLabel=[[MLEmojiLabel alloc] initWithFrame:CGRectMake(72, 38, 228, 18)];
        _detailLabel.backgroundColor=[UIColor clearColor];
        _detailLabel.font=[UIFont systemFontOfSize:12];
        //        HEXCOLOR(0x333333);
        _detailLabel.textColor=[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _detailLabel.numberOfLines=0;
        _detailLabel.disableAt=YES;
        _detailLabel.disablePhoneNumber=YES;
        _detailLabel.disablePoundSign=YES;
        //        _detailLabel.disableEmoji=YES;
        
        _detailLabel.lineBreakMode=NSLineBreakByCharWrapping;
        _detailLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        _detailLabel.customEmojiPlistName = @"expressionImage_custom.plist";
        //禁用单击事件.
        _detailLabel.userInteractionEnabled=NO;
        _tipImage=[[UIImageView alloc]initWithFrame:CGRectMake(72, 38+2, 12, 12)];

        _lineview=[[UIView alloc]initWithFrame:CGRectMake(72, 66.5, 248, 0.5)];
        _lineview.backgroundColor=[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:0.8];
        [bgView addSubview:_lineview];
        [bgView addSubview:_detailLabel];
        [bgView addSubview:_tipImage];
    }
    return self;
}



-(void)creatNumberHead{
    UIImage * defaultImage = [UIImage imageNamed:default_headImage];
    CGRect headFrame =CGRectMake(10, 10, 44, 44);
    CGRect headFrame1 = _headImage.frame;
    
    int imageCount=imageCount=self.memberList.count;;
    if(imageCount>3)
        imageCount=3;
    for (int i=0; i<imageCount; i++) {
        CGRect frame=CGRectZero;
        if (imageCount>=9) {
            CGFloat width=headFrame.size.width/3;
            CGFloat height=headFrame.size.height/3;
            frame=CGRectMake(width*(i%3), height*(i/3), width, height);
        }else{
            switch (imageCount) {
                case 3:
                {if (i == 0) {
                    frame = CGRectMake(12, 0, 20, 20);
                }
                else if (i == 1){
                    frame = CGRectMake(2, 18, 20, 20);
                }
                else if (i == 2){
                    frame = CGRectMake(22, 18, 20, 20);
                }

                    break;
                }
                case 4:
                {
                    CGFloat width=headFrame.size.width/2;
                    CGFloat height=headFrame.size.height/2;
                    frame=CGRectMake(width*(i%2), height*(i/2), width, height);
                    break;
                }
                default:
                {
                    int firstCount=imageCount%3;
                    int extraCount=imageCount/3;
                    int rowCount=extraCount+(firstCount>0?1:0);
                    int colCount=extraCount>0?3:firstCount;
                    CGFloat width=headFrame1.size.width/colCount;
                    CGFloat height=headFrame1.size.height/rowCount;
                    if (width<height) {
                        height=width;
                    }
                    CGFloat xOffset=0;
                    CGFloat yOffset=(headFrame1.size.height-height*rowCount)*0.5;
                    int xIndex=0;
                    int yIndex=0;
                    if (i<firstCount) {
                        xIndex=i;
                        xOffset=(headFrame1.size.width-firstCount*width)*0.5;
                    }else{
                        int addCount=0;
                        if (firstCount!=0) {
                            addCount=colCount-firstCount;
                        }
                        xIndex=(i+addCount)%colCount;
                        yIndex=(i+addCount)/colCount;
                    }
                    frame=CGRectMake(width*xIndex+xOffset*2, height*yIndex+yOffset, width, height);
                    break;
                }
            }
        }
        
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = frame.size.width * 0.5;
        if (message.chatType==1) {
            EmployeeModel *em=[message.roomInfoModel.roomMemberList objectAtIndex:i];
            [imageView setImageWithURL:[NSURL URLWithString:em.avatarimgurl] placeholderImage:defaultImage];
        }
        if (message.chatType==3) {
            EmployeeModel * qunFaem=[self.memberList objectAtIndex:i];
            [imageView setImageWithURL:[NSURL URLWithString:qunFaem.avatarimgurl] placeholderImage:defaultImage];
        }
        
        imageView.frame = frame;
        [_headImage addSubview:imageView];
    }
}

-(void)addImageToHeadImage{
    
    _barB.remindNum =message.unReadCount;
    BOOL isPublic=NO;
    if (message.chatType==1) {
        _nameLabel.text=message.roomInfoModel.roomName;
        if (_nameLabel.text.length<=0) {
            _nameLabel.text=message.toUserId;
        }
        self.memberList=message.roomInfoModel.roomMemberList;
        [self creatNumberHead];
    }else if(message.chatType==0){
        UIImage * defaultImage = [UIImage imageNamed:default_headImage];
        _nameLabel.text = message.memberInfo.name;
        [_headImage setImageWithURL:[NSURL URLWithString:message.memberInfo.avatarimgurl] placeholderImage:defaultImage];
        _Message_Unread = [NSString stringWithFormat:@"%d",message.unReadCount];
        
        [self Message_Unread_Methods];
        
    }else if (message.chatType==3){
        NSArray *tempArray=[message.toUserId componentsSeparatedByString:@";"];
        NSMutableArray *emArray=[[NSMutableArray alloc] init];
        NSMutableString *tempStr=[[NSMutableString alloc] init];
        for (NSString *imacc in tempArray) {
            EmployeeModel *em=[SqlAddressData queryMemberInfoWithImacct:imacc];
            if (em.imacct) {
                [emArray addObject:em];
                [tempStr appendFormat:@"%@,",em.name];
            }
        }
        _nameLabel.text=[tempStr substringToIndex:tempStr.length-1];
        self.memberList=emArray;
        [self creatNumberHead];
    }else if(message.chatType==2){
        _nameLabel.text = @"公众号";
        isPublic=YES;
        if (message.publicModelArray) {
            [_headImage setImage:[UIImage imageNamed:@"ads_icon_rss"]];
        }else{
            [_headImage setImageWithURL:[NSURL URLWithString:message.publicModel.logo] placeholderImage:defaultHeadImage];
        }
    }else if(message.chatType == 4)
    {
        _nameLabel.text = @"公告";
        [_headImage setImage:[UIImage imageNamed:@"icon_announcement"]];
        [starimageview setHidden:NO];
    }else if(message.chatType ==5){
        _nameLabel.text = @"和企录团队";
        [starimageview setFrame:CGRectMake(72+35+35+25, 14.5, 15, 15)];
        [_headImage setImage:[UIImage imageNamed:@"msg_icon_team"]];
        [starimageview setHidden:NO];
    }
    
    switch (message.lastMessageType) {
        case 0:{
            [_detailLabel setEmojiText:isPublic?[NSString stringWithFormat:@"%@:%@",message.publicModel.name,message.lastMessage]:message.lastMessage];
            break;
        }
        case 1:
        {
            _detailLabel.text =isPublic?[NSString stringWithFormat:@"%@:[图片]",message.publicModel.name]:@"[图片]";
            break;
        }
        case 3:
        {
            NSError *error=nil;
            NSXMLElement *x_parse=[[NSXMLElement alloc] initWithXMLString:message.lastMessage error:&error];
            
            if (error) {
                DDLogInfo(@"解析出错,error:%@",error);
            }else{
                NSArray *articleArray=[[x_parse elementForName:@"article"] elementsForName:@"mediaarticle"];
                NSXMLElement *dan_x=articleArray[0];
                
                NSString *title = [[dan_x elementForName:@"title"] stringValue];
  
                if(![title length])
                {
                    _detailLabel.text=[NSString stringWithFormat:@"%@:%@",message.publicModel.name,@""];

                }else
                {
                    _detailLabel.text=[NSString stringWithFormat:@"%@:%@",message.publicModel.name,title];
                }
//                _detailLabel.text=[[dan_x elementForName:@"title"] stringValue];
            }
            
            break;
        }
        case 2:
        {
            _detailLabel.text =isPublic?[NSString stringWithFormat:@"%@:[声音]",message.publicModel.name]:@"[声音]";
            break;
        }
        case 7:
        {
            _detailLabel.text=message.lastMessage;
            break;
        }
        case 4:{
            _detailLabel.text=isPublic?[NSString stringWithFormat:@"%@:[视频]",message.publicModel.name]:@"[视频]";
            break;
        }
        case 5:{
            [_detailLabel setEmojiText:[NSString stringWithFormat:@"[草稿]%@",message.lastMessage]];
            break;
        }
        case 9:{
            _tipImage.image=[UIImage imageNamed:@"icon_vedio_small"];
             _detailLabel.text=[NSString stringWithFormat:@"    %@",message.lastMessage];
            break;
        }
        case 10:
        {
            _tipImage.image=[UIImage imageNamed:@"icon_phone_small"];
            _detailLabel.text=[NSString stringWithFormat:@"    %@",message.lastMessage];
            break;
        }
        default:
            break;
    }
    
    NSArray * array = [message.lastTime componentsSeparatedByString:@" "];
    NSArray * dateArray = [array[0] componentsSeparatedByString:@"-"];
    
    NSArray * timeArray =array.count>1?[array[1] componentsSeparatedByString:@":"]:nil;
    
    NSString * month = dateArray[1];
    NSString * day = dateArray[2];
    
    NSString * hour = timeArray?timeArray[0]:@"";
    NSString * minute = timeArray?timeArray[1]:@"";
    
    NSString *nowDateStr=[[NSDate date] nowDateStringWithFormatter:@"YYYY-MM-dd"];
    
    if ([nowDateStr isEqualToString:array[0]]) {
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@",hour,minute];
    }else{
        _timeLabel.text = [NSString stringWithFormat:@"%@月%@日",month,day];
    }
    
    if (message.priority==1) {
        bgView.backgroundColor=[UIColor colorWithRed:0.965 green:0.960 blue:0.980 alpha:1.000];
    }
    
}

- (void)Message_Unread_Methods {
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    //创建发布内容
    NSDictionary*data=@{@"product":_Message_Unread};
    DDLogCInfo(@"_Message_Unread：%@",data);
    NSNotification*notificatione=[NSNotification notificationWithName:notificationMessage object:nil userInfo:data];
    //通知中心发送广播
    [center postNotification:notificatione];
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
