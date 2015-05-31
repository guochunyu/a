//
//  CreateHttpHeader.h
//  e企
//
//  Created by 许学 on 14/12/6.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateHttpHeader : NSObject

+ (NSString *)createHttpHeaderWithNoce:(NSString*)nonce;

@end
