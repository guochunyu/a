//
//  QFXmppManager.m
//  ChatDemo
//

//

#import "QFXmppManager.h"
#import "MessageModel.h"
#import "BulletinModel.h"
#import "TeamMessageModel.h"
#import "NSXMLElement+XEP_0203.h"
#import "NSDate+string.h"
#import "TaskTools.h"
#import "SoundWithMessage.h"
#import "AppDelegate.h"

#define xmpp_queueName "com.eqi.xmppRoomQueue"///<room名字
#define xmpp_queueStream "com.eqi.xmppStreamQueue"///<消息的queue

NSArray *faceNameArray;
NSArray *faceExpressionArray;

@implementation QFXmppManager

static id _s=nil;
+ (id) shareInstance {
    
    
    //    if (_s == nil) {
    //        _s = [[[self class] alloc] init];
    //    }
    
    // 保证线程安全.
    if (nil == _s) {
        @synchronized (self) {
            if (nil == _s) {
                _s = [[self allocWithZone:NULL] init];
            }
        }
    }
    
    return _s;
}

-(void)releaseXmppManager{
    [sendSuccsetodoWaitQueue removeAllObjects];
    if (_s) {
        _s=nil;
    }
}
- (id)init
{
    self = [super init];
    if (self) {
        _currUser = [[UserModel alloc] init];
        _allFriendList = [[NSMutableArray alloc] init];
        _xmppStream = [[XMPPStream alloc] init];
        newRoomListDict=[[NSMutableDictionary alloc] init];
        sendSuccsetodoWaitQueue=[[NSMutableDictionary alloc]init];
        
        faceNameArray=[[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression_custom" ofType:@"plist"]];//表情显示的文本
        faceExpressionArray=[[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression" ofType:@"plist"]];//表情传输文本
        
        queue2 =dispatch_queue_create(xmpp_queueName,DISPATCH_QUEUE_SERIAL); // 串行queue
        
        dispatch_queue_t streamQueue=dispatch_queue_create(xmpp_queueStream, DISPATCH_QUEUE_SERIAL);///<消息的queue
        
        CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        getRoomMessageId=cfuuidString;
        
        //允许后台
        _xmppStream.enableBackgroundingOnSocket = YES;
        
        [_xmppStream setHostName:openfire_ip];
        [_xmppStream setHostPort:openfire_port];
        // 在这里并没有连接....
        [_xmppStream addDelegate:self delegateQueue:streamQueue];
        
        if (!_roomDict) {
            self.roomDict=[[NSMutableDictionary alloc] init];
        }
        //设置断线重连
        XMPPReconnect *xmppReconnet=[[XMPPReconnect alloc] init];
        [xmppReconnet activate:_xmppStream];
        [xmppReconnet addDelegate:self delegateQueue:streamQueue];
    }
    return self;
}
#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"didDetectAccidentalDisconnect : \n %u ", connectionFlags);
    
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    NSLog(@"shouldAttemptAutoReconnect : \n %u ", connectionFlags);

    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *passWord=[userDefaults objectForKey:myPassWord];
    [_xmppStream authenticateWithPassword:passWord error:nil];
    return YES;
}



- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    //断开连接
    DDLogInfo(@"error==%@",error);
    if(error){
        [(AppDelegate *)[UIApplication sharedApplication].delegate timeout];
    }
    
    
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    // 输入密码
    // 给xmppserver/openfire pass
    // state machine状态机
    
    /**
     *  在这里获取openFire的服务器名字
     */
    NSString * openFire_name  = [[sender.rootElement attributeForName:@"from"] stringValue];
    NSLog(@"name:%@",openFire_name);
    openFireNameStr=openFire_name;
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSString *locationName=[userDefaults objectForKey:openfireName];
    
    if (![locationName isEqualToString:openFire_name]){
        //和上次的名字不一样,需要重新登录
        
        [userDefaults setObject:openFire_name forKey:openfireName];
        [userDefaults synchronize];
        isChangeName=YES;
    }
    
    NSError *err = nil;
    if (isInRegisting) {
        // 一旦注册就回到xmppStreamDidRegister
        [_xmppStream registerWithPassword:_currUser.password error:&err];
    } else {
        
        if (isChangeName) {
            
            [self loginUser:_currUser.jidStr withPassword:_currUser.password withCompletion:^(BOOL ret, NSError *err) {
                
            }];
            isChangeName=NO;
        }else{
            
            // 如果对于已经有的用户 这是授权密码
            [_xmppStream authenticateWithPassword:_currUser.password error:&err];
            // 一旦授权完成。。。就会进入密码授权正确
        }
        
    }

}
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
//    NSLog(@"function  %@", NSStringFromSelector(_cmd));
    dispatch_async(dispatch_get_main_queue(), ^{
        if (saveRegCb) {
            saveRegCb(YES, nil);
        }
    });
    
}
/**
 * This method is called if registration fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (saveRegCb) {
            NSError *myerr = [NSError errorWithDomain:error.description code:-1 userInfo:nil];
            saveRegCb(NO, myerr);
        }
    });
    
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error{
    
    DDXMLNode *errorNode = (DDXMLNode *)error;
    //遍历错误节点
    for(DDXMLNode *node in [errorNode children])
    {
        //若错误节点有【冲突】
        if([[node name] isEqualToString:@"conflict"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                MessageModel *mm=[[MessageModel alloc] init];
                mm.fileType=8;
                saveMessageCb(mm);
            });
            
            return;
            
        }
    }
    NSLog(@"登录重复didReceiveError:%@",error);
}
#pragma mark - 登录部分
- (void) loginUser:(NSString *)jid withPassword:(NSString *)pass withCompletion:(void (^) (BOOL ret, NSError *err))cb {
    
    if (!isChangeName) {
        saveLoginCb = [cb copy];
    }
    
    _currUser.jidStr=jid;
    
    isInRegisting = NO;
    // 登录分为2步
    // 1. 给服务器输入账号, 2. 给服务器输入密码
    NSRange range           = [jid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        jid = [NSString stringWithFormat:@"%@%@",jid,E_APP_KEY];
    }

    NSString *myJid=[NSString stringWithFormat:@"%@@%@/Smack",jid,[[NSUserDefaults standardUserDefaults] objectForKey:openfireName]];
//    NSString *myJid=[NSString stringWithFormat:@"%@@116.228.39.242",jid];
    
    _currUser.jid = myJid;
    _currUser.password = pass;
    XMPPJID *myjid = [XMPPJID jidWithString:myJid];
    
    [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"开始登录openfire,帐号:%@,密码:%@",myJid,pass]];
    
    if ([_xmppStream isConnected]) {
        [_xmppStream disconnect];
    }
    [_xmppStream setMyJID:myjid];
    NSError *error = nil;
    // 1. 给server
    [_xmppStream connectWithTimeout:-1 error:&error];
//    BOOL ret = [_xmppStream connectWithTimeout:-1 error:&error];
//    isConnectWithTimeout=ret;
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    
    // 授权成功
//    NSLog(@"function is %@", NSStringFromSelector(_cmd));
    // 可以上线...goonline
    dispatch_async(dispatch_get_main_queue(), ^{
        if (saveLoginCb) {
            saveLoginCb(YES, nil);
        }
    });
    
    // 上线//获取所有好友
    [self goOnline];
    //开启回执
    [self openReceipt];
    if ([ConstantObject sharedConstant].isHaveLoadRoomList==NO) {
        [ConstantObject sharedConstant].isHaveLoadRoomList=YES;
        [self getRoomList];
    }
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:offlineMessagefile];
    
    for(NSArray *array in data)
    {
        [self pullOfflineMessage:[array objectAtIndex:0] URLString:[array objectAtIndex:1]];
        [data removeObject:array];
    }
    [data writeToFile:offlineMessagefile atomically:YES];
}
#pragma mark - 开启消息回执
-(void)openReceipt{
    
    
    NSXMLElement *iq=[NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    [iq addAttributeWithName:@"to" stringValue:_xmppStream.myJID.domain];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"from" stringValue:_xmppStream.myJID.full];
    
    NSXMLElement *request_xml=[NSXMLElement elementWithName:@"request" xmlns:@"urn:cmcc:xmpp:receipts"];
    [iq addChild:request_xml];
    [_xmppStream sendElement:iq];
}
//发送消息回执
/**
 *  发送消息回执
 *
 *  @param messageId received 字段中的 id 要和 messageId 保持一致
 */
-(void)sendMessageReceipt:(NSString *)messageId{
    
//    XMPPMessage *oneMessage = [[XMPPMessage alloc] initWithType:chatTypeStr to:toJid elementID:messageID];
    XMPPMessage *receiptMessage=[[XMPPMessage alloc] initWithName:@"message"];
    [receiptMessage addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    //[receiptMessage addAttributeWithName:@"from" stringValue:_xmppStream.myJID.full];
    [receiptMessage addAttributeWithName:@"to" stringValue:_xmppStream.myJID.domain];
    
    NSXMLElement *received_xml=[NSXMLElement elementWithName:@"received" xmlns:@"urn:cmcc:xmpp:receipts"];
    [received_xml addAttributeWithName:@"id" stringValue:messageId];
    [receiptMessage addChild:received_xml];
    [_xmppStream sendElement:receiptMessage];
    
}

#pragma mark - 获取房间列表
-(void)getRoomList{
//    <iq id='F4Krv-5' to='conference.li726-26' type='get'><query xmlns='http://jabber.org/protocol/disco#items'></query></iq>
    
    NSXMLElement *get=[NSXMLElement elementWithName:@"iq"];
    [get addAttributeWithName:@"id" stringValue:getRoomMessageId];
    [get addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"conference.%@",openFireNameStr]];
    [get addAttributeWithName:@"type" stringValue:@"get"];
    
    NSXMLElement *queryXml=[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    [get addChild:queryXml];
    
    [_xmppStream sendElement:get];
    
}

#pragma mark  - 获取房间名
- (void)getRoomNameWithJid:(NSString *)jid
{
    NSXMLElement *get=[NSXMLElement elementWithName:@"iq"];
    [get addAttributeWithName:@"id" stringValue:[_xmppStream generateUUID]];
    NSRange range           = [jid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        jid = [NSString stringWithFormat:@"%@%@",jid,E_APP_KEY];
    }
    [get addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@conference.%@",jid,openFireNameStr]];
    [get addAttributeWithName:@"type" stringValue:@"get"];
    
    NSXMLElement *queryXml=[NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#info"];
    [get addChild:queryXml];
    [_xmppStream sendElement:get];
}
// IQ Information Query 信息查询
-(void)getAllFriends{
    // KissXML / GDATA
    NSXMLElement *query = [NSXMLElement
        elementWithName:@"query" xmlns:@"jabber:iq:roster"];
    // 用来产生一个节点 <query xmlns="jabber:iq:roster"/>
    // <query xmlns="jabber:iq:roster"></query>
    NSXMLElement *iq = [NSXMLElement
        elementWithName:@"iq"];
    // <iq></iq> = <iq/>
    [iq addAttributeWithName:@"type" stringValue:@"get"];
    // <iq type="get"></iq> = <iq/>
    [iq addChild:query];
    //<iq type="get"><query xmlns="jabber:iq:roster"></query></iq>
    
    // NSXMLElement就是一个节点...
    /*
     <iq type="get">
        <query xmlns="jabber:iq:roster"/>
     </iq>
     */
//    NSLog(@"all friends %@", iq);
    // 传给服务器... 服务器要返回 XML
    [_xmppStream sendElement:iq];
}
/**
 * This method is called if authentication fails.
 **/
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
//    NSLog(@"function is %@", NSStringFromSelector(_cmd));
    if (!isChangeName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (saveLoginCb) {
                saveLoginCb(NO, [NSError errorWithDomain:error.description code:-1 userInfo:nil]);
            }
        });
        
    }
    
}
#pragma mark - 上下线
- (void) goOnline {
//    XMPPPresence *p = [XMPPPresence presenceWithType:@"away"];
    XMPPPresence *p = [XMPPPresence presence];
    [p addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
//    [p addAttributeWithName:@"type" stringValue:@"away"];
    NSXMLElement *element1 = [NSXMLElement elementWithName:@"status" stringValue:@"在线"];
    NSXMLElement *element2 = [NSXMLElement elementWithName:@"priority" stringValue:@"8"];
    NSXMLElement *element3 = [NSXMLElement elementWithName:@"show" stringValue:@"available"];
    [p addChild:element1];
    [p addChild:element2];
    [p addChild:element3];                                                                                                                                                           
    
    //NSLog(@"%@",p);
    [_xmppStream sendElement:p];
}

-(void)goOffline{
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:presence];
    
    [_xmppStream disconnect];
    
}
#pragma mark - 收到消息
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    // 取得第一个节点
    //NSLog(@"iq is %@", [iq description]);

    //NSLog(@"%@",iq);
    NSString *id_str=[iq elementID];
    NSXMLElement *iqExten = [iq elementForName:@"query"];
    NSString *exten = [iqExten xmlns];
    if([exten isEqualToString:@"http://jabber.org/protocol/disco#info"])
    {
        NSXMLElement *identity = [iqExten elementForName:@"identity"];
        NSString *roomName = [[identity attributeForName:@"name"]stringValue];
        NSString *roomJid = [[iq from]user];
        [self getRoomInfo:roomJid name:roomName];
        return YES;
    }

    
    if (getRoomMessageId && [id_str isEqualToString:getRoomMessageId]) {
        [ConstantObject sharedConstant].isHaveLoadRoomList=YES;
        //获取我加入的房间列表成功
        NSXMLElement *queryXml=[iq elementForName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
        
        NSArray *itemsArray=[queryXml elementsForName:@"item"];
//        "<item jid=\"3df4e472-5766-4443-ae1e-b96d8a6fc1d0@conference.li726-26\" name=\"&#x7FA4;\"></item>"
        NSMutableArray *_tempArray=[[NSMutableArray alloc] init];
        NSMutableArray *_tempRoomRrray = [[NSMutableArray alloc]init];
        NSArray *roomArray=[[SqliteDataDao sharedInstanse] queryAllRoomData];
        for (RoomInfoModel *rim in roomArray) {
            [_tempArray addObject:rim.roomJid];
        }
        
        for (NSXMLElement *itemElement in itemsArray) {
            NSString *room_jid=[[[itemElement attributeForName:@"jid"] stringValue] deleteOpenFireName];
            [_tempRoomRrray addObject:room_jid];
            NSString *roomName=[[itemElement attributeForName:@"name"] stringValue];

            if ([_tempArray containsObject:room_jid]) {
                XMPPJID *roomJID = [XMPPJID jidWithString:[self checkRoomJIDString:room_jid]];
                
                //初始化聊天室
                XMPPRoom *_xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:roomJID dispatchQueue:queue2];
                _xmppRoom.roomName = roomName;
                [_xmppRoom activate:_xmppStream];
                [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
                [_roomDict setObject:_xmppRoom forKey:room_jid];

                continue;

            }

            NSLog(@"%@",room_jid);
            [self getRoomInfo:room_jid name:roomName];
//            [NSThread sleepForTimeInterval:0.1];
        }
        
        for(NSString *jid in _tempArray)
        {
            if(![_tempRoomRrray containsObject:jid])
            {
                [[SqliteDataDao sharedInstanse] deleteRoomWithRoomJid:jid];
            }
        }
        itemsArray=nil;
        
        
    }
    NSXMLElement *error_xml=[iq elementForName:@"error"];
    if (error_xml) {
        NSString *error_code=[[error_xml attributeForName:@"code"] stringValue];
    
        NSXMLElement *forbidden=[error_xml elementForName:@"forbidden"];
        if ([error_code isEqualToString:@"403"] && forbidden) {
            NSString *from=[[[iq attributeForName:@"from"] stringValue] deleteOpenFireName];
            [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:from];
            [[SqliteDataDao sharedInstanse] deleteRoomWithRoomJid:from];
        }
    }
    
//    NSLog(@"func %@ IQ %@", NSStringFromSelector(_cmd), iq);
    return YES;
}


- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    DDLogInfo(@"￥￥￥￥￥￥收到消息%@",message);
    NSString *messageId=[message elementID];
    NSString *chatType=[message type];
    
    [self sendMessageReceipt:messageId];
    //如果是回执消息
    NSXMLElement *received=[message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
    if(received){
        [self sendMessagesucceed:message];
        return;
    }

#pragma mark -离线消息推送通知
    NSArray *elementArray = [message elementsForName:@"x"];
    NSXMLElement *messageExten = [elementArray lastObject];
    NSString *exten = [messageExten xmlns];
    NSLog(@"%@",exten);
    if([exten isEqualToString:@"cmcc:offline:pushpull:count"])
    {
        //[self sendMessageReceipt:messageId];
        NSString *to = [[message to]user];
        NSString *from = [[message from]user];
        NSString *count = [messageExten stringValue];
        NSString *guid = [message attributeStringValueForName:@"guid"];
        NSDictionary *parameters;
        NSString *stringURL;
        if([chatType isEqualToString:@"chat"])
        {
            parameters = @{@"to":to,
                         @"from":from,
                           @"begin":guid != nil?guid:@"",
                         @"includebegin":@"1",
                         @"end":@"",
                         @"limit":count,
                         @"direction":@"1"};
            stringURL = [NSString stringWithFormat:@"http://%@:%@/hms/manage/selectchat",hms_ip,HTTP_PORT];

        }else if ([chatType isEqualToString:@"groupchat"])
        {
            parameters = @{@"group":from,
                         @"from":to,
                         @"begin":guid != nil?guid:@"",
                         @"includebegin":@"1",
                         @"end":@"",
                         @"limit":count,
                         @"direction":@"1"};
            stringURL = [NSString stringWithFormat:@"http://%@:%@/hms/manage/selectgroup",hms_ip,HTTP_PORT];

        }
//
//        AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
//                NSString *entity = [parameters JSONString];
//        NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:@"POST" URLString:stringURL parameters:nil error:nil];
//        [request setHTTPBody:[entity dataUsingEncoding:NSUTF8StringEncoding]];
//        [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
//        
//        AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSArray * hisMsgArray=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
//            DDLogInfo(@"%@",hisMsgArray);
//            NSMutableArray *array = [[NSMutableArray alloc]init];
//            for(NSInteger i=hisMsgArray.count-1;i>=0;i--)
//            {
//                NSString *msg = hisMsgArray[i];
//                DDXMLElement *messageXml = [[DDXMLElement alloc]initWithXMLString:msg error:nil];
//                
//                XMPPMessage *message = [XMPPMessage messageFromElement:messageXml];
//                NSTimeInterval receiveTime = [[[message attributeForName:@"recvtimestamp"]stringValue]doubleValue]/1000;
//                NSDate *receiveDate = [NSDate dateWithTimeIntervalSince1970:receiveTime];
//                NSString *receiveTimeStr    = [receiveDate stringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
//                MessageModel *mm = [MessageModel messageModelWithXMPPMessage:message];
//                if(mm == nil)
//                {
//                    continue;
//                }
//                mm.isOffline = YES;
//                if(mm.fileType == 7)
//                {
//                    [self dealRoomConfigMessage:message MessageModel:mm];
//                }else
//                {
//                    mm.receivedTime = receiveTimeStr;
//                }
//                [array addObject:mm];
//            }
//            
//            if([[SqliteDataDao sharedInstanse]insertDataListToMessageData:array])
//            {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (self.receviedGroupManagerMessage) {
//                        self.receviedGroupManagerMessage(array[0]);
//                    }
//                });
//            }
//            
//            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"offlineMessage" ofType:@"plist"];
//            NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
//            NSLog(@"%@", data);
//            
//            //添加一项内容
//            [data addObject:parameters];
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"offlineMessage" ofType:@"plist"];
//            NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
//            NSLog(@"%@", data);
//            
//            //添加一项内容
//            [data addObject:parameters];
//        }];
//        [client.operationQueue addOperation:operation];
//        //client.operationQueue.maxConcurrentOperationCount = 1;
        
        [self pullOfflineMessage:parameters URLString:stringURL];
        return;

    }
    
    NSString *from = [[message from] bare];
    NSRange range=[from rangeOfString:@"pubacct"];
    if (range.length>0) {
        //[self sendMessageReceipt:messageId];
        NSXMLElement *message_x=[message elementForName:@"x" xmlns:@"http://jabber.org/protocol/pubacct"];
        NSArray *message_c=[message_x children];
        NSXMLElement *content_x=message_c[0];
        NSString *xmlStr=[content_x XMLString];
        xmlStr=[xmlStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        xmlStr=[xmlStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        
        NSError *error=nil;
        NSXMLElement *content_message=[[DDXMLElement alloc] initWithXMLString:xmlStr error:&error];
        if (error) {
            NSLog(@"解析出错");
            return;
        }
        DDLogInfo(@"%@",content_message);
        NSString *pushType = [[content_message elementForName:@"msgbiztype"]stringValue];
        if([pushType isEqualToString:@"TASKGROUP_NOTIFY_PUSH"])
        {
            [self dealTaskMessage:message];
            return;
        }
#pragma mark -公告消息处理
        else if([pushType isEqualToString:@"EMS_BIZ_NOTIFY_PUSH"])
        {
            MessageModel *mm = [[MessageModel alloc]init];
            NSString *bulletinID = [[content_message elementForName:@"msgbiztype"]stringValue];
            BulletinModel *bm = [[BulletinModel alloc]initWithMessage:content_message];
            [[SqliteDataDao sharedInstanse]insertDataToBulletinData:bm];
            mm.chatType = 4;
            mm.msg = bm.title;
            mm.fileType = 0;
            mm.from   = bulletinID; // 收到的消息,to和from都是from.
            mm.to     = bulletinID;   // 收到的消息,to和from都是from.
            NSString *theradStr = [message thread];
            mm.thread         = theradStr ? theradStr : @"";
            
            //判断是否是离线消息,如果是,跳过
            
            BOOL isOffLineMessage=[message wasDelayed];
            
            if (isOffLineMessage) {
                //离线消息
                NSDate *date=[message delayedDeliveryDate];
                NSString *receiveTimeStr=[date stringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                mm.receivedTime=receiveTimeStr;
                mm.messageID=bm.bulletinID;
            }else{
                NSDate *date=[NSDate date];
                NSString *nowTimeStr=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                mm.receivedTime=nowTimeStr;
                mm.messageID=bm.bulletinID;
            }
            if (saveMessageCb) {
                saveMessageCb(mm);
            }
            
            return;
        }
        
#pragma -mark 和企录团队消息
        else if ([pushType isEqualToString:@"EEC_DEVTEAM_NOTIFY_PUSH"])
        {
            MessageModel *mm = [[MessageModel alloc]init];
            NSString *teamMessageID = [[content_message elementForName:@"msgbiztype"]stringValue];
            TeamMessageModel *tm = [[TeamMessageModel alloc]initWithMessage:content_message];
            [[SqliteDataDao sharedInstanse]insertDataToTeamMessageModelData:tm];
            mm.chatType = 5;
            mm.teamMsgModel = tm;
            if(tm.notify_fileType == 1)
            {
                mm.msg = tm.notify_summary;
                mm.fileType = 0;
            }else if (tm.notify_fileType == 2)
            {
                mm.msg = @"[图片]";
                mm.fileType = 1;
            }else if (tm.notify_fileType == 3)
            {
                mm.msg = tm.notify_title;
                mm.fileType = 6;
                return;
            }
            mm.from   = @"EEC_DEVTEAM"; // 收到的消息,to和from都是from.
            mm.to     = teamMessageID;   // 收到的消息,to和from都是from.
            NSString *theradStr = [message thread];
            mm.thread         = theradStr ? theradStr : @"";
            
            //判断是否是离线消息,如果是,跳过
            
            BOOL isOffLineMessage=[message wasDelayed];
            
            if (isOffLineMessage) {
                //离线消息
                NSDate *date=[message delayedDeliveryDate];
                NSString *receiveTimeStr=[date stringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                mm.receivedTime=receiveTimeStr;
                mm.messageID=tm.notify_msgid;
            }else{
                NSDate *date=[NSDate date];
                NSString *nowTimeStr=[date nowDateStringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
                mm.receivedTime=nowTimeStr;
                mm.messageID=tm.notify_msgid;
            }
            if (saveMessageCb) {
                saveMessageCb(mm);
            }
            
            return;

        }
#pragma -mark 电话会议状态消息
        
        else if([pushType isEqualToString:@"EAS_CONFPARTNERSSTATUS_DOWN"])
        {
            return;
        }
    }
    
    MessageModel *mm = [MessageModel messageModelWithXMPPMessage:message];
    if(mm == nil)
        return;
    if(mm.chatType == 0 || mm.chatType == 1)
    {
        
        if(mm.fileType == 7)
        {
            [self dealRoomConfigMessage:message MessageModel:mm];
            return;
        }else if ([exten isEqualToString:XMPPMUCUserNamespace])
        {
            NSString *nickName = [[message from]resource];
            NSRange range = [nickName rangeOfString:@"_"];
            if(range.location == NSNotFound)
            {
                nickName = [NSString stringWithFormat:@"%@_%@",nickName,[[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
            }
            NSString *imacct = [ConstantObject sharedConstant].userInfo.imacct;
            range = [imacct rangeOfString:E_APP_KEY];
            if(!(range.location == NSNotFound))
            {
                imacct = [imacct stringByReplacingOccurrencesOfString:E_APP_KEY withString:@""];
            }
            if([nickName isEqualToString:imacct]){
                [self sendMessagesucceed:message];
                return ;
            }
        }


        if (saveMessageCb) {
            saveMessageCb(mm);
        }
        
    }

}

#pragma mark - 拉取离线消息

- (void)pullOfflineMessage:(NSDictionary *)parameters URLString:(NSString*)stringURL
{
    AFHTTPRequestOperationManager *client = [AFHTTPRequestOperationManager manager];
    NSString *entity = [parameters JSONString];
    NSMutableURLRequest *request = [client.requestSerializer requestWithMethod:@"POST" URLString:stringURL parameters:nil error:nil];
    [request setHTTPBody:[entity dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray * hisMsgArray=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        DDLogInfo(@"%@",hisMsgArray);
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for(NSInteger i=hisMsgArray.count-1;i>=0;i--)
        {
            NSString *msg = hisMsgArray[i];
            DDXMLElement *messageXml = [[DDXMLElement alloc]initWithXMLString:msg error:nil];
            
            XMPPMessage *message = [XMPPMessage messageFromElement:messageXml];
            NSTimeInterval receiveTime = [[[message attributeForName:@"recvtimestamp"]stringValue]doubleValue]/1000;
            NSDate *receiveDate = [NSDate dateWithTimeIntervalSince1970:receiveTime];
            NSString *receiveTimeStr    = [receiveDate stringWithFormatter:@"yyyy-MM-dd HH:mm:ss"];
            MessageModel *mm = [MessageModel messageModelWithXMPPMessage:message];
            if(mm == nil)
            {
                continue;
            }
            mm.isOffline = YES;
            if(mm.fileType == 7)
            {
                [self dealRoomConfigMessage:message MessageModel:mm];
            }else
            {
                mm.receivedTime = receiveTimeStr;
            }
            [array addObject:mm];
        }
        
        if([[SqliteDataDao sharedInstanse]insertDataListToMessageData:array])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.receviedGroupManagerMessage) {
                    self.receviedGroupManagerMessage(array[0]);
                }
            });
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:offlineMessagefile];
        NSLog(@"%@", data);
        //添加一项内容
        NSArray *array = [NSArray arrayWithObjects:parameters,stringURL, nil];
        [data addObject:array];
        
        //输入写入
        [data writeToFile:offlineMessagefile atomically:YES];

    }];
    [client.operationQueue addOperation:operation];
    //client.operationQueue.maxConcurrentOperationCount = 1;
}

#pragma mark - 群配置消息处理
- (void)dealRoomConfigMessage:(XMPPMessage *)message MessageModel:(MessageModel *)mm
{
    NSArray *elementArray = [message elementsForName:@"x"];
    NSXMLElement *messageExten;
    if(elementArray){
        NSString *firstExten = [[elementArray objectAtIndex:0] xmlns];
        if([firstExten isEqualToString:@"set-natural-name"] || [firstExten isEqualToString:@"jabber:x:MemberUpdatedMessageExtention"] || [firstExten isEqualToString:XMPPMUCUserNamespace]){
            messageExten = [elementArray objectAtIndex:0];
        }else{
            messageExten = [elementArray lastObject];
        }
    }
    NSString *exten = [messageExten xmlns];
    if([exten isEqualToString:@"jabber:x:MemberUpdatedMessageExtention"])
    {
        NSLog(@"收到新建群消息");
        //新建群消息<x xmlns="http://jabber.org/protocol/muc#user"><item jid="+8618867101716_3388665511#993300vv@li726-26/+8618867101716" affiliation="member" role="participant"/></x>
        NSString *roomJid = [[[message from]user]deleteOpenFireName];
        NSString *nickName = [[message from]resource];
        NSRange range = [nickName rangeOfString:@"_"];
        if(range.location == NSNotFound)
        {
            nickName = [NSString stringWithFormat:@"%@_%@",nickName,[[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
        }
        NSString *members = [[messageExten elementForName:@"members"]stringValue];
        NSArray *memberArray = [members componentsSeparatedByString:@";"];
        NSMutableString *memberNameStr = [[NSMutableString alloc]init];
        if([nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct])
        {
            [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
            [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.receviedGroupManagerMessage) {
                    self.receviedGroupManagerMessage(mm);
                }
            });
            
            
            return;
        }else
        {
            NSString *roomName = [[messageExten elementForName:@"groupName"]stringValue];
            NSMutableString *roommemberList = [[NSMutableString alloc]init];
            for(NSString *imacct in memberArray)
            {
                NSString *memImacct = imacct;
                NSRange range = [imacct rangeOfString:@"_"];
                if(range.location == NSNotFound)
                {
                    memImacct = [NSString stringWithFormat:@"%@_%@",imacct,[[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
                }
                
                [roommemberList appendFormat:@"%@;",memImacct];
                if([memImacct isEqualToString:nickName])
                    continue;
                
                NSString *memName = [SqlAddressData queryMemberInfoWithImacct:memImacct].name;
                [memberNameStr appendFormat:@"%@;",memName];
            }
            NSString *roommemListstr = [roommemberList substringToIndex:roommemberList.length -1];
            RoomInfoModel *roomInfo=[[RoomInfoModel alloc] init];
            roomInfo.roomName=roomName;
            roomInfo.roomJid=roomJid;
            roomInfo.roomMemberListStr=roommemListstr;
            [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:roomInfo];
            
            [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
            [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
            [self getRoomInfo:roomJid name:roomName];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.receviedGroupManagerMessage) {
                    self.receviedGroupManagerMessage(mm);
                }
            });
        }
        return;
        
    }else if ([exten isEqualToString:XMPPMUCUserNamespace])
    {
        NSLog(@"群相关操作");
        //其他群配置消息
        NSString *roomJid = [[[message from]user]deleteOpenFireName];
        NSString *nickName = [[message from]resource];
        NSRange range = [nickName rangeOfString:@"_"];
        if(range.location == NSNotFound)
        {
            nickName = [NSString stringWithFormat:@"%@_%@",nickName,[[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
        }
        
        NSString *affiliation = [[messageExten elementForName:@"item"]attributeStringValueForName:@"affiliation"];
        
        if([affiliation isEqualToString:@"owner"])
        {
            return;
        }else if([affiliation isEqualToString:@"none"])
        {
            if([nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct])
            {
                NSLog(@"自己退出群聊");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.haveleaveRoom) {
                        self.haveleaveRoom(YES);
                    }
                });
            }else
            {
                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
                NSArray *roomArray=[[SqliteDataDao sharedInstanse] queryAllRoomData];
                for (RoomInfoModel *rim in roomArray) {
                    if([roomJid isEqualToString:rim.roomJid])
                    {
                        //                                [self getRoomInfo:roomJid name:rim.roomName];
                        rim.roomMemberListStr = [rim.roomMemberListStr stringByReplacingOccurrencesOfString:nickName withString:@""];
                        rim.roomMemberListStr = [rim.roomMemberListStr stringByReplacingOccurrencesOfString:@";;" withString:@";"];
                        NSMutableArray *memArray = [NSMutableArray arrayWithArray:rim.roomMemberList];
                        [memArray removeObject:[SqlAddressData queryMemberInfoWithImacct:nickName]];
                        rim.roomMemberList = [NSArray arrayWithArray:memArray];
                        
                        [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:rim];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.receviedGroupManagerMessage) {
                                NSLog(@"#####649有人退出群");
                                self.receviedGroupManagerMessage(mm);
                            }else{
                                NSLog(@"#####退群逻辑为空");
                            }
                        });
                        return;
                    }
                }
                
            }
            return;
            
        }else if([affiliation isEqualToString:@"member"])
        {
            if([nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct])
            {
                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.addMemberJidToRoom) {
                        self.addMemberJidToRoom(YES);
                    }
                });
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.receviedGroupManagerMessage) {
                        NSLog(@"####682邀请他人加入群");
                        self.receviedGroupManagerMessage(mm);
                    }
                });
                
                
                return;
            }else
            {
                NSXMLElement *addMemberitem = [messageExten elementForName:@"item"];
                NSString *imacct = [[[addMemberitem attributeForName:@"jid"]stringValue]deleteOpenFireName];
                if([nickName isEqualToString:imacct])
                {
                    return;
                }
                [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
                [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
                [newRoomListDict setObject:mm forKey:mm.to];
                
                NSArray *roomArray=[[SqliteDataDao sharedInstanse] queryAllRoomData];
                for (RoomInfoModel *rim in roomArray) {
                    if([roomJid isEqualToString:rim.roomJid])
                    {
                        [self getRoomInfo:roomJid name:rim.roomName];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.receviedGroupManagerMessage) {
                                NSLog(@"####713邀请他人加入群");
                                self.receviedGroupManagerMessage(mm);
                            }
                        });
                        
                        return;
                    }
                    
                }
                
                [self getRoomNameWithJid:roomJid];
                double delayInSeconds = 2000/1000.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime,dispatch_get_main_queue(), ^{
                    if (self.receviedGroupManagerMessage) {
                        NSLog(@"####728邀请他人加入群");
                        self.receviedGroupManagerMessage(mm);
                    }
                });
                
                //                        dispatch_async(dispatch_get_main_queue(), ^{
                //                            if (self.receviedGroupManagerMessage) {
                //                                self.receviedGroupManagerMessage(mm);
                //                            }
                //                        });
                
                
            }
            return;
            
        }else
        {
            NSString *nickName = [[message from]resource];
            NSRange range = [nickName rangeOfString:@"_"];
            if(range.location == NSNotFound)
            {
                nickName = [NSString stringWithFormat:@"%@_%@",nickName,[[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
            }
            if([nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]){
                [self sendMessagesucceed:message];
                return ;
            }
        }
        
    }else if ([exten isEqualToString:@"set-natural-name"])
    {
        NSLog(@"群相关操作");
        //其他群配置消息
        NSString *roomJid = [[[message from]user]deleteOpenFireName];
        NSString *newRoomName = [messageExten stringValue];
        [[SqliteDataDao sharedInstanse] insertDataToMessageData:mm];
        [[SqliteDataDao sharedInstanse] updateReadStateWithToMessageId:mm.messageID];
        [[SqliteDataDao sharedInstanse] updateRoomInfoWithRoomJid:roomJid RoomName:newRoomName];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.receviedGroupManagerMessage) {
                DDLogInfo(@"修改群名称");
                self.receviedGroupManagerMessage(mm);
            }
            if(self.changeRoomName){
                self.changeRoomName(YES);
            }
        });
        
        return;
        
    }else
    {
        
        NSString *nickName = [[message from]resource];
        NSRange range = [nickName rangeOfString:@"_"];
        if(range.location == NSNotFound)
        {
            nickName = [NSString stringWithFormat:@"%@_%@",nickName,[[NSUserDefaults standardUserDefaults] objectForKey:myGID]];
        }
        if([nickName isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]){
            NSLog(@"自己发送消息的回执，就是自己发的那条消息");
            [self sendMessagesucceed:message];
            return ;
        }
        
    }

}

