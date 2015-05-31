//
//  PublicDataParse.m
//  e企
//
//  Created by roya-7 on 14/11/25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "PublicDataParse.h"

@implementation PublicDataParse
+(NotesData *)publicDataParse:(NSXMLElement *)parse{
    NotesData *nd=[[NotesData alloc] init];
    
    nd.sendContents=[parse XMLString];
    
    return nd;
    
}
@end
