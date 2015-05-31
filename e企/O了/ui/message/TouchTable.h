//
//  TouchTable.h
//  HuaXinShop
//
//  Created by roya-hua on 13-8-2.
//  Copyright (c) 2013年 huaxin. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol TouchTableDelegate <NSObject>

@optional

- (void)tableView:(UITableView *)tableView
     touchesBegan:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
 touchesCancelled:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesEnded:(NSSet *)touches
        withEvent:(UIEvent *)event;

- (void)tableView:(UITableView *)tableView
     touchesMoved:(NSSet *)touches
        withEvent:(UIEvent *)event;


@end
@interface TouchTable : UITableView
{
    id touchDelegate;
}
@property (nonatomic,assign) id<TouchTableDelegate> touchDelegate;
@end
