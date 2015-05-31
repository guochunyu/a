//
//  ServiceNumberMsgDetailViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-3-24.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NotesData;

@interface ServiceNumberMsgDetailViewController : UIViewController

@property(nonatomic,strong) NotesData *notesData;

@property(nonatomic,strong)NSXMLElement *x_element;///<

@property(nonatomic,strong)NSDictionary *serviceNewsDict;///<serviceNews字典

@end
