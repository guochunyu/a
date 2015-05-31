//
//  MessageModel.m
//  ChatDemo
//

//

#import "MessageModel.h"
#import "NSData+Base64.h"
#import "XMPPMessage.h"
#import "QFXmppManager.h"
#import "NSXMLElement+XEP_0203.h"
#import "VoiceConverter.h"

@implementation MessageModel

- (id)init
{
    if(self = [super init])
    {
        self.isOffline  = NO;
        _purpose        = 0;
    }
    return self;
}

- (UIImage *) image {
    // msg 转化成nsdata-->uiimage
    
    if (self.msg.length < 1000) return nil;
    
    NSData *d = [NSData dataFromBase64String:self.msg];
    if (d == nil) return nil;
    UIImage *img = [[UIImage alloc] initWithData:d];
    return img;
}

+ (id)messageModelWithXMPPMessage:(XMPPMessage *)message
{
    MessageModel *mm = [[MessageModel alloc] initWithXMPPMessage:message];
    return mm;
}

- (id)initWithXMPPMessage:(XMPPMessage *)message
{
    if (self = [super init]) {        
        BOOL isOffLineMessage   = [message wasDelayed];
        NSString *messageId     = [message elementID];
        NSString *chatType      = [message type];
        if ([chatType isEqualToString:@"chat"] || [chatType isEqualToString:@"groupchat"]) {
            // 普通消息.
            
            NSString *from  = nil;
            NSString *to    = [[[message to] bare] deleteOpenFireName];
            if ([chatType isEqualToString:@"chat"]) {
                //单聊
                self.chatType   = 0;
                from            = [[[message from] bare] deleteOpenFireName];
                to              = from;
            }
            else if ([chatType isEqualToString:@"groupchat"]) {
                //群聊
                self.chatType   = 1;
                
                from            = [[[message from] resource] deleteOpenFireName];
                NSRange range   = [from rangeOfString:@"_"];
                if(range.location == NSNotFound) {
                    from = [NSString stringWithFormat:@"%@_%@",
                            from,
                            [[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                }
                
                to                          = [[[message from] bare] deleteOpenFireName];
                NSXMLElement *messageExten  = [message elementForName:@"x"];
                NSString *exten             = [messageExten xmlns];
                
                //NSLog(@"%@",exten);
                if([exten isEqualToString:@"jabber:x:MemberUpdatedMessageExtention"]) {
                    // 新建群消息.
                    
                    //NSLog(@"收到新建群消息");
                    NSString *roomJid   = [[[message from]user]deleteOpenFireName];
                    NSString *nickName  = [[message from]resource];
                    NSRange range       = [nickName rangeOfString:@"_"];
                    if(range.location == NSNotFound) {
                        nickName = [NSString stringWithFormat:@"%@_%@",
                                    nickName,
                                    [[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                    }
                    NSString *members               = [[messageExten elementForName:@"members"]stringValue];
                    NSArray *memberArray            = [members componentsSeparatedByString:@";"];
                    NSMutableString *memberNameStr  = [[NSMutableString alloc] init];
                    NSDate *date                    = [NSDate date];
                    NSString *nowTimeStr            = [date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    
                    self.chatType       = 1;
                    self.fileType       = 7;
                    self.receivedTime   = nowTimeStr;
                    self.messageID      = messageId;
                    self.to             = [[[message from]user]deleteOpenFireName];
                    self.thread         = @"";
                    self.roomInfo       = [[message from]full];
                    self.from           = nickName;
                    NSString *myImacct = [ConstantObject sharedConstant].userInfo.imacct;
                    range = [myImacct rangeOfString:E_APP_KEY];
                    if(!(range.location == NSNotFound))
                    {
                        myImacct = [myImacct stringByReplacingOccurrencesOfString:E_APP_KEY withString:@""];
                    }
                    if([nickName isEqualToString:myImacct]) {
                        
                        for(NSString *imacct in memberArray) {
                            if([imacct isEqualToString:myImacct])
                                continue;
                            NSString *memImacct = imacct;
                            NSRange range       = [imacct rangeOfString:@"_"];
                            if(range.location == NSNotFound) {
                                memImacct = [NSString stringWithFormat:@"%@_%@",
                                             imacct,
                                             [[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                            }
                            
                            NSString *name  = [SqlAddressData queryMemberInfoWithImacct:memImacct].name;
                            [memberNameStr appendFormat:@"%@;", name];
                        }
                        NSString *memberName    = [memberNameStr substringToIndex:memberNameStr.length-1];
                        NSString *msg           =[NSString stringWithFormat:@"你邀请%@加入了群聊", memberName];
                        self.msg    = msg;
                        self.from   = [ConstantObject sharedConstant].userInfo.imacct;
                        
                        return self;
                    }
                    else {
                        NSString *roomName              = [[messageExten elementForName:@"groupName"] stringValue];
                        NSString *name                  = [SqlAddressData queryMemberInfoWithImacct:nickName].name;
                        NSMutableString *roommemberList = [[NSMutableString alloc]init];
                        for(NSString *imacct in memberArray) {
                            NSString *memImacct = imacct;
                            NSRange range       = [imacct rangeOfString:@"_"];
                            if(range.location == NSNotFound) {
                                memImacct   = [NSString stringWithFormat:@"%@_%@",
                                               imacct,
                                               [[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                            }
                            [roommemberList appendFormat:@"%@;", memImacct];
                            if([memImacct isEqualToString:nickName])
                                continue;
                            
                            NSString *memName   = [SqlAddressData queryMemberInfoWithImacct:memImacct].name;
                            [memberNameStr appendFormat:@"%@;", memName];
                        }
                        NSString *memberName        = [memberNameStr substringToIndex:memberNameStr.length-1];
                        NSString *roommemListstr    = [roommemberList substringToIndex:roommemberList.length -1];
                        RoomInfoModel *roomInfo     = [[RoomInfoModel alloc] init];
                        roomInfo.roomName           = roomName;
                        roomInfo.roomJid            = roomJid;
                        roomInfo.roomMemberListStr  = roommemListstr;
                        [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:roomInfo];
                        
                        NSString *msg   = [NSString stringWithFormat:@"%@邀请%@加入了群聊", name, memberName];
                        self.msg        = msg;
                        //NSLog(@"$$$571$$$%@", msg);
                    }
                    return self;
                }
                else if ([exten isEqualToString:XMPPMUCUserNamespace]) {
                    // 其他群配置消息.
                    
                    //NSLog(@"群相关操作");
                    NSString *roomJid   = [[[message from] user]deleteOpenFireName];
                    NSString *nickName  = [[message from] resource];
                    NSRange range       = [nickName rangeOfString:@"_"];
                    if(range.location == NSNotFound) {
                        nickName = [NSString stringWithFormat:@"%@_%@",
                                    nickName,
                                    [[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                    }
                    NSString *members               = [[messageExten elementForName:@"members"] stringValue];
                    NSArray *memberArray            = [members componentsSeparatedByString:@";"];
                    NSMutableString *memberNameStr  = [[NSMutableString alloc]init];
                    NSDate *date                    = [NSDate date];
                    NSString *nowTimeStr            = [date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    
                    self.chatType       = 1;
                    self.fileType       = 7;
                    self.receivedTime   = nowTimeStr;
                    self.messageID      = messageId;
                    self.to             = [[[message from] user]deleteOpenFireName];
                    self.thread         = @"";
                    self.roomInfo       = [[message from] full];
                    self.from           = nickName;
                    
                    NSString *affiliation = [[messageExten
                                              elementForName:@"item"]
                                             attributeStringValueForName:@"affiliation"];
                    if([affiliation isEqualToString:@"owner"])
                    {
                        return nil;
                    }

                    if([affiliation isEqualToString:@"none"]) {
                        if(![nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
                            //NSString *roomName = [[messageExten elementForName:@"groupName"]stringValue];
                            NSString *name  = [SqlAddressData queryMemberInfoWithImacct:nickName].name;
                            NSString *msg   =[NSString stringWithFormat:@"%@退出了群聊",name];
                            self.msg        = msg;
                        }
                        return self;
                    }
                    else if([affiliation isEqualToString:@"member"]) {
                        if([nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
                            NSString *name              = [SqlAddressData queryMemberInfoWithImacct:nickName].name;
                            NSXMLElement *addMemberitem = [messageExten elementForName:@"item"];
                            NSString *imacct            = [[[addMemberitem
                                                             attributeForName:@"jid"]
                                                            stringValue]
                                                           deleteOpenFireName];
                            NSString *membername        = [SqlAddressData queryMemberInfoWithImacct:imacct].name;
                            NSString *msg               =[NSString stringWithFormat:@"你邀请了%@加入群聊",membername];
                            self.msg                    = msg;
                        }
                        else {
                            NSString *name              = [SqlAddressData queryMemberInfoWithImacct:nickName].name;
                            NSXMLElement *addMemberitem = [messageExten elementForName:@"item"];
                            NSString *imacct            = [[[addMemberitem
                                                             attributeForName:@"jid"]
                                                            stringValue]
                                                           deleteOpenFireName];
                            NSString *membername        = [SqlAddressData queryMemberInfoWithImacct:imacct].name;
                            
                            NSString *msg   =[NSString stringWithFormat:@"%@邀请%@加入了群聊", name, membername];
                            self.msg        = msg;
                        }
                        return self;
                    }
                }
                else if ([exten isEqualToString:@"set-natural-name"]) {
                    // 其他群配置消息.
                    
                    //NSLog(@"群相关操作");
                    NSString *roomJid       = [[[message from]user]deleteOpenFireName];
                    NSString *newRoomName   = [messageExten stringValue];
                    NSString *nickName      = [[message from]resource];
                    NSRange range           = [nickName rangeOfString:@"_"];
                    if(range.location == NSNotFound) {
                        nickName = [NSString stringWithFormat:
                                    @"%@_%@",
                                    nickName,
                                    [[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                    }

                    NSString *name = [SqlAddressData queryMemberInfoWithImacct:nickName].name;
                    NSDate *date            = [NSDate date];
                    NSString *nowTimeStr    = [date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                    
                    self.chatType       =1;
                    self.fileType       =7;
                    self.receivedTime   =  nowTimeStr;
                    self.messageID      = messageId;
                    self.to             = [[[message from] user]deleteOpenFireName];
                    self.thread         = @"";
                    self.roomInfo       = [[message from] full];
                    self.from           = nickName;
                    NSString* msg       = [NSString stringWithFormat:@"%@修改群名称为:%@", name, newRoomName];
                    self.msg            = msg;
                    
                    return self;
                }
            }
            else {
                self.chatType=2;
            }
            
            if (from.length > 0) {
                NSArray *fromArray  = [from componentsSeparatedByString:@"_"];
                if (fromArray.count > 1) {
                    NSString *from_GID  =[fromArray objectAtIndex:1];
                    NSString *myGidStr  =[[NSUserDefaults standardUserDefaults] objectForKey:myGID];
                    if (![from_GID isEqualToString:myGidStr]) {
                        self = nil;
                        return self;
                    }
                }
            }
            
            NSString *body              = [message body];
            NSXMLElement *file_element  = [message elementForName:@"x" xmlns:@"jabber:x:fileMessageExtention"];
            NSString *fileTypeStr       = [[file_element elementForName:@"fileType"] stringValue];
            if (fileTypeStr.length <= 0) {
                //普通文本消息
                self.fileType=0;
            }
            else {
                int fileType    = [fileTypeStr intValue];
                switch (fileType) {
                    case 1:
                    {
                        //图片消息
                        self.fileType   = 1;
                        
                        NSString *middle_link   = [[file_element elementForName:@"middle_link"] stringValue];
                        NSString *original_link = [[file_element elementForName:@"original_link"] stringValue];
                        NSString *small_link    = [[file_element elementForName:@"small_link"] stringValue];
                        NSString *fileName      = [[file_element elementForName:@"fileName"] stringValue];
                        NSString *imagewidth    = [[file_element elementForName:@"width"] stringValue];
                        NSString *imageheight   = [[file_element elementForName:@"height"] stringValue];
                        
                        ImageChatData *imgData  = [[ImageChatData alloc] init];
                        imgData.middleLink      = middle_link;
                        imgData.originalLink    = original_link;
                        imgData.imageName       = fileName;
                        imgData.imagewidth      = [imagewidth integerValue];
                        imgData.imageheight     = [imageheight integerValue];
                        imgData.smallLink       = small_link;
                        self.imageChatData=imgData;
                        
                        break;
                    }
                    case 2:
                    {
                        //声音消息
                        self.fileType   = 2;
                        
                        ChatVoiceData *chatVoiceData    = [[ChatVoiceData alloc] init];
                        chatVoiceData.voiceUrl          = [[file_element elementForName:@"original_link"] stringValue];
                        chatVoiceData.voiceName         = [[file_element elementForName:@"fileName"] stringValue];
                        chatVoiceData.voiceLenth        = [[file_element elementForName:@"duration"] stringValue];
                        NSArray *voiceNameArray         = [[chatVoiceData.voiceName
                                                            stringByDeletingPathExtension]
                                                           componentsSeparatedByString:@"_"];
                        NSString *voiceLength           = voiceNameArray[1];
                        chatVoiceData.voiceLenth        = voiceLength;
                        self.chatVoiceData=chatVoiceData;
                        self.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,self.chatVoiceData.voiceName];
                        [self messageManage];
                        
                        break;
                    }
                    case 6:
                    {
                        self.fileType   = 0;
                        
                        NSString *fileName  = [[file_element elementForName:@"fileName"] stringValue];
                        body                = [NSString stringWithFormat:@"[收到文件]:%@(iOS版本暂无文件传输功能)", fileName];
                        
                        break;
                    }
                    default:
                        self.fileType   = 3;
                        break;
                }
            }
            
            
            /**
             *  判断是否是离线消息,如果是,跳过
             */
            //BOOL isOffLineMessage=[message wasDelayed];
            
            if (isOffLineMessage) {
                // 离线消息.
                
                //[NSThread sleepForTimeInterval:0.1];
                NSDate *date                = [message delayedDeliveryDate];
                NSString *receiveTimeStr    = [date stringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                self.receivedTime           = receiveTimeStr;
                //NSLog(@"收到%@的时间%@",body,receiveTimeStr);
            }
            else {
                NSDate *date            = [NSDate date];
                NSString *nowTimeStr    = [date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                self.receivedTime       = nowTimeStr;
                //NSLog(@"收到%@的时间%@",body,nowTimeStr);
            }
            
            if ([from isEqualToString:to]) {
                //自己给自己发送的消息
                messageId   = [NSString stringWithFormat:@"self_%@", messageId];
            }
            self.messageID  = messageId;
            
            NSString *str   = body;
            for(int i=0; i<faceExpressionArray.count; i++){
                str = [str stringByReplacingOccurrencesOfString:faceExpressionArray[i] withString:faceNameArray[i]];
            }
            self.msg    = str;
            self.from   = from; // 收到的消息,to和from都是from.
            self.to     = to;   // 收到的消息,to和from都是from.
            NSString *theradStr = [message thread];
            self.thread         = theradStr ? theradStr : @"";
        }
    }
    return self;
}

#pragma  mark -语音处理
-(void)messageManage
{
    [[DownManage sharedDownload] downloadWhithUrl:self.chatVoiceData.voiceUrl fileName:self.chatVoiceData.voiceName type:2 downFinish:^(NSString *filePath) {
        
        NSString *fileExtention = [filePath pathExtension];
        if([fileExtention isEqualToString:@"amr"])
        {
            [self voiceAmrToWavMm:filePath];
        }else
        {
            self.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,self.chatVoiceData.voiceName];
        }
        
    } downFail:^(NSError *error) {
        
    }];
}

- (void)voiceAmrToWavMm:(NSString *)filePath
{
    NSString *wavfilePath=[[NSString stringWithFormat:@"%@%@",voice_path,self.chatVoiceData.voiceName] filePathOfCaches];
    [VoiceConverter amrToWav:[filePath filePathOfCaches] wavSavePath:wavfilePath];
    
    self.chatVoiceData.voicePath=[NSString stringWithFormat:@"%@%@",voice_path,self.chatVoiceData.voiceName];
}


@end
