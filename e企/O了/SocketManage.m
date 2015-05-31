//
//  SocketManage.m
//  O了
//
//  Created by 化召鹏 on 14-5-12.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "SocketManage.h"
#import "NSString+FilePath.h"

@implementation SocketManage
@synthesize isTranmist,taskId,selectNotesData;
static SocketManage *socketManage=nil;
+(SocketManage *)shardSocket{
    
    socketManage=[[SocketManage alloc] init];
    return socketManage;
}
NSString *timeStr;
//上传文件
-(void)uploadingFile:(NSDictionary *)fileInfo fileType:(int)type taskId:(NSString *)selfTaskId didReadData:(void (^)(NSData *data))succees didDisconnect:(void (^)(NSError *error))faile{
    didReadData=[succees copy];
    didDisconnect=[faile copy];
    if (_dataSocket == nil){
        //如果socket为空,创建
        _dataSocket=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error=nil;
        if(![_dataSocket connectToHost:HTTP_IP onPort:80 error:&error])
        {
            DDLogInfo(@"连接失败");
        }else{
            DDLogInfo(@"连接成功");
            
            
//            NSString *taskId=[[self.chatMemberArray objectAtIndex:0] objectForKey:@"taskId"];
            taskId=selfTaskId;
            
            
            NSTimeInterval nowTime=[[NSDate date] timeIntervalSince1970];
            long long int dateTime=(long long int) nowTime;
            NSDate *time = [NSDate dateWithTimeIntervalSince1970:dateTime];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString *destDateString=[dateFormatter stringFromDate:time];
            timeStr=destDateString;
            NSString *fileName=nil;
            NSString *voiceLength=nil;
            NSData *fileData;
            switch (type) {
                case 2:
                {
                    //图片
                    fileName = fileInfo[@"name"];
                    voiceLength = @"";
                    //                    for (NSString * key in fileInfo) {
                    //                        if (![key isEqualToString:AssetsPickerMediaName]) {
                    //                            fileData = fileInfo[key];
                    //                        }
                    //                    }
                    fileData=[NSData dataWithContentsOfFile:[fileInfo[@"filePath"] filePathOfCaches]];
                    break;
                }
                case 3:
                {
                    //声音
                    NSString *filePath=fileInfo[AudioRecorderPath];
                    fileName=fileInfo[AudioRecorderName];
                    
                    voiceLength=fileInfo[AudioRecorderDuration];
                    fileData=[NSData dataWithContentsOfFile:filePath];
                    if (isTranmist) {
                        NSArray *pathArray=[selectNotesData.sendContents componentsSeparatedByString:@"#"];
                        voiceLength=pathArray[1];
                        fileName = fileInfo[@"name"];
                        fileData=[NSData dataWithContentsOfFile:[fileInfo[@"filePath"] filePathOfCaches]];
                    }
                    
                    break;
                }
                case 5:
                {
                    //视频
                    fileName = fileInfo[AssetsPickerMediaName];
                    voiceLength = fileInfo[@"videoLength"];
                    fileData = fileInfo[@"videoData"];
                    if (isTranmist) {
                        fileName = fileInfo[@"name"];
                    }
                    break;
                }
                default:
                    break;
            }
            
            NSString *dataStr=[NSString stringWithFormat:@"Content-Length=%d;filename=%@;sourceid=0;taskId=%@;fromUserId=%@;sendTime=%@;type=%d;voiceLength=%@\r\n",fileData.length,fileName,taskId,[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE],destDateString,type,voiceLength];
            NSData *strData = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
            
            [[LogRecord sharedWriteLog] writeLog:[NSString stringWithFormat:@"时间:%@,上传文件,头文件为:%@",timeStr,dataStr]];
            
            NSMutableData *allData = [[NSMutableData alloc] init];
            [allData appendData:strData];
            [allData appendData:fileData];
            int socketTag=1;
            [_dataSocket writeData:strData withTimeout:-1 tag:socketTag];
            [_dataSocket writeData:fileData withTimeout:-1 tag:socketTag+1];
//            if ([_imageArray count]>0) {
//                [_imageArray removeObjectAtIndex:0];
//            }
            //好像没有用到
            //            socketTag+=1;
            
            //    [socket writeData:allData withTimeout:-1 tag:0];
            
            //            //    data1 = [NSData dataWithBytes:buffer length:allData.length-1024*(allData.length/1024)];
            //
            //            NSInputStream *stream=[[NSInputStream alloc] initWithData:fileData];
            //            [stream open];
            //            Byte buffer[1024];
            //            int m = 0;
            //            DDLogInfo(@"%d",[stream read:buffer maxLength:1024]);
            //
            //            int alreadyCount = 1;
            //
            //            while ( [stream read:buffer maxLength:1024] > 0)
            //            {
            //
            //                NSData *data1 = nil;
            //
            //                m = [stream read:buffer maxLength:1024];
            //                data1 = [NSData dataWithBytes:buffer length:m];
            //
            //                if (m<1024) {
            //                    data1 = [NSData dataWithBytes:buffer length:allData.length-1024*(allData.length/1024)];
            //                    [_dataSocket writeData:data1 withTimeout:-1 tag:socketTag];
            //                    DDLogInfo(@"完成比例 == %f",(alreadyCount * 1024.f+data1.length)/(allData.length));
            //                }else{
            //
            //                }
            //                DDLogInfo(@"写入大小   %d",data1.length);
            //                DDLogInfo(@"完成大小 == %f",alreadyCount * 1024.f);
            //                DDLogInfo(@"总大小   == %d",allData.length);
            //                [_dataSocket writeData:data1 withTimeout:-1 tag:socketTag];
            //                DDLogInfo(@"完成比例 == %f",(alreadyCount * 1024.f)/(fileData.length));
            //                alreadyCount++;
            //                
            //                
            //                socketTag++;
            //            }
            //            
            //            
            //            [stream close];
            //            [_dataSocket disconnectAfterReadingAndWriting];
            
        }
    }else{
        DDLogInfo(@"已经存在socket对象");
    }

}