#pragma mark - 任务消息处理
- (void)dealTaskMessage:(XMPPMessage*)message
{
    static NSTimeInterval lastTime2PlaySound = 0;
    
    NSString *messageId = [message elementID];
    NSString *bodyString = [[message elementForName:@"x"] stringValue];
    NSRange msgIdRange1 = [bodyString rangeOfString:@"<msgid>"];
    NSRange msgIdRange2 = [bodyString rangeOfString:@"</msgid>"];
    if (msgIdRange1.length > 0 && msgIdRange2.length > 0)
    {
        messageId = [bodyString substringWithRange:NSMakeRange(msgIdRange1.location+msgIdRange1.length, msgIdRange2.location-msgIdRange2.length-msgIdRange1.location+1)];
        [self sendMessageReceipt:messageId];
    }
    
    NSString *taskString = @"";
    NSRange range1 = [bodyString rangeOfString:@"<text>"];
    NSRange range2 = [bodyString rangeOfString:@"</text>"];
    
    if (range1.length > 0 && range2.length > 0)
    {
        taskString = [bodyString substringWithRange:NSMakeRange(range1.location+range1.length, range2.location-range2.length-range1.location+1)];
    }
    
    taskString = [taskString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\\"]];
    
    if ([taskString length] > 0)
    {
        NSDictionary *actionDict = [taskString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        if (![actionDict isKindOfClass:[NSDictionary class]])
        {
            return;
        }
        NSDictionary *messageDict = [[actionDict objectForKey:@"message"] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        if (![messageDict isKindOfClass:[NSDictionary class]])
        {
            return ;
        }
        
        NSDictionary *taskStatusDict = [TaskTools dealWithTaskStatusDict:messageDict sourceType:TaskStatusSourceTypePush];
        if (![taskStatusDict isKindOfClass:[NSDictionary class]])
        {
            return ;
        }
        
        id task_id = [taskStatusDict objectForKey:@"task_id"];
        if (!task_id || task_id == [NSNull null]) {
            return;
        }
        
        if ([taskStatusDict count] > 0 )
        {
            NSTimeInterval time     = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = time - lastTime2PlaySound;
            if (lastTime2PlaySound <= 0 || interval > 5) {
                lastTime2PlaySound = time;
                if([[NSUserDefaults standardUserDefaults] boolForKey:REMIND_SOUND] && [[NSUserDefaults standardUserDefaults] boolForKey:REMIND_MSG])
                {
                    [SoundWithMessage playMessageReceivedSound];
                }
            }
            
            if ([taskStatusDict objectForKey:@"status_id"] &&[[SqliteDataDao sharedInstanse]  findSetWithDictionary:@{@"status_id":[taskStatusDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE orderBy:nil] == 0)
            {
                if (![[SqliteDataDao sharedInstanse]  insertStatusRecord:taskStatusDict andTableName:TASK_STATUS_TABLE])
                {
                    NSLog(@"insert status fail");
                }
            }
            else if([taskStatusDict objectForKey:@"status_id"])
            {
                if ([[SqliteDataDao sharedInstanse]  deleteRecordWithDict:@{@"status_id":[taskStatusDict objectForKey:@"status_id"]} andTableName:TASK_STATUS_TABLE])
                {
                    if (![[SqliteDataDao sharedInstanse]  insertStatusRecord:taskStatusDict andTableName:TASK_STATUS_TABLE])
                    {
                        NSLog(@"insert status fail");
                    }
                }
            }
            else
            {
                if (![[SqliteDataDao sharedInstanse]  insertStatusRecord:taskStatusDict andTableName:TASK_STATUS_TABLE])
                {
                    NSLog(@"insert status fail");
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
            
                if (self.receiveTaskPushInTaskCreate)
                {
                    self.receiveTaskPushInTaskCreate(taskStatusDict);
                }
                if (self.receiveTaskPushInTaskView)
                {
                    self.receiveTaskPushInTaskView(taskStatusDict);
                }
                if (self.receiveTaskPushInAppDelegate)
                {
                    self.receiveTaskPushInAppDelegate(taskStatusDict);
                }
            });
            
        }
    }
    return;
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    // 是数组中某个人的信息 状态改变...
    NSString *jid = [presence attributeStringValueForName:@"from"];
    NSString *status = @"online";
    // 判断里面show
    for (NSXMLElement *oneChild in presence.children) {
        if ([oneChild.name isEqualToString:@"show"]) {
            status = @"away";
        }
    };
    // qianfeng@1000phone.net/YangMac-2
    XMPPJID *hisJid = [XMPPJID jidWithString:jid];
    jid = [NSString stringWithFormat:@"%@@%@", hisJid.user, hisJid.domain];
//    NSLog(@"online jid %@", jid);
    [self addOrUpdateUser:jid withStatus:status];
    

}

// 增加这个人，如果这个人已经存在了 就不要改变状态
- (void) addOrUpdateUser:(NSString *)jid withStatus:(NSString *)status needToChangeStatus:(BOOL)yesOrNO{
    for (UserModel *um in _allFriendList) {
        if ([um.jid isEqualToString:jid]) {
            return;
        }
    }
    
    [self addOrUpdateUser:jid withStatus:status];
}

- (void) addOrUpdateUser:(NSString *)jid withStatus:(NSString *)status {
    for (UserModel *um in _allFriendList) {
        if ([um.jid isEqualToString:jid]) {
            // 存在这个
            um.status = status;
            return;
        } 
    }
    UserModel *um = [[UserModel alloc] init];
    um.jid = jid;
    um.status = status;
    [_allFriendList addObject:um];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (saveFriendsCb) {
            saveFriendsCb(_allFriendList);
        }
    });
    
}

- (void) getAllFriends:( void (^) (NSArray *) ) cb {
    saveFriendsCb = [cb copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (saveFriendsCb) {
            saveFriendsCb(_allFriendList);
        }
    });
    
}

- (void) registerForMessage:( void (^) (MessageModel *mm) )cb {
    //saveMessageCb = [cb copy];
    saveMessageCb = cb;

}
#pragma mark - 发送消息
- (void)updatejuhua:(NSString *)messageID withCompletion:(void (^)(BOOL ret,NSString *siID))cb{
    
    
    if([sendSuccsetodoWaitQueue objectForKey:messageID]){
    
       saveSendMessageFinishCb=[sendSuccsetodoWaitQueue objectForKey:messageID];
        saveSendMessageFinishCb(YES,nil);
    }
    [sendSuccsetodoWaitQueue setObject:[cb copy] forKey:messageID];
//     DDLogCInfo(@"替换后%@----block----%p----%p",messageID,[sendSuccsetodoWaitQueue objectForKey:messageID],sendSuccsetodoWaitQueue);
    
}
- (void) sendMessage:(NSDictionary *)msgDict chatType:(int)chatType withType:(MessageType)type toUser:(NSString *)toUser messageId:(NSString *)messageID withCompletion:(void (^)(BOOL ret,NSString *siID))cb {
    
       NotesData *nd=[[SqliteDataDao sharedInstanse] queryChatMessageWithMessageID:messageID];
    DDLogInfo(@"%@",nd.isSend);
    if([nd.isSend isEqualToString:@"1"]){
        cb(YES,nil);
        return ;
    }
//    saveSendMessageFinishCb = [cb copy];
    NSString *str=[msgDict objectForKey:key_messageText];
    for(int i=0;i<faceNameArray.count;i++){
        str=[str stringByReplacingOccurrencesOfString:faceNameArray[i] withString:faceExpressionArray[i]];
    }
    if(![sendSuccsetodoWaitQueue objectForKey:messageID]){
        [sendSuccsetodoWaitQueue setObject:[cb copy] forKey:messageID];
    }else{
        cb(YES,nil);
    }
    NSString *chatTypeStr=@"chat";
    NSString *toJidStr=[self checkJid:toUser];
    
    if (chatType==1) {
        //群聊
        toJidStr=[self checkRoomJIDString:toUser];
        chatTypeStr=@"groupchat";
    }else if (chatType==0){
//        toJidStr=[self checkJid:toUser];
    }else if (chatType==2){
        //公众号
#pragma mark 公众号上行
//        <message id='328Gr-16' to='padata1@pubacct.li726-26'>
//        <x xmlns='http://jabber.org/protocol/pubacct'>
//        <msg_content>
//        <media_type>10</media_type>
//        <create_time>2014-10-28 22:34:54</create_time>
//        <text>你好</text>
//        <pa_uuid>544f95ba24acd552751c9c3a</pa_uuid>
//        </msg_content>
//        </x>
//        </message>
        NSXMLElement *publicMessage=[NSXMLElement elementWithName:@"message"];
        [publicMessage addAttributeWithName:@"id" stringValue:messageID];
        [publicMessage addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",msgDict[key_public_sip_uri]]];
        NSXMLElement *x_xml=[NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/pubacct"];
        NSXMLElement *msg_content=[NSXMLElement elementWithName:@"msg_content"];
        NSXMLElement *c=[NSXMLElement elementWithName:@"media_type" stringValue:@"10"];
        [msg_content addChild:c];
        c=[NSXMLElement elementWithName:@"create_time" stringValue:msgDict[key_public_creat_time]];
        [msg_content addChild:c];
        c=[NSXMLElement elementWithName:@"text" stringValue:str];
        [msg_content addChild:c];
        c=[NSXMLElement elementWithName:@"pa_uuid" stringValue:msgDict[key_public_pa_uuid]];
        [msg_content addChild:c];
        [x_xml addChild:msg_content];
        
        [publicMessage addChild:x_xml];
        // 发到服务器上
        [_xmppStream sendElement:publicMessage];
        return;
    }
    
    XMPPJID *toJid = [XMPPJID jidWithString:toJidStr];
    
    XMPPMessage *oneMessage = [[XMPPMessage alloc] initWithType:chatTypeStr to:toJid elementID:messageID];
    if(chatType==0){//如果是单聊，添加回执请求
        XMPPMessage *requestnode= [[XMPPMessage alloc] initWithName:@"request" xmlns:@"urn:xmpp:receipts"];
        [oneMessage addChild:requestnode];
    }
    switch (type) {
        case kMsgText:
        {
            //文字
            [oneMessage addBody:str];
            break;
        }
        case kMsgImage:
        {
            //图片
            
            NSXMLElement *bodyElement=[NSXMLElement elementWithName:@"body" stringValue:@""];
            [oneMessage addChild:bodyElement];
            
            XMPPMessage *X_Message = [[XMPPMessage alloc] initWithName:@"x" xmlns:@"jabber:x:fileMessageExtention"];
            
            NSXMLElement *element1 = [NSXMLElement elementWithName:@"fileName" stringValue:msgDict[key_messageImage_image_name]];
            
            NSXMLElement *element2 = [NSXMLElement elementWithName:@"fileType" stringValue:@"1"];
            NSXMLElement *element3 = [NSXMLElement elementWithName:@"original_link" stringValue:msgDict[key_messageImage_original_link]];
            NSXMLElement *element4 = [NSXMLElement elementWithName:@"middle_link" stringValue:msgDict[key_messageImage_middle_link]];
            NSXMLElement *element7=[NSXMLElement elementWithName:@"small_link" stringValue:msgDict[key_messageImage_small_link]];
            NSXMLElement *element8=[NSXMLElement elementWithName:@"fileLength" stringValue:key_messageImage_fileLength];
            NSXMLElement *element5=[NSXMLElement elementWithName:@"width" stringValue:msgDict[key_messageImage_image_width]];
            NSXMLElement *element6=[NSXMLElement elementWithName:@"height" stringValue:msgDict[key_messageImage_image_height]];

            [X_Message addChild:element1];
            [X_Message addChild:element2];
            [X_Message addChild:element3];
            [X_Message addChild:element4];
            [X_Message addChild:element7];
            [X_Message addChild:element8];
            [X_Message addChild:element5];
            [X_Message addChild:element6];

            
            [oneMessage addChild:X_Message];
            
            break;
        }
        case kMsgVoice:
        {
            //声音
            
            NSXMLElement *bodyElement=[NSXMLElement elementWithName:@"body" stringValue:@""];
            [oneMessage addChild:bodyElement];
            
            XMPPMessage *X_Message = [[XMPPMessage alloc] initWithName:@"x" xmlns:@"jabber:x:fileMessageExtention"];
            
            NSXMLElement *element1 = [NSXMLElement elementWithName:@"fileName" stringValue:msgDict[key_messageVoice_name]];
            
            NSXMLElement *element2 = [NSXMLElement elementWithName:@"fileType" stringValue:@"2"];
            NSXMLElement *element3 = [NSXMLElement elementWithName:@"original_link" stringValue:msgDict[key_messageVoice_url]];
            NSXMLElement *element4= [NSXMLElement elementWithName:@"duration" stringValue:msgDict[key_messageVoice_length]];
            [X_Message addChild:element1];
            [X_Message addChild:element2];
            [X_Message addChild:element3];
            [X_Message addChild:element4];
            [oneMessage addChild:X_Message];
            
            
            break;
        }
        default:
            break;
    }
    // 发到服务器上
    //NSLog(@"######发送消息实体%@",oneMessage);
    [_xmppStream sendElement:oneMessage];
}


//上传device token
- (void)sendTokenToOpenfireWithCompletion:(void(^)(BOOL ret,NSError *err))cb  //发送device token
{
    saveSendDeviceTokenFinishCb = [cb copy];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    
    [iq addAttributeWithName:@"id" stringValue:[_xmppStream generateUUID]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    XMPPJID *myjid = [XMPPJID jidWithString:_currUser.jid];
    
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",myjid]];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"cmcc.pushnotification.%@",[[NSUserDefaults standardUserDefaults] objectForKey:openfireName]]];
    
    XMPPMessage *X_Message = [[XMPPMessage alloc] initWithName:@"x" xmlns:@"http://jabber.org/xep/cmcc/pushnotification"];
    
    [iq addChild:X_Message];
    
    NSXMLElement *bodyElement=[NSXMLElement elementWithName:@"body"];
    
    NSXMLElement *element1 = [NSXMLElement elementWithName:@"action" stringValue:@"set-token"];
    NSXMLElement *element2 = [NSXMLElement elementWithName:@"token" stringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]];
    NSXMLElement *element3 = [NSXMLElement elementWithName:@"os_type" stringValue:@"iOS"];
    NSXMLElement *element4 = [NSXMLElement elementWithName:@"ios_crt_type" stringValue:PUSH_NOTIFICATION];
    
    [bodyElement addChild:element1];
    [bodyElement addChild:element2];
    [bodyElement addChild:element3];
    [bodyElement addChild:element4];
    
    [X_Message addChild:bodyElement];
    
    NSLog(@"%@",iq);
    [_xmppStream sendElement:iq];
    
}

- (void)CancelPushNotification
{
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    
    [iq addAttributeWithName:@"id" stringValue:[_xmppStream generateUUID]];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    
    XMPPJID *myjid = [XMPPJID jidWithString:_currUser.jid];
    
    [iq addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@",myjid]];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"cmcc.pushnotification.%@",[[NSUserDefaults standardUserDefaults] objectForKey:openfireName]]];
    
    XMPPMessage *X_Message = [[XMPPMessage alloc] initWithName:@"x" xmlns:@"http://jabber.org/xep/cmcc/pushnotification"];
    
    [iq addChild:X_Message];
    
    NSXMLElement *bodyElement=[NSXMLElement elementWithName:@"body"];
    
    NSXMLElement *element1 = [NSXMLElement elementWithName:@"action" stringValue:@"quit"];

    [bodyElement addChild:element1];
    
    [X_Message addChild:bodyElement];
    
    NSLog(@"%@",iq);
    [_xmppStream sendElement:iq];

}

#pragma -mark 开启计数功能
- (void)openMessageCount
{
    XMPPJID *jid = [XMPPJID jidWithString:openFireNameStr];

    XMPPIQ *iq = [[XMPPIQ alloc]initWithType:@"set" to:jid elementID:[_xmppStream generateUUID]];
    NSString *myjid = [ConstantObject sharedConstant].userInfo.imacct;
    NSRange range           = [myjid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        myjid = [NSString stringWithFormat:@"%@%@",myjid,E_APP_KEY];
    }
    NSString *from = [NSString stringWithFormat:@"%@@%@/%@",myjid, openFireNameStr,@"Smack"];
    [iq addAttributeWithName:@"from" stringValue:from];
    NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [request addAttributeWithName:@"opt" stringValue:@"open"];
    [iq addChild:request];
    [_xmppStream sendElement:iq];
}

#pragma -mark 关闭计数功能
- (void)closeMessageCount
{
    XMPPJID *jid = [XMPPJID jidWithString:openFireNameStr];
    
    XMPPIQ *iq = [[XMPPIQ alloc]initWithType:@"set" to:jid elementID:[_xmppStream generateUUID]];
    NSString *myjid = [ConstantObject sharedConstant].userInfo.imacct;
    NSRange range           = [myjid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        myjid = [NSString stringWithFormat:@"%@%@",myjid,E_APP_KEY];
    }
    NSString *from = [NSString stringWithFormat:@"%@@%@/%@",myjid, openFireNameStr,@"Smack"];
    [iq addAttributeWithName:@"from" stringValue:from];
    NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [request addAttributeWithName:@"opt" stringValue:@"close"];
    [iq addChild:request];
    [_xmppStream sendElement:iq];
}

- (void)setUnReadMessageCount:(NSInteger)count
{
    XMPPJID *jid = [XMPPJID jidWithString:openFireNameStr];
    
    XMPPIQ *iq = [[XMPPIQ alloc]initWithType:@"set" to:jid elementID:[_xmppStream generateUUID]];
    NSString *myjid = [ConstantObject sharedConstant].userInfo.imacct;
    NSRange range           = [myjid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        myjid = [NSString stringWithFormat:@"%@%@",myjid,E_APP_KEY];
    }
    NSString *from = [NSString stringWithFormat:@"%@@%@/%@",myjid, openFireNameStr,@"Smack"];
    [iq addAttributeWithName:@"from" stringValue:from];
    NSXMLElement *request = [NSXMLElement elementWithName:@"request" xmlns:@"urn:xmpp:receipts"];
    [request addAttributeWithName:@"opt" stringValue:@"set"];
    [request addAttributeWithName:@"num" integerValue:count];
    [iq addChild:request];
    [_xmppStream sendElement:iq];
}

-(void)sendMessagesucceed:(XMPPMessage *)message{
    NSString *messageId;
    NSXMLElement *received=[message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
    if(received){
        messageId=[[received attributeForName:@"id"] stringValue];
    }else{
       messageId=[message elementID];
    }
    [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:messageId state:@"1"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        saveSendMessageFinishCb=[sendSuccsetodoWaitQueue objectForKey:messageId];
//        DDLogCInfo(@"调用时%@----block----%p----%p",messageId,[sendSuccsetodoWaitQueue objectForKey:messageId],sendSuccsetodoWaitQueue);
        
        if (saveSendMessageFinishCb) {
            saveSendMessageFinishCb(YES,messageId);
        }
        [sendSuccsetodoWaitQueue removeObjectForKey:messageId];
    });
}

- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
//      发送成功的事物逻辑判定点不在这里，改到收到回执中

    
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{
    NSString *messageId;
    NSXMLElement *received=[message elementForName:@"received" xmlns:@"urn:xmpp:receipts"];
    if(received){
        messageId=[[received attributeForName:@"id"] stringValue];
    }else{
        messageId=[message elementID];
    }
    
    [[SqliteDataDao sharedInstanse] updateSendStateWithMessageID:messageId state:@"2"];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        saveSendMessageFinishCb=[sendSuccsetodoWaitQueue objectForKey:messageId];
        if (saveSendMessageFinishCb) {
            saveSendMessageFinishCb(NO,messageId);
        }
        [sendSuccsetodoWaitQueue removeObjectForKey:messageId];
        
    });
    
    if (![_xmppStream isConnected]) {
        NSError *error = nil;
        [_xmppStream connectWithTimeout:-1 error:&error];
        
    }

}
#pragma mark - 聊天室相关
-(void)getRoomInfo:(NSString *)roomJid name:(NSString *)roomName
{
    NSLog(@"+++++++++++++++++%@",roomJid);
    XMPPJID *roomJID = [XMPPJID jidWithString:[self checkRoomJIDString:roomJid]];
    
    //初始化聊天室
    XMPPRoom *_xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:roomJID dispatchQueue:queue2];
    _xmppRoom.roomName = roomName;
    [_xmppRoom activate:_xmppStream];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoom fetchModeratorsList];
    [_xmppRoom fetchMembersList];
    
    roomJid = [roomJid deleteOpenFireName];
    [_roomDict setObject:_xmppRoom forKey:roomJid];
    
}

-(void)creatRoomWithName:(NSString *)roomName jids:(NSArray *)jids compltion:(CreatRoomSuccess)creatSuccess{
    
    
    
    self.creatRoomSuccess=[creatSuccess copy];
    
    if (!_xmppStream.isConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            creatSuccess(NO,nil);
        });
        
        return;
    }
    
    self.createRoomJIDs = [NSArray arrayWithArray:jids];
    
    CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *cfuuidString = [(NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid)) lowercaseString];
    XMPPJID *roomJID = [XMPPJID jidWithString:[self checkRoomJIDString:cfuuidString]];
    NSString *nickName = [NSString stringWithFormat:@"+86%@",[ConstantObject sharedConstant].userInfo.phone];
    //初始化聊天室
    XMPPRoom *_xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:[XMPPRoomCoreDataStorage sharedInstance] jid:roomJID dispatchQueue:queue2];
    _xmppRoom.roomName=roomName;
    [_xmppRoom activate:_xmppStream];
    [_xmppRoom joinRoomUsingNickname:nickName history:nil];
    //[self configNewRoom:_xmppRoom isLeave:NO];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_roomDict setObject:_xmppRoom forKey:cfuuidString];
}


