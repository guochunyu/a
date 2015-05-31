//
//  MailEditHandler.m
//  EnterpriseMail
//
//  Created by 陆广庆 on 14/12/15.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "MailEditHandler.h"
#import "MailEditController.h"
#import "MailEditRouter.h"
#import "MailLogic.h"
#import "Email.h"
#import "LogicHelper.h"
#import "AppNotificationCenter.h"


@import AssetsLibrary;

@interface MailEditHandler ()

@property (nonatomic) EmailAccount *account;
@property (nonatomic) Email *email;
@property (nonatomic) EmailSendType type;
@property (nonatomic) ALAssetsLibrary *library;

@end


@implementation MailEditHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        [AppNotificationCenter registerNotification:AppNotificationTypePhotoAlbumSelectCompleted receiver:self action:@selector(showSelectedPhotoFromAlbum:)];
    }
    return self;
}

- (void)dealloc
{
    [AppNotificationCenter removeNotification:AppNotificationTypePhotoAlbumSelectCompleted receiver:self];
}

- (void)initData
{
    _library = [ALAssetsLibrary new];
    _account = _userInfo[@"account"];
    _type = [_userInfo[@"type"] integerValue];
    _email = _userInfo[@"email"];
    if (_email != nil) {
        [_controller setValue:_email forKey:@"email"];
    }
    
    [_controller setValue:@(_type) forKey:@"type"];
    [_controller setValue:_account forKey:@"account"];
    NSArray *accounts = [EmailAccount listAccounts];
    [_controller setValue:accounts forKey:@"accounts"];
}

- (void)cancel:(BOOL)recv
{
    if (recv) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"recvBox" object:nil];
    }
    [_router popViewController];
}

- (void)sendWithSubject:(NSString *)subject body:(NSString *)body to:(NSArray *)to cc:(NSArray *)cc files:(NSArray *)files
{
#warning 附件处理
    NSMutableArray *arr = [NSMutableArray new];
    NSUInteger dataLength = 0;
    for (NSObject *obj in files) {
        if ([obj isKindOfClass:[ALAsset class]]) {
            ALAsset *asset = (ALAsset *)obj;
            NSData *data = [self assetData:asset];
            dataLength += data.length;
            NSDictionary *dict = @{asset.defaultRepresentation.filename : data};
            [arr addObject:dict];
        } else if ([obj isKindOfClass:[UIImage class]]) {
            NSData *data = UIImageJPEGRepresentation((UIImage *)obj, 0.5);
            dataLength += data.length;
            NSDictionary *dict = @{@"IMG.jpg" : data };
            [arr addObject:dict];
        } else if ([obj isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)obj;
            name = [name lastPathComponent];
            NSData *data = [NSData dataWithContentsOfFile:(NSString *)obj];
            dataLength += data.length;
            NSDictionary *dict = @{name : data };
            [arr addObject:dict];
        } else {
            Attachment *att = (Attachment *)obj;
            NSString *path = [LogicHelper getLocalFilePath:att.filename];
            NSData *data = [NSData dataWithContentsOfFile:path];
            dataLength += data.length;
            NSDictionary *dict = @{att.filename : data};
            [arr addObject:dict];
        }
    }
    if (dataLength / 1024 / 1024 >= 30) {
        [_controller onSendCompleted:NO desc:@"附件大小超过30M，发送失败。"];
        return;
    }
    
    [MailLogic sendEmailWithAccount:_account to:to cc:cc subject:subject body:body files:arr completion:^(NSError *error) {
        if (error) {
            [_controller onSendCompleted:NO desc:[error localizedDescription]];
        } else {
            [_controller onSendCompleted:YES desc:nil];
        }
    }];
}

- (NSData *)assetData:(ALAsset *)asset
{
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    long long size = representation.size;
    NSUInteger usize = (unsigned int)size;
    NSMutableData *rawData = [[NSMutableData alloc] initWithCapacity:usize];
    void *buffer = [rawData mutableBytes];
    [representation getBytes:buffer fromOffset:0 length:usize error:nil];
    NSData *assetData = [[NSData alloc] initWithBytes:buffer length:usize];
    return assetData;
}

- (void)selectPhotos
{
    [_router presentPhotoAlbumsController:@{@"ALAssetsLibrary" : _library,
                                            @"maxPhotoCount" : @(3),
                                            @"caller" : self}];

}

#warning 选择附件
- (void)showSelectedPhotoFromAlbum:(NSNotification *)nc
{
    NSDictionary *dic = nc.userInfo;
    NSArray *photos = dic[@"photos"];
    if ([photos count] > 0) {
        [_controller addFiles:photos];
    }
    
    //[_userInterface showSelectedPhotoFromAlbum:photos];
}

- (void)changeAccount:(EmailAccount *)account
{
    _account = account;
}

@end
