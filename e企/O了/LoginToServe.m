//
//  LoginToServe.m
//  O了
//
//  Created by 化召鹏 on 14-5-9.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "LoginToServe.h"
#import "Keychain.h"
#import "sys/utsname.h"
#import "NSData+Base64.h"
#import "CrypoUtil.h"
#import "AppDelegate.h"

@implementation LoginToServe
NSString *nonce;
int my_login_count=0;
+(void)loginToServe{
    NSString *password=[[NSUserDefaults standardUserDefaults] objectForKey:myPassWord];
    NSString *phoneNum=[[NSUserDefaults standardUserDefaults] objectForKey:MOBILEPHONE];
    NSString *passMd5=[CrypoUtil md5:password];
    NSData *strData=[passMd5 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Md5=[strData base64EncodedString];
    NSString *md5Str=[NSString stringWithFormat:@"%@%@%@",nonce,phoneNum,base64Md5];
    
    NSString *md5Str_1=[CrypoUtil md5:md5Str];
    NSString *headStr=[[md5Str_1 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
    
    AFClient *afClicent=[AFClient sharedClient];
    
    if (nonce) {
        [afClicent setHeaderValue:[NSString stringWithFormat:@"user=\"%@\",response=\"%@\"",phoneNum,headStr] headerKey:@"Authorization"];
    }
    [afClicent postPath:@"eas/login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        my_login_count=0;
        
        [[NSUserDefaults standardUserDefaults] setObject:phoneNum forKey:MOBILEPHONE];
        //存储密码
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:myPassWord];
        
        [self getMineInfo];
        
        AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [delegate enterMain];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        my_login_count++;
        
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"JSESSIONID"]) {
                [[NSUserDefaults standardUserDefaults]setObject:cookie.value forKey:JSSIONID];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
        NSDictionary *ddd=operation.response.allHeaderFields;
        DDLogInfo(@"ddd==%@",ddd);
        if ([[ddd objectForKey:@"Www-Authenticate"] isKindOfClass:[NSString class]]) {
            nonce=[ddd objectForKey:@"Www-Authenticate"];
        }
//        NSString *SetCookieStr=[ddd objectForKey:@"Set-Cookie"];
//        NSArray *tempArray=[SetCookieStr componentsSeparatedByString:@";"];
//        NSString *ssionId=tempArray[0];
//        DDLogInfo(@"ssionId====%@",ssionId);
        if (error && my_login_count<5) {
            [self loginToServe];
        }else{
            [afClicent releaseAFClient];
            nonce=nil;
            my_login_count=0;
            AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            delegate.isChangeIp = YES;
            [delegate login];
            
        }
    }];
}
#pragma mark-获得个人信息
+(void)getMineInfo
{
    
    NSString *gid=[[NSUserDefaults standardUserDefaults] objectForKey:myGID];
    NSString *cid=[[NSUserDefaults standardUserDefaults] objectForKey:myCID];
    
    NSDictionary *dict=@{@"cid": cid?cid:@"",
                         @"gid":gid?gid:@"",
                         @"version": nowVersion?nowVersion:@""};
    //    NSMutableArray * userArray=[NSMutableArray arrayWithCapacity:0];
    AFClient * client=[AFClient sharedClient];
    [client postPath:@"eas/userinfo" parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * dic=[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:nil];
        DDLogInfo(@"%@",dic);
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setObject:dic forKey:MyUserInfo];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DDLogInfo(@"获取个人信息成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginToServeSucceed" object:nil];
        //[self getPublicData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogInfo(@"获取个人信息失败");

    }];
    
}
//获取已关注公众号数据
+(void)getPublicData{
    [[PublicAccountClient sharedPublicClient] requestOperationWithMsgname:@"queryusersub" withVersion:@"1.0.0" withBodyStr:[PublicAccountClient xmlQueryusersubWithPagesize:pageSize withPageNum:@"1"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"s---%@",operation.responseString);

        NSError *error=nil;
        NSXMLElement *content_message=[[DDXMLElement alloc] initWithXMLString:operation.responseString error:&error];
        if (error) {
            DDLogInfo(@"解析出错");
        }
        NSArray *publicaccounts=[content_message elementsForName:@"publicaccounts"];
        NSArray *_arraySNInfo=[[SqliteDataDao sharedInstanse] queryPublicDataWithPa_uuid];
        if (publicaccounts.count==0) {
            
            //清空
            for (PublicaccountModel *publicModel in _arraySNInfo) {
                [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:publicModel.pa_uuid];
                [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:publicModel.pa_uuid];
                [[SqliteDataDao sharedInstanse] deletePublicDataWithPa_uuid:publicModel.pa_uuid];
                
            }
            if (_arraySNInfo.count>0) {
                //  取消关注公众号，刷新聊天列表
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
            }
            
        }else{
            NSMutableArray *publicArray=[[NSMutableArray alloc] init];
            NSMutableArray *pa_uuidArray=[[NSMutableArray alloc] initWithArray:_arraySNInfo];
            for (NSXMLElement *element in publicaccounts) {
                PublicaccountModel *pm=[[PublicaccountModel alloc] init];
                pm.logo=[[element elementForName:@"logo"] stringValue];
                pm.name=[[element elementForName:@"name"] stringValue];
                pm.pa_uuid=[[element elementForName:@"pa_uuid"] stringValue];
                pm.sip_uri=[[element elementForName:@"sip_uri"] stringValue];
                [publicArray addObject:pm];
                for (int i=0;i<pa_uuidArray.count;) {
                    PublicaccountModel *publicModel = [pa_uuidArray objectAtIndex:i];
                    if ([publicModel.pa_uuid isEqualToString:pm.pa_uuid]) {
                        [pa_uuidArray removeObject:publicModel];
                    }else{
                        i++;
                    }
                }
            }
            BOOL isDelete=NO;
            for (PublicaccountModel *publicModel in pa_uuidArray) {
                isDelete=YES;
                [[SqliteDataDao sharedInstanse] deleteChatDataWithToUserId:publicModel.pa_uuid];
                [[SqliteDataDao sharedInstanse] deleteChatListWithToUserId:publicModel.pa_uuid];
                [[SqliteDataDao sharedInstanse] deletePublicDataWithPa_uuid:publicModel.pa_uuid];
            }
            if (isDelete) {
                //  取消关注公众号，刷新聊天列表
                [[NSNotificationCenter defaultCenter] postNotificationName:@"haveSendMessage" object:nil];
            }
            [[SqliteDataDao sharedInstanse] insertDataToPublicData:publicArray];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[ConstantObject app] showWithCustomView:nil detailText:@"无法连接到网络,请稍候重试!" isCue:1 delayTime:1 isKeyShow:NO];
    }];
}

@end
