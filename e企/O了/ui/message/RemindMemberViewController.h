//
//  RemindMemberViewController.h
//  O了
//
//  Created by 化召鹏 on 14-8-25.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import "UIMyViewController.h"
#import "RemindMemberCell.h"

typedef void(^RemindMember)(BOOL isCancel,NSString *name);

@interface RemindMemberViewController : UIMyViewController<UITableViewDataSource,UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>{
    UITableView *_remindTable;
    UISearchBar *_searchBar;
    UISearchDisplayController *_searchDisplayVC;
}
@property(nonatomic,copy)RemindMember remindMember;///<block回调
@end
