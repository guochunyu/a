//
//  MLChatView.m
//  O了
//
//  Created by roya-7 on 14-9-16.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "MLChatView.h"


#define labwidth 184
@implementation MLChatView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithData:(NotesData *)notesData :(MenuButton *)bubble :(BOOL)isMyself :(UIView *)bgView :(UIButton *)headImage :(UIView *)activityView :(UILabel *)headNameLabel :(UIImageView *)headImageView :(ChatView *)returnView :(MLEmojiLabel *)label isRoom:(BOOL)isRoom{
    self=[super init];
    if (self) {
        [self getChatView:notesData :bubble :isMyself :bgView :headImage :activityView :headNameLabel :headImageView :returnView :label isRoom:isRoom];
    }
    return self;
}

-(void)getChatView:(NotesData *)notesData :(MenuButton *)bubble :(BOOL)isMyself :(UIView *)bgView :(UIButton *)headImage :(UIView *)activityView :(UILabel *)headNameLabel :(UIImageView *)headImageView :(ChatView *)returnView :(MLEmojiLabel *)label isRoom:(BOOL)isRoom{
    
    //创建一个字体大小，目的是计算字符串在本字体大小小的宽高
    UIFont *font=[UIFont systemFontOfSize:14];
    //constrained强迫
    //获得字符串 在CGSizeMake(150, 1000)区域内的宽高，注意：这个范围必须能足够大 能装下所有的字符串
    //UILineBreakModeCharacterWrap指定换行模式为  字符 换行，注意：高低版本所用的枚举不同  低版本：UI 高版本是 NS
    NSString *text=notesData.sendContents;
    text=[text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    //在前面的限制条件下创建一个 正好能装下 字符串的 label
    //图文混排
    
    label.frame=CGRectMake(0, 0, labwidth, 1000);
    label.numberOfLines=0;
    label.font=font;
    label.nd=notesData;
    label.backgroundColor=[UIColor clearColor];
    label.lineBreakMode=NSLineBreakByCharWrapping;
    
    //这两个顺序好像不能调换...[]
    label.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";

    label.customEmojiPlistName = @"expressionImage_custom.plist";
    [label setEmojiText:text];
    [label sizeToFit];
    CGSize size1=label.frame.size;
    //设置气泡的大小，要略微比label大一些
//    bubble.frame=CGRectMake(0, 0, size1.width+37, size1.height+24);
    int labelTopMargin = 12;//label距气泡上边距
    int labelLeftmargin;//label距气泡左边距
    int labelRightmargin;//label距气泡右边距
    int bubbletoleft;
    int bubbletotop;
    //根据不同的人发的信息  来设置view的位置和大小
    if (isMyself) {
        bubbletoleft=320-(12+36+3)-size1.width-23-14;//23=bubbleWargin+labeLeftlMargin
        bubbletotop=6;//|-d-气泡
        labelLeftmargin=14;
        labelRightmargin=23;
        label.textColor=[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
    }else{
        bubbletoleft=12+36+3;//|-d-头像w-d-气泡
        bubbletotop=6+10+5;//|-d-名字-d-气泡
        labelLeftmargin=23;
        labelRightmargin=16.5;
        if(!headNameLabel.text){
            bubbletotop=6;
        }
    }
    bgView.frame=CGRectMake(0, 0, 320, size1.height+labelTopMargin*2+bubbletotop+6);
    bubble.frame=CGRectMake(bubbletoleft, bubbletotop, size1.width+labelRightmargin+labelLeftmargin, size1.height+labelTopMargin*2);
    UIImageView *taskImgView = [[UIImageView alloc] init];
    if (isMyself) {
        taskImgView.frame = CGRectMake(0, 0, 25, 25);
        taskImgView.image = [UIImage imageNamed:@"icon_task_left"];
    }else {
        taskImgView.frame = CGRectMake(size1.width+labelRightmargin+labelLeftmargin-25, 0, 25, 25);
        taskImgView.image = [UIImage imageNamed:@"icon_task_right"];
    }
    if (notesData.isTask == 2) {
        taskImgView.hidden = NO;
    }else {
        taskImgView.hidden = YES;
    }
    [bubble addSubview:taskImgView];
    label.frame=CGRectMake(labelLeftmargin, labelTopMargin, size1.width, size1.height);
    if (isMyself) {
        if (activityView==nil) {
            //如果没有传进来这个view，创建一个
            activityView=[[UIView alloc] init];
            [activityView setBackgroundColor:[UIColor clearColor]];
        }
        [bgView addSubview:activityView];
        activityView.frame=CGRectMake(bubbletoleft-20-8, bgView.frame.size.height/2-8, 15, 15);
        
        if ([notesData.isSend isEqualToString:@"2"]) {
//            发送失败
            MenuButton *sendFailedButt=[MenuButton buttonWithType:UIButtonTypeCustom];
            sendFailedButt.frame=CGRectMake(0, 0, 15, 15);
            sendFailedButt.nd=notesData;
//          sendFailedButt.tag=sendFailedButt_tag+[self.chatNotesDataArray indexOfObject:notesData];
//            [sendFailedButt addTarget:self action:@selector(sendMessageAgain:) forControlEvents:UIControlEventTouchUpInside];
            [sendFailedButt setImage:[UIImage imageNamed:@"icon_tip"] forState:UIControlStateNormal];
//          [sendFailedButt setTitle:@"失败" forState:UIControlStateNormal];
            [activityView addSubview:sendFailedButt];
            self.send_Failed_Butt=sendFailedButt;
        }
    }
    [bubble addSubview:label];
    [bgView addSubview:bubble];
    //返回带有气泡和内容的view
    returnView.frame=CGRectMake(0, 0, 320, bgView.frame.size.height);
    [returnView addSubview:bgView];
    [headImage addSubview:headImageView];
    [returnView addSubview:headImage];
    [returnView addSubview:headNameLabel];
    self.chat_View=returnView;
}

@end
