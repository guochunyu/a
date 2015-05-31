//
//  PhotoInPhoneHandler.m
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

#import "PhotoInPhoneHandler.h"
#import "PhotoInPhoneRouter.h"
@import AssetsLibrary;

@interface PhotoInPhoneHandler ()

@property (nonatomic) NSArray *photos;

@end

@implementation PhotoInPhoneHandler

- (void)initDataForUserInterface
{
    if (_userInfo != nil) {
        if (_userInfo[@"photos"] != nil) {
            _photos = _userInfo[@"photos"];
            [_userInterface setValue:_userInfo[@"photos"] forKey:@"photos"];
        }
        if (_userInfo[@"albumName"] != nil) {
            [_userInterface setValue:_userInfo[@"albumName"] forKey:@"albumName"];
        }
        if (_userInfo[@"maxPhotoCount"] != nil) {
            [_userInterface setValue:_userInfo[@"maxPhotoCount"] forKey:@"maxPhotoCount"];
        }
    }
}

- (void)didPhotoSelected:(NSArray *)photos
{
    [_router dismissViewController:@{@"photos" : photos}];
}

@end
