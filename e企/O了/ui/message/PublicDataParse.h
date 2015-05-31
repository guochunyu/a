//
//  PublicDataParse.h
//  e企
//
//  Created by roya-7 on 14/11/25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotesData.h"

@interface PublicDataParse : NSObject

@property(nonatomic,assign)NSInteger publicType;///<公众号消息类型,10文本,20图片,50图文

#pragma mark - 图文相关
@property(nonatomic,copy)NSString *author;///<作者
@property(nonatomic,copy)NSString *digest;///<描述
@property(nonatomic,copy)NSString *major_article;///<是否是主要的
@property(nonatomic,copy)NSString *source_link;///<服务号详情url


@property(nonatomic,copy)NSString *createtime;///<时间
@property(nonatomic,copy)NSString *media_uuid;///<uuid
@property(nonatomic,copy)NSString *title;///<标题
@property(nonatomic,copy)NSString *original_link;///<图片url
@property(nonatomic,copy)NSString *thumb_link;///<小图
#pragma mark - 图片相关
@property(nonatomic,copy)NSString *fileSize;///<图片大小


//+(NotesData *)publicDataParse:(NSXMLElement *)parse;
@end
