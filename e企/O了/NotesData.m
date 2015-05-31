//
//  NotesData.m
//  O了
//
//  Created by 化召鹏 on 14-2-9.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NotesData.h"

@implementation NotesData
-(id)initWihtMessageUuid:(NSString *)uuid content:(NSString *)content fromUserName:(NSString *)fromUserName fromUserId:(NSString *)fromUserId typeMessage:(NSString *)typeMessage serverTime:(NSString *)serverTime{
    self=[super init];
    if (self) {
        self.contentsUuid=uuid;
        self.sendContents=content;
        
        self.fromUserName=fromUserName;
        self.fromUserId=fromUserId;
        self.typeMessage=typeMessage;
        self.serverTime=serverTime;
    }
    return self;
}

-(id)initWihtMessageUuid:(NSString *)uuid content:(NSString *)content fromUserName:(NSString *)fromUserName fromUserId:(NSString *)fromUserId typeMessage:(NSString *)typeMessage serverTime:(NSString *)serverTime middleLink:(NSString *)middleLink originalLink:(NSString *)originalLink smallLink:(NSString *)smallLink imageName:(NSString *)imageName imagePath:(NSString *)imagePath imageWidth:(int)imageWidth imageHeight:(int)imageHeight{
    
    self=[super init];
    if (self) {
        self.contentsUuid=uuid;
        self.sendContents=content;
        
        self.fromUserName=fromUserName;
        self.fromUserId=fromUserId;
        self.typeMessage=typeMessage;
        self.serverTime=serverTime;
        
        ImageChatData *imgData=[[ImageChatData alloc] init];
        imgData.middleLink=middleLink;
        imgData.originalLink=originalLink;
        imgData.smallLink=smallLink;
        imgData.imageName=imageName;
        imgData.imagePath=imagePath;
        imgData.imagewidth=imageWidth;
        imgData.imageheight=imageHeight;
        self.imageCHatData=imgData;
    }
    return self;
}
-(id)initWihtMessageUuid:(NSString *)uuid content:(NSString *)content fromUserName:(NSString *)fromUserName fromUserId:(NSString *)fromUserId typeMessage:(NSString *)typeMessage serverTime:(NSString *)serverTime voicePath:(NSString *)voicePath voiceUrl:(NSString *)voiceUrl voiceLength:(NSString *)voiceLength voiceName:(NSString *)voiceName{
    self=[super init];
    if (self) {
        self.contentsUuid=uuid;
        self.sendContents=content;
        
        self.fromUserName=fromUserName;
        self.fromUserId=fromUserId;
        self.typeMessage=typeMessage;
        self.serverTime=serverTime;
        
        ChatVoiceData *voiceData=[[ChatVoiceData alloc] init];
        self.chatVoiceData=voiceData;
        self.chatVoiceData.voiceUrl=voiceUrl;
        self.chatVoiceData.voicePath=voicePath;
        self.chatVoiceData.voiceLenth=voiceLength;
        self.chatVoiceData.voiceName=voiceName;
    }
    return self;
}

@end
