//
//  ConstantObject.m
//  JSSLSJB_address
//
//  Created by 化召鹏 on 14-7-23.
//  Copyright (c) 2014年 a. All rights reserved.
//

#import "ConstantObject.h"
#import <AVFoundation/AVFoundation.h>

@implementation ConstantObject
static ConstantObject *constantObject=nil;
+(ConstantObject *)sharedConstant{
    if (!constantObject) {
        constantObject=[[ConstantObject alloc] init];
    }
//    DDLogInfo(@"constantObject-->:%@",constantObject);
    return constantObject;
}
+(AppDelegate *)app{
    AppDelegate *app=(AppDelegate *)[UIApplication sharedApplication].delegate;
    return app;
}
-(id)init{
    self=[super init];
    if (self) {
        [self selfNum];
        [self selfName];
    }
    return self;
}
-(NSString *)selfNum{
    if (self.myNum.length<=0) {
        //不存在的清空下才去获取
        self.myNum=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
        if (!self.myNum) {
            //如果还是为空,返回空字符串
            self.myNum=@"";
            return @"";
        }
    }
    
    return self.myNum;
}

#pragma mark - 获取个人信息
- (NSDictionary *)selfUserInfo{
    if (!self.selfUserInfo) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        self.selfUserInfo=[userDefaults objectForKey:MyUserInfo];
    }
    return self.selfUserInfo;
}
- (NowLoginUserInfo *)userInfo{
    if (!_userInfo || !_userInfo.imacct) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        NSDictionary *dict=[userDefaults objectForKey:MyUserInfo];
        _userInfo=[[NowLoginUserInfo alloc] initWithDictionary:dict];
//        NSDictionary *loginDict=[userDefaults objectForKey:myLoginUserInfo];
        
    }
    return _userInfo;
}
-(NSString *)selfName{
    
    NSString *num=self.myNum;
    if (num.length<=0) {
        num=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
        if (num<=0) {
            //如果手机号还是为空,直接返回为空
            self.myName=@"";
            return @"";
        }
    }
    
    return self.myName;
}
-(BOOL)avdioGranted{
    __block BOOL RESULT=NO;
    
    if (IS_IOS_7) {
        
        if (avdioGrantedStr) {
            if ([avdioGrantedStr isEqualToString:@"1"]) {
                RESULT=YES;
            }else{
                RESULT=NO;
            }
        }else{
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                if (granted) {
                    // 用户同意获取数据
                    RESULT=YES;
                    avdioGrantedStr=@"1";
                    //                [self allocButtAudio:button];
                } else {
                    // 可以显示一个提示框告诉用户这个app没有得到允许？
                    
                    //                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"麦克风被禁用" message:@"请在iPhone的\"设置-隐私-麦克风\"中允许O了访问你的麦克风." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    //                [alert show];
                    avdioGrantedStr=@"0";
                    RESULT=NO;
                }
            }];
        }
        
        
    }else{
        RESULT=YES;
        avdioGrantedStr=@"1";
    }
    
    
    
    return RESULT;
    
}

- (NSString *)customTel{
    
    NSString *tel=@"13988888888";
    
    return tel;
}
- (NSString *)customTelPass{
    NSString *pass=@"szoa1234";
    return pass;
}
- (NSArray *)faceNameArray{
    
    NSArray *faceNameArray=[[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"expression_custom" ofType:@"plist"]];
    if (faceNameArray) {
        return faceNameArray;
    }else{
        return nil;
    }
}

#pragma mark - text

-(NSString *)originalFaceText:(NSString *)textStr{

    
    NSArray *emojis = nil;
    NSRegularExpression *customEmojiRegularExpression=[[NSRegularExpression alloc] initWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    if (customEmojiRegularExpression) {
        //自定义表情正则
        emojis = [customEmojiRegularExpression matchesInString:textStr
                                                            options:NSMatchingWithTransparentBounds
                                                              range:NSMakeRange(0, [textStr length])];
    }
    NSUInteger location = 0;
    
    NSMutableString *mutableStr=[[NSMutableString alloc] init];
    
    for (NSTextCheckingResult *result in emojis){
        
        
        NSRange range = result.range;
        NSString *subStr = [textStr substringWithRange:NSMakeRange(location, range.location - location)];
        
        if (subStr.length>0) {
            [mutableStr appendString:subStr];
        }
        
        NSString *emojiKey = [textStr substringWithRange:range];
        location = range.location + range.length;
        
//        NSString *faceIndexStr=[emojiKey substringWithRange:NSMakeRange(1, emojiKey.length-2)];
        
        if([self.faceNameArray containsObject:emojiKey]){
            //存在,
            
            int faceIndex=[self.faceNameArray indexOfObject:emojiKey]+1;
            
            if (faceIndex<10) {
                emojiKey=[NSString stringWithFormat:@"[0%d]",faceIndex];
            }else{
//                str=[NSString stringWithFormat:@"[%d]",i-i/21];
                emojiKey=[NSString stringWithFormat:@"[%d]",faceIndex];
            }
            
        }
        [mutableStr appendString:emojiKey];

        
    }
    if (location < [textStr length]) {
        NSRange range = NSMakeRange(location, [textStr length] - location);
        NSString *endStr = [textStr substringWithRange:range];
        [mutableStr appendString:endStr];
    }
    
    return mutableStr;
}


-(void)releaseAllValue{
    if (constantObject) {
        constantObject=nil;
    }
    
}
//self.customEmojiRegularExpression =
@end
