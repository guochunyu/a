//
//  ChatVoiceData.h
//  e企
//
//  Created by roya-7 on 14/11/10.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatVoiceData : NSObject
@property(nonatomic,copy)NSString *voiceUrl;///<语音文件url
@property(nonatomic,copy)NSString *voicePath;///<语音文件路径
@property(nonatomic,copy)NSString *voiceLenth;///<语音长度
@property(nonatomic,copy)NSString *voiceName;///<语音长度
@property(nonatomic,assign)int  isRead;///<是否读过
//@property(nonatomic,assign)NSString * messageID;///<语音id
@end
