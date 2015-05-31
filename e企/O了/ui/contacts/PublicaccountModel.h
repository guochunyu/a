//
//  PublicaccountModel.h
//  e企
//
//  Created by roya-7 on 14/11/24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicaccountModel : NSObject
//<logo>http://218.205.81.12/upload/picture/small/3d2a08d6e07045019104aacacdd3f544_small.jpg</logo>
//<name>财务部</name>
//<pa_uuid>5472fd9724ac9b648a6e6cf0</pa_uuid>
//<sip_uri>padata1@pubacct.li726-26</sip_uri>
@property(nonatomic,copy)NSString *logo;///<logo
@property(nonatomic,copy)NSString *name;///<名字
@property(nonatomic,copy)NSString *pa_uuid;///<
@property(nonatomic,copy)NSString *sip_uri;///<
@end
