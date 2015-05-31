//
//  ServiceNumberDetailViewController.h
//  O了
//
//  Created by 卢鹏达 on 14-3-5.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicaccountModel.h"

typedef void(^RemovePublic)();

@interface ServiceNumberDetailViewController : UITableViewController<MBProgressHUDDelegate>{
    MBProgressHUD *_HUD;
}

@property(nonatomic,strong)PublicaccountModel *publicaccontModel;///<公众号对象
@property(nonatomic,assign)BOOL isCompelService;//是否是强制服务号

@property(nonatomic,assign)BOOL isFromMessage;//是否是从聊天页面进来
@property(nonatomic,assign)int subscribestatusType;///<是否关注,0为关注


@property(nonatomic,copy)RemovePublic removePublic;
@end
