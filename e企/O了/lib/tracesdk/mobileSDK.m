//
//  mobileSDK.m
//  MobileSDK
//
//  Created by Dora.Lin on 14-1-21.
//  Copyright (c) 2014年 LiPo. All rights reserved.
//

#import "mobileSDK.h"
#import <AdSupport/AdSupport.h>//idfa
#import "IPAddress.h"//macIp
//#import "JSONKit.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>//定位
#import <CoreTelephony/CTCarrier.h>
#import "Reachability.h"//网络
#import "CommonCrypto/CommonDigest.h"//md5
#import "base64.h"
#import "myDataBase.h"
#import <UIKit/UIKit.h>
#import "buildConfig.h"

//#define checkversionurl @"http://192.168.1.105:8080/TRACEProbeService/accept?"

#define checkversionurl @"http://183.131.13.103:9090/TRACEProbeService/accept?"  //线上服务器
//#define checkversionurl @"http://trace.hotpotpro.com:8080/TRACEProbeService/accept?"//线上服务器
//#define checkversionurl @"http://223.202.47.143:8080/TRACEProbeService/accept?"//线上服务器 新


NSMutableArray * _activityArray;
NSMutableArray * _eventArray;
NSMutableArray * _terminateArray;
NSMutableArray * _launchArray;
NSMutableDictionary * _headDict;
CLLocationManager *_locManager;
NSInteger _groupId;
NSString * _urlStr;
NSMutableData *_receivedData;
BOOL isFirstRun = YES;
BOOL isSubtractDruationTime;
float  _druationTimeBackground;

@implementation mobileSDK

static mobileSDK * _sharedMobileSDK;
+(mobileSDK *)sharedMobileSDK{
    if (!_sharedMobileSDK) {
        _sharedMobileSDK=[[self.class alloc]init];
    }
    return _sharedMobileSDK;
}
-(void)dealloc
{
    [_activityArray release];
    [_eventArray release];
    [_terminateArray release];
    [_launchArray release];
    [_headDict release];
    [_receivedData release];
    [super dealloc];
}
-(id)init
{
    self=[super init];
    if (self) {
        _receivedData=[[NSMutableData alloc]init];
        [base64 base64Initialize];
        [self getLocation];
        _activityArray=[[NSMutableArray alloc]init];
        _eventArray = [[NSMutableArray alloc]init];
        _terminateArray = [[NSMutableArray alloc]init];
        _launchArray = [[NSMutableArray alloc]init];
        _headDict = [[NSMutableDictionary alloc]init];
        //isFirstRun = YES;
        isSubtractDruationTime = NO;
    }
    return self;
}

//获得idfa
-(NSString *)getAdvertisingIdentifier{
    //NSLog(@"%d",[[UIDevice currentDevice].systemVersion intValue]);
    if ([[UIDevice currentDevice].systemVersion intValue]>=6.0) {
        NSString *adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return adId;
    }else{
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * macIp = [userDefaults objectForKey:@"macIp"];
        if (!macIp) {
            macIp = [self createIpAddresses];
            [userDefaults setObject:macIp forKey:@"macIp"];
        }
        return macIp;
    }
}
//获取mac地址
-(NSString *)createIpAddresses{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    int i;
    NSString *deviceIP = nil;
    for (i=0; i<MAXADDRS; ++i)
    {
        static unsigned long localHost = 0x7F000001;            // 127.0.0.1
        unsigned long theAddr;
        theAddr = ip_addrs[i];
        if (theAddr == 0) break;//结束整个循环
        if (theAddr == localHost) continue;//结束单词循环
        //NSLog(@"Name: %s MAC: %s IP: %s\n", if_names[i], hw_addrs[i], ip_names[i]);
        deviceIP = [NSString stringWithFormat:@"%s",hw_addrs[i]];
        
        //decided what adapter you want details for
        if (strncmp(if_names[i], "en", 2) == 0)
        {
           //NSLog(@"Adapter en has a IP of %@", [NSString stringWithFormat:@"%s", ip_names[i]]);
        }
    }
    //NSLog(@"mac:%@",deviceIP);
    return deviceIP;
}

