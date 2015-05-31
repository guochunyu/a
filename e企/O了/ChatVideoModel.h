//
//  ChatVideoModel.h
//  e企
//
//  Created by roya-7 on 14/12/3.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatVideoModel : NSObject

@property(nonatomic,copy)NSString *createTime;///<创建时间
@property(nonatomic,copy)NSString *duration;///<视频长度(秒)
@property(nonatomic,copy)NSString *filesize;///<视频大小
@property(nonatomic,copy)NSString *media_uuid;///<消息uuid
@property(nonatomic,copy)NSString *original_link;///<视频连接
@property(nonatomic,copy)NSString *title;///<title
@end
