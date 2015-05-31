//
//  CustomViewServiceListView.h
//  O了
//
//  Created by roya-7 on 14-9-18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotesData.h"
#import "TouchTable.h"

typedef void(^TabelDidClick)(UITableView *tableView,NSIndexPath *indexPath,NSXMLElement *element);

typedef void (^MenuClick)(NSString *menuName);

static NSString *const myTransmit=@"myTransmit";
static NSString *const myDelete=@"myDelete";
static NSString *const myMore=@"myMore";

@interface CustomViewServiceListView : UIView<UITableViewDataSource,UITableViewDelegate,TouchTableDelegate>{
    TouchTable *_myTable;
}

@property(nonatomic,strong)NotesData *nd;
@property(nonatomic,copy)TabelDidClick tabelDidClick;///<表格点击
@property(nonatomic,copy)MenuClick menuClick;///<菜单点击
@end