//获得设备型号
-(NSString *)getDeviceType{
    NSString* deviceType =[UIDevice currentDevice].model;
    //NSLog(@"%@",deviceType);
    return deviceType;
}
//系统名称 版本
-(NSString*)getVersion{
//    NSString* systemVersion = [NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
//    NSLog(@"%@",systemVersion);
    return [UIDevice currentDevice].systemVersion;
}
//
-(NSString *)getSession_id{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString * session_id = [NSString stringWithFormat:@"%@%.0f",[self getAdvertisingIdentifier],time*1000];
    //NSString * session_id = [NSString stringWithFormat:@"%.0f",time*1000];
    //NSLog(@"%@",session_id);
    return session_id;
}
//当前类名
//-(NSString *)getClassName{
//    return [NSString stringWithUTF8String:object_getClassName(self)];
//}
//获得时间
-(NSString *)getNSTimeInterval{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    //NSLog(@"%@",currentTime);
    return currentTime;
}
-(NSString *)timeTransformationWithlaunchTime:(NSString *)launchTime andTerminateTime:(NSString *)terminateTime{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    NSDate *launchDate=[formatter dateFromString:launchTime];
    NSDate *terminateDate=[formatter dateFromString:terminateTime];
    float time=[terminateDate timeIntervalSinceDate:launchDate]*1000;
    [formatter release];
    NSString * druationTime = [NSString stringWithFormat:@"%.0f",time];
    //NSLog(@"%@",druationTime);
    return druationTime;
}
//获得time zone 时区
-(NSString*)GetTimeZone{
    
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];//获得当前应用程序默认的时区
    NSString* currentZone = [NSString stringWithFormat:@"%@",zone];
    NSArray * array = [currentZone componentsSeparatedByString:@" "];
    //NSLog(@"tz=\n%@\n%@",currentZone, array);
    if ([array count]>=3) {
        //Asia/Harbin (GMT+08:00) offset 28800
        if ([[array objectAtIndex:1] length] >=5) {
            NSRange range=NSMakeRange(4,[[array objectAtIndex:1] length]-5);//
            NSString *str=[[array objectAtIndex:1] substringWithRange:range];
            //NSLog(@"str:%@",str);
            return str;
        }
        else{
            if ([[array objectAtIndex:2] length]>=3) {
                NSRange range=NSMakeRange(1,[[array objectAtIndex:2] length]-3);//
                NSString *str=[[array objectAtIndex:2] substringWithRange:range];
                //NSLog(@"str:%@",str);
                return str;
            }else{
                return @"unknown";
            }
        }
    }else{
        return @"unknown";
    }
}
//设备分辨率
-(NSString*)GetDeviceResolution{
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    NSString* dpiStr = [NSString stringWithFormat:@"%d*%d",(int)size.height,(int)size.width];
    return dpiStr;
}
//获得当前系统语言
-(NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    //NSLog(@"Preferred Language:%@", preferredLang);
    return preferredLang;
}
//获取运营商
-(NSString* )getCarrier  {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    [info release];
    NSString * str=carrier.carrierName;
    if (str.length>0) {
        return str;
    }else{
        return @"unknown";
    }    
}
-(NSString *)getProgramVersion{
    //NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *) kCFBundleVersionKey];
    return appBuild;
}
//判断网络
-(NSString*)getReachability{
    BOOL twoGisAvailable = [Reachability isNetWorkVia2G];
    BOOL threeGisAvailable = [Reachability isNetWorkVia3G];
    BOOL wifiIsAviable = [Reachability isNetWorkViaWiFi];
    NSString* currentNETStatus;
    if (wifiIsAviable) {
        currentNETStatus = @"WIFI";
    }
    else if(threeGisAvailable){
        currentNETStatus = @"3G";
    }
    else if(twoGisAvailable){
        currentNETStatus = @"2G";
    }
    else{
        currentNETStatus = @"NO CONNECT";
    }
    return currentNETStatus;
}
#pragma mark -
#pragma mark head
-(void)getHeadDictionary{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSMutableDictionary * head = [NSMutableDictionary dictionary];
    [head setObject:[self getAdvertisingIdentifier] forKey:@"24"];// device_mac
    [head setObject:[self getVersion] forKey:@"35"];// os_version
    [head setObject:[self getDeviceType] forKey:@"27"];// device_model
    [head setObject:@"unknown" forKey:@"46"];// cpu
    [head setObject:@"unknown" forKey:@"36"];// country
    [head setObject:[NSNumber numberWithInt:1] forKey:@"33"];// sdk_version
    [head setObject:@"iOS" forKey:@"34"];// os
    [head setObject:[self getAdvertisingIdentifier] forKey:@"25"];// device_id
    [head setObject:[self GetDeviceResolution] forKey:@"39"];// resolution
    [head setObject:@"unknown" forKey:@"26"];// device_imsi
    [head setObject:[self getPreferredLanguage] forKey:@"37"];// language
    [head setObject:@"apple" forKey:@"28"];// device_manufacture
    [head setObject:[NSNumber numberWithInt:8] forKey:@"38"];// timezone  [self GetTimeZone]
    [head setObject:[self getProgramVersion] forKey:@"29"];// app_version 应用程序版本
    [head setObject:[self getCarrier] forKey:@"43"];// carrier
    [head setObject:@"unknown" forKey:@"42"];// access_subtype
    [head setObject:[self getReachability] forKey:@"41"];// access
    [head setObject:@"iphone" forKey:@"32"];// sdk_type
    [head setObject:[NSNumber numberWithInt:0] forKey:@"31"];// version_code
    
    NSString * lat = [userDefaults objectForKey:@"lat"];
    NSString * lng = [userDefaults objectForKey:@"lng"];
    if (lat==nil || [lat length]==0 || lng==nil || [lng length]==0) {
        lat = @"unknown";
        lng = @"unknown";
    }
    [head setObject:lat forKey:@"44"];// lat
    [head setObject:lng forKey:@"45"];// lng
    [head setObject:[userDefaults objectForKey:@"appKey"] forKey:@"5"];// appkey
    NSFileManager *fileManager=[NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[LOGIN_FLAG filePathOfCaches]] && [ConstantObject sharedConstant].userInfo.phone)
    {
        [head setObject:[ConstantObject sharedConstant].userInfo.phone forKey:@"51"];;//user_id
    }else
    {
        [head setObject:@"user" forKey:@"51"];//user_id
    }
    NSString * channelId = [userDefaults objectForKey:@"channelId"];
    if (channelId==nil || [channelId length]==0) {
        channelId = @"和企录";
    }
    [head setObject:channelId forKey:@"52"];//channelId

    [_headDict addEntriesFromDictionary:head];

    //NSLog(@"%@",_headDict);
    
