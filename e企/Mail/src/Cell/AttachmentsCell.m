//
//  AttachmentsCell.m
//  e企
//
//  Created by 陆广庆 on 15/1/17.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import "AttachmentsCell.h"
#import "LogicHelper.h"

@interface AttachmentsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iImageView;
@property (weak, nonatomic) IBOutlet UILabel *iTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *iSizeLabel;


@end

@implementation AttachmentsCell

- (void)configureWithAttachment:(NSString *)filePath
{
    _iTitleLabel.text = [filePath lastPathComponent];
    _iImageView.image = [self thumbnail:filePath];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    _iSizeLabel.text = [LogicHelper attachmentSize:[data length]];
}

- (UIImage *)thumbnail:(NSString *)fileName
{
    if ([fileName hasSuffix:@".xls"] || [fileName hasSuffix:@".XLS"] ||
        [fileName hasSuffix:@".csv"] || [fileName hasSuffix:@".CSV"] ||
        [fileName hasSuffix:@".xlsm"] || [fileName hasSuffix:@".XLSM"] ||
        [fileName hasSuffix:@".xlsx"] || [fileName hasSuffix:@".XLSX"]) {
        return [UIImage imageNamed:@"ic_exl"];
    }
    if ([fileName hasSuffix:@".pdf"] || [fileName hasSuffix:@".PDF"]) {
        return [UIImage imageNamed:@"ic_pdf"];
    }
    if ([fileName hasSuffix:@".ppt"] || [fileName hasSuffix:@".PPT"] || [fileName hasSuffix:@".pptx"] || [fileName hasSuffix:@".PPTX"]) {
        return [UIImage imageNamed:@"ic_ppt"];
    }
    if ([fileName hasSuffix:@".txt"] || [fileName hasSuffix:@".TXT"]) {
        return [UIImage imageNamed:@"ic_txt"];
    }
    if ([fileName hasSuffix:@".doc"] || [fileName hasSuffix:@".DOC"] || [fileName hasSuffix:@".docx"] || [fileName hasSuffix:@".DOCX"]) {
        return [UIImage imageNamed:@"ic_word"];
    }
    if ([fileName hasSuffix:@"ic_exl"]) {
        return [UIImage imageNamed:@"ic_pdf"];
    }
    if ([fileName hasSuffix:@".png"] || [fileName hasSuffix:@".PNG"] || [fileName hasSuffix:@".jpg"] || [fileName hasSuffix:@".JPG"]) {
        UIImage *image = [UIImage imageWithContentsOfFile:fileName];
        return image;
    }
    return [UIImage imageNamed:@"file"];
}

@end
