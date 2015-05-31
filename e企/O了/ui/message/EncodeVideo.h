//
//  EncodeVideo.h
//  O了
//
//  Created by 化召鹏 on 14-4-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RYAssetsPickerController.h"
typedef enum {
    encodeFailed,          ///失败
    encodeFinish,   ///完成
    encodeCancel//取消
}encodeType;
@interface EncodeVideo : NSObject{
    void (^encodeViewSuccess)(encodeType type,NSDictionary *dict);
}
@property(nonatomic,assign)encodeType encodeTp;
-(void)encodeVideoWithUrl:(NSURL *)url whitFinish:(void (^) (encodeType encodeTp,NSDictionary *dict))cb;//完成

+(EncodeVideo *)shareEncode;
+(void)releaseEncode;
@end