//    [self GetTimeZone];//测试用
    
}
#pragma mark -
#pragma mark Launch
-(void)setLaunchProgram{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString * launchTime = [[mobileSDK sharedMobileSDK] getNSTimeInterval];
    NSString * session_id = [[mobileSDK sharedMobileSDK] getSession_id];
    
    NSMutableDictionary * launch = [NSMutableDictionary dictionary];
    [launch setObject:session_id forKey:@"6"];//session_id
    [launch setObject:launchTime forKey:@"9"];//time
    
    [userDefaults setObject:session_id forKey:@"session_id"];
    [userDefaults setObject:launchTime forKey:@"launchTime"];
    
    [_launchArray addObject:launch];
}
#pragma mark -
#pragma mark Terminate
+(void)setTerminateProgram{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [mobileSDK endActivityWithClassName:[userDefaults objectForKey:@"className"]];
    
    NSString * launchTime = [userDefaults objectForKey:@"launchTime"];
    NSString * terminateTime = [[mobileSDK sharedMobileSDK] getNSTimeInterval];
    NSString * druationTime = [[mobileSDK sharedMobileSDK] timeTransformationWithlaunchTime:launchTime andTerminateTime:terminateTime];
    //NSLog(@"%@",druationTime);
    NSMutableDictionary * terminate = [NSMutableDictionary dictionary];
    [terminate setObject:[userDefaults objectForKey:@"session_id"] forKey:@"6"];//session_id
    [terminate setObject:terminateTime forKey:@"9"];//time
    [terminate setObject:druationTime forKey:@"1"];//druation
//    if (TRACE_ACTIVITY) {
//        NSString * idfa = [[mobileSDK sharedMobileSDK] getAdvertisingIdentifier];
//        NSString * lastChar = [idfa substringFromIndex:[idfa length]-1];
//        //int x = arc4random() % TRACE_ACTIVITY_PERCENTAGE*10+1;
//        if ([lastChar intValue]==1 || [lastChar intValue]==2) {
//             [terminate setObject:_activityArray forKey:@"4"];//activities
//        }else{
//            
//        }
//    }
    [terminate setObject:_activityArray forKey:@"4"];//activities

    [_terminateArray addObject:terminate];
    //NSLog(@"%@",_activityArray);
    [[mobileSDK sharedMobileSDK] saveDeviceInfo];
    
    [userDefaults setObject:terminateTime forKey:@"terminateTime"];//保存程序退出时间
}
+(void)startActivityWithClassName:(NSString *)className{
    //NSLog(@"startActivityWithClassName:   %@",className);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString * nowClassName = [userDefaults objectForKey:@"className"];
    //NSLog(@"nowClassName\n%@",nowClassName);
    if (![nowClassName isEqualToString:className] || isFirstRun) {
        NSString * startActivityTime = [[mobileSDK sharedMobileSDK] getNSTimeInterval];
        [userDefaults setObject:startActivityTime forKey:@"startActivityTime"];
        [userDefaults setObject:className forKey:@"className"];
    }
}
+(void)endActivityWithClassName:(NSString *)className{
    //NSLog(@"endActivityWithClassName:\n%@",className);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString * startActivityTime = [userDefaults objectForKey:@"startActivityTime"];
    NSString * endActivityTime = [[mobileSDK sharedMobileSDK] getNSTimeInterval];
    NSString * druationTime = [[mobileSDK sharedMobileSDK] timeTransformationWithlaunchTime:startActivityTime andTerminateTime:endActivityTime];
    //NSLog(@"%@",druationTime);
    if (isSubtractDruationTime) {
        //NSLog(@"%f",_druationTimeBackground);
        float time = [druationTime floatValue]-_druationTimeBackground;
        druationTime = [NSString stringWithFormat:@"%.0f",time];
        //NSLog(@"%@",druationTime);
        isSubtractDruationTime = NO;
    }
    NSString *saveClassName;
    if (className==Nil) {
        saveClassName = [userDefaults objectForKey:@"className"];
    }else{
        saveClassName = className;
    }
    NSArray * array = [NSArray arrayWithObjects:saveClassName,druationTime, nil];//[userDefaults objectForKey:@"className"]
    //NSLog(@"%@",saveClassName);
    if ([_activityArray count]>0) {
        NSArray * lastarray = [NSArray arrayWithArray:[_activityArray lastObject]];
        NSString * lastClassName;
        if ([lastarray count]>0) {
            lastClassName = [lastarray objectAtIndex:0];
            //NSLog(@"%@",lastClassName);
        }else{
            lastClassName = Nil;
        }
        
        if ([lastClassName isEqualToString:className]) {//防止重复调用
            [_activityArray replaceObjectAtIndex:[_activityArray count]-1 withObject:array];
        }else{
            [_activityArray addObject:array];
        }
    }else{
        [_activityArray addObject:array];
    }
    //NSLog(@"_activityArray:%@",_activityArray);
}
#pragma mark -
#pragma mark event
+(void)setEventWithLable:(NSString *)lable andTag:(NSString *)tag andAttribute:(NSString *)attribute{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSMutableDictionary * event =[NSMutableDictionary dictionary];
    [event setObject:lable forKey:@"17"];// label
    [event setObject:[NSNumber numberWithInt:1] forKey:@"18"];// acc
    [event setObject:tag forKey:@"16"];// tag
    [event setObject:attribute forKey:@"50"];// tag
    [event setObject:[[mobileSDK sharedMobileSDK] getNSTimeInterval] forKey:@"9"];//time
    [event setObject:[userDefaults objectForKey:@"session_id"] forKey:@"6"];//session_id
    [_eventArray addObject:event];
    
}
-(void)saveDeviceInfo {
    NSMutableDictionary * body=[NSMutableDictionary dictionary];
    [body setObject:_launchArray forKey:@"8"];//launch
    [body setObject:_terminateArray forKey:@"11"];//terminate
    [body setObject:_eventArray forKey:@"15"];//event
    NSMutableDictionary * messageDict = [NSMutableDictionary dictionary];
    [messageDict setObject:_headDict forKey:@"19"];//head
    [messageDict setObject:body forKey:@"21"];//body
    
//    NSMutableDictionary * messageDict = [NSMutableDictionary dictionary];
//    [messageDict setObject:message forKey:@"content"];
    
    //NSString * message = [base64 base64EncodeString:[messageDict JSONString]];
    //NSString * message=[self getMd5_32Bit_String:[messageArray JSONString]];
    //NSLog(@"message:%@\n\n\n",[messageDict JSONString]);//
    //NSLog(@"message:%@\n\n\n",[messageArray JSONString]);//    
//    // 返回一个JSON对象
//    
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    NSArray *songArray = [json objectForKey:@"song"];
    
    if ([NSJSONSerialization isValidJSONObject:messageDict])
    {
        NSError *error;
        // 创造一个json从Data, NSJSONWritingPrettyPrinted指定的JSON数据产的空白，使输出更具可读性。
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:messageDict options:NSJSONWritingPrettyPrinted error:&error];
        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //NSLog(@"json data:%@",json);
        _groupId=[[myDataBase sharedMyDataBase] getGroupID];
        _groupId++;
        [[myDataBase sharedMyDataBase] insertData:json groupID:_groupId];
    }
    
