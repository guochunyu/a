//
//  mobileSDK.h
//  MobileSDK
//
//  Created by Dora.Lin on 14-1-21.
//  Copyright (c) 2014年 LiPo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface mobileSDK : NSObject<CLLocationManagerDelegate,NSURLConnectionDelegate,NSURLConnectionDataDelegate>

+(mobileSDK *)sharedMobileSDK;

//程序启动时调用。
+(void)startWithAppkey:(NSString *)appKey;

////程序启动时选择性调用。发送策略sure默认YES为启动时发送，NO为每日单次发送；url默认为nil，用户可以自定义接收数据的网址；channelId是渠道商；
//+(void)startWithAppkey:(NSString *)appKey channelId:(NSString *)channelId theCustomURL:(NSString *)url EveryTimeStartSendData:(BOOL)sure;

//程序结束时调用
+(void)setTerminateProgram;

//进入新的界面时调用  viewWillApper
+(void)startActivityWithClassName:(NSString *)className;

//退出当前界面时调用    viewVillDissApper
+(void)endActivityWithClassName:(NSString *)className;

//设置自定义事件时调用
+(void)setEventWithLable:(NSString *)lable andTag:(NSString *)tag andAttribute:(NSString *)attribute;

@end
