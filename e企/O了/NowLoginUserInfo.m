//
//  NowLoginUserInfo.m
//  e企
//
//  Created by roya-7 on 14/11/4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "NowLoginUserInfo.h"
//{"time":"2014-11-04 10:29:23","status":1,"data":{"uid":"13912341004","phone":"13912341004","shortnum":"111111","orgid":[4249],"email":"请输入邮件账号","duty":["员工"],"department":["研发部门"],"name":"ios004","qrcard":"","avatar":"http://218.205.81.12/upload/picture/middle/2000.jpg","imacct":"+8613912341004_3398351030"},"msg":"获取个人信息成功"}
//@property (nonatomic, copy) NSString *phone;///<手机号码
//@property (nonatomic, copy) NSString *qrcard;
//@property (nonatomic, copy) NSString *uid;///<uid,
//@property (nonatomic, copy) NSString *imacct;///<openfire登录帐号
//@property (nonatomic, strong) NSArray *duty;
//@property (nonatomic, copy) NSString *avatar;///<头像url
//@property (nonatomic, strong) NSArray *orgid;
//@property (nonatomic, copy) NSString *email;///<邮箱
//@property (nonatomic, strong) NSArray *department;
//@property (nonatomic, copy) NSString *shortnum;///<短号
//@property (nonatomic, copy) NSString *name;///<名字
@implementation NowLoginUserInfo
-(id)initWithDictionary:(NSDictionary *)dict{
    self=[super init];
    if (self && dict) {
        NSDictionary *dataDict=dict[@"data"];
        if ([dataDict isKindOfClass:[NSDictionary class]] &&
            [dataDict count] > 0)
        {
            self.phone=dataDict[@"phone"];
            self.qrcard=dataDict[@"qrcard"];
            self.uid=dataDict[@"uid"];
            NSString *imacct = dataDict[@"imacct"];
            NSRange range = [imacct rangeOfString:E_APP_KEY];
            if(!(range.location == NSNotFound))
            {
                imacct = [imacct stringByReplacingOccurrencesOfString:E_APP_KEY withString:@""];
            }
            self.imacct=imacct;
            self.duty=dataDict[@"duty"];
            self.avatar=dataDict[@"avatar"];
            
            self.orgid=dataDict[@"orgid"];
            self.email=dataDict[@"email"];
            self.department=dataDict[@"department"];
            self.shortnum=dataDict[@"shortnum"];
            self.name=dataDict[@"name"];
            self.time=dict[@"time"];
            self.gid = dataDict[@"gid"];
        }
    }
    return self;
}
@end