//    _groupId=[[myDataBase sharedMyDataBase] getGroupID];
//    _groupId++;
//    //    NSLog(@"groupID:%d",_groupId);
//    [[myDataBase sharedMyDataBase] insertData:[messageDict JSONString] groupID:_groupId];
    
//    [self sendURLConnection];
//    [self setLaunchProgram];
//    [self getHeadDictionary];
    
//    UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"调用launch" delegate:Nil cancelButtonTitle:@"确定" otherButtonTitles:Nil, nil];
//    [alter show];
//    [alter release];
}
- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}
-(void)getLocation{
//    NSInteger intager=[CLLocationManager authorizationStatus];
//    NSLog(@"%d",intager);
    _locManager = [[CLLocationManager alloc] init];
    [_locManager setDelegate:self];
    [_locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    _locManager.distanceFilter = 5.0;
    [_locManager startUpdatingLocation];
    //[self performSelector:@selector(startUpLocation) withObject:nil afterDelay:300];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    CLLocationCoordinate2D loc = [newLocation coordinate];
    NSString *lat =[NSString stringWithFormat:@"%f",loc.latitude];//get latitude
    NSString *lng =[NSString stringWithFormat:@"%f",loc.longitude];//get longitude
    //NSLog(@"%@ %@",lat,lng);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:lat forKey:@"lat"];
    [userDefaults setValue:lng forKey:@"lng"];
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}
#pragma mark -
#pragma mark 开始调用
//sdk入口函数
+(void)startWithAppkey:(NSString *)appKey{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString * startTime = [[mobileSDK sharedMobileSDK] getNSTimeInterval];
    NSString * endTime =[userDefaults objectForKey:@"terminateTime"];
    _druationTimeBackground = [[[mobileSDK sharedMobileSDK] timeTransformationWithlaunchTime:endTime andTerminateTime:startTime] floatValue];
    //NSLog(@"druTime:%f",_druationTimeBackground);
    if (_druationTimeBackground<BACKGROUND_DURATION_TIME && !isFirstRun) {
        NSInteger groupId=[[myDataBase sharedMyDataBase] getGroupID];
        [[myDataBase sharedMyDataBase] removeDataWithId:groupId];
        [_terminateArray removeAllObjects];
        isSubtractDruationTime = YES;
    }else{
        //防止数据重复添加
        [_activityArray removeAllObjects];
        [_launchArray removeAllObjects];
        [_terminateArray removeAllObjects];
        [_eventArray removeAllObjects];
        [_headDict removeAllObjects];
        [userDefaults setObject:appKey forKey:@"appKey"];
        isFirstRun = NO;

        [[mobileSDK sharedMobileSDK] sendURLConnection];
        [[mobileSDK sharedMobileSDK] setLaunchProgram];
        [[mobileSDK sharedMobileSDK] getHeadDictionary];
    }
    
}
//+(void)startWithAppkey:(NSString *)appKey channelId:(NSString *)channelId theCustomURL:(NSString *)url EveryTimeStartSendData:(BOOL)sure{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setObject:appKey forKey:@"appKey"];
//    [userDefaults setObject:channelId forKey:@"channelId"];
//    _urlStr=url;
//    if (sure) {
//        [[mobileSDK sharedMobileSDK] sendURLConnection];
//    }else{
//        [[mobileSDK sharedMobileSDK] SendTheDataOnceADay];
//    }
//    [[mobileSDK sharedMobileSDK] setLaunchProgram];
//    [[mobileSDK sharedMobileSDK] getHeadDictionary];
//}

-(void)SendTheDataOnceADay{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * lastTime = [userDefaults objectForKey:@"currentTime"];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    //NSLog(@"lastTime:%@,currentTime:%@",lastTime,currentTime);
    
    [userDefaults setObject:currentTime forKey:@"currentTime"];
    
    if (![lastTime isEqualToString:currentTime]) {
        [[mobileSDK sharedMobileSDK] sendURLConnection];
    }
}
//发送网络请求
-(void)sendURLConnection{
    NSString * url = (_urlStr==nil)?checkversionurl:_urlStr;
    //NSLog(@"url:%@",url);
    NSDictionary * dict = [[myDataBase sharedMyDataBase] fillData];
    NSArray * array = [NSArray arrayWithArray:[myDataBase sharedMyDataBase].dataArray];
    //NSLog(@"array:%@",array);
    if ([array count]>0 ) {
        for (int i=0;i<[array count];i++) {
            NSString *string = [dict objectForKey:[array objectAtIndex:i]];
            NSString *str = [base64 base64EncodeString:string];
            NSLog(@"content=\n%@\n",string);
            NSString * str2 = [NSString stringWithFormat:@"content=%@",str];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:[str2 dataUsingEncoding:NSUTF8StringEncoding]];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            NSString *len=[NSString stringWithFormat:@"%d",[str length]];
            [request setValue:len forHTTPHeaderField:@"Content-Length"];
            NSURLConnection *aUrlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:true];
            [aUrlConnection start];
            [aUrlConnection release];
        }
    }
}
/*
- (void)httpAsynchronousRequest{    
    NSString * url = (_urlStr==nil)?checkversionurl:_urlStr;
    NSLog(@"url:%@",url);
    NSDictionary * dict = [[myDataBase sharedMyDataBase] fillData];
    NSArray * array = [dict allKeys];
    if ([array count]>0 ) {
        for (int i=0;i<[array count];i++) {
            NSString *string = [dict objectForKey:[array objectAtIndex:i]];
            
            NSString *str = [base64 base64EncodeString:string];
            NSLog(@"body=\n%@\n",string);
            NSString * str2 = [NSString stringWithFormat:@"content=%@",str];
            NSData *postData = [str2 dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
            [request setHTTPMethod:@"POST"];
            [request setHTTPBody:postData];
            [request setTimeoutInterval:10.0];
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                if (error) {
                    NSLog(@"Httperror:%@%d", error.localizedDescription,error.code);
                }else{
                    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"HttpResponseCode:%d", responseCode);
                    NSLog(@"HttpResponseBody %@",responseString);
                }
            }];
        }
    }
}
 */

