//
//  AttachmentsController.h
//  e企
//
//  Created by 陆广庆 on 15/1/17.
//  Copyright (c) 2015年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttachmentsControllerDelegate <NSObject>

- (void)didFileSelected:(NSString *)filePath;

@end

@interface AttachmentsController : UITableViewController

@property (nonatomic) id<AttachmentsControllerDelegate> delegate;

@end