-(NSString *)checkRoomJIDString:(NSString *)jid{
    NSRange range           = [jid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        jid = [NSString stringWithFormat:@"%@%@",jid,E_APP_KEY];
    }
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *locationName=[userDefaults objectForKey:openfireName];
    NSString *str=[NSString stringWithFormat:@"%@@conference.%@",jid,locationName];
    return str;
}
-(NSString *)checkJid:(NSString *)jid{
    NSRange range           = [jid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        jid = [NSString stringWithFormat:@"%@%@",jid,E_APP_KEY];
    }
    NSString *str=[NSString stringWithFormat:@"%@@%@",jid, openFireNameStr];
    return str;
}
#pragma mark 添加群成员
-(void)addMemberJidToRoom:(XMPPRoom *)sender jids:(NSArray *)jids compltion:(AddMemberJidToRoom)addMemberToRoom{
    self.addMemberJidToRoom=[addMemberToRoom copy];
    self.addMemberJIDs = [NSArray arrayWithArray:jids];
    if (!self.xmppStream.isConnected) {
        //在线
        dispatch_async(dispatch_get_main_queue(), ^{
            addMemberToRoom(NO);
            if (sender.groupState==2) {
                if (self.haveleaveRoom) {
                    self.haveleaveRoom(NO);
                }
            }
            
        });
        
        return;
    }

    [self massRoomMessageType:@"INVITEMEMBER" withMember:jids room:sender];
}
#pragma mark - 退出群
-(void)outRoom:(XMPPRoom *)room compltion:(LeaveRoom)leaveRoom{
    self.haveleaveRoom=[leaveRoom copy];
    if (!_xmppStream.isConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            leaveRoom(NO);
        });
        
        return;
    }
    
