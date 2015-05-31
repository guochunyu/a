//
//  GroupAddress.h
//  O了
//
//  Created by macmini on 14-01-22.
//  Copyright (c) 2014 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellContact.h"
#import "MBProgressHUD.h"

@interface GroupAddress : UITableViewController<CellContactDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *_HUD;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (assign, nonatomic)NSInteger grou_ID;
@property (strong, nonatomic)NSArray *arr_enterprise;
@property (strong, nonatomic)NSArray *arr_menber;

@property (nonatomic, strong)NSMutableArray *search_array_grou;
@property (nonatomic, strong)NSMutableArray *search_array_menber;
@end
