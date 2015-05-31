//
//  PhotoAlbumsHandler.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class PhotoAlbumsRouter;
#import "PhotoAlbumsProtocol.h"


@interface PhotoAlbumsHandler : NSObject <PhotoAlbumsLogicInterface, PhotoAlbumsInteractorOutput>

@property (nonatomic) PhotoAlbumsRouter *router;
@property (nonatomic) id<PhotoAlbumsInteractorInput> interactor;
@property (nonatomic) UIViewController<PhotoAlbumsUserInterface> *userInterface;

@property (nonatomic) NSDictionary *userInfo;


@end