/*
    [room fetchMembersList];
    NSString *jid=[self checkJid:[ConstantObject sharedConstant].userInfo.imacct];
    XMPPJID *roomJID = [XMPPJID jidWithString:jid];
    NSXMLElement *items = [XMPPRoom itemWithAffiliation:@"none" jid:roomJID];
    NSArray *array=@[items];
    
//    [room removeDelegate:self delegateQueue:queue2];
    
    if (room.roomMemberList.count<1) {
        /**
         *  如果群成员为空了,直接返回
         */
    /*
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.haveleaveRoom) {
                self.haveleaveRoom(YES);
            }
        });
        [room destroyRoom:roomJID];
        return;
    }else{
        [room editRoomPrivileges:array];
        room.groupState=2;
    }
 */
    [self massRoomMessageType:@"EXITROOM" withMember:nil room:room];
}
#pragma mark 创建聊天室成功
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    //NSLog(@"%@: %@", THIS_FILE, THIS_METHOD);
    //获取服务器配置,获取所有者列表
//    [sender fetchConfigurationForm];
//    [_xmppRoom fetchBanList];
    //获取参与者(可忽略)
//    [_xmppRoom fetchMembersList];
    //获取所有者(群主)
    
    [self configNewRoom:sender isLeave:YES];
    /*
    [sender fetchModeratorsList];
    
    if (!_xmppStream.isConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.creatRoomSuccess) {
                self.creatRoomSuccess(NO,sender);
            }
        });
        
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.creatRoomSuccess) {
            self.creatRoomSuccess(YES,sender);
        }
    });
    */
}

