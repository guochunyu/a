//
//  PhotoInPhoneHandler.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class PhotoInPhoneRouter;
#import "PhotoInPhoneProtocol.h"

@interface PhotoInPhoneHandler : NSObject <PhotoInPhoneLogicInterface, PhotoInPhoneInteractorOutput>

@property (nonatomic) PhotoInPhoneRouter *router;
@property (nonatomic) id<PhotoInPhoneInteractorInput> interactor;
@property (nonatomic) UIViewController<PhotoInPhoneUserInterface> *userInterface;

@property (nonatomic) NSDictionary *userInfo;

@end
