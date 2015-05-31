//
//  AttachmentsView.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/21.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "AttachmentsView.h"
#import "LogicHelper.h"
#import "Attachment.h"
#import "UIImage+Scaling.h"

#define DANGCHUSHIYAOFENKAIFENKAIJIUFENKAI [UIScreen mainScreen].bounds.size.height

static const CGFloat kSpacingH = 0;
static const CGFloat kSpacingV = 4;
static const CGFloat kAttItemHeight = 60;
static const CGFloat kTitleHeight = 30;
static const CGFloat kImageSize = 30;
@import AssetsLibrary;

@interface AttachmentsView () 

@property (nonatomic) NSArray *attachments;
@property (nonatomic) CGFloat height;
@property (nonatomic) BOOL send;

@end

@implementation AttachmentsView
{
    NSMutableArray *selectedPath;
}

- (instancetype)initWithAttachments:(NSArray *)attachments
{
  
    self = [super init];
    if (self) {
        _send = NO;
        _attachments = attachments;
        [self setup];
    }
    return self;
}

- (instancetype)initWithSendAttachments:(NSArray *)attachments
{

    self = [super init];
    if (self) {
        _send = YES;
        _attachments = attachments;
        [self setup];
        
    }
    return self;
}

- (void)setup
{

   
    NSUInteger count = [_attachments count];
    if (count == 0) {
        return;
    }
    CGFloat y = 0;

    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(kSpacingH, y, ABDEVICE_SCREEN_WIDTH - kSpacingH * 2, (kAttItemHeight + 2) * count + kTitleHeight + 2)];
    //wrapper.layer.borderWidth = 2.0;
    //wrapper.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //wrapper.layer.cornerRadius = 6.0;
    wrapper.userInteractionEnabled = YES;
    [self addSubview:wrapper];
    
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(kSpacingH, kSpacingV, ABDEVICE_SCREEN_WIDTH, kTitleHeight)];
    _title.font = [UIFont systemFontOfSize:12];
    _title.textColor = [UIColor lightGrayColor];
    _title.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    _title.text = [NSString stringWithFormat:@"   附件:共       个"];
    [wrapper addSubview:_title];
    
    UILabel*titles = [[UILabel alloc]initWithFrame:CGRectMake(kSpacingH+51.5, kSpacingV+10, 23, 10)];
    titles.font = [UIFont systemFontOfSize:12];
    titles.textColor = [UIColor colorWithRed:54.0/255.0 green:103.0/255.0 blue:202.0/255.0 alpha:1.0];
    titles.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
    titles.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
    titles.textAlignment = UITextAlignmentCenter;
    [wrapper addSubview:titles];
    
    y += kTitleHeight;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, wrapper.frame.size.width, 1)];
    [wrapper addSubview:line];
    y += 2;
    
    CGFloat itemW = wrapper.frame.size.width;
    selectedPath = [NSMutableArray new];
    for (NSInteger i = 0; i < count; i++) {
        NSString *fileName;
        NSString *fileSize;
        
        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(0, y, itemW, kAttItemHeight)];
        [wrapper addSubview:itemView];
        y += kAttItemHeight;
//        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(kSpacingH, (kAttItemHeight - kImageSize) / 2, kImageSize, kImageSize)];
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, kImageSize, kImageSize)];
        image.contentMode = UIViewContentModeScaleToFill;
        if ([_attachments[i] isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)_attachments[i];
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            long long size = representation.size;
            NSUInteger usize = (unsigned int)size;
            fileName = representation.filename;
            fileSize = [LogicHelper attachmentSize:usize];
            UIImage *img = [UIImage imageWithCGImage:asset.thumbnail];
            image.image = img;
            [itemView addSubview:image];
            NSString *filePath = [LogicHelper sandboxFilePath:fileName];
            NSData *data = UIImageJPEGRepresentation(img, 0.5);
            [data writeToFile:filePath atomically:YES];
            
            [selectedPath addObject:[NSURL fileURLWithPath:filePath]];
        } else if ([_attachments[i] isKindOfClass:[UIImage class]]) {
            UIImage *img = _attachments[i];
//            fileName = representation.filename;
//            fileSize = [LogicHelper attachmentSize:[];
//
            image.image = img;
            NSData *data = UIImageJPEGRepresentation(img, 0.5);
            NSString *filePath = [LogicHelper sandboxFilePath:@"tmp.JPG"];
            [data writeToFile:filePath atomically:YES];

            [selectedPath addObject:filePath];
            [itemView addSubview:image];
        } else if ([_attachments[i] isKindOfClass:[NSString class]]) {
            NSString *filePath = _attachments[i];
            image.image = [self thumbnail:filePath];
            fileName = [filePath lastPathComponent];
//            NSData *data = [NSData dataWithContentsOfFile:filePath];
//            fileSize = [LogicHelper attachmentSize:[data length]];
            NSNumber *size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] objectForKey:@"NSFileSize"];;
            fileSize = [LogicHelper attachmentSize:[size intValue]];
            [itemView addSubview:image];
            [selectedPath addObject:[NSURL fileURLWithPath:filePath]];
        } else {
            Attachment *att = (Attachment *)_attachments[i];
            fileName = att.filename;
            NSString *filePath = [LogicHelper sandboxFilePath:fileName];
           
//            NSData *data = [NSData dataWithContentsOfFile:filePath];
//            fileSize = [LogicHelper attachmentSize:[data length]];
            NSNumber *size = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] objectForKey:@"NSFileSize"];;
            fileSize = [LogicHelper attachmentSize:[size intValue]];
            image.image = [self thumbnail:filePath];
            [itemView addSubview:image];
            [selectedPath addObject:[NSURL fileURLWithPath:filePath]];
        }

        //[self kaishi];
        
