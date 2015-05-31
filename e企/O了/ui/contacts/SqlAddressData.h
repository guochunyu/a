//
//  SqlAddressData.h
//  e企
//
//  Created by  on 14-11-4.
//  Copyright (c) 2014年 QYB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmployeeModel.h"
#import "ContactsModel.h"
#import "VisibilityContactModel.h"
#import "FMDatabase.h"

@interface SqlAddressData : NSObject

+(void)releaseDataQueue;

//创建个人信息表
+(void)createPersoninfoTable;
+(void)addPersonInfo:(NSArray*)dataArray;
+(BOOL)createTable1:(NSString *)table columns:(NSArray *)columns indexes:(NSArray *)indexes whithDb:(FMDatabase *)db;
//创建部门关系列表
+(void)createBranchTable;
+(void)addContactsInfo:(NSArray*)dataArray;
//+(NSArray*)selectContactTbale;
//+(NSArray*)selectOrgTable;
+(BOOL)queryOrgIsNull;
//删除表
+(void)deleTableData;
//查询有父节点的部门表
+(NSArray*)selectBranchTable;
//修改部门表的字段
+(void)updateBranchTable;
//更新个人信息
+(void)upDateAvatarimgurl:(NSString *)imgurl WithUserPhone:(NSString *)phone;
//表中是否存在某字段
+(BOOL)isExitSomeColumn;
//获得自己所在的部门id
+(NSArray*)selectOrgByUserName;
//获得自己所在部门的同事联系信息
+(NSArray*)selectMinefriend;
//获得自己同事所在部门名字
+(NSArray*)selectOrgName;
//获得部门ID
+(NSString*)getOrganiztionsBySection:(NSString*)name;
//获得这个部门的人
+(NSArray*)getOrgPeopleByOrgId:(NSString*)orgId;
///增加contact表中的字段
+(void)adapterContactSomeColumn;

+(NSArray*)getNewOrgPeopleByOrgId:(NSString*)orgId;
//在联系人表中获得所有的部门Id
+(NSArray*)getAllOrgId;
//在部门表中获得所有的部门名字
+(NSArray*)getAllorgName;
//获得联系人表中所有的名字
+(NSArray*)getAllContactName;
//将汉字名字转化拼音
+(NSString*)getFirstZimu:(NSString*)name;
+(NSString*)changeNameChinese:(NSString*)zhongwenName;
//添加联系人表中的属性
//+(void)addContactOfAttribute;
//添加联系人表的属性之后，添加这些属性的值
+(void)updateContactNewAttribute;
//在联系人表插入部门名字
+(void)updateContactOfOrgName;

+(void)updateCommenContactImage:(NSString *)imgurl WithUserPhone:(NSString *)phone;
//获得搜索条件的人
+ (NSArray *)getContactWithRequirement:(NSString *)requirement;
+ (NSArray *)getNewContactWithRequirement:(NSString *)requirement;

//查找顶级节点
//+(NSString*)getRootName;
//查找根节点
+(NSDictionary*)getRootOrganiztions;
//获得第一层
+(NSArray*)getOrgName;
//根据区名查看有没有子结点
+(NSInteger)getChildByName:(NSString*)name;
//根据区名找到该部门下的联系人
+(NSArray*)getContactByOrgName:(NSString*)name;
//根据孩子节点找到这个部门的下属部门
+(NSString*)getOrgTag;
//得到自部门
+(NSArray*)getOfOrgChildByOrgTag;
//获得这个部门下所有的人
+(NSArray*)getOfContactPeople:(NSString*)org_tag;
/**
 *  根据imacct获取对象信息
 *
 *  @param
 *
 *  @return
 */
+(EmployeeModel *)queryMemberInfoWithImacct:(NSString *)imacct;
+(EmployeeModel *)queryMemberInfoWithEmail:(NSString *)email;
+(EmployeeModel *)queryMemberInfoWithPhone:(NSString *)phone;
//创建常用联系人表
+(void)createCommenContact;
//更新常用联系表的信息
+(void)updateCommenContact:(EmployeeModel*)model OrgName:(NSString*)orgName;
//查询常用联系人表
+(NSArray*)selectCommanContact:(NSString*)userUid;
+(NSArray*)selectCommanContactByPhone:(NSString*)phone;

/**
 *  查询contact表中是否有数据,YES为有
 *
 *  @return
 */
+(BOOL)queryContactIsNull;
//创建可见性表
+(void)createVisibilityContactTable;
//查看可见性表是否为空
+(BOOL)queryVisibilityContact;
//添加可见性联系人表的信息
+(void)deleteVisilityInfo:(NSString*)see_orgId;
+(void)addVisibilityInfo:(VisibilityContactModel*)model;
+(NSArray*)selectvisibility;
+(void)deleteVisilityContact;
//创建领导人可见性表
+(void)deleteLeadertable;
+(void)createVisibilityLeaderTable;
+(void)addLeaderVisibilityLeader:(BOOL)leader_all leaderPhone:(BOOL)leader_phone;
+(NSDictionary*)selecLeaderVisibility;

+(void)createNewVisibilityTable;
+(void)addNewVisibility:(VisibilityContactModel*)model;
//根据需要屏蔽的部门找到设置的可见性数据
+(NSArray*)selectNewVisibilityTable;

+(NSArray*)selectNewVisibilityTable:(NSString*)see_orgId;
//查询新可见性表的所有数据
+(NSArray*)checkOutAll;
+(NSArray*)selectAllOrgID;
//查询这个人是不是常用联系人
//+(BOOL)selectMemberBy
@end
