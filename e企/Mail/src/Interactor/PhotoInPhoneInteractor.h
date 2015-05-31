//
//  PhotoInPhoneInteractor.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
@class CoreDataStore;
@class UserDefaultsStore;
#import "PhotoInPhoneProtocol.h"

@interface PhotoInPhoneInteractor : NSObject <PhotoInPhoneInteractorInput>

@property (nonatomic) CoreDataStore *store;
@property (nonatomic) UserDefaultsStore *defaultsStore;
@property (nonatomic) id<PhotoInPhoneInteractorOutput> handler;

@end
