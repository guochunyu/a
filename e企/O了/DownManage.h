//
//  DownManage.h
//  O了
//
//  Created by 化召鹏 on 14-3-14.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface DownManage : NSObject
+(DownManage *)sharedDownload;
//- (void) registerForMessage:( void (^) (MessageModel *mm) )cb;
-(void)downloadWhithUrl:(NSString *)url fileName:(NSString *)fileName type:(int)type downFinish:(void (^) (NSString *filePath))downFinish downFail:(void (^) (NSError *error))fail;
@end
