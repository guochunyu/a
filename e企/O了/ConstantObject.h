//
//  ConstantObject.h
//  JSSLSJB_address
//
//  Created by 化召鹏 on 14-7-23.
//  Copyright (c) 2014年 a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "menber_info.h"
#import "ConstantObject.h"
#import "NowLoginUserInfo.h"

static int const task_reply_text_max_length=10;///<任务回复的最大字数
static int const task_Receipt_length=100;///<任务回执列表每页的数量
static int const task_list_count=30;///<任务列表每页的数量
static int const my_app_listSize=100;///<我的应用,每次加载的数量

@interface ConstantObject : NSObject{
    
    NSString *avdioGrantedStr;///<麦克风的权限,0为允许,1为不允许
    
}
@property(nonatomic,copy)NSString *myNum;//手机号
@property(nonatomic,copy)NSString *myName;//名字

@property(nonatomic,copy)NSString *selfNum;///<当前登录用户手机号
@property(nonatomic,copy)NSString *selfName;///<当前登录用户名字


@property(nonatomic,strong)NSDictionary *selfUserInfo;///<个人信息
@property(nonatomic,strong)NowLoginUserInfo *userInfo;///<个人信息
+(ConstantObject *)sharedConstant;
+(AppDelegate *)app;


-(BOOL)avdioGranted;///<麦克风的权限


@property(nonatomic,copy)NSString *customTel;///<自定义的一个帐号,可以绕过yd123456和验证码登录.
@property(nonatomic,copy)NSString *customTelPass;///<自定义的帐号密码




#pragma mark - 表情数组,用于表情键盘,和[01]转换到汉字

@property(nonatomic,strong)NSArray *faceNameArray;///<表情名字数组

-(NSString *)originalFaceText:(NSString *)textStr;///<把表情的汉字替换为数字,实现和安卓的互通


#pragma mark - 群组相关
@property(nonatomic,assign)BOOL isHaveLoadRoomList;///<是否加载过群聊列表,默认为NO

-(void)releaseAllValue;///<释放单例


@end