#pragma AsyncScoket Delagate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    //连接成功
    DDLogInfo(@"连接成功:%@:%d",host,port);
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //收到数据
    /**
     *  block回调
     */
    didReadData(data);
    is_recivied_data=YES;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    NSString *resultStr;
    resultStr=[[NSString alloc] initWithData:data encoding:enc];
    if (resultStr==nil) {
        resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    
    NSData *resultData=[resultStr dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error=nil;
    NSDictionary *resultDict=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
    if ([resultDict[@"result"] intValue] == 200) {
        //        DDLogInfo(@"%@",resultDict[@"resultMsg"]);
        
        NSString *strUuid;
        NSString *str=[[resultDict[@"path"] componentsSeparatedByString:@"#"] objectAtIndex:0];
        if ([resultDict[@"ImMessage"][@"type"] intValue] == 3) {
            
            str=[str stringByDeletingPathExtension];
            
            strUuid=[[str componentsSeparatedByString:@"/"] objectAtIndex:2];
        }else if ([resultDict[@"ImMessage"][@"type"] intValue] == 2){
            
            str=[str stringByDeletingPathExtension];
            
            strUuid=[[str componentsSeparatedByString:@"/"] objectAtIndex:3];
        }else if ([resultDict[@"ImMessage"][@"type"] intValue] == 5){
            str=[str stringByDeletingPathExtension];
            strUuid=[[str componentsSeparatedByString:@"/"] objectAtIndex:3];
        }
        
        if (isTranmist) {
            
            AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
            [app showWithCustomView:nil detailText:@"转发成功" isCue:0 delayTime:1 isKeyShow:NO];
            isTranmist=NO;
            CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
            NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
            strUuid=cfuuidString;
        }
        //        if([SqliteDataDao insertChatNotesData:resultDict :strUuid]){
        
        [_dataSocket disconnectAfterWriting];
        
        _dataSocket=nil;
        
        
        if ([resultDict[@"ImMessage"][@"type"] intValue] == 2) {
            //图片发送成功
            
//            if ([_imageArray count]>0) {
//                [self imageSendFinash:_imageArray];
//            }
        }
        //        }
        
    }
    
//    socketManage=nil;
    
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    //断开连接
    if (is_recivied_data==NO) {
        didDisconnect(err);
    }
    
//    DDLogInfo(@"连接被断开,error=%@",err);
//    socketManage=nil;
//    if (_dataSocket!=nil) {
//        _dataSocket=nil;
//    }
    
}

@end
