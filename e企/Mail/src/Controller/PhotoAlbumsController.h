//
//  PhotoAlbumsController.h
//  AmericanBaby
//
//  Created by 陆广庆 on 14-8-11.
//  Copyright (c) 2014年 陆广庆. All rights reserved.
//

@import Foundation;
@import UIKit;
#import "PhotoAlbumsProtocol.h"

@interface PhotoAlbumsController : UITableViewController <PhotoAlbumsUserInterface>

@property (nonatomic) id<PhotoAlbumsLogicInterface> handler;

@end
