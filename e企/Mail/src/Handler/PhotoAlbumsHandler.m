//
//  PhotoAlbumsHandler.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import AssetsLibrary;
#import "PhotoAlbumsHandler.h"
#import "PhotoAlbumsRouter.h"

@interface PhotoAlbumsHandler ()

//相册 K:相册名 V:照片array
@property (nonatomic) NSMutableDictionary *albumsDic;
//所有照片
@property (nonatomic) NSMutableArray *photos;
//相册
@property (nonatomic) NSMutableArray *albums;

@property (nonatomic, weak) ALAssetsLibrary *library;

@end

@implementation PhotoAlbumsHandler

- (void)initDataForUserInterface
{
    
}

- (void)loadPhotos
{
    _albumsDic = [NSMutableDictionary new];
    _photos = [NSMutableArray new];
    _albums = [NSMutableArray new];
    _library = _userInfo[@"ALAssetsLibrary"];
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group != nil) {
            ALAssetsFilter *filter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter:filter];
            
            NSMutableArray *albumPhotos = [NSMutableArray new];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    [_photos addObject:result];
                    [albumPhotos addObject:result];
                }
            }];
            [_albums addObject:group];
            _albumsDic[[group valueForProperty:ALAssetsGroupPropertyName]] = albumPhotos;
        } else {
            [_userInterface showPhotoAlbums:_albums];
//            //展示所有照片
//            [_router pushPhotoInPhoneController:@{@"photos" : _photos,
//                                                  @"maxPhotoCount" : _userInfo[@"maxPhotoCount"]}];
        }
    } failureBlock:^(NSError *error) {
        //[AppHelper showAlertWithTitle:nil message:[error localizedDescription]];
    }];
}

- (void)showPhotoInAlbums:(NSString *)albumName
{
    NSArray *photos = _albumsDic[albumName];
    [_router pushPhotoInPhoneController:@{@"albumName" : albumName,
                                          @"photos" : photos,
                                          @"maxPhotoCount" : _userInfo[@"maxPhotoCount"]}];
}

- (void)cancleChoose
{
    [_router dismissController:@{@"photos" : @[]}];
}

@end
