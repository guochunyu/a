//
//  PhotoInPhoneController.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "PhotoInPhoneProtocol.h"

@interface PhotoInPhoneController : UICollectionViewController <PhotoInPhoneUserInterface>

@property (nonatomic) id<PhotoInPhoneLogicInterface> handler;

@end