#pragma mark  配置房间成功
- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    [self massRoomMessageType:@"TYPE_CREATEGROUP" withMember:nil room:sender];
    
    if (!_xmppStream.isConnected) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.creatRoomSuccess) {
                self.creatRoomSuccess(NO,sender);
            }
        });
        
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.creatRoomSuccess) {
            self.creatRoomSuccess(YES,sender);
        }
    });

}

#pragma mark 配置房间失败
- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.creatRoomSuccess) {
            self.creatRoomSuccess(NO,sender);
        }
    });
    

}
//如果房间存在，会调用委托
#pragma mark 获取到服务器配置
- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
    RoomInfoModel *roomModel=[[RoomInfoModel alloc] init];
    NSString *roomJid=[sender.roomJID.user deleteOpenFireName];
    for (NSXMLElement *children in configForm.children) {
        
        NSString *varStr=[[children attributeForName:@"var"] stringValue];
        
        if ([varStr isEqualToString:@"muc#roomconfig_roomowners"]) {
            //群成员
            NSArray *memberList=[children elementsForName:@"value"];
            NSMutableString *mutableMemberListStr=[[NSMutableString alloc] init];
            for (NSXMLElement *strt in memberList) {
//                NSLog(@"%@",[strt stringValue]);
                NSString *imacc=[[strt stringValue] deleteOpenFireName];
                [mutableMemberListStr appendFormat:@"%@;",imacc];
            }
            NSString *memberListStr=[mutableMemberListStr substringToIndex:mutableMemberListStr.length-1];
            roomModel.roomMemberListStr=memberListStr;
        }
        if ([varStr isEqualToString:@"muc#roomconfig_roomname"]) {
            NSArray *memberList=[children elementsForName:@"value"];
            //房间名字
            if (memberList.count>0) {
                NSXMLElement *roomName_x=memberList[0];
                NSString *roomName=[roomName_x stringValue];
                roomModel.roomName=roomName;

//                }
            }
        }
    }
    
    roomModel.roomJid=roomJid;
    
    [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:roomModel];

    
    if ([newRoomListDict.allKeys containsObject:roomJid]) {
        //包含
        if (self.receviedGroupManagerMessage) {
            MessageModel *mm=(MessageModel *)[newRoomListDict objectForKey:roomJid];
            self.receviedGroupManagerMessage(mm);
        }
        [newRoomListDict removeObjectForKey:roomJid];
    }
    
}
#pragma mark 收到好友名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items{
    //NSLog(@"---%d",items.count);
    //NSLog(@"%@",sender.roomName);
    RoomInfoModel *roomModel=[[RoomInfoModel alloc] init];
    //    NSLog(@"%@",sender.roomJID);
    NSString *roomJid=[sender.roomJID.user deleteOpenFireName];
    NSMutableString *mutableMemberListStr=[[NSMutableString alloc] init];
    NSMutableArray *mutableRoomMember = [[NSMutableArray alloc]init];
    [mutableMemberListStr appendFormat:@"%@;",sender.moderatorsImacc];
    EmployeeModel *moderator = [SqlAddressData queryMemberInfoWithImacct:sender.moderatorsImacc];
    [mutableRoomMember addObject:moderator];
    
    for (NSXMLElement *member in items) {
        
        NSString *imacc=[[[member attributeForName:@"jid"] stringValue] deleteOpenFireName];
        EmployeeModel *em = [SqlAddressData queryMemberInfoWithImacct:imacc];
        [mutableRoomMember addObject:em];
       [mutableMemberListStr appendFormat:@"%@;",imacc];
    }
    NSString *memberListStr=[mutableMemberListStr substringToIndex:mutableMemberListStr.length-1];
    roomModel.roomMemberListStr=memberListStr;
    roomModel.roomMemberList = [NSArray arrayWithArray:mutableRoomMember];
    //房间名字
    roomModel.roomName = sender.roomName;
    
    roomModel.roomJid=roomJid;
    
    [[SqliteDataDao sharedInstanse] insertDataToGroupTabel:roomModel];
}
#pragma mark 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items{
    NSLog(@"收到主持人名单的房间名%@",sender.roomName);
    if([items count]){
    NSXMLElement *x=items[0];
    //NSLog(@"%@",x);
    NSString *jid=[[[x attributeForName:@"jid"] stringValue] deleteOpenFireName];
    sender.moderatorsImacc=jid;
    }
}

