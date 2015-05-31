//
//  EncodeVideo.m
//  O了
//
//  Created by 化召鹏 on 14-4-21.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "EncodeVideo.h"
#import "NSString+FilePath.h"
@implementation EncodeVideo
static EncodeVideo *encodeVideo=nil;

+(EncodeVideo *)shareEncode{
    
    if (encodeVideo==nil) {
        encodeVideo=[[EncodeVideo alloc] init];
    }
    
    return encodeVideo;
}
-(void)encodeVideoWithUrl:(NSURL *)url whitFinish:(void (^) (encodeType encodeTp,NSDictionary *dict))cb{
    encodeViewSuccess=[cb copy];
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetLowQuality];
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
        
        CFUUIDRef cfuuid = CFUUIDCreate(kCFAllocatorDefault);
        NSString *cfuuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, cfuuid));
        
        NSString * fileName = [NSString stringWithFormat:@"output%@.mp4",cfuuidString];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * fileDoc = [@"andron_video" filePathOfCaches];
        if (![fileManager fileExistsAtPath:fileDoc]) {
            [fileManager createDirectoryAtPath:fileDoc withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString * mp4Path = [[NSString stringWithFormat:@"/andron_video/%@",fileName] filePathOfCaches];
        __block NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:mp4Path,@"filePath",fileName,AssetsPickerMediaName, nil];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                {
                    encodeViewSuccess(encodeFailed,nil);
                    break;
                }
                    
                case AVAssetExportSessionStatusCancelled:
                    encodeViewSuccess(encodeCancel,nil);
                    break;
                case AVAssetExportSessionStatusCompleted:
                    encodeViewSuccess(encodeFinish,dict);
                    break;
                default:
                    break;
            }
            
        }];
    }
}
+(void)releaseEncode{
    encodeVideo=nil;
}
@end
