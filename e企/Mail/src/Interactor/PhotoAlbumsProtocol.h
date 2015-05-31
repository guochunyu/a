//
//  PhotoAlbumsProtocol.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//



@protocol PhotoAlbumsUserInterface <NSObject>

- (void)showPhotoAlbums:(NSArray *)photoAlbums;

@end

@protocol PhotoAlbumsLogicInterface <NSObject>

- (void)initDataForUserInterface;
- (void)cancleChoose;
- (void)loadPhotos;
- (void)showPhotoInAlbums:(NSString *)albumName;

@end

@protocol PhotoAlbumsInteractorInput <NSObject>

@end

@protocol PhotoAlbumsInteractorOutput <NSObject>

@end
