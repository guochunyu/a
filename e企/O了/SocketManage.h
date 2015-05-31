//
//  SocketManage.h
//  O了
//
//  Created by 化召鹏 on 14-5-12.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "ButtonAudioRecorder.h"
#import "RYAssetsPickerController.h"
#import "NotesData.h"
@interface SocketManage : NSObject{
    GCDAsyncSocket *_dataSocket;
    
    void (^didReadData)(NSData *data);
    void (^didDisconnect)(NSError *error);
    
    BOOL is_recivied_data;//是否收到数据
}

@property(nonatomic,assign)BOOL isTranmist;
@property(nonatomic,strong)NSString *taskId;
@property(nonatomic,strong)NotesData *selectNotesData;
+(SocketManage *)shardSocket;
-(void)uploadingFile:(NSDictionary *)fileInfo fileType:(int)type taskId:(NSString *)selfTaskId didReadData:(void (^)(NSData *data))succees didDisconnect:(void (^)(NSError *error))faile;
@end
