//
//  NotifyViewController.h
//  e企
//
//  Created by 许学 on 14/11/19.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "TimePickerView.h"
@interface NotifyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,timepickdelegate>

@property (nonatomic, strong) UITableView *table;
//@property (nonatomic, strong) UISwitch *switch_Rev;
@property (nonatomic, strong) UISwitch *switch_Noty;
@property(nonatomic,strong)UINavigationController*nc;


@end