#pragma mark 房间不存在，调用委托
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError{
    NSLog(@"-didNotFetchBanList");
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError{
    NSLog(@"-didNotFetchMembersList");
    if (sender.roomMemberList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.creatRoomSuccess) {
                self.creatRoomSuccess(NO,nil);
            }
        });
        
    }
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError{
    NSLog(@"-didNotFetchModeratorsList");
    if (sender.roomMemberList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.creatRoomSuccess) {
                self.creatRoomSuccess(NO,nil);
            }
        });
        
    }
    
}
#pragma mark 有人加入
- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
    NSLog(@"加入房间");
}
#pragma mark 收到群消息
- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    
}
#pragma mark 有人离开房间
- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    //退出房间
    /*
    if (sender.roomMemberList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.haveleaveRoom) {
                self.haveleaveRoom(YES);
            }
        });
    }
    */
}
- (void)noSendHistory:(NSString *)roomJid
{
    XMPPPresence* y = [[XMPPPresence alloc] initWithType:@"" to:[XMPPJID jidWithString:[self checkRoomJIDString:roomJid]]];
    [y addAttributeWithName:@"from" stringValue:[self checkJid:[ConstantObject sharedConstant].userInfo.imacct]];
    [y removeAttributeForName:@"type"];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    NSXMLElement *p = [NSXMLElement elementWithName:@"history"];
    [p addAttributeWithName:@"maxchars" stringValue:@"0"];
    [x addChild:p];
    [y addChild:x];
    [_xmppStream sendElement:y];
}
-(void)configNewRoom:(XMPPRoom *)sender isLeave:(BOOL)leave{
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    NSXMLElement *p;
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [p addAttributeWithName:@"type" stringValue:@"hidden"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
    [p addAttributeWithName:@"type" stringValue:@"text-single"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:sender.roomName]];     //房间名
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"];
    [p addAttributeWithName:@"type" stringValue:@"text-single"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:sender.roomSubject]];     //房间描述
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_changesubject"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];     //允许改变主题
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_maxusers"];
    [p addAttributeWithName:@"type" stringValue:@"list-single"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"200"]];     //最大用户数
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];     //公共房间
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];     //永久房间
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_moderatedroom"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_allowinvites"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];     //允许邀请
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_whois"];
    [p addAttributeWithName:@"type" stringValue:@"list-single"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"anyone"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_enablelogging"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"x-muc#roomconfig_canchangenick"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"x-muc#roomconfig_registration"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roommembers"];
    [p addAttributeWithName:@"type" stringValue:@"jid-multi"];
    sender.roomMemberList = [NSArray arrayWithArray:self.createRoomJIDs];
    for (EmployeeModel  *em in self.createRoomJIDs) {
        NSString *imacc=em.imacct;
        NSString *nickName = [NSString stringWithFormat:@"+86%@",em.phone];
        NSRange range           = [imacc rangeOfString:E_APP_KEY];
        if(range.location == NSNotFound) {
            imacc = [NSString stringWithFormat:@"%@%@",imacc,E_APP_KEY];
        }
        [p addChild:[NSXMLElement elementWithName:@"value" stringValue:[NSString stringWithFormat:@"%@@%@/%@",imacc, openFireNameStr,nickName]]];     //群成员
    }
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var" stringValue:@"muc#roomconfig_isdiscussionroom"];
    [p addAttributeWithName:@"type" stringValue:@"boolean"];
    [p addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
    [x addChild:p];
    NSLog(@"%@",x);
    [sender configureRoomUsingOptions:x];
}
-(void)ChangeRoomName:(NSString *)roomJid name:(NSString *)name compltion:(ChangeRoomName)changeRoomName{
    self.changeRoomName= changeRoomName;
    XMPPMessage *message=[[XMPPMessage alloc] initWithName:@"message"];
    
    [message addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
    NSRange range           = [roomJid rangeOfString:E_APP_KEY];
    if(range.location == NSNotFound) {
        roomJid = [NSString stringWithFormat:@"%@%@",roomJid,E_APP_KEY];
    }

    NSString *toroomJID = [NSString stringWithFormat:@"%@@conference.li726-26",roomJid];
    
    //[message addAttributeWithName:@"from" stringValue:toroomJID];
    [message addAttributeWithName:@"to" stringValue:toroomJID];
    [message addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"set-natural-name"];
    [x setStringValue:name];
    [message addChild:x];
    [_xmppStream sendElement:message];
}

-(void)massRoomMessageType:(NSString*)type withMember:(NSArray *)memberList room:(XMPPRoom *)sender
{
    
    if([type isEqualToString:@"TYPE_CREATEGROUP"])
    {
        
        XMPPMessage *message=[[XMPPMessage alloc] initWithName:@"message"];
        
        [message addAttributeWithName:@"id" stringValue:[XMPPStream generateUUID]];
        [message addAttributeWithName:@"to" stringValue:sender.roomJID.full];
        [message addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        NSMutableString *memberNameStr=[[NSMutableString alloc] init];
        NSMutableString *memberNickName=[[NSMutableString alloc] init];
        [memberNickName appendFormat:@"%@;",[ConstantObject sharedConstant].userInfo.imacct];
        for (EmployeeModel *emp in sender.roomMemberList) {
            
            if ([emp.imacct isEqualToString:[ConstantObject sharedConstant].userInfo.imacct]) {
                //continue;
            }
            [memberNameStr appendFormat:@"%@,",emp.name];
            [memberNickName appendFormat:@"+86%@;",emp.phone];
            
        }
        NSString *memberNickNameList = [memberNickName substringToIndex:memberNickName.length -1];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:@"新建群聊"];
        [message addChild:body];
        
        NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:MemberUpdatedMessageExtention"];
        NSXMLElement *element1 = [NSXMLElement elementWithName:@"member_updated_type" stringValue:type];
        [x addChild:element1];
        NSXMLElement *element2 = [NSXMLElement elementWithName:@"groupId" stringValue:sender.roomJID.full];
        [x addChild:element2];
        NSXMLElement *element3 = [NSXMLElement elementWithName:@"groupName" stringValue:sender.roomName];
        [x addChild:element3];
        NSXMLElement *element4 = [NSXMLElement elementWithName:@"members" stringValue:memberNickNameList];
        [x addChild:element4];
        [message addChild:x];
        
        [_xmppStream sendElement:message];

    }
    
    if([type isEqualToString:@"INVITEMEMBER"])
    {
        XMPPIQ *iq =[[XMPPIQ alloc]initWithType:@"set" elementID:[_xmppStream generateUUID]];
 
        [iq addAttributeWithName:@"to" stringValue:sender.roomJID.full];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
        for(EmployeeModel *em in memberList)
        {
            NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
            [item addAttributeWithName:@"affiliation" stringValue:@"member"];
            NSString *myjid = em.imacct;
            NSRange range           = [myjid rangeOfString:E_APP_KEY];
            if(range.location == NSNotFound) {
                myjid = [NSString stringWithFormat:@"%@%@",myjid,E_APP_KEY];
            }
            [item addAttributeWithName:@"jid" stringValue:[NSString stringWithFormat:@"%@@%@/%@",myjid, openFireNameStr,[NSString stringWithFormat:@"+86%@",em.phone]]];
            [query addChild:item];
        }
        [iq addChild:query];
        //NSLog(@"%@",iq);
        [_xmppStream sendElement:iq];

    }
    
    if([type isEqualToString:@"EXITROOM"])
    {
        XMPPIQ *iq =[[XMPPIQ alloc]initWithType:@"set" elementID:[_xmppStream generateUUID]];
        
        [iq addAttributeWithName:@"to" stringValue:sender.roomJID.full];
        
        NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:XMPPMUCAdminNamespace];
 
        NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
        [item addAttributeWithName:@"affiliation" stringValue:@"none"];
        
        NSString *myjid = [ConstantObject sharedConstant].userInfo.imacct;
        NSRange range           = [myjid rangeOfString:E_APP_KEY];
        if(range.location == NSNotFound) {
            myjid = [NSString stringWithFormat:@"%@%@",myjid,E_APP_KEY];
        }
        [item addAttributeWithName:@"jid" stringValue:[NSString stringWithFormat:@"%@@%@/Smack",myjid, openFireNameStr]];
        [query addChild:item];
        
        [iq addChild:query];

        //NSLog(@"%@",iq);
        [_xmppStream sendElement:iq];
    }
}
@end