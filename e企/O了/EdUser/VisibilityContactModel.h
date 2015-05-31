//
//  VisibilityContactModel.h
//  e企
//
//  Created by royaMAC on 14/11/18.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VisibilityContactModel : NSObject
@property (nonatomic,assign)int personID;///<<个人id
@property (nonatomic,strong)NSString * uid;
@property (nonatomic,strong)NSString * positionId;///<<个人所在职位ID
@property (nonatomic,strong)NSString * mine_orgId;///<<我所在部门的ID
@property (nonatomic,strong)NSString * visibilityList_orgId;///<<需要可见性设置的部门ID
@property (nonatomic,assign)int   type ;
@property (nonatomic,strong)NSString * parentId;///<<可见性设置的部门的父ID
@property (nonatomic,assign)BOOL visibilityList_leadView;///<<对领导可见性
@property (nonatomic,assign)BOOL visibilityList_staffView;///<<对员工可见性

- (id)init;
@end