// 收到响应时, 会触发

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response{
    [_receivedData setLength:0];
    NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
    if (responseCode==200) {
        NSLog(@"HttpResponseCode:%d success", responseCode);
        NSInteger groupId=[[myDataBase sharedMyDataBase] getID];
        [[myDataBase sharedMyDataBase] removeDataWithId:groupId];
//        
//        UIAlertView * alter = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"已发送数据" delegate:Nil cancelButtonTitle:@"确定" otherButtonTitles:Nil, nil];
//        [alter show];
//        [alter release];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_receivedData appendData:data];
    //NSLog(@"接收完数据:data=%@",data);//:data=%@",data
    //判断返回值是否是200
    //http协议  友盟    秒数改为毫秒

}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error  {
    NSLog(@"数据接收错误:%@",error);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection  {
    //NSLog(@"连接完成:%@",connection);
    //[self downLoadFinish:_receivedData];
}

//-(void)downLoadFinish:(NSMutableData*)data
//{
//    NSMutableDictionary *rootDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//    NSLog(@"rootDict%@",rootDict);
//    
//    NSString *receivedString=[rootDict objectForKey:@"ts"];
//    if ([receivedString isEqualToString:@"200"]) {
//        NSInteger groupId=[[myDataBase sharedMyDataBase] getID];
//        [[myDataBase sharedMyDataBase] removeDataWithId:groupId];
//    }
//}


@end





