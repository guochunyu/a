//
//  AnalysisJsonUtil.h
//  O了
//
//  Created by royasoft on 14-2-11.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotesData.h"
@interface AnalysisJsonUtil : NSObject

//重返回的json数据中构建NotesData
+(NotesData *)getNotesDataFromMessageModelJson:(MessageModel *)msg;

+(NSMutableDictionary *)analysisMsg:(MessageModel *)msg;
@end