//        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, y, wrapper.frame.size.width, 1)];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, y, wrapper.frame.size.width-15, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        if (i < count - 1)
        {
            [wrapper addSubview:line];
        }
        y += 2;
        
        
//        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(kSpacingH * 2 + kImageSize, kSpacingV, 200, 21)];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 200, 21)];
        title.textColor = [UIColor blackColor];
        title.text = fileName;
        [itemView addSubview:title];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 200, 21)];
        desc.textColor = [UIColor lightGrayColor];
        desc.font = [UIFont systemFontOfSize:13];
        desc.text = fileSize;
        [itemView addSubview:desc];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = CGRectMake(itemW - kSpacingH - kImageSize, (kAttItemHeight - kImageSize) / 2, kImageSize, kImageSize);
        button.frame = CGRectMake(260, 10, kImageSize, kImageSize);
        button.tag = i;
        UIImage *img;
        if (_send) {
            img = [UIImage imageNamed:@"deleteImage"];
        } else {
            img = [UIImage imageNamed:@"3_icon_click-download"];
        }
        
        [button setImage:img forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didAttachmentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [itemView addSubview:button];
        
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemViewClick:)];
        [itemView addGestureRecognizer:tap];
    }
    _height = y;
}
/*
-(void)kaishi{
    
    NSNotificationCenter*center=[NSNotificationCenter defaultCenter];
    NSNotification*notification=[NSNotification notificationWithName:notificationName object:nil userInfo:nil];

    [center postNotification:notification];
}
*/
- (UIImage *)thumbnail:(NSString *)fileName
{

    NSString *lowerFileName = [fileName lowercaseString];
    if ([lowerFileName hasSuffix:@".xls"] || [lowerFileName hasSuffix:@".csv"] || [lowerFileName hasSuffix:@".xlsm"] || [lowerFileName hasSuffix:@".xlsx"]) {
        return [UIImage imageNamed:@"ic_exl"];
    }
    if ([lowerFileName hasSuffix:@".pdf"]) {
        return [UIImage imageNamed:@"ic_pdf"];
    }
    if ([lowerFileName hasSuffix:@".ppt"] || [lowerFileName hasSuffix:@".pptx"]) {
        return [UIImage imageNamed:@"ic_ppt"];
    }
    if ([lowerFileName hasSuffix:@".txt"]) {
        return [UIImage imageNamed:@"ic_txt"];
    }
    if ([lowerFileName hasSuffix:@".doc"] || [lowerFileName hasSuffix:@".docx"]) {
        return [UIImage imageNamed:@"ic_word"];
    }
    if ([lowerFileName hasSuffix:@"ic_exl"]) {
        return [UIImage imageNamed:@"ic_pdf"];
    }
    if ([lowerFileName hasSuffix:@".png"] || [lowerFileName hasSuffix:@".PNG"] || [lowerFileName hasSuffix:@".jpg"] || [lowerFileName hasSuffix:@".JPG"] || [lowerFileName hasSuffix:@".jpeg"] || [lowerFileName hasSuffix:@".JPEG"] || [lowerFileName hasSuffix:@".bmp"] || [lowerFileName hasSuffix:@".BMP"]) {
        UIImage *image = [UIImage imageWithContentsOfFile:fileName];
        CGSize size = CGSizeMake(64, 64);
        return [image imageByScalingToSize:size];
    }
    return [UIImage imageNamed:@"file"];
}

- (CGFloat)viewHeight
{
    
    return _height;
}

- (void)didAttachmentButtonClick:(UIButton *)sender
{
     DDLogCInfo(@"点击删除附件时调用");
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didAttachmentClick:)]) {
        [_delegate didAttachmentClick:_attachments[sender.tag]];
    }
}

- (void)itemViewClick:(UITapGestureRecognizer *)tap
{
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(didAttachmentItemClick:)]) {
        NSInteger i = [tap view].tag;
        if (![selectedPath[i] isMemberOfClass:[NSURL class]]) {
            return;
        }
        NSURL *url = selectedPath[i];
        [_delegate didAttachmentItemClick:url];
    }
}

@end
