//
//  PhotoInPhoneProtocol.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@protocol PhotoInPhoneUserInterface <NSObject>

@end

@protocol PhotoInPhoneLogicInterface <NSObject>

- (void)initDataForUserInterface;
- (void)didPhotoSelected:(NSArray *)photos;

@end

@protocol PhotoInPhoneInteractorInput <NSObject>

@end

@protocol PhotoInPhoneInteractorOutput <NSObject>

@end
